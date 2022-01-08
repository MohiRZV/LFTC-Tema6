bits 32

global start

extern exit, printf, scanf

import exit msvcrt.dll
import printf msvcrt.dll
import scanf msvcrt.dll

segment data use32 class=data
format_i db '%d', 0
format_o db '%d', 10, 13, 0
h dd 0
base dd 0
areatr dd 0
temp0 dd 1
temp1 dd 1
temp2 dd 1

segment code use32 class=code
start:
push dword h
push dword format_i
call [scanf]
add esp, 4*2

push dword base
push dword format_i
call [scanf]
add esp, 4*2

mov eax, 3
mov [temp0], eax

mov eax, [temp0]
mul dword [h]
mov [temp1], eax

mov eax, [temp1]
mul dword [base]
mov [temp2], eax

mov eax, [temp2]
mov [areatr], eax

push dword [areatr]
push dword format_o
call [printf]
add esp, 4*2

push dword 0
call [exit]
