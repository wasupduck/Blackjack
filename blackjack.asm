; Wade Aiello
; Blackjack game

.ORIG x3000         ; program start at x3000

LD R0, SEEDSP      ; Load the address stored in SEEDSP into R0

; Store each register at appropriate offset from base address
; For whatever reason, SEEDSP points to the address before the SEEDS address space, so there's an offset
STR R1, R0, #1     ; Store R1 at SEEDS+1
STR R2, R0, #2     ; Store R2 at SEEDS+2
STR R3, R0, #3     ; Store R3 at SEEDS+3
STR R4, R0, #4     ; Store R4 at SEEDS+4
STR R5, R0, #5     ; Store R5 at SEEDS+5


AND R0, R0, #0      ; R0: load strings, store inputs
AND R1, R1, #0      ; R1: 
AND R2, R2, #0      ; 
AND R3, R3, #0      ; 
AND R4, R4, #0      ; 
AND R5, R5, #0      ; 
AND R6, R6, #0      ; R6: store player total
AND R7, R7, #0      ;           

    NewRound

        JSR Reset
    
        JSR NewLine
        
        LEA R1, INITP       ; load pointer
        LDR R0, R1, #0      ; load INIT from pointer
        TRAP x22            ; print the string at R0

        JSR InitLoop        ; jump to InitLoop subroutine
        LD R0, QUIT
        BRp done

        JSR NewLine
        LEA R1, CARDS12P    ; load pointer
        LDR R0, R1, #0      ; load CARDS12 from pointer
        TRAP x22            ; print
        
    
    ; player cards
        LEA R1, PLAYER2P     ; load pointer
        LDR R0, R1, #0      ; load PLAYER to R0
        ST R0, CURRENT      ; store in current

        
        JSR GetCard         ; run GetCard routine to get, add, and display card
        
        JSR DisplayCard     ; displays card

        LEA R1, NDSTRP      ; load pointer
        LDR R0, R1, #0      ; point to NDSTR, the ' and ' string
        TRAP x22            ; print
    
        JSR GetCard         ; run GetCard for second card
        
        JSR DisplayCard     ; displays card

        JSR NewLine

    
        LD R6, TOTAL        ; load current total
        ST R6, TOTALP       ; store player total

    ; dealer cards
        AND R6, R6, #0
        ST R6, TOTAL
        
        LEA R1, DEALERP     ; load pointer
        LDR R0, R1, #0      ; load DEALER to R0
        ST R0, CURRENT      ; store in current
       
        JSR NewLine
        
        LEA R1, DCARDP      ; load pointer
        LDR R0, R1, #0      ; load DCARD from pointer
        TRAP x22            ; print

        JSR GetCard         ; run GetCard for card
        JSR DisplayCard     ; displays card


        JSR GetCard         ; hidden card
        LD R1, CARDS        ; store in hidden
        ST R1, HIDDEN

        LD R6, TOTAL
        ST R6, TOTALD
    

    ; start player game loop
    
        ;store player total in TOTAL

        
        ;load 'your ' into CURRENT to print string
        LEA R1, DEALER2P     ; load pointer
        LDR R0, R1, #0      ; load PLAYER to R0
        ST R0, CURRENT      ; store in current
        
    JSR GameLoopP
    
    LD R1, HASWON
    ADD R1, R1, #0
    BRp winner
    
    JSR GameLoopD
    
    winner
    BR NewRound
    done

HALT

;pointer to set and get seeds
SEEDSP  .FILL SEEDS
GETSEEDP    .FILL x4020
TSEEDP  .FILL TSEED

;pointers to strings
PLAYERP     .FILL PLAYER
PLAYER2P    .FILL PLAYER2
DEALERP     .FILL DEALER
DEALER2P    .FILL DEALER2
DEALERFP    .FILL DEALERF
INITP       .FILL INIT          
WRONGP      .FILL WRONG         
CARDS12P    .FILL CARDS12       
NDSTRP      .FILL NDSTR         
DRAWP       .FILL DRAW           
TOTALSTP    .FILL TOTALST       
HORSP       .FILL HORS
DCARDP      .FILL DCARD
SUPRISEP    .FILL SUPRISE
LOSEP       .FILL LOSE
WINP        .FILL WIN
PUSHP       .FILL PUSH


