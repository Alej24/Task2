.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
playerWalkState: .res 1
playerFrameCounter: .res 1
player2_x: .res 1
player2_y: .res 1
player2WalkState: .res 1
player2FrameCounter: .res 1
player3_x: .res 1
player3_y: .res 1
player3WalkState: .res 1
player3FrameCounter: .res 1
player4_x: .res 1
player4_y: .res 1
player4WalkState: .res 1
player4FrameCounter: .res 1

.exportzp player_x, player_y, playerWalkState, playerFrameCounter
.exportzp player2_x, player2_y, player2WalkState, player2FrameCounter
.exportzp player3_x, player3_y, player3WalkState, player3FrameCounter
.exportzp player4_x, player4_y, player4WalkState, player4FrameCounter

.segment "CONST"
standingState = $00     ; States for player animation
firstStepState = $01
secondStepState = $02
animationSpeed = $24    ; Higher value means slower animation speed

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00

  ; update tiles *after* DMA transfer
	JSR updatePlayer
  JSR updatePlayer2
  JSR updatePlayer3
  JSR updatePlayer4
  JSR draw_player
  JSR draw_player2
  JSR draw_player3
  JSR draw_player4

  LDA #20
  LDA #$00
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  ; Increase frame counters
  INC playerFrameCounter
  
  ; Check if it's time to update animation frame
  LDA playerFrameCounter
  CMP #animationSpeed
  BNE skipUpdatePlayer

  ; Reset frame counter
  LDA #$00
  STA playerFrameCounter

  ; Update animation frame
  JSR updatePlayer
  JSR updatePlayer2
  JSR updatePlayer3
  JSR updatePlayer4

  skipUpdatePlayer:
  
  JMP forever
.endproc

.proc updatePlayer
.endproc

.proc updatePlayer2
.endproc

.proc updatePlayer3
.endproc

.proc updatePlayer4
.endproc

