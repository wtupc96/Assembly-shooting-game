DATAS SEGMENT
	data1 db 0CH,' ',0BH,' ',0AH,' ',0DH,' ',0fh,' ',09h,' ',08h,' ',07h,' ',06h,' ',05h ,' ',04h,' ',03h ,' ',02h,' ',01h,' ',10h
	score dw 0
	score2 dw 30h,'$'
	DBUFFER DB 8 DUP (':'),'$'
	DBUFFER2 DB 8 DUP (':'),'$'
	TIME DB '00:00:00','$'
	PROMPT1 DB 'score:$'
	PROMPT2 DB 'time:$'
	m4 db ?
	CHARACTOR DB 18
	X DB ?
	Y DB ?
	COUNT DB 15
DATAS ENDS

STACKS SEGMENT
STACKS ENDS

CLEAR_SCREEN macro op1,op2,op3,op4 ;清屏宏定�?
	MOV AH,06h
	MOV AL,00h
	MOV BH,07h
	MOV CH,op1
	MOV CL,op2
	MOV DH,op3
	MOV DL,op4
	INT 10h
	MOV AH,02h
	MOV BH,00h
	MOV DH,00h
	MOV DL,00h
	INT 10h
endm

BCDASC MACRO DBUFFERs ;时间数值转换成ASCII码字符子程序
	PUSH BX
	PUSH AX
	CBW
	MOV BL,10
	DIV BL
	ADD AL,'0'
	MOV DBUFFERs[SI],AL
	INC SI
	ADD AH,'0'
	MOV DBUFFERs[SI],AH
	INC SI
	POP AX
	POP BX
ENDM

CODES SEGMENT

ASSUME CS:CODES,DS:DATAS,SS:STACKS

START:
	MOV AX,DATAS
	MOV DS,AX
	MOV AX,0
	INT 33H
	CMP AX,0
	JE over
	MOV AX,01
	INT 33H
	CLEAR_SCREEN 01d,01d,23d,78d ;清屏宏调�?
	MOV AH,0
	MOV AL,03h
	INT 10h;80*25 16色文本显�?
	LEA SI,data1;加载数据
	MOV DI,29;总共29个位置，15个图�?4个空
	MOV DH,0AH;射击图形的行、列
	MOV DL,14h
	
input:
	MOV AH,2;设置光标位置
	INC DL;增加�?
	INT 10h
	PUSH SI
	MOV SI, OFFSET CHARACTOR
	MOV AL,[SI];目标图像
	POP SI
	MOV BH,0
	MOV BL,[SI];图像对应的属�?
	MOV CX,1;显示一�?
	MOV AH,9;在光标位置显示字符及其属�?
	INT 10h
	INC SI
	DEC DI
	JNZ input1
	PUSH AX
	PUSH BX
	PUSH DX
	MOV AH,02h;将光标设置到score位置
	MOV BH,00h
	MOV DH,02
	MOV DL,02h
	INT 10h
	MOV AH,09h
	MOV DX,OFFSET PROMPT1;显示分数
	INT 21h
	MOV AH,09h
	MOV DX,OFFSET score2
	INT 21h
	POP DX
	POP BX
	POP AX
	PUSH SI
	PUSH BX
	PUSH AX
	PUSH DX
	MOV AH,02;设置时间位置
	MOV BH,00
	MOV DH,02
	MOV DL,42H
	INT 10H
	MOV SI,0
	MOV BX,100
	DIV BL
	MOV AH,09h
	MOV DX,OFFSET PROMPT2;显示时间
	INT 21h
	MOV AH,2CH;获取开始的时间
	INT 21H
	MOV AL,CH;�?
	MOV DBUFFER[SI],0
	INC SI
	MOV DBUFFER[SI],AL
	INC SI
	INC SI
	MOV AL,CL;�?
	MOV DBUFFER[SI],0
	INC SI
	MOV DBUFFER[SI],AL
	INC SI
	INC SI
	MOV AL,DH;�?
	MOV DBUFFER[SI],0
	INC SI
	MOV DBUFFER[SI],AL
	MOV AH,09
	MOV DX,OFFSET TIME
	INT 21H
	POP DX
	POP AX
	POP BX
	POP SI
	MOV AH,02h ;图像输入完后，设置射击位置的光标
	MOV BH,00h
	MOV DH,22d
	MOV DL,15d
	INT 10h
	MOV AH,09h
	MOV AL,05h;发射子弹的图�?
	MOV BL,0fh
	MOV CX,1
	INT 10h
	JMP in_key
	
