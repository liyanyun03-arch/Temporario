#include "defines.h"
#include "battle_structs.h" 
#include "static_references.h"

u16 apply_statboost(u16 stat, u8 boost);
u8 get_bank_side(u8 bank);
bool is_bank_present(u32 bank);
u8 has_ability_effect(u8 bank, u8 mold_breaker);
bool check_ability(u8 bank, u8 ability);
void atk0C_datahpupdate(void);
u8 is_of_type(u8 bank, u8 type);
u8 get_item_effect(u8 bank, u8 check_negating_effects);
void update_rtc(void);
void prep_string(u16 strID, u8 bank);
s8 get_priority(u16 move, u8 bank);
void bs_push_current(void* now);
u8 check_field_for_ability(u8 ability, u8 side_to_ignore, u8 mold);
u16 get_airborne_state(u8 bank, u8 mode, u8 check_levitate);
u8 get_move_table_target(u16 move,u8 atk_bank);

//Rage Powder
bool is_immune_to_powder(u8 bank)
{
	if (is_of_type(bank, TYPE_GRASS) || check_ability(bank, ABILITY_OVERCOAT) ||
		get_item_effect(bank_attacker, 1) == ITEM_EFFECT_SAFETYGOOGLES)
		return 1;
	return 0;
}

bool photon_geyser_special(u16 move)
{
	if (move == MOVE_PHOTON_GEYSER)
	{
		u16 attack_stat = apply_statboost(battle_participants[bank_attacker].atk,
				battle_participants[bank_attacker].atk_buff);
		u16 spatk_stat = apply_statboost(battle_participants[bank_attacker].sp_atk,
				battle_participants[bank_attacker].sp_atk_buff);
		if (attack_stat > spatk_stat)
			return 0; //switch to a physical move
	}
	return 1; // remain a special move
}

//Pollen Puff, 
void atkF9_pollen_puff(void)
{
	if ((bank_target ^ bank_attacker) == 2)
	{ //Targeting Friend
		dynamic_base_power = 0;
		if (battle_participants[bank_target].current_hp >= battle_participants[bank_target].max_hp)
			battlescripts_curr_instruction = (void*) 0x082D9EFB;
		else if (new_battlestruct->bank_affecting[bank_target].heal_block)
			battlescripts_curr_instruction = BS_HEALBLOCK_PREVENTS;
		else
		{
			damage_loc = (battle_participants[bank_target].max_hp / 2) * (-1);
			battlescripts_curr_instruction = (void*) 0x082D9EE1;
		}
	}
	else
		dynamic_base_power = move_table[current_move].base_power;
	if (dynamic_base_power)
		battlescripts_curr_instruction = (void*) 0x082D8A30;
}

void atkFA_blowifnotdamp(void)
{
	if(move_table[current_move].arg1 == MOVEARG2_MIND_BLOWN)
	{
		for (u8 i = 0; i < 4; i++)
		{
			if (is_bank_present(i) && battle_participants[i].ability_id == ABILITY_DAMP && has_ability_effect(i, 1))
			{
				bank_target = i;
				gLastUsedAbility = ABILITY_DAMP;
				record_usage_of_ability(i, ABILITY_DAMP);
				move_outcome.failed = 1;
				move_outcome.explosion_stop = 1;
				battlescripts_curr_instruction = (void*) (0x082DB560);
				return;
			}
		}
	}
	damage_loc = (battle_participants[bank_attacker].max_hp + 1) >>1;
	if (check_ability(bank_attacker, ABILITY_MAGIC_GUARD) || new_battlestruct->bank_affecting[bank_attacker].head_blown)
		damage_loc = 0;
	else 
		new_battlestruct->bank_affecting[bank_attacker].head_blow_hpupsdate = 1;
	//set head_blown flag
	new_battlestruct->bank_affecting[bank_attacker].head_blown = 1;
	battlescripts_curr_instruction++; //Needs Revision
}

