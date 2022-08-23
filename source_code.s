.equ seven_segment, 0xff200020
.equ timer, 0xfffec600
.text
.global start

_start:
LDR R0,=timer //R0 points to 0xFFFEC600
LDR R1,=Hextableandwon // R1 points to Hextable and won
LDR R2,=seven_segment // R2 points to 0xFF200020
LDR R3, =30000000 // 30M -> 0.15s
STR R3, [R0] // write load value to load register
MOV R3, #0b011 // enable is 1
STR R3, [R0, #0x8]// write to timer's control register

LDR R5, =0//clear register 5  
MOV R9,#0 
MOV R8,#8
MOV R4,#0
STR R4, [R2]//clear the 7 segment location in order to clean display 
MOV R5, #0 
MOV R6,#0 
MOV R10,#0

LOOP:
LDRB R4, [R1,R5] //load first digit from the Hextableandwon table 
LDRB R7,[R1,R6] //load second digit from the Hextableandwon table 
ADD R4, R7, LSL #8 //shifts the values for the display  
ADD R4, R10, LSL #16//shifts the values for the display  
STR R4, [R2]//store into the 7 segment display location 

WAIT_LOOP:
LDR R3, [R0, #0xC]//load Periodh - upper 16 bits of Timeout period
CMP R3, #0//check timeout period if zero
BEQ WAIT_LOOP
STR R3, [R0, #0xC]//
ADD R5, R5, #1 // loop counter
B CHECK_KEY

CONTINUE:
CMP R5, #9 // control ones digits
MOVGT R5, #0
ADDGT R6, #1 //move to the tens digit
CMP R6,#9 // control tens digits
MOVGT R6,#0
B LOOP

CHECK_KEY:
LDR R12, =0xff20005C//load the location of the edge capture register 
LDR R11, [R12] //read edge capture register
CMP R11 ,#1//check if the button is pressed
BNE CONTINUE
STREQ R11, [R12]//store button value to edge capture register in order to make it zero
MOVEQ R10,R4
ADDEQ R9,#1
STREQ R5,[R2, #8]
BEQ SAVECHARACTER // keep looking if equal

SAVECHARACTER:
CMP R9,#2
ADDNE R4, R10, LSL #8
STR R4, [R2]
STR R11, [R12]//store value to edge capture register in order to make it zero
MOV R11, #0
CMP R9,#2
BEQ COMPARETWONUMBERS
BNE LOOP

COMPARETWONUMBERS:
LDR R8, =0xFFFF0000 
MOV R5,R4
AND R5,R8
MOV R6, R4, LSL #16
CMP R5,R6
MOVEQ R11,#1
BEQ WON // if won display 'won', do not continue
BNE _start//if not start again 

WON:
//Display 'Won'
LDRB R4, [R1,#14]
LDRB R5, [R1,#12]
LDRB R6, [R1,#0]
LDRB R7, [R1,#11]
ADD R4, R6, LSL #8
ADD R4, R7, LSL #16
ADD R4, R5, LSL #24
STR R4, [R2]

end: B end

Hextableandwon: .byte 0x3F , 0x06 ,0x5b ,0x4f ,0x66 ,0x6d ,0x7d ,0x07 ,0x7f ,0x6f,0xC0, 0x1E,0x3C,0x1B,0x37  //0,1,2,3,5,6,7,8,9, W,O,N

.end