STSEED  .BLKW 1     ; store current seed
CURRENT .BLKW 1     ; stores string for currently checked player/dealer
STORER6 .BLKW 1     ; store R6
STORER7 .BLKW 1     ; store R7
STORER7D    .BLKW 1         ;special storage block for display
GameLoopR7  .BLKW 1         ; Reserve space for R7
GameLoopR5  .BLKW 1         ; Reserve space for R5
TOTAL   .BLKW 1     ; store current total
TOTALP  .BLKW 1     ; store player total
TOTALD  .BLKW 1     ; store dealer total
CARD    .BLKW 1     ; store current card
CARDS   .BLKW 1     ; store current card string
HIDDEN  .BLKW 1     ; store hidden card for dealer
HASWON  .BLKW 1     ; check to see if player has won
QUIT    .BLKW 1     ; check to see if player wants to quit
ISACEP   .BLKW 1     ; check to see if there is an ace


; this subroutine resets totals after each round
Reset
    ; R1: zero, used to reset each total
    
    AND R1, R1, #0
    ST R1, TOTAL
    ST R1, TOTALP
    ST R1, TOTALD
    ST R1, HASWON

RET


; new line subroutine
NewLine
    ; R0: used to load new line char
        LD R0, NL               ; load and print newline
        TRAP x21
    RET
    
    
; this subroutine displays given card using the CARDST array with the current seed
DisplayCard
; R1: loads current seed
; R4: loads address, increments by seed and displays incremented address
; R7: sometimes broke the game when called, so R7 is stored at beginning and loaded at end

    ST R7, STORER7D
    LEA R4, CARDST          ; load address at CARDST, the string array
    LD R1, STSEED           ; load current seed
    ADD R4, R4, R1          ; increment address by seed
    LDR R0, R4, #0          ; load string pointed to by address in R4 to R0
    TRAP x22                ; display string
    LD R7, STORER7D
    
RET


; This subroutine checks if the seed is between 0-12, and loops GetSeed until it is.
GetCard
; R0: loads address pointed by TSEEDP
; R1: loads seed from TSEEDP/STSEED
; R2: loads address at CARDARR and increments to seeded card
; R3: loads card value and stores in CARD label
; R4: loads address for card strings
; R6: loads total, adds card value to total and saves it
; R7: needed for stack

    ST R7, STORER7          ; for whatever reason, R7 was pointing to the 'ADD R4, R4, R1' whenever the RET command was
                            ; used, so I fixed it by storing the return address and loading it back into R7 at the end
    LD R0, GETSEEDP
    JSRR R0
    
    LD R0, TSEEDP           ; load address of seed into R0
    LDR R1, R0, #0          ; load seed into R1
    ST R1, STSEED           ; store in STSEED
    AND R3, R3, #0          ; clear R3
    ADD R3, R1, #0          ; add seed to R3
    
        BRnp notace         ; skips ISACEP iteration if it's not an ace (0th address location in CARDARR)
            LD R3, ISACEP
            ADD R3, R3, #1
            ST R3, ISACEP
        notace

    LEA R2, CARDARR         ; load address at CARDARR, or the integer array
    ADD R2, R2, R1          ; increment address by seed
    LDR R3, R2, #0          ; load value from address in R2 into R3
    ST R3, CARD             ; stores current card value ************************
    

    LD R6, TOTAL            ; load current total
    ADD R6, R6, R3          ; add card to total
    ST R6, TOTAL            ; store total
    
    LEA R4, CARDST          ; load address at CARDST, the string array
    LD R1, STSEED           ; load current seed
    ADD R4, R4, R1          ; increment address by seed
    LDR R0, R4, #0          ; load string pointed to by address in R4 to R0
    ST R0, CARDS            ; stores current card string ************************

    LD R7, STORER7          ; load return address
    
