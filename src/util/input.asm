;
; This version of input.asm has been modified by Eievui to fit VuiBui naming
; conventions.
;
; Controller reading for Game Boy and Super Game Boy
;
; Copyright 2018 Damian Yerrick
;
; This software is provided 'as-is', without any express or implied
; warranty.  In no event will the authors be held liable for any damages
; arising from the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.
;
include "hardware.inc"

DAS_DELAY equ 15
DAS_SPEED equ 3

P1F_NONE     equ $30
P1F_BUTTONS  equ $10
P1F_DPAD     equ $20

section "hram_pads", hram
hCurrentKeys:: db
hNewKeys:: db

section "ram_pads", wram0
wDasKeys:: ds 1
wDasTimer:: ds 1

section "rom_pads", rom0

; Controller reading ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This controller reading routine is optimized for size.
; It stores currently pressed keys in hCurrentKeys (1=pressed) and
; keys newly pressed since last read in hNewKeys, with the same
; nibble ordering as the Game Boy Advance.
; 76543210
; |||||||+- A
; ||||||+-- B
; |||||+--- Select
; ||||+---- Start
; |||+----- Right
; ||+------ Left
; |+------- Up
; +-------- Down

UpdateInput::
	; Poll half the controller
	ld a,P1F_BUTTONS
	call .onenibble
	ld b,a  ; B7-4 = 1; B3-0 = unpressed buttons

	; Poll the other half
	ld a,P1F_DPAD
	call .onenibble
	swap a   ; A3-0 = unpressed directions; A7-4 = 1
	xor b    ; A = pressed buttons + directions
	ld b,a   ; B = pressed buttons + directions

	; And release the controller
	ld a,P1F_NONE
	ldh [rP1],a

	; Combine with previous hCurrentKeys to make hNewKeys
	ldh a,[hCurrentKeys]
	xor b    ; A = keys that changed state
	and b    ; A = keys that changed to pressed
	ldh [hNewKeys],a
	ld a,b
	ldh [hCurrentKeys],a
	ret

.onenibble:
	ldh [rP1],a     ; switch the key matrix
	call .knownret  ; burn 10 cycles calling a known ret
	; ignore value while waiting for the key matrix to settle
	ldh a,[rP1] ; no-optimize Useless loads.
	ldh a,[rP1] ; no-optimize Useless loads.
	ldh a,[rP1]     ; this read counts
	or $F0   ; A7-4 = 1; A3-0 = unpressed keys
.knownret:
	ret
