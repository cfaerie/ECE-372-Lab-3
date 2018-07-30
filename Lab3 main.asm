;*****************************************************************
;* ParsingLoop.ASM
;* 
;*****************************************************************
; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 
		
;-------------------------------------------------- 
; Equates Section  
;----------------------------------------------------  
ROMStart    EQU  $2000  ; absolute address to place my code

;---------------------------------------------------- 
; Variable/Data Section
;----------------------------------------------------  
            ORG RAMStart   ; loc $1000  (RAMEnd = $3FFF)
; Insert here your data definitions here

PROMPT      dc.b    $0A, $0D   ; CR LF
            dc.b    "Make a selection: V,W,A,D,4,2 "
            dc.b    0    ; using zero terminated strings
            
PROMPT1     dc.b    $0A, $0D   ; CR LF
            dc.b    "Enter an 8-bit charachter "
            dc.b    0    ; using zero terminated strings

CARRY       dc.b    $0A, $0D   ; CR LF
            dc.b    "invalid unsigned"
            dc.b    0    ; using zero terminated strings 

OVERFLOW    dc.b    $0A, $0D   ; CR LF
            dc.b    "invalid signed"
            dc.b    0    ; using zero terminated strings
                                  
JUMPLN      dc.b    $0A, $0D   ; CR LF
            dc.b    0    ; using zero terminated strings 

DOLLAR      dc.b    "$"
            dc.b    0    ; using zero terminated strings 

SPACE       dc.b    " "
            dc.b    0    ; using zero terminated strings 
                        
PLUS        dc.b    " + "
            dc.b    0    ; using zero terminated strings 

EQUAL       dc.b    " = "
            dc.b    0    ; using zero terminated strings 
                        
YESSTRG     dc.b    "   YES  "
            dc.b    0    ; using zero terminated strings

NOSTRG      dc.b    "   NO   "
            dc.b    0    ; using zero terminated strings

MAYBESTRG   dc.b    "   MAYBE  "
            dc.b    0    ; using zero terminated strings
         
OP1STRG     dc.b    $0A, $0D   ; CR LF
            dc.b    "OP1= $"  
            dc.b    0    ; using zero teminated strings
            
OP2STRG     dc.b    $0A, $0D   ; CR LF
            dc.b    "OP2= $"         
            dc.b    0    ; using zero teminated strings
         
OP1         DS      1    ; RESERVE STORAGE FOR OP1

OP2         DS      1    ; RESERVE STORAGE FOR OP2

SUM         DS      1    ; RESERVE STORAGE FOR SUM


       INCLUDE 'utilities.inc'
       INCLUDE 'LCD.inc'

;---------------------------------------------------- 
; Code Section
;---------------------------------------------------- 
            ORG   ROMStart  ; loc $2000
Entry:
_Startup:
            ; remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
            ; set registers at $0000
            CLR   $11                  ; INITRG= $0
            ; set ram to end at $3FFF
            LDAB  #$39
            STAB  $10                  ; INITRM= $39

            ; set eeprom to end at $0FFF
            LDAA  #$9
            STAA  $12                  ; INITEE= $9
            JSR   PLL_init      ; initialize PLL  
  endif

;---------------------------------------------------- 
; Insert your code here
;---------------------------------------------------- 
         LDS   #ROMStart   ; load stack pointer
         JSR   TermInit    ; needed for Simulator only
         CLR   OP1         ; initialize OP1
         CLR   OP2         ; initialize OP2
         CLR   SUM         ; initialize SUM
         
LOOP     LDD   #PROMPT     ; pass the adr of the string
         JSR   printf    	 ; print the string         
         JSR   getchar     ; call getchar function -result is: character in B
         
VCASE    CMPB  #'V'        ; is it V ?
         BNE   WCASE       ; jump ahead if not
         JSR   VFCN        ; else do corresponding function for V
         PSHD              ; push D to stack
         LDD   #OP1STRG    ; pass the adr of the string
         JSR   printf      ; print the string
         PULD              ; pull D from stack
         TAB               ; print the content of register A 
         JSR   out2hex     ; to the terminal 
         CLRB
         
WCASE    CMPB  #'W'        ; is it W ?
         BNE   ACASE       ; jump ahead if not
         JSR   WFCN        ; else do corresponding function for W
         PSHD              ; push D to stack
         LDD   #OP2STRG    ; pass adr of string
         JSR   printf      ; print string
         PULD              ; pull D from stack
         TAB               ; print the contents of register A
         JSR   out2hex     ; to the terminal
         CLRB
         
ACASE    CMPB  #'A'        ; is it A ?
         BNE   DCASE       ; jump ahead if not 	       
         JSR   AFCN 	     ; else do corresponding function of A 
         CLRB 
         
DCASE    CMPB  #'D'        ; is it D ?
         BNE   FOURCASE    ; jump ahead if not    	       
         JSR   DFCN 	     ; else do corresponding function of D 
         CLRB 
         
FOURCASE CMPB  #'4'        ; is it 4 ?
         BNE   TWOCASE     ; jump ahead if not   	       
         JSR   FOURFCN     ; else do corresponding function of 4
         CLRB
         