void atkFC_set_snow(void) 
{
    battlescripts_curr_instruction++;
    if (battle_weather.flags.air_current || battle_weather.flags.harsh_sun || battle_weather.flags.heavy_rain) 
	{
        battlescripts_curr_instruction = (void*) 0x082D9F1C; //but it failed script
    } else if (HAIL_WEATHER) 
	{
        move_outcome.missed = 1;
        battle_communication_struct.multistring_chooser = 2;
    } else 
	{
        battle_weather.int_bw = weather_hail;
        battle_communication_struct.multistring_chooser = 5;

        if (get_item_effect(bank_attacker, 1) == ITEM_EFFECT_ICYROCK)
            battle_effects_duration.weather_dur = 8;
        else
            battle_effects_duration.weather_dur = 5;
        // @ Verifica se o movimento foi Chilly Reception
        if (current_move == MOVE_CHILLY_RECEPTION) 
		{
            battle_weather.flags.hail = 1; // Ativa o flag existente
            battle_weather.flags.chilly_reception_hail = 1; // Ativa o novo flag
        }
    }
}

void atkFB_chloroblastEffect(void)
{
    // @ Verifica se o move atual tem o argumento relacionado ao Chloroblast
    if (move_table[current_move].arg1 == MOVEARG2_CHLOROBLAST)
    {
        // @ Calcula o dano auto-infligido ao usuário como 50% do HP máximo arredondado para baixo
        damage_loc = (battle_participants[bank_attacker].max_hp + 1) >> 1;

        // @ Verifica se o atacante possui Magic Guard para evitar dano auto-infligido
        if (check_ability(bank_attacker, ABILITY_MAGIC_GUARD))
        {
            // @ Se Magic Guard está ativo, anula o auto-dano
            damage_loc = 0;
        }
        else
        {
            // @ Define que o movimento causará auto-dano ao final
            new_battlestruct->bank_affecting[bank_attacker].chloroblast_recoil = 1;
        }

        // @ Marca que o usuário do movimento já ativou o Chloroblast para evitar múltiplas ativações
        new_battlestruct->bank_affecting[bank_attacker].chloroblast_activated = 1;

        // @ Avança o script de batalha para o próximo comando
        battlescripts_curr_instruction++;
    }
    else
    {
        // @ Caso o movimento não seja Chloroblast, falha no processamento
        move_outcome.failed = 1;
        battlescripts_curr_instruction++;
    }
}

//Spotlight
void set_spotlight(void)
{
	u8 target_side = get_bank_side(bank_target);
	side_timers[target_side].followme_timer = 1;
	side_timers[target_side].followme_target = bank_target;
}

//Speed Swap
void various_speed_swap(void)
{
	u16 speed_temp = battle_participants[bank_attacker].spd;
	battle_participants[bank_attacker].spd = battle_participants[bank_target].spd;
	battle_participants[bank_target].spd = speed_temp;
}

//Spit Up
void jumpifnostockpile(void)
{
	if (new_battlestruct->bank_affecting[bank_attacker].stockpile_counter) //Not Jump
		battlescripts_curr_instruction += 4;
	else //Jump
		battlescripts_curr_instruction = (void*) read_word(battlescripts_curr_instruction);
}

//Calculate Recoil Damage
void calc_recoil_dmg2(void)
{
	if ((check_ability(bank_attacker, ABILITY_ROCK_HEAD) || check_ability(bank_attacker, ABILITY_MAGIC_GUARD)) && current_move != MOVE_STRUGGLE) 
	{
		record_usage_of_ability(bank_attacker, battle_participants[bank_attacker].ability_id);
		damage_loc = 0;
		battle_communication_struct.multistring_chooser = 0;
	}
	else 
	{
		u16 recoil_dmg;
		//formula is dmg = HP dealt / arg2 or MaxHP / arg2 if value is negative
		s8 arg = move_table[current_move].arg2;
		if (arg < 0)
			recoil_dmg = battle_participants[bank_attacker].max_hp / (arg * -1);
		else
			recoil_dmg = hp_dealt / arg;
		damage_loc = ATLEAST_ONE(recoil_dmg);
		battle_communication_struct.multistring_chooser = 1;
	}
	battlescripts_curr_instruction++;
}

bool check_ability_with_mold(u8 bank, u8 ability) 
{
	return (has_ability_effect(bank, 1) && battle_participants[bank].ability_id == ability);
}

