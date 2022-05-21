INCLUDE "defines.inc"
INCLUDE "draw_menu.inc"
INCLUDE "hardware.inc"
INCLUDE "menu.inc"
INCLUDE "structs.inc"

DEF MAIN_CURSOR_X EQU 5
DEF MAIN_CURSOR_Y EQU 4

SECTION "Pause Menu", ROMX
xPauseMenu::
	db BANK(@)
	dw xPauseMenuInit
	; Used Buttons
	db PADF_A | PADF_B | PADF_UP | PADF_DOWN
	; Auto-repeat
	db 1
	; Button functions
	; A, B, Sel, Start, Right, Left, Up, Down
	dw xPauseMenuAPress, null, null, null, null, null, null, null
	db 0 ; Last selected item
	; Allow wrapping
	db 0
	; Default selected item
	db 0
	; Number of items in the menu
	db 6
	; Redraw
	dw xPauseMenuRedraw
	; Private Items Pointer
	dw null
	; Close Function
	dw xPauseMenuClose

; Place this first to define certain constants.
xDrawPauseMenu:
	load_tiles .frame, 9, vFrame
	DEF idof_vBlankTile EQU idof_vFrame + 4
	dregion vTopMenu, 0, 0, 9, 14
	set_frame vTopMenu, idof_vFrame
	print_text 3, 1, "Return"
	print_text 3, 3, "Items"
	print_text 3, 5, "Party"
	print_text 3, 7, "Save", 3
	print_text 3, 9, "Options"
	print_text 3, 11, "Escape!", 5
	end_dmg
	set_region 0, 0, SCRN_VX_B, SCRN_VY_B, 0
	end_cgb

	; Custom vallocs must happen after the menu has been defined.
	; Unused tiles reserved for submenus to draw text on.
	dtile vScratchRegion
	dtile_section $8000
	dtile vCursor, 4

.frame INCBIN "res/ui/hud_frame.2bpp"

xPauseMenuInit:
	; Set scroll
	xor a, a
	ldh [hShadowSCX], a
	ldh [hShadowSCY], a
	ld [wScrollInterp.x], a
	ld [wScrollInterp.y], a

	; Clear background.
	ld d, idof_vBlankTile
	ld bc, $400
	ld hl, $9800
	call VRAMSet

	ld hl, xDrawPauseMenu
	call DrawMenu
	call LoadTheme
	; Load palette
	ldh a, [hSystem]
	and a, a
	jr z, .skipCGB
	call LoadPalettes
.skipCGB

	; Set palettes
	ld a, 20
	ld [wFadeSteps], a
	ld a, -4
	ld [wFadeDelta], a

	; Initialize cursors
	ld hl, wPauseMenuCursor
	ld a, MAIN_CURSOR_X
	ld [hli], a
	ld a, MAIN_CURSOR_Y
	ld [hli], a
	ld a, idof_vCursor
	ld [hli], a
	ld [hl], OAMF_PAL1
	; This menu is expected to maintain submenu's cursors so that they show
	; while scrolling.
	ld hl, wSubMenuCursor
	ld a, -16
	ld [hli], a
	ld [hli], a
	ld a, idof_vCursor
	ld [hli], a
	ld [hl], OAMF_PAL1
	ret

xPauseMenuRedraw:
	ld hl, sp+2
	ld a, [hli]
	ld h, [hl]
	ld l, a
	dec hl
	dec hl ; Size
	dec hl ; Selection
	ld a, [hl]
	add a, a ; a * 2
	add a, a ; a * 4
	add a, a ; a * 8
	add a, a ; a * 16
	add a, MAIN_CURSOR_Y
	ld b, a
	ld c, MAIN_CURSOR_X
	ld hl, wPauseMenuCursor
	call DrawCursor
	ld hl, wSubMenuCursor
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	call DrawCursor

	jp xScrollInterp

xPauseMenuAPress:
	ld hl, sp+2
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl
	ld a, [hl]
	and a, a
	ret z
	dec a
	jr z, .inventory
	dec a
	jr z, .party
	dec a
	ret z
.options
	xor a, a
	ld [wMenuAction], a
	ld de, xOptionsMenu
	ld b, BANK(xOptionsMenu)
	jp AddMenu

.party
	xor a, a
	ld [wMenuAction], a
	ld de, xPartyMenu
	ld b, BANK(xPartyMenu)
	jp AddMenu

