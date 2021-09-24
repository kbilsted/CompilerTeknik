@echo off
if exist %1.asm goto ASM
echo Usage :    asm "filename" 
echo filename must be WITHOUT extension. 
Echo Extension MUST be ASM 
goto END
:ASM
  tasm /ml /mv30 /m8 /la /p /t /w2 /z /zi %1.asm
  echo ÿ
  if errorlevel = 1 goto ASM_ERROR
  goto link
:LINK
  tlink /l /s /v %1.obj
  echo ÿ
  if errorlevel = 1 goto LINKER_ERROR
  goto end
:ASM_ERROR
  Echo Error when assembling 
  goto end
:LINKER_ERROR
  Echo Error when linking 
  goto end
:END