RET                     


; This is the subroutine for the initialization loop. It reads an input and repeats until it's 'n' or 'x'
InitLoop
; R0: input
; R1: reads input from R0
; R2: loads characters to be compared to input
; R3: compares inputs here
; R7: needed for stack

    ST R7, STORER7
    input1
        TRAP x20            ; read input into R0
        TRAP x21            ; echo character
        ADD R1, R0, #0
        JSR NewLine
        
        LD R2, CHN          ; load address of 'n' character
        ;IF input = 'n'
        NOT R3, R2          ; bitwise NOT of R2
        ADD R3, R3, #1      ; R3 = -R2 (2's complement)
        ADD R3, R1, R3
        BRz equalsn         ; branch off if R3 is 2's compliment of R1
                            ; AKA if input = 'n'


        LD R2, CHX          ; load address of 'n' character
     
        NOT R3, R2          
        ADD R3, R3, #1      
        ADD R3, R1, R3
        BRz equalsx         ; branch off if R3 is 2's compliment of R1
                            ; AKA if input = 'x'
                
        ;ELSE
        
        
        LEA R1, WRONGP   ; load from string table
        LDR R0, R1, #0      ; 
        TRAP x22            ; print string
        
        BR input1           ; branch to input 1 until char equals 'n'
        
    equalsx
    
    AND R0, R0, #0 
    ADD R0, R0, #1
    ST R0, QUIT             ;adds 1 to QUIT, which branches to halt after InitLoop if 'x' is clicked
    
    equalsn
    
    LD R7, STORER7

RET
    
;displays total for players by logically finding tens and ones and outputting them consecutively
DisplayTotal
; R0: loads currently used string to be displayed (so this function can be used by dealer and player) and outputs digits
; R1: loads pointer to TOTALST string
; R2: holds tens digit
; R3: holds ones digit
; R4: used in tens digit loop
; R5: used to store ascii value for zero

    LD R0, CURRENT
    TRAP X22
    
    LEA R1, TOTALSTP        ; load pointer
    LDR R0, R1, #0          ; point to TOTALST
    TRAP x22
    
    LD R1, TOTAL
    AND R2, R2, #0
    AND R3, R3, #0
    AND R4, R4, #0  ; 
    AND R5, R5, #0  ; 

    ADD R3, R1, #0  ; sets R3 to TOTAL

    ; increments tens digit value until number is less than ten
    tensloop
        ADD R4, R3, #-10    ; subtract 10 from current total
        BRn tensdone        ; ends loop if result is negative
        ADD R3, R3, #-10    ; otherwise, subtracts 10 from ones digit value
        ADD R2, R2, #1      ; increments tens digit value by 1
        BR tensloop         ; loops around
    tensdone
    
    LD R5, ASCII0           ; load ascii value for zero
    ADD R2, R2, R5          ; adds ascii value for zero to tens digit
    ADD R3, R3, R5          ; adds ascii value for zero to ones digit
    
    NOT R5, R5              
    ADD R5, R5, #1          ; 2's compliment of ascii value for zero
    ADD R4, R2, R5          ; checks if R2 = 0
    BRz printones           ; if zero, skip tens
    
    ADD R0, R2, #0
    TRAP x21                ; print tens digit

    printones
        ADD R0, R3, #0
        TRAP x21            ; print ones digit
RET


