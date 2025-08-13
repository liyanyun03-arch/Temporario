@echo off

rem Caminho para a pasta build
set build_dir=build

rem Deleta a pasta build, se existir
if exist %build_dir% (
    rmdir /s /q %build_dir%
    echo Pasta '%build_dir%' excluida com sucesso.
)

rem Deleta os arquivos, se existirem
del /q text.gba test.ini 2>nul
if errorlevel 1 (
    echo Arquivos 'text.gba' e 'test.ini' nao encontrados ou erro ao excluir.
) else (
    echo Arquivos 'text.gba' e 'test.ini' excluidos com sucesso.
)

rem Executa os scripts Python
python scripts/make.py
python scripts/pgeinidump.py

pause