input1:
	MOV AH,2 ;实现每隔一个空格输入一个图�?
	INC DL
	INT 10h
	MOV AL,' '
	MOV BH,0
	MOV BL,[SI]
	INC SI
	DEC DI
	JNZ input
	
in_key:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX;��ʼ���λ��
	PUSH SI
	MOV SI,OFFSET X
	MOV DH,16H
	MOV [SI],DH
	MOV SI,OFFSET Y
	MOV [SI],DL
	MOV AH,06h ;从键盘输入字�?
	MOV DL,0ffh
	INT 21h
	CMP AL,65H ;如果键入e，则退�?
	JE over
	POP SI
	MOV AX,03H
	INT 33H
	MOV AX,CX
	MOV CL,8
	DIV CL;鼠标列坐标在AL�?
	MOV DH,16H
	MOV DL,AL
	AND BX,1H
	JNZ DIsappear
	POP DX
	MOV DH,16H
	MOV DL,AL
	MOV AH,02h
	INT 10h
	MOV AH,09h
	MOV AL,05h
	MOV BL,0fh
	MOV CX,1
	INT 10h
	PUSH SI
	MOV SI,OFFSET X
	CMP DH,[SI]
	JNZ CLEAR
	MOV SI,OFFSET Y
	CMP DL,[SI]
	JNZ CLEAR
	JMP CLEAR_NEXT
	
CLEAR:	
	PUSH DX
	MOV DH,16H
	MOV SI,OFFSET X
	MOV DH,[SI]
	MOV SI,OFFSET Y
	MOV DL,[SI]
	MOV AH,02h
	INT 10h
	MOV AH,09h
	MOV AL ,' '
	MOV CX,1
	INT 10h
	POP DX
	
CLEAR_NEXT:
	POP SI
	POP CX
	POP BX
	POP AX
	JMP in_key
	
DIsappear:
	PUSH AX
	MOV DH,10h
	MOV AH,02h
	MOV BH,00h
	INT 10h;设置光标位置
	MOV AH,09h
	MOV AL,1eh
	MOV BL,0fh
	MOV CX,1
	INT 10h;显示子弹
	SUB DH,2
	
con1: 
	MOV AH,02h
	MOV BH,00h
	INT 10h;设置光标位置
	MOV AH,09h
	MOV AL,1eh
	MOV BL,0fh
	MOV CX,1
	INT 10h;显示子弹	
	CALL delay
	ADD DH,2
	MOV AH,02h
	MOV BH,00h
	INT 10h;设置光标位置
	MOV AH,09h
	MOV AL,0
	MOV BL,0fh
	MOV CX,1
	INT 10h;清除子弹
	SUB DH,4
	CMP DH,0AH
	JA con1
	MOV AH,02h
	MOV BH,00h
	MOV DH,0CH
	INT 10h
	MOV AH,09h
	MOV AL,0
	MOV BL,0fh
	MOV CX,1
	INT 10h;清除最后一颗子�?
	POP AX
	MOV AH,02h;将光标设置到图像位置
	MOV BH,00h
	MOV DH,0AH
	INT 10h
	MOV AH,08h;读取光标处字�?
	MOV BH,00
	INT 10h
	MOV m4,AL
	