.inventory
	xor a, a
	ld [wMenuAction], a
	ld de, xInventoryMenu
	ld b, BANK(xInventoryMenu)
	jp AddMenu

xPauseMenuClose:
	; Set palettes
	ld a, %11111111
	ld [wBGPaletteMask], a
	ld a, %11111111
	ld [wOBJPaletteMask], a
	ld a, 20
	ld [wFadeSteps], a
	ld a, $80
	ld [wFadeAmount], a
	ld a, 4
	ld [wFadeDelta], a
	ld hl, wFadeCallback
	ld a, LOW(SwitchToDungeonState)
	ld [hli], a
	ld [hl], HIGH(SwitchToDungeonState)
	ret

xInventoryMenu::
	db BANK(@)
	dw xInventoryMenuInit
	; Used Buttons
	db PADF_A | PADF_B | PADF_UP | PADF_DOWN
	; Auto-repeat
	db 1
	; Button functions
	; A, B, Sel, Start, Right, Left, Up, Down
	dw null, null, null, null, null, null, null, null
	db 0 ; Last selected item
	; Allow wrapping
	db 0
	; Default selected item
	db 0
	; Number of items in the menu
	db 8
	; Redraw
	dw xInventoryMenuRedraw
	; Private Items Pointer
	dw null
	; Close Function
	dw xInventoryMenuClose

xInventoryMenuInit:
	ld a, SCRN_VX - SCRN_X
	ld [wScrollInterp.x], a
	xor a, a
	ld [wScrollInterp.y], a
	ld hl, wSubMenuCursor
	ld a, SCRN_VX - SCRN_X + 64
	ld [hli], a
	ld a, 4
	ld [hli], a
	ld a, idof_vCursor
	ld [hli], a
	ld [hl], OAMF_PAL1
	ret

xInventoryMenuRedraw:
	ld hl, wSubMenuCursor
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	call DrawCursor
	ld hl, wPauseMenuCursor
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	call DrawCursor
	jp xScrollInterp

xInventoryMenuClose:
	xor a, a
	ld [wScrollInterp.x], a
	ld [wScrollInterp.y], a
	ret

xPartyMenu::
	db BANK(@)
	dw xPartyMenuInit
	; Used Buttons
	db PADF_A | PADF_B | PADF_UP | PADF_DOWN
	; Auto-repeat
	db 1
	; Button functions
	; A, B, Sel, Start, Right, Left, Up, Down
	dw null, null, null, null, null, null, null, null
	db 0 ; Last selected item
	; Allow wrapping
	db 0
	; Default selected item
	db 0
	; Number of items in the menu
	db 4
	; Redraw
	dw xPartyMenuRedraw
	; Private Items Pointer
	dw null
	; Close Function
	dw xPartyMenuClose

xPartyMenuInit:
	ld a, SCRN_VX - SCRN_X
	ld [wScrollInterp.x], a
	xor a, a
	ld [wScrollInterp.y], a
	ld hl, wSubMenuCursor
	ld a, SCRN_VX - SCRN_X + 4
	ld [hli], a
	ld a, 4
	ld [hli], a
	ld a, idof_vCursor
	ld [hli], a
	ld [hl], OAMF_PAL1
	ret

xPartyMenuRedraw:
	ld hl, wSubMenuCursor
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	call DrawCursor
	ld hl, wPauseMenuCursor
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	call DrawCursor
	jp xScrollInterp

xPartyMenuClose:
	xor a, a
	ld [wScrollInterp.x], a
	ld [wScrollInterp.y], a
	ret

DEF OPTIONS_CURSOR_X EQU SCRN_VX - SCRN_X + 69
DEF OPTIONS_CURSOR_Y EQU 20

xOptionsMenu::
	db BANK(@)
	dw xOptionsMenuInit
	; Used Buttons
	db PADF_A | PADF_B | PADF_UP | PADF_DOWN
	; Auto-repeat
	db 1
	; Button functions
	; A, B, Sel, Start, Right, Left, Up, Down
	dw xOptionsMenuAPress, null, null, null, null, null, null, null
	db 0 ; Last selected item
	; Allow wrapping
	db 0
	; Default selected item
	db 0
	; Number of items in the menu
	db 3
	; Redraw
	dw xOptionsMenuRedraw
	; Private Items Pointer
	dw null
	; Close Function
	dw xOptionsMenuClose

