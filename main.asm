BLACK = 0
WHITE = 1
DARKBLUE = 6
GREEN = 5
GREY = 15
RASTERREGISTER = $d012 
SID = $d400
VIC2 = $d000
VICMEMCTRL = $d018
SCREEN = $400
COLORRAM = $d800
LogLeftChar = 34
LogRightChar = 36
JOY1 = $dc00
    *=$801
    !byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
    lda #3
    sta $d021
    jsr clearScreen
    jsr copyCharset
    jsr setCharSetLoc
    jsr resetSIDRegisters
    ldx #123
    lda #34
    sta SCREEN,x
    lda #7
    sta COLORRAM,x
    lda #35
    inx
    sta SCREEN,x
    lda #9
    sta COLORRAM,x 
    inx 
    lda #35
    sta SCREEN,x
    lda #9
    sta COLORRAM,x 
    inx
    lda #36
    sta SCREEN,x 
    lda #7
    sta COLORRAM,x 
    jsr colorLogArea
    jsr setWater
    jsr drawLogs
    jsr prepareRasterInterrupt
   
mainloop
    lda JOY1
    cmp #127
    beq mainloop
    sta inputData
    lda #0
    sta waitingForInput
    jmp mainloop
moveFrog ; what I want is to move the frog once every click of the joystick so register the command, set a flag to wait for the movement to occur set that flag to zero when mv was applied and
; then read the next input 
    lda waitingForInput
    cmp #0
    bne endMov
    inc waitingForInput
    lda #8
    bit inputData
    bne right
    inc frogPosition
right
    lda #4
    bit inputData
    bne up
    dec frogPosition
up
    lda #2
    bit inputData
    bne down
    inc frogPosition+1
down
    lda #1
    bit inputData
    bne endMov
    dec frogPosition+1
endMov
    rts
    
    
    
clearStreets
    ldx #40
clrStreetloop
    lda #32
    sta SCREEN+40*14-1,x
    sta SCREEN+40*16-1,x
    sta SCREEN+40*18-1,x 
    dex
    bne clrStreetloop
    rts
    
moveCars
    ldx  #6
moveCarLoop
    sec
    lda carsFirstLine-1,x 
    sbc #1 
    cmp #255
    bne next
    lda #39
next
    sta carsFirstLine-1,x
    dex
    bne moveCarLoop
    rts
    
    
drawCars 
    ldy #2
carLoop
    ;first Line isc
    lda carsFirstLine-1,y  
    tax
    lda #33
    sta SCREEN+40*14,x
    lda carsSecondLine-1,y  
    tax 
    lda #33
    sta SCREEN+40*16,x
    lda carsThirdLine-1,y
    tax 
    lda #33
    sta SCREEN+40*18,x
    dey
    bne carLoop
    rts
    

drawStreets
    lda #37
    ldx #40
streetLoop
    sta SCREEN+40*15-1,x 
    sta SCREEN+40*17-1,x
    sta SCREEN+40*19-1,x
    dex
    bne streetLoop
    rts
    

    
colorLogArea 
    ldx #200
    lda #9
colorLoop
    sta COLORRAM,x 
    dex 
    bne colorLoop
    sta COLORRAM,x
    rts
    

moveLogs 
    ldx #0
mvLoop
    clc
    lda Logs+1,x 
    adc #1
    cmp #40
    bne strValue
    lda #0
strValue
    sta Logs+1,x 
    inx
    inx 
    cpx #16
    bne mvLoop
    rts

setWater
    ldx #201
    lda #42
    clc
    adc currentAnimationState
setWaterLoop
    sta SCREEN-1,x 
    dex
    bne setWaterLoop
    lda currentAnimationState
    clc
    adc #1
    and #1
    sta currentAnimationState
    rts
    