TWOCASE  CMPB  #'2'        ; is it 2 ?
         BNE   NEXT        ; jump ahead if not
         JSR   TWOFCN      ; else do corresponding function of 2          	       
NEXT     JMP   LOOP        ; loop for more input

; Note: main program is an endless loop and subroutines follow
; (Must press reset to quit.)

;===================================================================
; FUNCTIONS CALLED BY MAIN LOOP


; Function: VFCN
; prompts the user to enter an 8-bit value from the keyboard
; The value entered is stored in a memory location named OP1
; The value entered is also returned to the main program in register A        
VFCN    LDD     #PROMPT1    ; pass the address of the string PROMT1
        JSR     printf	    ; print the string
        JSR     getchar     ; call getchar; value is in B
        TBA                 ; return the value fetched in A
        STAB    OP1         ; store the value  fetched in OP1
        RTS

; Function: WFCN
; prompts the user to enter an 8-bit value from the keyboard
; The value entered is stored in a memory location named OP2
; The value entered is also returned to the main program in register A      
WFCN    LDD     #PROMPT1    ; pass the address of the string PROMT1
        JSR     printf	    ; print the string
        JSR     getchar     ; call getchar; value is in B
        TBA                 ; return the value fetched in A
        STAB    OP2         ; store the value feetched in B
        RTS

; Function: AFCN
; adds the current value of OP1 to the current value of OP2
; prints a line showing the addition result
; e.g.  $2A + $52 = $7C
; If the addition result is invalid assuming unsigned operands it also prints "invalid unsigned".
; If the addition result is invalid assuming signed operands it also prints "invalid signed".      
AFCN    LDAA    OP1         ; load OP1 in A
        LDAB    OP2         ; load OP2 in B
        ABA                 ; add A and B:  A = A + B
        
        PSHA                
        TFR     CCR,A
        TAB
        ANDA    #%00000010
        CMPA    #%00000010
        BNE     ANOTHER
        LDD     #OVERFLOW
        JSR     printf
ANOTHER ANDB    #%00000001
        CMPB    #%00000001
        BNE     VALID
        LDD     #CARRY
        JSR     printf       
        
VALID   PULA
        STAA    SUM         ; store the result in SUM
        LDD     #JUMPLN     ; jump a line   
        JSR     printf
        LDD     #DOLLAR     ; print '$'   
        JSR     printf
        LDAB    OP1         ; print contents of OP1 in hex
        JSR     out2hex
        LDD     #PLUS       ; print' + '
        JSR     printf
        LDD     #DOLLAR     ; print '4'   
        JSR     printf
        LDAB    OP2         ; print the content of OP2 in hex
        JSR     out2hex
        LDD     #EQUAL      ; print ' = '
        JSR     printf
        LDD     #DOLLAR     ; print '$'    
        JSR     printf
        LDAB    SUM         ; print the content of SUM in hex
        JSR     out2hex     
        RTS

; Function: DFCN
; inputs: value in OP1
; It then places this value in A register and calls a function named HEX2BCD 
; which converts the value passed to it in A register to BCD (decimal) 
; return the converted value in A register
; print the original value followed by the decimal value on the same line and return.
; e.g.  1B  27
DFCN    LDD     #JUMPLN     ; jump to a new line
        JSR     printf
        LDAB    OP1         ; print the contents of OP1 in hex
        JSR     out2hex
        PSHB
        LDAB    #' '        ; print ' '
        JSR     putchar     
        PULB
        TBA                 ; transfer B to A
        JSR     HEX2D       ; convert the value to decimal
        TAB                 ; print the converterd value
        JSR     out2hex     
        RTS

; Function: FOURFCN
; inputs: OP1, OP2
; prints the current value of the four hex digits in memory beginning at the address of OP1 to the terminal
; e.g. If OP1 is $2A  and OP2 is $3B it prints $2A3B                                       
FOURFCN LDD     #JUMPLN     ; jump to a new line
        JSR     printf
        LDD     #DOLLAR     ; print '$'
        JSR     printf
        LDAB    OP1         ; print the value in OP1
        JSR     out2hex
        LDAB    OP2         ; print the value in OP2
        JSR     out2hex     
        RTS

; Function: TWOFCN
; passes the address of OP1 to X register
; multiplies the value in that adderess by 2
; return the new value to OP1 and replaces the old value       
TWOFCN  LDX     #OP1        ; pass the address of OP1 to X
        LDAB    0,X         ; load the value in the desired address to register B
        ASLB                ; arithmetic shift left the contents => B = 2*B
        STAB    OP1         ; store the result in OP1
        JSR     out2hex
        RTS 
                                             
; Function: HEX2BCD
; converts hex to bcd, e.g. $1B becomes $27
; expects input in A reg
; returns converted value in A register

HEX2D  	TFR       A,B     ; COPY A TO B
LT      CMPB      #10     ; is B < 10
        BLO       DONE    ; if so we are done
        SUBB      #10     ; B <- B-10
        ADDA      #6      ; A <- A+6
        BRA       LT
DONE    RTS
    
                                    
ClearLeds
        CLR   PORTB      ; clear all LED's
        RTS                                  
                         
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   Vreset
            DC.W  Entry         ; Reset Vector
 