//Throat Chop
void set_throatchop(void)
{
	void* failjump = (void*) read_word(battlescripts_curr_instruction /*+ 1*/);
	if (new_battlestruct->bank_affecting[bank_target].throatchop_timer)
		battlescripts_curr_instruction = failjump;
	else
	{
		new_battlestruct->bank_affecting[bank_target].throatchop_timer = 2;
		battlescripts_curr_instruction += 4;//5;
	}
}

void check_weather_trio(void) {
	if (battle_weather.flags.heavy_rain && !check_field_for_ability(ABILITY_PRIMORDIAL_SEA, 3, 0)) 
	{
		battle_weather.flags.downpour = 0;
		battle_weather.flags.rain = 0;
		battle_weather.flags.heavy_rain = 0;
	}
	if (battle_weather.flags.harsh_sun && !check_field_for_ability(ABILITY_DESOLATE_LAND, 3, 0)) 
	{
		battle_weather.flags.sun = 0;
		battle_weather.flags.harsh_sun = 0;
	}
	if (battle_weather.flags.air_current && !check_field_for_ability(ABILITY_DELTA_STREAM, 3, 0)) 
	{
		battle_weather.flags.air_current = 0;
	}
}

//Beak Blast
void set_beak_charge(void)
{
	for (u8 i = 0; i < 4; i++)
	{
		if (menu_choice_pbs[i] == 0 && chosen_move_by_banks[i] == MOVE_BEAK_BLAST
			&& !(disable_structs[i].truant_counter & 1) && !(protect_structs[i].flag0_onlystruggle))
		{
			new_battlestruct->bank_affecting[i].beak_blast_charge = 1;
		}
		else
			new_battlestruct->bank_affecting[i].beak_blast_charge = 0;
	}
}

//Shell Trap
void set_shell_charge(void)
{
	for (u8 i = 0; i < 4; i++)
	{
		if (menu_choice_pbs[i] == 0 && chosen_move_by_banks[i] == MOVE_SHELL_TRAP &&
			!battle_participants[i].status.flags.sleep
			&& !(disable_structs[i].truant_counter & 1) && !(protect_structs[i].flag0_onlystruggle))
		{
			new_battlestruct->bank_affecting[i].shell_trap_charge = 1;
		}
		else
			new_battlestruct->bank_affecting[i].shell_trap_charge = 0;
	}
}

//Effects of Clanging Scales and Clangorous Soulblaze
bool clanging_scales_stat(void)
{	
	if ((MOVE_WORKED || new_battlestruct->bank_affecting[bank_attacker].move_worked_thisturn) //move has worked at least once this turn
		&& (!battle_flags.double_battle || !is_bank_present(bank_target ^ 2) || bank_target > (bank_target ^ 2))) //if it is the last target
	{
		if (current_move == MOVE_CLANGING_SCALES)
		{
			bs_push_current(BS_CHANGE_ATK_STAT);
			battle_scripting.stat_changer = move_table[current_move].arg1;
		}
		return 1;
	}
	return 0;
}


//Mind Blown
void jumpifuserheadblown(void)
{
	if (!new_battlestruct->bank_affecting[bank_attacker].head_blown) //Not Jump
		battlescripts_curr_instruction += 4;
	else //Jump
		battlescripts_curr_instruction = (void*) read_word(battlescripts_curr_instruction);
}

#define NUM_BATTLE_STATS (6 + 2) // includes Accuracy and Evasion
#define DEFAULT_STAT_STAGE 6
// Haze
void normalisebuffs_aly_only(void) 
{
    for (u8 i = 0; i < gBattlersCount; i++)
    {
        battle_participants[i].hp_buff = 0;
        battle_participants[i].atk_buff = 0;
        battle_participants[i].def_buff = 0;
        battle_participants[i].spd_buff = 0;
        battle_participants[i].sp_atk_buff = 0;
        battle_participants[i].sp_def_buff = 0;
        battle_participants[i].acc_buff = 0;
        battle_participants[i].evasion_buff = 0;
    }
    battlescripts_curr_instruction++;
}