;this is the gameloop subroutine for the dealer. There's a couple differences, most notably the lack of input processing.
GameLoopD
; R0: output processing
; R1: loads pointer to TOTALST string
; R2: holds tens digit
; R3: holds ones digit
; R4: used in tens digit loop
; R5: used to store ascii value for zero
; R6: used in tens digit loop
; R7: used for stack, has it's own label to prevent recursive stack problems

    ST R7, GameLoopR7    ; Use a uniquely named label
    ST R5, GameLoopR5    ; Use a uniquely named label
    LEA R6, DEALER2P
    LDR R5, R6, #0
    ST R5, CURRENT

        JSR NewLine
        LEA R1, DEALERFP       ; load pointer
        LDR R0, R1, #0      ; load HORP from pointer
        TRAP x22            ; print

        LEA R1, HIDDEN       ; load pointer
        LDR R0, R1, #0      ; load HORP from pointer
        TRAP x22            ; print

      ;load dealer total
        LD R6, TOTALD
        ST R6, TOTAL
        
        JSR NewLine
        JSR DisplayTotal
    
    ;check to see if total is greater than 16, doesn't add new cards if so
        LD R1, DSTOP
        ADD R2, R6, R1
        BRp skiploop
        
    DealLoop
    
        AND R1, R1, #0
        ST R1, ISACEP

        JSR GetCard
        
    ;display cards
        JSR NewLine
        LD R0, CURRENT
        TRAP x22            ; print
        
        LEA R1, DRAWP       ; load pointer
        LDR R0, R1, #0      ; load HORP from pointer
        TRAP x22            ; print
        
        JSR DisplayCard
        JSR NewLine
        JSR DisplayTotal
        ST R1, TOTALD       ; store total
        
    ;check if it's greater than 16
        LD R1, TOTAL
        LD R6, DSTOP
        ADD R2, R6, R1
        BRnz DealLoop       ;loop if not
        
        ;check if it's less than 21
        LD R2, BJ2S
        ADD R3, R1, R2
        
        BRnz skiploop

        LD R2, ISACEP
        BRnz goon
        
            ADD R1, R1, #-10
            ST R1, TOTAL
            ST R1, TOTALP
            ADD R1, R1, #-1
            ST R1, ISACEP
            BR DealLoop
    
        goon
        
        BR winpl
    
    skiploop

        LD R2, TOTALP
        LD R1, TOTALD

        NOT R3, R1
        ADD R3, R3, #1
        ADD R4, R2, R3
        
    BRp winpl
    BRz pushpl
    BRn wind
        
        winpl
        
        JSR NewLine
        LEA R1, WINP    ; load pointer
        LDR R0, R1, #0      ; load CARDS12 from pointer
        TRAP x22            ; print
        BR finish
        
        pushpl
        
        JSR NewLine
        LEA R1, PUSHP    ; load pointer
        LDR R0, R1, #0      ; load CARDS12 from pointer
        TRAP x22            ; print
        BR finish

        wind
        
        JSR NewLine
        LEA R1, LOSEP    ; load pointer
        LDR R0, R1, #0      ; load CARDS12 from pointer
        TRAP x22            ; print

    finish
    
    LD R7, GameLoopR7
    LD R5, GameLoopR5
RET

