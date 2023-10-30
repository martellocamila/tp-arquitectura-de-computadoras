# MPLAB IDE generated this makefile for use with GNU make.
# Project: prueba.mcp
# Date: Mon Oct 23 16:28:15 2023

AS = MPASMWIN.exe
CC = mcc18.exe
LD = mplink.exe
AR = mplib.exe
RM = rm

prueba.cof : Untitled.o
	$(LD) /p16F628A "Untitled.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"prueba.cof" /M"prueba.map" /W

Untitled.o : Untitled.asm P16F628A.INC
	$(AS) /q /p16F628A "Untitled.asm" /l"Untitled.lst" /e"Untitled.err" /o"Untitled.o" /d__DEBUG=1

clean : 
	$(RM) "Untitled.o" "Untitled.err" "Untitled.lst" "prueba.cof" "prueba.hex"

