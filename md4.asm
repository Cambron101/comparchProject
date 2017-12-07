.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
; message
message BYTE 55 DUP('A') 

; padded message
messagepadded BYTE 55 DUP('A'), 80h, 0b8h, 01h, 6 DUP(0)

;64 bit representation of length of message
b qword ?

; initialize MD buffers A,B,C,D
T dword 01234567h  ; A
U dword 89ABCDEFh  ; B
V dword 0FECDBA98h ; C, These letters are used because we cant use the letter C
W dword 76543210h  ; D

TT dword ? ; AA
UU dword ? ; BB
VV dword ? ; CC
WW dword ? ; DD

; for the F,G, and H functions
X dword ?
Y dword ?
Z dword ?

N dword LENGTHOF messagepadded

array dword 16 DUP(?)
.code
main proc
; process each 16 dword blocks
; For i = 0 to N/16-1 do where N is the length of the padded message and is a multiple of 16 
mov ecx, N
div ecx, 16
sub ecx, 1

L1:

	push ecx
	; Copy block i into X.
	mov ecx 16
	L2:

	loop L2
	pop ecx
	; Save A as AA, B as BB, C as CC, and D as DD.
	mov TT, T
	mov UU, U
	mov VV, V
	mov WW, W

	; Round 1. Let [abcd k s] denote the operation a = (a + F(b,c,d) + X[k]) <<< s.
	mov ebx, T
	mov X, U
	mov Y, V
	mov Z, W
	call F
	add eax, ebx
	add eax, array[0]
	shl eax, 3

	; Round 2. Let [abcd k s] denote the operation a = (a + G(b,c,d) + X[k] + 5A827999) <<< s.

	; Round 3. Let [abcd k s] denote the operation a = (a + H(b,c,d) + X[k] + 6ED9EBA1) <<< s.

	; increment each of the four registers by the value it had before this block was started
	add T, TT
	add U, UU
	add V, VV
	add W, WW
loop L1

; message output. The message digest produced as output is A, B, C, D. That is, we
; begin with the low-order byte of A, and end with the high-order byte of D.


invoke ExitProcess,0
main endp
end main

; procedures
; these funtions take in three 32-bit words and output one 32-bit word
; the functions perform the comparison on each bit of the words
; F(X,Y,Z) = XY v not(X) Z
proc F
mov eax, X
and eax, Y
mov ebx, not X
and ebx, Z
or eax, ebx
ret eax

; G(X,Y,Z) = XY v XZ v YZ
proc G
mov eax, X
and eax, Y
mov ebx, X
and ebx, Z
mov edx, Y
and edx, Z
or ebx, edx
or eax, ebx
ret eax

; H(X,Y,Z) = X xor Y xor Z
proc H
mov eax, X
xor eax, Y
xor eax, Z
ret eax

proc FF

ret

proc GG

ret

proc HH

ret