;this is the gameloop subroutine for the player. It includes some input processing.
GameLoopP
; R0: output processing
; R1: loads pointer to TOTALST string
; R2: holds tens digit
; R3: holds ones digit
; R4: used in tens digit loop
; R5: used to store ascii value for zero
; R6: used in tens digit loop
; R7: used for stack, has it's own label to prevent recursive stack problems

    ST R7, GameLoopR7    
    ST R5, GameLoopR5
    
    LEA R6, PLAYER2P    ;sets CURRENT to PLAYER2 string
    LDR R5, R6, #0
    ST R5, CURRENT
        LD R6, TOTALP
        ST R6, TOTAL


    MainLoop    ;loops back if hit and not above 21
    
        JSR NewLine
        JSR DisplayTotal

        JSR NewLine
        
        LEA R1, HORSP       ; load pointer
        LDR R0, R1, #0      ; load HORP from pointer
        TRAP x22            ; print
        
        TRAP x20            ; read char
        TRAP x21            ; print char
        
        ADD R1, R0, #0      ; copy character into R1
        
        LD R2, CHH          ; load address of 'h' character
        
        ;IF input = 'h'
        NOT R3, R2          ; bitwise NOT of R2
        ADD R3, R3, #1      ; R3 = -R2 (2's complement)
        ADD R3, R1, R3
        BRz equalsh         ; branch off if R3 is 2's compliment of R1
                            ; AKA if input = 'h'
                    
        AND R3, R3, #0
        LD R2, CHS
        
        ;IF input = 's'
        NOT R3, R2          ; bitwise NOT of R2
        ADD R3, R3, #1      ; R3 = -R2 (2's complement)
        ADD R3, R1, R3
        BRz equalss         ; branch off if R3 is 2's compliment of R1
                            ; AKA if input = 's'
                            
        ;ELSE
        LD R0, NL           ; load newline char
        TRAP x21            ; print
        
        LEA R1, WRONGP      ; load from string table
        LDR R0, R1, #0      ; load string to address

        TRAP x22            ; print string
        BR MainLoop         ; branch to input 1 until char equals 'h' or 's'

    equalsh ;branches here if 'h'
        
        JSR GetCard ; gets card

        JSR NewLine
        LEA R1, PLAYER2P       ; load pointer
        LDR R0, R1, #0      ; load PLAYER2 from pointer
        TRAP x22            ; print
        
        LEA R1, DRAWP       ; load pointer
        LDR R0, R1, #0      ; load HORP from pointer
        TRAP x22            ; print
        
        JSR DisplayCard
        
        
        LD R1, TOTAL    ;loads total into R1
        LD R2, BJ2S     ;loads -21
        ADD R3, R1, R2  ;adds total to -21
            
        BRnz MainLoop   ;loops if not positive
        
        
    ;isace stuff
        ;checks for ace
        LD R2, ISACEP
        BRnz losepl ;skips if not positive
        
        ADD R1, R1, #-10
        ST R1, TOTAL
        ST R1, TOTALP
        AND R1, R1, #0
        ST R1, ISACEP
        BR MainLoop
        
        losepl
        
        ;displays "you lose"
        JSR NewLine
        JSR DisplayTotal
        JSR NewLine
        LEA R1, LOSEP       ; load pointer
        LDR R0, R1, #0      ; load HORP from pointer
        TRAP x22            ; print
        AND R1, R1, #0
        ADD R1, R1, #1
        ST R1, HASWON
        
    equalss
        
        AND R1, R1, #0
        ST R1, ISACEP

        LD R1, TOTAL
        ST R1, TOTALP

    LD R7, GameLoopR7
    LD R5, GameLoopR5
    
RET



; This is the card array. GetCard will select a number from this array
; Jack, queen, and king all have their own 
CARDARR .FILL #11   ; ace card
        .FILL #2
        .FILL #3
        .FILL #4
        .FILL #5
        .FILL #6
        .FILL #7
        .FILL #8
        .FILL #9
        .FILL #10
        .FILL #10   ; jack card
        .FILL #10   ; queen card
        .FILL #10   ; king card

BJ2S    .FILL #-21
BJ      .FILL #21    
DSTOP   .FILL #-16
NL      .FILL x000A     ; newline character
CHH     .FILL x68       ; 'h' character
CHN     .FILL x6E       ; 'n' character
CHS     .FILL x73       ; 's' character
CHX     .FILL x78       ; 'x' character
ASCII0  .FILL x30       ; '0' character

CARDST  .FILL AST
        .FILL TWOST
        .FILL THREEST
        .FILL FOURST
        .FILL FIVEST
        .FILL SIXST
        .FILL SEVENST
        .FILL EIGHTST
        .FILL NINEST
        .FILL TENST
        .FILL JST
        .FILL QST
        .FILL KST

.ORIG x3500         ;store strings at x3500
        
AST     .STRINGZ "Ace"
TWOST   .STRINGZ "2"
THREEST .STRINGZ "3"
FOURST  .STRINGZ "4"
FIVEST  .STRINGZ "5"
SIXST   .STRINGZ "6"
SEVENST .STRINGZ "7"
EIGHTST .STRINGZ "8"
NINEST  .STRINGZ "9"
TENST   .STRINGZ "10"
JST     .STRINGZ "Jack"
QST     .STRINGZ "Queen"
KST     .STRINGZ "King"