calculatePosition
    lda #0
    sta $fb 
    sta $fb+1
    lda frogPosition+1
    sta $fb+1
    clc
    rol $fb+1
    rol $fb
    rol $fb+1
    rol $fb
    rol $fb+1
    rol $fb
    rol $fb+1
    rol $fb
    rol $fb+1
    rol $fb
    lda frogPosition+1
    sta $fe
    rol $fe
    rol $fd
    rol $fe
    rol $fd
    rol $fe
    rol $fd
    lda $fb+1
    adc $fe
    sta $fc
    lda $fb
    adc $fd 
    sta $fb
    lda frogPosition
    clc
    adc $fc
    sta $fc
    lda $fb
    adc #$4
    sta $fb
    ldx $fb
    ldy $fc
    stx $fc
    sty $fb
    lda #24
    ldx #0
    sta ($fb,x)
    
    rts 
    
    ; calculate y
    
   

!zone drawing    

setCharacter ; pass in x and y position in the x and y register
    tya 
    asl 
    asl
    asl
    asl
    asl 
    pha 
    tya 
    asl
    asl
    asl
    sta $fb
    pla 
    clc 
    adc $fb 
    stx $fb
    adc $fb
    tax
    lda #34
    sta SCREEN,x 
    lda #36
    sta SCREEN+1,x
    rts

drawLogs 
    ldx #0
drawLoop
    txa
    pha 
        lda Logs,x
        tay
        lda Logs+1,x
        tax
        jsr setCharacter 
    pla 
    tax
    inx
    inx
    cpx #16
    bne drawLoop
    rts
    ; set position
    
    
!zone charImport

copyCharset
    ldx #255
.loop
    lda CHARS+0,x
    sta $2000+0,x
    lda CHARS+256,x
    sta $2000+256,x
    lda CHARS+512,x
    sta $2000+512,x
    lda CHARS+768,x
    sta $2000+768,x
    lda CHARS+1024,x
    sta $2000+1024,x
    lda CHARS+1280,x
    sta $2000+1280,x
    lda CHARS+1536,x
    sta $2000+1536,x
    lda CHARS+1792,x
    sta $2000+1792,x
    dex
    bne .loop
    rts

setCharSetLoc
    lda VICMEMCTRL
    and #240 ; masking out lower nibble
    ora #8
    sta VICMEMCTRL
    rts
    
!zone graphics    
clearScreen 
    ldx #250
    lda #32
.loop
    sta SCREEN,x
    sta SCREEN+250,x
    sta SCREEN+500,x
    sta SCREEN+750,x 
    dex
    bne .loop
    sta SCREEN,x
    sta SCREEN,x
    sta SCREEN+500,x
    sta SCREEN+750,x 
    rts
!zone sound
resetSIDRegisters
    ldx #24
    lda #0
.loop
    sta SID,x 
    dex 
    bne .loop
    rts
; sets up the system for the custom raster interrupt routine 
prepareRasterInterrupt 
    sei 
    lda #$7f
    sta $dc0d  ;disable timer interrupts which can be generated by the two CIA chips
    sta $dd0d  ;the kernal uses such an interrupt to flash the cursor and scan the keyboard, so we better
           ;stop it.

    lda $dc0d  ;by reading this two registers we negate any pending CIA irqs.
    lda $dd0d 
    lda #>rasterIRQ
    sta $0315
    lda #<rasterIRQ
    sta $0314
    lda $d011
    and #%01111111
    sta $d011
    lda #0
    sta $d012 
    lda #1 
    sta $d01a 
    cli
    rts 
SCREENSTART = 0
RIVERIRQ = 30
BANKIRQ = 100
STREETIRQ  = 190
ENDOFSTREET = 120
VBLANK = 250 
 
rasterIRQ 
    sei
    lda $d019
    sta $d019 
    bmi rasterChecked
    lda $dc0d
    cli
    jmp $ea31
rasterChecked 
    lda RASTERREGISTER
    cmp #SCREENSTART
    bne halfway
    lda #BLACK
    sta $d021 
    lda #120
    clc
    sta RASTERREGISTER
    jmp cleanUp