xDrawOptionsMenu::
	dtile_section vScratchRegion
	dregion vOptionsMenu, 20, 0, 12, 13
	set_frame vOptionsMenu, idof_vFrame
	print_text 24, 1, "Options"
	print_text 23, 3, "Theme:"
	print_text 23, 6, "Color:"
	print_text 23, 9, "Window style:"
	end_menu
	dtile vSelectionsText

xOptionsMenuInit:
	ld a, SCRN_VX - SCRN_X
	ld [wScrollInterp.x], a
	xor a, a
	ld [wScrollInterp.y], a
	ld hl, wSubMenuCursor
	ld a, OPTIONS_CURSOR_X
	ld [hli], a
	ld a, OPTIONS_CURSOR_Y
	ld [hli], a
	ld a, idof_vCursor
	ld [hli], a
	ld [hl], OAMF_PAL1
	ld hl, xDrawOptionsMenu
	call DrawMenu
	call xOptionsMenuDrawSelections
	ret

xOptionsMenuRedraw:
	ld hl, sp+2
	ld a, [hli]
	ld h, [hl]
	ld l, a
	dec hl
	dec hl ; Size
	dec hl ; Selection
	ld a, [hl]
	add a, a ; a * 2
	add a, a ; a * 4
	add a, a ; a * 8
	ld b, a
	add a, a ; a * 16
	add a, b
	add a, OPTIONS_CURSOR_Y
	ld b, a
	ld c, OPTIONS_CURSOR_X
	ld hl, wSubMenuCursor
	call DrawCursor
	ld hl, wPauseMenuCursor
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	call DrawCursor
	jp xScrollInterp

	ld hl, wSubMenuCursor
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	call DrawCursor
	ld hl, wPauseMenuCursor
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	call DrawCursor
	jp xScrollInterp

xOptionsMenuAPress:
	ld hl, sp+2
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl
	ld a, [hl]
	and a, a
	jr z, .changeTheme
	dec a
	jr z, .changeColor
	jr .toggleSticky

.toggleSticky
	xor a, a
	ld [wMenuAction], a
	ld hl, wWindowSticky
	ld a, 1
	xor a, [hl]
	ld [hl], a
	jr xOptionsMenuDrawSelections

.changeColor
	ld hl, wActiveMenuPalette
	ldh a, [hCurrentBank]
	call ChangeColorROM0
PUSHS
SECTION "Change Color ROM0", ROM0
ChangeColorROM0:
	push af
	ld a, [hli]
	rst SwapBank
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [wActiveMenuPalette], a
	ld a, [hli]
	ld [wActiveMenuPalette + 1], a
	ld a, [hl]
	ld [wActiveMenuPalette + 2], a
	jp BankReturn
POPS
	xor a, a
	ld [wMenuAction], a

	; Reload the palette.
	ldh a, [hSystem]
	and a, a
	jr z, xOptionsMenuDrawSelections
	call LoadPalettes
	ld a, $81
	ld [wFadeAmount], a
	ld a, 1
	ld [wFadeSteps], a
	ld a, -1
	ld [wFadeDelta], a
	jr xOptionsMenuDrawSelections

.changeTheme
	ld hl, wActiveMenuTheme
	ldh a, [hCurrentBank]
	call ChangeThemeROM0
PUSHS
SECTION "Change Theme ROM0", ROM0
ChangeThemeROM0:
	push af
	ld a, [hli]
	rst SwapBank
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [wActiveMenuTheme], a
	ld a, [hli]
	ld [wActiveMenuTheme + 1], a
	ld a, [hl]
	ld [wActiveMenuTheme + 2], a
	jp BankReturn
POPS
	xor a, a
	ld [wMenuAction], a
	call LoadTheme
	jr xOptionsMenuDrawSelections