PLAYER  .STRINGZ "You"
PLAYER2 .STRINGZ "Your"
DEALER  .STRINGZ "The dealer"
DEALER2 .STRINGZ "The dealer's"
DEALERF .STRINGZ "The dealer flips over a "
INIT    .STRINGZ "To start a new round, hit 'n', or hit 'x' to quit: " 
WRONG   .STRINGZ "Invalid Character, please try again: "
CARDS12 .STRINGZ "Here is your starting hand: "
NDSTR   .STRINGZ " and "
DRAW    .STRINGZ " next card is: "
TOTALST .STRINGZ " total is : "
HORS    .STRINGZ "Hit or stay? Press 'h' or 's': "
DCARD   .STRINGZ "The dealer shows a "
SUPRISE .STRINGZ " hit blackjack!"
LOSE    .STRINGZ "You lose!"
WIN     .STRINGZ "You win!"
PUSH    .STRINGZ "A tie! The hand is pushed."

; I did this part last, and any more lines of code would have lead to offset problems
.ORIG x4020

; This function uses the random numbers stored at the beginning to pick a number between 0-12. For some reason, it doesn't
; generate Jack, Queen, and King cards as often as it does Ace-10. In short, it does an XOR operation for seeds 1 and 2, an
; ADD operation for seeds 3 and 4, and an XOR function for the results of both of those. I tried many different iterations
; here, from simple arithmetic operations from a single seed, to a large algorithm involving 7 seeds iterating on each other
; over and over again, but each time either it would end up looping between the same 1-6 numbers. This was the first one that
; continually produced novel results.

GETSEEDS
    ST R7, SEEDR7   ;

    LEA R0, SEEDS
    LDR R1, R0, #1
    LDR R2, R0, #2
    LDR R3, R0, #3
    LDR R4, R0, #4

    seedLoop
        NOT R1, R1
        AND R6, R1, R2
        NOT R7, R6          ; NOT(R1 AND R2).
    
        NOT R6, R1
        NOT R5, R2
        AND R5, R6, R5      ; NOT ((NOT R1) AND (NOT R2)). AKA R1 OR R2
        NOT R6, R5          ; NOT (R1 OR R2)
    
    AND R5, R6, R7          ; (R1 OR R2) AND NOT (R1 AND R2). AKA, R1 XOR R2
    
    
    ADD R6, R3, R4          ; R3 + R4
        
                            ; R5 = R1 XOR R2
                            ; R6 = R3 + R4
        ST R3, TEMPR3       ; store R3 temporarily so that R3 can be used for XOR
        

        AND R3, R5, R6
        NOT R4, R3          ; NOT(R5 AND R6)
    
        NOT R3, R5
        NOT R7, R6
        AND R7, R4, R7      ; R5 OR R6
        NOT R3, R5          ; NOT (R5 OR R6)
        
    AND R7, R6, R4          ; (R5 OR R6) AND NOT (R5 AND R6). AKA, R5 XOR R6
    
    LD R3, TEMPR3           ; load R3
    
    STR R2, R0, #1          ;store R2 at SEED+1
    STR R3, R0, #2          ;store R3 at SEED+2
    STR R4, R0, #3          ;store R4 at SEED+3
    STR R7, R0, #4          ;store R7 at SEED+4
    
    
    AND R7, R7, #15     ; R7 mod 15
    ADD R0, R7, #-13
    BRp seedLoop
    
    ST R7, TSEED        ; Store seed in TSEED

    LD R7, SEEDR7

RET

TEMPR3    .BLKW 1
TSEED   .BLKW 1
SEEDR7  .BLKW 1
SEEDS   .BLKW 8

ADDY1   .BLKW 1
ADDY2   .BLKW 1
ADDY3   .BLKW 1





        .END