next2: 
	MOV AH,09h;将射击到的位置用空格填补
	MOV AL,' '
	MOV DH,0AH
	MOV CX,1
	INT 10h
	PUSH SI
	MOV SI, OFFSET CHARACTOR
	PUSH AX
	MOV AL, [SI]
	CMP m4,AL;判断该位置是否有射击�?
	POP AX
	POP SI
	JNZ next4
	ADD score,1;分数�?
	PUSH AX
	PUSH BX
	PUSH DX
	MOV AH,02h;将光标设置到score位置
	MOV BH,00h
	MOV DH,02h
	MOV DL,02h
	INT 10h
	MOV AH,09h
	MOV DX,OFFSET PROMPT1;显示分数
	INT 21h
	MOV AX,score
	MOV score2,AX
	ADD score2,30h
	CMP score2,3AH
	JB disp3
	MOV AX,3100h
	SUB score2,10
	OR AX,score2
	XCHG AH,AL
	MOV score2,AX
	
disp3:
	MOV AH,09h
	MOV DX,OFFSET score2
	INT 21h
	POP DX
	POP BX
	POP AX
	PUSH SI
	PUSH BX
	PUSH AX
	PUSH CX
	PUSH DX
	MOV AH,02
	MOV BH,00
	MOV DH,02
	MOV DL,42H
	INT 10H
	MOV SI,0
	MOV BX,100
	DIV BL
	MOV AH,2CH ;获取打中的时�?
	INT 21H
	MOV AL,CH
	MOV DBUFFER2[SI],0
	INC SI
	MOV DBUFFER2[SI],AL
	INC SI
	INC SI
	MOV AL,CL
	MOV DBUFFER2[SI],0
	INC SI
	MOV DBUFFER2[SI],AL
	INC SI
	INC SI
	MOV AL,DH
	MOV DBUFFER2[SI],0
	INC SI
	MOV DBUFFER2[SI],AL
	;计算时间�?
	MOV AL,DBUFFER[1]
	SUB DBUFFER2[1],AL
	MOV AL,DBUFFER[4]
	CMP DBUFFER[4],AL
	JNB N1
	ADD DBUFFER2[4],60
	
N1: 
	MOV AH,DBUFFER[7]
	CMP DBUFFER2[7],AH
	JA S1
	JMP S2
	
S1: 
	SUB DBUFFER2[4],AL
	JMP CM
	
S2:
	SUB DBUFFER2[4],AL
	SUB DBUFFER2[4],1
	
CM: 
	MOV AL,DBUFFER[7]
	CMP DBUFFER2[7],AL
	JNB N2
	ADD DBUFFER2[7],60
	
N2: 
	SUB DBUFFER2[7],AL
	MOV AH,09h
	MOV DX,OFFSET PROMPT2;显示时间
	INT 21h
	MOV SI,0
	MOV AL,DBUFFER2[1]
	BCDASC TIME
	INC SI
	MOV AL,DBUFFER2[4]
	BCDASC TIME
	INC SI
	MOV AL,DBUFFER2[7]
	BCDASC TIME
	MOV AH,09
	MOV DX,OFFSET TIME
	INT 21H
	MOV SI,OFFSET COUNT
	MOV AL,[SI]
	DEC AL
	JZ over
	MOV [SI],AL
	POP DX
	POP CX
	POP AX
	POP BX
	POP SI
	
next4:
	MOV AH,02h ;射击后将光标回到原射击位�?
	MOV BH,00h
	MOV DH,16H
	INT 10h
	MOV AH,09h
	MOV AL,05h
	MOV BL,0fh
	MOV CX,1
	INT 10h
	JMP in_key
over:
	MOV AH,02
	INT 33H
	MOV AH,4CH
	INT 21H
	
delay PROC near;延时子程�?
	PUSH CX
	PUSH DX
	MOV DX,0ffffh
DL1:	
	DEC DX
	JNZ DL1
	POP DX
	POP CX
	RET
delay ENDP
CODES ENDS
END START
END START