xOptionsMenuDrawSelections:
	; Clear the tiles of text where we will draw.
	ld hl, $9800 + 23 + 4 * 32
	lb bc, idof_vBlankTile, 8
	call VRAMSetSmall
	ld hl, $9800 + 23 + 7 * 32
	lb bc, idof_vBlankTile, 8
	call VRAMSetSmall
	ld hl, $9800 + 23 + 10 * 32
	lb bc, idof_vBlankTile, 8
	call VRAMSetSmall

	; Print palette name.
	ld hl, wActiveMenuPalette
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	add a, MenuPal_Name + 2
	ld l, a
	adc a, h
	sub a, l
	ld h, a
	ld a, 1
	call PrintVWFText

	; Text is already mostly initialized by the menu renderer.
	xor a, a
	ld [wTextLetterDelay], a
	ld a, idof_vSelectionsText
	ld [wTextCurTile], a
	ld [wWrapTileID], a
	ld a, $FF
	ld [wLastTextTile], a
	lb de, 8, 1
	ld hl, $9800 + 23 + 7 * 32
	call TextDefineBox

	call PrintVWFChar
	call DrawVWFChars

	; Print theme name.
	ld hl, wActiveMenuTheme
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	add a, MenuTheme_Name + 2
	ld l, a
	adc a, h
	sub a, l
	ld h, a
	ld a, 1
	call PrintVWFText

	; Text is already mostly initialized by the menu renderer.
	lb de, 8, 1
	ld hl, $9800 + 23 + 4 * 32
	call TextDefineBox

	call PrintVWFChar
	call DrawVWFChars

	ld a, [wWindowSticky]
	ld hl, .loose
	and a, a
	jr z, :+
	ld hl, .sticky
:
	ld a, 1
	ld b, BANK(@)
	call PrintVWFText

	; Text is already mostly initialized by the menu renderer.
	lb de, 8, 1
	ld hl, $9800 + 23 + 10 * 32
	call TextDefineBox

	call PrintVWFChar
	call DrawVWFChars

	ret

.loose db "Loose", 0
.sticky db "Sticky", 0

xOptionsMenuClose:
	xor a, a
	ld [wScrollInterp.x], a
	ld [wScrollInterp.y], a
	ret

; Scroll towards a target position.
xScrollInterp:
	ld hl, hShadowSCX
	ld a, [wScrollInterp.x]
	cp a, [hl]
	jr z, .finishedX
	jr c, .moveLeft
.moveRight
	ld a, [hl]
	add a, 8
	ld [hl], a
	jr .finishedX
.moveLeft
	ld a, [hl]
	sub a, 8
	ld [hl], a
.finishedX
	inc l

	ld a, [wScrollInterp.y]
	cp a, [hl]
	ret z
	jr c, .moveDown
.moveUp
	ld a, [hl]
	add a, 8
	ld [hl], a
	ret
.moveDown
	ld a, [hl]
	sub a, 8
	ld [hl], a
	ret

SECTION "Pause Menu Load Palettes", ROM0
LoadPalettes:
	ldh a, [hCurrentBank]
	push af
	ld hl, wActiveMenuPalette
	ld a, [hli]
	rst SwapBank
	ld a, [hli]
	ld h, [hl]
	ld l, a
	; Skip over next pointer.
	ASSERT MenuPal_Colors == 3
	inc hl
	inc hl
	inc hl
	push hl
	; The first member of a theme is a palette.
	ld de, wBGPaletteBuffer
	ld c, 12
	call MemCopySmall
	pop hl
	inc hl
	inc hl
	inc hl
	ld de, wOBJPaletteBuffer
	ld c, 12
	call MemCopySmall

	ld a, %10000000
	ld [wBGPaletteMask], a
	ld a, %10000000
	ld [wOBJPaletteMask], a
	jp BankReturn

SECTION "Pause Menu Load Theme", ROM0
LoadTheme:
	ldh a, [hCurrentBank]
	push af
	; Load theme
	ld hl, wActiveMenuTheme
	ld a, [hli]
	rst SwapBank
	ld a, [hli]
	ld h, [hl]
	ld l, a
	; Skip next pointer.
	ASSERT MenuTheme_Cursor == 3
	inc hl
	inc hl
	inc hl
	; First is the cursor. We can seek over it by loading!
	ld de, vCursor
	ld c, 16 * 4
	call VRAMCopySmall
	; After this is the emblem tiles
	; First read the length
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	; THen deref the tiles
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	ld de, $9000
	call VRAMCopy
	pop hl
	inc hl

	ld a, [hli]
	ld h, [hl]
	ld l, a
	; And finally, the tilemap.
	lb bc, 11, 10
	ld de, $9909
	call MapRegion
	jp BankReturn

SECTION "Scroll interp vars", WRAM0
wScrollInterp:
.x db
.y db

SECTION "Pause menu cursor", WRAM0
	dstruct Cursor, wPauseMenuCursor
	dstruct Cursor, wSubMenuCursor
