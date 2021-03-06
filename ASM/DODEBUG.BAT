echo off
REM Batch file to assemble, link, and debug a assembler program
if exist %1.asm goto ASM
echo Usage :    doasm "filename" 
echo filename must be WITHOUT extension. 
Echo Extension MUST be ASM 
goto END
:ASM
  tasm /zi %1.asm
  echo �
  if errorlevel = 1 goto ASM_ERROR
  goto link
:LINK
  tlink /v %1.obj
  echo �
  if errorlevel = 1 goto LINKER_ERROR
  echo
  td %1.exe �
  goto end
:ASM_ERROR
  Echo Error when assembling 
  goto end
:LINKER_ERROR
  Echo Error when linking 
  goto end
:END