.proc draw_player ; Draw right animation
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; Increase the walk state for the player
  INC playerWalkState

  ; Choose which sprite to draw based on playerWalkState
  LDA playerWalkState
  AND #$03 ; Keep playerWalkState between 0 and 3
  CMP #standingState
  BEQ standing
  CMP #firstStepState
  BEQ step1
  CMP #secondStepState
  BEQ step2

  step2:
  ; write player ship tile numbers
  LDA #$04
  STA $0201
  LDA #$05
  STA $0205
  LDA #$0a
  STA $0209
  LDA #$0b
  STA $020d
  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e
  JMP drawDone

  step1:
  ; write player ship tile numbers
  LDA #$04
  STA $0201
  LDA #$05
  STA $0205
  LDA #$08
  STA $0209
  LDA #$09
  STA $020d
  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e
  JMP drawDone

  standing:
  ; write player ship tile numbers
  LDA #$04
  STA $0201
  LDA #$05
  STA $0205
  LDA #$06
  STA $0209
  LDA #$07
  STA $020d
  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e
  JMP drawDone

  drawDone:
  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player2  ; Draw left animation
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; Increase the walk state for the player
  INC playerWalkState

  ; Choose which sprite to draw based on playerWalkState
  LDA playerWalkState
  AND #$03 ; Keep playerWalkState between 0 and 3
  CMP #standingState
  BEQ standing
  CMP #firstStepState
  BEQ step1
  CMP #secondStepState
  BEQ step2

  standing:
  ; write player ship tile numbers
  LDA #$0c
  STA $0211
  LDA #$0d
  STA $0215
  LDA #$0e
  STA $0219
  LDA #$0f
  STA $021d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e
  JMP drawDone

  step1:
  ; write player ship tile numbers
  LDA #$0c
  STA $0211
  LDA #$0d
  STA $0215
  LDA #$10
  STA $0219
  LDA #$11
  STA $021d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e
  JMP drawDone

  step2:
  ; write player ship tile numbers
  LDA #$0c
  STA $0211
  LDA #$0d
  STA $0215
  LDA #$12
  STA $0219
  LDA #$13
  STA $021d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e
  JMP drawDone

  drawDone:
  ; store tile locations
  ; top left tile:
  LDA player2_y
  STA $0210
  LDA player2_x
  STA $0213

  ; top right tile (x + 8):
  LDA player2_y
  STA $0214
  LDA player2_x
  CLC
  ADC #$08
  STA $0217

  ; bottom left tile (y + 8):
  LDA player2_y
  CLC
  ADC #$08
  STA $0218
  LDA player2_x
  STA $021b

  ; bottom right tile (x + 8, y + 8)
  LDA player2_y
  CLC
  ADC #$08
  STA $021c
  LDA player2_x
  CLC
  ADC #$08
  STA $021f

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player3  ; Draw down animation
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; Increase the walk state for the player
  INC playerWalkState

  ; Choose which sprite to draw based on playerWalkState
  LDA playerWalkState
  AND #$03 ; Keep playerWalkState between 0 and 3
  CMP #standingState
  BEQ standing
  CMP #firstStepState
  BEQ step1
  CMP #secondStepState
  BEQ step2

  standing:
  ; write player ship tile numbers
  LDA #$14
  STA $0221
  LDA #$15
  STA $0225
  LDA #$16
  STA $0229
  LDA #$17
  STA $022d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0222
  STA $0226
  STA $022a
  STA $022e
  JMP drawDone

  step1:
  ; write player ship tile numbers
  LDA #$18
  STA $0221
  LDA #$19
  STA $0225
  LDA #$1a
  STA $0229
  LDA #$1b
  STA $022d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0222
  STA $0226
  STA $022a
  STA $022e
  JMP drawDone

  step2:
  ; write player ship tile numbers
  LDA #$1c
  STA $0221
  LDA #$1d
  STA $0225
  LDA #$1e
  STA $0229
  LDA #$1f
  STA $022d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0222
  STA $0226
  STA $022a
  STA $022e
  JMP drawDone

  drawDone:
  ; store tile locations
  ; top left tile:
  LDA player3_y
  STA $0220
  LDA player3_x
  STA $0223

  ; top right tile (x + 8):
  LDA player3_y
  STA $0224
  LDA player3_x
  CLC
  ADC #$08
  STA $0227

  ; bottom left tile (y + 8):
  LDA player3_y
  CLC
  ADC #$08
  STA $0228
  LDA player3_x
  STA $022b

  ; bottom right tile (x + 8, y + 8)
  LDA player3_y
  CLC
  ADC #$08
  STA $022c
  LDA player3_x
  CLC
  ADC #$08
  STA $022f

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player4    ; Draw up animation
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; Increase the walk state for the player
  INC playerWalkState

  ; Choose which sprite to draw based on playerWalkState
  LDA playerWalkState
  AND #$03 ; Keep playerWalkState between 0 and 3
  CMP #standingState
  BEQ standing
  CMP #firstStepState
  BEQ step1
  CMP #secondStepState
  BEQ step2

  standing:
  ; write player ship tile numbers
  LDA #$20
  STA $0231
  LDA #$21
  STA $0235
  LDA #$22
  STA $0239
  LDA #$23
  STA $023d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0232
  STA $0236
  STA $023a
  STA $023e
  JMP drawDone

  step1:
  ; write player ship tile numbers
  LDA #$24
  STA $0231
  LDA #$25
  STA $0235
  LDA #$26
  STA $0239
  LDA #$27
  STA $023d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0232
  STA $0236
  STA $023a
  STA $023e
  JMP drawDone

  step2:
  ; write player ship tile numbers
  LDA #$28
  STA $0231
  LDA #$29
  STA $0235
  LDA #$2a
  STA $0239
  LDA #$2b
  STA $023d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0232
  STA $0236
  STA $023a
  STA $023e
  JMP drawDone

  drawDone:
  ; store tile locations
  ; top left tile:
  LDA player4_y
  STA $0230
  LDA player4_x
  STA $0233

  ; top right tile (x + 8):
  LDA player4_y
  STA $0234
  LDA player4_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA player4_y
  CLC
  ADC #$08
  STA $0238
  LDA player4_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA player4_y
  CLC
  ADC #$08
  STA $023c
  LDA player4_x
  CLC
  ADC #$08
  STA $023f

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $2c, $12, $23, $27
.byte $2c, $2b, $3c, $39
.byte $2c, $0c, $07, $13
.byte $2c, $19, $09, $29

.byte $2c, $0f, $07, $30
.byte $2c, $19, $09, $29
.byte $2c, $19, $09, $29
.byte $2c, $3a, $24, $11

.segment "CHR"
.incbin "spriteAnim.chr"
