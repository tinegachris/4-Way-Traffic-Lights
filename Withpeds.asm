.model medium

.data 

.stack 
dw 128 dup (0)

.code   

DELAY:  ;input: CX, this value controls the delay. CX=50 means 1ms
        ;output: none
    	JCXZ @DELAY_END
    	@DEL_LOOP:
    	LOOP @DEL_LOOP	
    	@DELAY_END:
    	RET    
    	
time:    push cx
         mov cx,50000
         CALL DELAY
         pop cx
         loop time  
            
         ret  

OUT_A:  ;sends data to output port and saves them in a variable
        ;input: AL
        ;output: PORTA_VAL
        	OUT 30h,AL
        	RET	


OUT_B:  ;output: PORTB_VAL	
        	OUT 32h,AL
        	RET

OUT_C:  ;input: AL
        ;output: PORTC_VAL	
        	OUT 34h,AL
        	RET           
        	         
         
all_red: mov al, 12h  
         call OUT_A
         call OUT_B 
         
         mov cx,5
         call time
         
         mov al, 09h  
         call OUT_A
         call OUT_B 
         
         mov cx,5
         call time 
         
         ret  

foot:    mov al,12h  
         call OUT_A
         call OUT_B 
                     
         mov cx,3
         call time
         
         mov al,09h  
         call OUT_A
         call OUT_B  
                 
         mov al, 0AAH ;Lights the green LED for pedestrians to cross
         call OUT_C
         
         mov cx,5
         call time
         
         mov al,55h   ;Lights the red LED
         call OUT_C
         
         ret
         
emergency:
call all_red 

iret 

allpeds:
call foot

iret

start:
;initialise data segment
mov ax,@data
mov ds,ax   
                       
                       
;initialise extra segment
mov ax, 00h
mov es, ax
            
             
;initialise 8255
mov al, 80h     ;10000000= 80h ;initialise portA
out 36h, al
             
             
;initialise 8259
mov al, 13h  ; ICW1 = 0001 0011 =13h
out 18h, al

mov al, 30h   ; ICW2 = 00110000 = 30h
out 1Ah, al

mov al, 03h    ;ICW4 =   00000011 = 03h
out 1Ah, al 
             
             
;interrupt vector table initialization
lea ax, emergency ;Emergency 
mov di, 00c0h
stosw

mov ax, cs
stosw

lea ax, allpeds   ; Pedestrians Interrupts
mov di, 00c4h
stosw

mov ax, cs
stosw

STI    ;set interrupt flag  


 
lights:
;situation1:
;lighting R1 and R2
mov al, 09h     ;00_001_001
call OUT_A

;lighting G3 and G4
mov al, 24h     ;00_100_100    
call OUT_B   

;pedestrian no crossing
mov al,55h
call OUT_C


mov cx, 5
call time
              
              
;situation2: 
;lightiing R1,Y1 and R2,Y2
mov al, 1bh    ;00_011_011
call OUT_A

;lighting Y3 and Y4
mov al, 12h   ;00_010_010
call OUT_B  


mov cx, 5
call time


;situation3:
;lighting G1 and G2
mov al, 24h    ;00_100_100
call OUT_A

;lighting  R3 and R4
mov al, 09h     ;00_001_001
call OUT_B   


mov cx, 5
call time

;situation4:
;lighting Y1 and Y2
mov al, 12h    ;00_010_010
call OUT_A

;lighting  R3,Y3 and R4, Y4
mov al, 1bh    ;00_011_011  
call OUT_B


mov cx, 5
call time
  
jmp lights  ;looping

hlt  

end start