halfway  
    cmp #120
    bne cleanUp
    lda #GREEN
    sta $d021 
    lda #SCREENSTART 
    sta RASTERREGISTER
cleanUp
    pla                                ;Y vom Stack
    tay
    pla                                ;X vom Stack
    tax
    pla                                ;Akku vom Stack
    cli
    rti 
irqPosition !byte 123
Logs 
    !byte $00,13,$00,20,$00,24,$01,12,$01,32,$01,34,$03,12,$03,54
currentAnimationState 
    !byte $00
frameCounter
    !byte 00
frogPosition
    !byte 20,20
carsFirstLine
    !byte 12,20
carsSecondLine
    !byte 6,15
carsThirdLine
    !byte 15,30
waitingForInput
    !byte 1
inputData 
    !byte 0
CHARS
!MEDIA "char.chr",char
!byte $3c,$66,$6e,$6e,$60,$62,$3c,$00
!byte $18,$3c,$66,$7e,$66,$66,$66,$00
!byte $7c,$66,$66,$7c,$66,$66,$7c,$00
!byte $3c,$66,$60,$60,$60,$66,$3c,$00
!byte $78,$6c,$66,$66,$66,$6c,$78,$00
!byte $7e,$60,$60,$78,$60,$60,$7e,$00
!byte $7e,$60,$60,$78,$60,$60,$60,$00
!byte $3c,$66,$60,$6e,$66,$66,$3c,$00
!byte $66,$66,$66,$7e,$66,$66,$66,$00
!byte $3c,$18,$18,$18,$18,$18,$3c,$00
!byte $1e,$0c,$0c,$0c,$0c,$6c,$38,$00
!byte $66,$6c,$78,$70,$78,$6c,$66,$00
!byte $60,$60,$60,$60,$60,$60,$7e,$00
!byte $63,$77,$7f,$6b,$63,$63,$63,$00
!byte $66,$76,$7e,$7e,$6e,$66,$66,$00
!byte $3c,$66,$66,$66,$66,$66,$3c,$00
!byte $7c,$66,$66,$7c,$60,$60,$60,$00
!byte $3c,$66,$66,$66,$66,$3c,$0e,$00
!byte $7c,$66,$66,$7c,$78,$6c,$66,$00
!byte $3c,$66,$60,$3c,$06,$66,$3c,$00
!byte $7e,$18,$18,$18,$18,$18,$18,$00
!byte $66,$66,$66,$66,$66,$66,$3c,$00
!byte $22,$3c,$7e,$ff,$ff,$7e,$3c,$22
!byte $44,$3c,$7e,$ff,$ff,$7e,$3c,$44
!byte $5a,$5a,$3c,$3c,$3c,$3c,$42,$42
!byte $18,$5a,$7e,$3c,$3c,$7e,$42,$00
!byte $7e,$06,$0c,$18,$30,$60,$7e,$00
!byte $3c,$30,$30,$30,$30,$30,$3c,$00
!byte $0c,$12,$30,$7c,$30,$62,$fc,$00
!byte $3c,$0c,$0c,$0c,$0c,$0c,$3c,$00
!byte $00,$18,$3c,$7e,$18,$18,$18,$18
!byte $00,$10,$30,$7f,$7f,$30,$10,$00
!byte $00,$00,$00,$00,$00,$00,$00,$00
!byte $63,$ff,$9f,$9f,$9f,$9f,$ff,$63
!byte $00,$7f,$e6,$ec,$c9,$db,$7f,$00
!byte $00,$ff,$c9,$db,$93,$b7,$ff,$00
!byte $00,$fe,$67,$37,$93,$db,$fe,$00
!byte $00,$00,$00,$3c,$3c,$00,$00,$00
!byte $66,$00,$00,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$00,$00,$66
!byte $e3,$ff,$9f,$9f,$9f,$9f,$ff,$e3
!byte $89,$ff,$ff,$ff,$ff,$ff,$ff,$89
!byte $00,$12,$24,$24,$24,$44,$48,$00
!byte $90,$48,$48,$48,$44,$24,$00,$00
!byte $00,$00,$00,$00,$00,$18,$18,$30
!byte $00,$00,$00,$7e,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$18,$18,$00
!byte $00,$03,$06,$0c,$18,$30,$60,$00
!byte $3c,$66,$6e,$76,$66,$66,$3c,$00
!byte $18,$18,$38,$18,$18,$18,$7e,$00
!byte $3c,$66,$06,$0c,$30,$60,$7e,$00
!byte $3c,$66,$06,$1c,$06,$66,$3c,$00
!byte $06,$0e,$1e,$66,$7f,$06,$06,$00
!byte $7e,$60,$7c,$06,$06,$66,$3c,$00
!byte $3c,$66,$60,$7c,$66,$66,$3c,$00
!byte $7e,$66,$0c,$18,$18,$18,$18,$00
!byte $3c,$66,$66,$3c,$66,$66,$3c,$00
!byte $3c,$66,$66,$3e,$06,$66,$3c,$00
!byte $00,$00,$18,$00,$00,$18,$00,$00
!byte $00,$00,$18,$00,$00,$18,$18,$30
!byte $0e,$18,$30,$60,$30,$18,$0e,$00
!byte $00,$00,$7e,$00,$7e,$00,$00,$00
!byte $70,$18,$0c,$06,$0c,$18,$70,$00
!byte $3c,$66,$06,$0c,$18,$00,$18,$00
!byte $00,$00,$00,$ff,$ff,$00,$00,$00
!byte $08,$1c,$3e,$7f,$7f,$1c,$3e,$00
!byte $18,$18,$18,$18,$18,$18,$18,$18
!byte $00,$00,$00,$ff,$ff,$00,$00,$00
!byte $00,$00,$ff,$ff,$00,$00,$00,$00
!byte $00,$ff,$ff,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$ff,$ff,$00,$00
!byte $30,$30,$30,$30,$30,$30,$30,$30
!byte $0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c
!byte $00,$00,$00,$e0,$f0,$38,$18,$18
!byte $18,$18,$1c,$0f,$07,$00,$00,$00
!byte $18,$18,$38,$f0,$e0,$00,$00,$00
!byte $c0,$c0,$c0,$c0,$c0,$c0,$ff,$ff
!byte $c0,$e0,$70,$38,$1c,$0e,$07,$03
!byte $03,$07,$0e,$1c,$38,$70,$e0,$c0
!byte $ff,$ff,$c0,$c0,$c0,$c0,$c0,$c0
!byte $ff,$ff,$03,$03,$03,$03,$03,$03
!byte $00,$3c,$7e,$7e,$7e,$7e,$3c,$00
!byte $00,$00,$00,$00,$00,$ff,$ff,$00
!byte $36,$7f,$7f,$7f,$3e,$1c,$08,$00
!byte $60,$60,$60,$60,$60,$60,$60,$60
!byte $00,$00,$00,$07,$0f,$1c,$18,$18
!byte $c3,$e7,$7e,$3c,$3c,$7e,$e7,$c3
!byte $00,$3c,$7e,$66,$66,$7e,$3c,$00
!byte $18,$18,$66,$66,$18,$18,$3c,$00
!byte $06,$06,$06,$06,$06,$06,$06,$06
!byte $08,$1c,$3e,$7f,$3e,$1c,$08,$00
!byte $18,$18,$18,$ff,$ff,$18,$18,$18
!byte $c0,$c0,$30,$30,$c0,$c0,$30,$30
!byte $18,$18,$18,$18,$18,$18,$18,$18
!byte $00,$00,$03,$3e,$76,$36,$36,$00
!byte $ff,$7f,$3f,$1f,$0f,$07,$03,$01
!byte $00,$00,$00,$00,$00,$00,$00,$00
!byte $f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0
!byte $00,$00,$00,$00,$ff,$ff,$ff,$ff
!byte $ff,$00,$00,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$00,$00,$ff
!byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
!byte $cc,$cc,$33,$33,$cc,$cc,$33,$33
!byte $03,$03,$03,$03,$03,$03,$03,$03
!byte $00,$00,$00,$00,$cc,$cc,$33,$33
!byte $ff,$fe,$fc,$f8,$f0,$e0,$c0,$80
!byte $03,$03,$03,$03,$03,$03,$03,$03
!byte $18,$18,$18,$1f,$1f,$18,$18,$18
!byte $00,$00,$00,$00,$0f,$0f,$0f,$0f
!byte $18,$18,$18,$1f,$1f,$00,$00,$00
!byte $00,$00,$00,$f8,$f8,$18,$18,$18
!byte $00,$00,$00,$00,$00,$00,$ff,$ff
!byte $00,$00,$00,$1f,$1f,$18,$18,$18
!byte $18,$18,$18,$ff,$ff,$00,$00,$00
!byte $00,$00,$00,$ff,$ff,$18,$18,$18
!byte $18,$18,$18,$f8,$f8,$18,$18,$18
!byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
!byte $e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0
!byte $07,$07,$07,$07,$07,$07,$07,$07
!byte $ff,$ff,$00,$00,$00,$00,$00,$00
!byte $ff,$ff,$ff,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$ff,$ff,$ff
!byte $03,$03,$03,$03,$03,$03,$ff,$ff
!byte $00,$00,$00,$00,$f0,$f0,$f0,$f0
!byte $0f,$0f,$0f,$0f,$00,$00,$00,$00
!byte $18,$18,$18,$f8,$f8,$00,$00,$00
!byte $f0,$f0,$f0,$f0,$00,$00,$00,$00
!byte $f0,$f0,$f0,$f0,$0f,$0f,$0f,$0f
!byte $c3,$99,$91,$91,$9f,$99,$c3,$ff
!byte $e7,$c3,$99,$81,$99,$99,$99,$ff
!byte $83,$99,$99,$83,$99,$99,$83,$ff
!byte $c3,$99,$9f,$9f,$9f,$99,$c3,$ff
!byte $87,$93,$99,$99,$99,$93,$87,$ff
!byte $81,$9f,$9f,$87,$9f,$9f,$81,$ff
!byte $81,$9f,$9f,$87,$9f,$9f,$9f,$ff
!byte $c3,$99,$9f,$91,$99,$99,$c3,$ff
!byte $99,$99,$99,$81,$99,$99,$99,$ff
!byte $c3,$e7,$e7,$e7,$e7,$e7,$c3,$ff
!byte $e1,$f3,$f3,$f3,$f3,$93,$c7,$ff
!byte $99,$93,$87,$8f,$87,$93,$99,$ff
!byte $9f,$9f,$9f,$9f,$9f,$9f,$81,$ff
!byte $9c,$88,$80,$94,$9c,$9c,$9c,$ff
!byte $99,$89,$81,$81,$91,$99,$99,$ff
!byte $c3,$99,$99,$99,$99,$99,$c3,$ff
!byte $83,$99,$99,$83,$9f,$9f,$9f,$ff
!byte $c3,$99,$99,$99,$99,$c3,$f1,$ff
!byte $83,$99,$99,$83,$87,$93,$99,$ff
!byte $c3,$99,$9f,$c3,$f9,$99,$c3,$ff
!byte $81,$e7,$e7,$e7,$e7,$e7,$e7,$ff
!byte $99,$99,$99,$99,$99,$99,$c3,$ff
!byte $99,$99,$99,$99,$99,$c3,$e7,$ff
!byte $9c,$9c,$9c,$94,$80,$88,$9c,$ff
!byte $99,$99,$c3,$e7,$c3,$99,$99,$ff
!byte $99,$99,$99,$c3,$e7,$e7,$e7,$ff
!byte $81,$f9,$f3,$e7,$cf,$9f,$81,$ff
!byte $c3,$cf,$cf,$cf,$cf,$cf,$c3,$ff
!byte $f3,$ed,$cf,$83,$cf,$9d,$03,$ff
!byte $c3,$f3,$f3,$f3,$f3,$f3,$c3,$ff
!byte $ff,$e7,$c3,$81,$e7,$e7,$e7,$e7
!byte $ff,$ef,$cf,$80,$80,$cf,$ef,$ff
!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte $e7,$e7,$e7,$e7,$ff,$ff,$e7,$ff
!byte $99,$99,$99,$ff,$ff,$ff,$ff,$ff
!byte $99,$99,$00,$99,$00,$99,$99,$ff
!byte $e7,$c1,$9f,$c3,$f9,$83,$e7,$ff
!byte $9d,$99,$f3,$e7,$cf,$99,$b9,$ff
!byte $c3,$99,$c3,$c7,$98,$99,$c0,$ff
!byte $f9,$f3,$e7,$ff,$ff,$ff,$ff,$ff
!byte $f3,$e7,$cf,$cf,$cf,$e7,$f3,$ff
!byte $cf,$e7,$f3,$f3,$f3,$e7,$cf,$ff
!byte $ff,$99,$c3,$00,$c3,$99,$ff,$ff
!byte $ff,$e7,$e7,$81,$e7,$e7,$ff,$ff
!byte $ff,$ff,$ff,$ff,$ff,$e7,$e7,$cf
!byte $ff,$ff,$ff,$81,$ff,$ff,$ff,$ff
!byte $ff,$ff,$ff,$ff,$ff,$e7,$e7,$ff
!byte $ff,$fc,$f9,$f3,$e7,$cf,$9f,$ff
!byte $c3,$99,$91,$89,$99,$99,$c3,$ff
!byte $e7,$e7,$c7,$e7,$e7,$e7,$81,$ff
!byte $c3,$99,$f9,$f3,$cf,$9f,$81,$ff
!byte $c3,$99,$f9,$e3,$f9,$99,$c3,$ff
!byte $f9,$f1,$e1,$99,$80,$f9,$f9,$ff
!byte $81,$9f,$83,$f9,$f9,$99,$c3,$ff
!byte $c3,$99,$9f,$83,$99,$99,$c3,$ff
!byte $81,$99,$f3,$e7,$e7,$e7,$e7,$ff
!byte $c3,$99,$99,$c3,$99,$99,$c3,$ff
!byte $c3,$99,$99,$c1,$f9,$99,$c3,$ff
!byte $ff,$ff,$e7,$ff,$ff,$e7,$ff,$ff
!byte $ff,$ff,$e7,$ff,$ff,$e7,$e7,$cf
!byte $f1,$e7,$cf,$9f,$cf,$e7,$f1,$ff
!byte $ff,$ff,$81,$ff,$81,$ff,$ff,$ff
!byte $8f,$e7,$f3,$f9,$f3,$e7,$8f,$ff
!byte $c3,$99,$f9,$f3,$e7,$ff,$e7,$ff
!byte $ff,$ff,$ff,$00,$00,$ff,$ff,$ff
!byte $f7,$e3,$c1,$80,$80,$e3,$c1,$ff
!byte $e7,$e7,$e7,$e7,$e7,$e7,$e7,$e7
!byte $ff,$ff,$ff,$00,$00,$ff,$ff,$ff
!byte $ff,$ff,$00,$00,$ff,$ff,$ff,$ff
!byte $ff,$00,$00,$ff,$ff,$ff,$ff,$ff
!byte $ff,$ff,$ff,$ff,$00,$00,$ff,$ff
!byte $cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf
!byte $f3,$f3,$f3,$f3,$f3,$f3,$f3,$f3
!byte $ff,$ff,$ff,$1f,$0f,$c7,$e7,$e7
!byte $e7,$e7,$e3,$f0,$f8,$ff,$ff,$ff
!byte $e7,$e7,$c7,$0f,$1f,$ff,$ff,$ff
!byte $3f,$3f,$3f,$3f,$3f,$3f,$00,$00
!byte $3f,$1f,$8f,$c7,$e3,$f1,$f8,$fc
!byte $fc,$f8,$f1,$e3,$c7,$8f,$1f,$3f
!byte $00,$00,$3f,$3f,$3f,$3f,$3f,$3f
!byte $00,$00,$fc,$fc,$fc,$fc,$fc,$fc
!byte $ff,$c3,$81,$81,$81,$81,$c3,$ff
!byte $ff,$ff,$ff,$ff,$ff,$00,$00,$ff
!byte $c9,$80,$80,$80,$c1,$e3,$f7,$ff
!byte $9f,$9f,$9f,$9f,$9f,$9f,$9f,$9f
!byte $ff,$ff,$ff,$f8,$f0,$e3,$e7,$e7
!byte $3c,$18,$81,$c3,$c3,$81,$18,$3c
!byte $ff,$c3,$81,$99,$99,$81,$c3,$ff
!byte $e7,$e7,$99,$99,$e7,$e7,$c3,$ff
!byte $f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9
!byte $f7,$e3,$c1,$80,$c1,$e3,$f7,$ff
!byte $e7,$e7,$e7,$00,$00,$e7,$e7,$e7
!byte $3f,$3f,$cf,$cf,$3f,$3f,$cf,$cf
!byte $e7,$e7,$e7,$e7,$e7,$e7,$e7,$e7
!byte $ff,$ff,$fc,$c1,$89,$c9,$c9,$ff
!byte $00,$80,$c0,$e0,$f0,$f8,$fc,$fe
!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
!byte $ff,$ff,$ff,$ff,$00,$00,$00,$00
!byte $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
!byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
!byte $33,$33,$cc,$cc,$33,$33,$cc,$cc
!byte $fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc
!byte $ff,$ff,$ff,$ff,$33,$33,$cc,$cc
!byte $00,$01,$03,$07,$0f,$1f,$3f,$7f
!byte $fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc
!byte $e7,$e7,$e7,$e0,$e0,$e7,$e7,$e7
!byte $ff,$ff,$ff,$ff,$f0,$f0,$f0,$f0
!byte $e7,$e7,$e7,$e0,$e0,$ff,$ff,$ff
!byte $ff,$ff,$ff,$07,$07,$e7,$e7,$e7
!byte $ff,$ff,$ff,$ff,$ff,$ff,$00,$00
!byte $ff,$ff,$ff,$e0,$e0,$e7,$e7,$e7
!byte $e7,$e7,$e7,$00,$00,$ff,$ff,$ff
!byte $ff,$ff,$ff,$00,$00,$e7,$e7,$e7
!byte $e7,$e7,$e7,$07,$07,$e7,$e7,$e7
!byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
!byte $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
!byte $f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8
!byte $00,$00,$ff,$ff,$ff,$ff,$ff,$ff
!byte $00,$00,$00,$ff,$ff,$ff,$ff,$ff
!byte $ff,$ff,$ff,$ff,$ff,$00,$00,$00
!byte $fc,$fc,$fc,$fc,$fc,$fc,$00,$00
!byte $ff,$ff,$ff,$ff,$0f,$0f,$0f,$0f
!byte $f0,$f0,$f0,$f0,$ff,$ff,$ff,$ff
!byte $e7,$e7,$e7,$07,$07,$ff,$ff,$ff
!byte $0f,$0f,$0f,$0f,$ff,$ff,$ff,$ff
!byte $0f,$0f,$0f,$0f,$f0,$f0,$f0,$f0