#!/usr/bin/env python3

import shutil
import sys
import os

############
# Options go here.
############

ROM_NAME = "BPEE0.gba"  # the name of your rom
OFFSET_TO_PUT = 0x1483000
SEARCH_FREE_SPACE = False  # Set to True if you want the script to search for free space; Set to False if you don't want to search for free space as you for example update the engine
CLEAR_ALL_OLDTABLES = True  # Set to True if you want to clear all old tables
CLEAR_OLD_MOVETABLE = True  # Set to True if you want to clear the old move table
CLEAR_OLD_LEARNSETTABLE = True  # Set to True if you want to clear the old learnsets table
CLEAR_OLD_TYPEEFFECTIVENESSTABLE = True  # Set to True if you want to clear the old type effectiveness table
CLEAR_OLD_MOVESDESCRIPTIONTABLE = True  # Set to True if you want to clear the old move description table

#############
# Options end here.
#############

###############
# Functions start here.
###############

def clean_previous_build():
    """Remove the 'build' folder, 'test.gba', and 'test.ini' if they exist."""
    if os.path.exists("build"):
        shutil.rmtree("build")
        print("Pasta 'build' removida.")
    if os.path.exists("test.gba"):
        os.remove("test.gba")
        print("Antigo 'test.gba' deletado.")
    if os.path.exists("test.ini"):
        os.remove("test.ini")
        print("Antigo 'test.ini' deletado.")

def align_x100(offset):
    mod_x100 = offset % 0x100
    if mod_x100 != 0x0:  # not aligned properly
        offset += (0x100 - mod_x100)
    return offset

def find_offset_to_put(rom, needed_bytes, start_loc):
    offset = start_loc
    rom.seek(0, 2)
    max_pos = rom.tell()
    found_bytes = 0
    while found_bytes < needed_bytes:
        if offset + found_bytes >= max_pos:
            print("End of file reached. Not enough free space.")
            return 0
        found_bytes += 1
        rom.seek(offset + found_bytes)
        if rom.read(1) != b'\xFF':
            offset = align_x100(offset + found_bytes)
            found_bytes = 0
    return offset

def file_change_line(file_path, line_to_change, replacement):
    with open(file_path, 'r+') as file:
        copy = file.readlines()
        if line_to_change <= len(copy):
            copy[line_to_change - 1] = replacement
        file.seek(0)
        file.writelines(copy)
        file.truncate()

def edit_linker(offset):
    file_change_line("linker.ld", 4, f"\t\trom     : ORIGIN = (0x08000000 + {hex(offset)}), LENGTH = 32M\n")

def edit_insert(offset):
    file_change_line("./scripts/insert.py", 11, f"OFFSET_TO_PUT = {hex(offset)}\n")

def build_code():
    os.system("python scripts/build.py")

def insert_code():
    os.system("python scripts/insert.py")

def clear_from_to(rom, from_, to_):
    rom.seek(from_)
    for _ in range(to_ - from_):
        rom.write(b'\xFF')

##############
# Functions end here.
##############

# Clean up previous build files
clean_previous_build()

# Proceed with the build process
with open(ROM_NAME, 'rb+') as rom:
    offset = OFFSET_TO_PUT
    if SEARCH_FREE_SPACE:
        offset = find_offset_to_put(rom, 0x50000, align_x100(offset))
    edit_linker(offset)
    edit_insert(offset)
    build_code()
    insert_code()
    rom.close()

with open("test.gba", 'rb+') as new_rom:
    if CLEAR_OLD_MOVETABLE or CLEAR_ALL_OLDTABLES:
        clear_from_to(new_rom, 0x31C898, 0x31D93C)
    if CLEAR_OLD_LEARNSETTABLE or CLEAR_ALL_OLDTABLES:
        clear_from_to(new_rom, 0x3230DC, 0x32531C)  # clear actual old learnsets
        clear_from_to(new_rom, 0x32937C, 0x3299EC)  # clear pointers to moves
    if CLEAR_OLD_TYPEEFFECTIVENESSTABLE or CLEAR_ALL_OLDTABLES:
        clear_from_to(new_rom, 0x31ACE8, 0x31AE38)
    if CLEAR_OLD_MOVESDESCRIPTIONTABLE or CLEAR_ALL_OLDTABLES:
        clear_from_to(new_rom, 0x61C524, 0x61CAAC)
    new_rom.close()
