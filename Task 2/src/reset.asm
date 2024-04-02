.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, playerWalkState, playerFrameCounter
.importzp player2_x, player2_y, player2WalkState, player2FrameCounter
.importzp player3_x, player3_y, player3WalkState, player3FrameCounter
.importzp player4_x, player4_y, player4WalkState, player4FrameCounter

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX $2000
  STX $2001
  STX $4010
  BIT $2002
vblankwait:
  BIT $2002
  BPL vblankwait

	LDX #$00
	LDA #$FF
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam

	; initialize zero-page values
	LDA #$90
	STA player_x
	LDA #$70
	STA player_y
	LDA #$00
	STA playerWalkState
	LDA #$00
	STA playerFrameCounter

  	LDA #$60
	STA player2_x
	LDA #$70
	STA player2_y
	LDA #$00
	STA player2WalkState
	LDA #$00
	STA player2FrameCounter
	

  	LDA #$78
	STA player3_x
	LDA #$80
	STA player3_y
	LDA #$00
	STA player3WalkState
	LDA #$00
	STA player3FrameCounter

  	LDA #$78
	STA player4_x
	LDA #$60
	STA player4_y
	LDA #$00
	STA player4WalkState
	LDA #$00
	STA player4FrameCounter

vblankwait2:
  BIT $2002
  BPL vblankwait2
  JMP main
.endproc
