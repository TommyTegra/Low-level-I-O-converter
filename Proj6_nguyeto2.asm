TITLE ASCII Converter and Basic Stats Calculator     (Proj6_nguyeto2.asm)

; Author: Tommy Nguyen
; Last Modified: 6/11/2023
; OSU email address: nguyeto2@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: Project 6                Due Date: 6/11/2023 @ 11:59 PM PST
; Description: This programs takes 10 valid inputs as strings from the user and converts them to
;			integers and calculates their total and their mean. Then the integers are converted
;			back into strings and displayed along with the total and the average to the console.

INCLUDE Irvine32.inc


; ---------------------------------------------------------------------------------
; Name: mGetString

; Obtains a string from the user and stores input along with the number of characters
;		that was entered.

; Preconditions: The parameters/arguments that were passed must exist and the OFFSET
;		must be passed correctly according to the MACRO below.

; Postconditions: EAX, ECX, and EDX are used but restored by the end, thus, unchanged
;		after completing the procedure. 

; Receives: Parameters passed by reference:
;				prompt = address of the string to be displayed for the user
;				input = address of the variable to store the input from the user
;				inputSize = value of the biggest string length can accommodate

; Returns: Parameters passed by reference:
;				input = address of the variable to store the input from the user
;				bytesRead = address of variable which contains the amount of bytes
;								of the string that was inputted

; ---------------------------------------------------------------------------------
mGetString			MACRO	prompt, input, inputSize, bytesRead
	push	EAX
	push	ECX
	push	EDX
	mov		EDX, prompt							; OFFSET in main/proc
	call	WriteString
	mov		EDX, input							; OFFSET in main/proc
	mov		ECX, inputSize
	call	ReadString
	mov		bytesRead, EAX						; OFFSET in main/proc

	pop		EDX
	pop		ECX
	pop		EAX
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString

; Displays a string that was passed to the console.

; Preconditions: The parameter/argument that was passed must exist and the OFFSET
;		must be passed correctly according to the MACRO below.

; Postconditions: EDX is used but restored by the end, thus, unchanged after 
;		completing the procedure. 

; Receives: Parameters passed by reference:
;				stringInput = address of the variable that contains the string

; Returns: None.

; ---------------------------------------------------------------------------------
mDisplayString		MACRO	stringInput
	push	EDX
	mov		EDX, stringInput					; OFFSET in main/proc
	call	WriteString

	pop		EDX
ENDM

MAXINPUT = 10

.data

intro_1				BYTE	"ASCII Converter and Basic Stats Calculator			by Tommy Nguyen",13,10,0
describe_1			BYTE	"Please input 10 signed decimal integers. The criteria for the numbers are as followed: ",13,10,
							"Must not overflow a 32 bit register.",13,10, "Must be a signed number.",13,10,13,10,
							"Once completed, a list of valid inputs along with their sum and truncated average will be shown.",13,10,0
promptInput			BYTE	"Please input a valid number: ",0
numberPrompt		BYTE	"Here are the numbers that are considered valid inputs: ",13,10,0
sumPrompt			BYTE	"The calculated sum of the valid inputs is: ",0
averagePrompt		BYTE	"The calculated truncated average of the valid inputs is: ",0
goodbyeMessage		BYTE	"Thanks for using this program! Until next time!" ,13,10,0
userInput_1			BYTE	33 DUP(0)
inputLength			DWORD	30					; Technically anything over 10 numerical digits would be invalid, but we'll allow large inputs since it'll be checked either way
bytesCount			DWORD	?
numberInt			DWORD	0
errorMessage		BYTE	"Error, invalid input: Your input was either not a signed number or it was outside the range of a 32 bit register.",13,10,0
intArray			SDWORD	10 DUP(?)
arrayLength			DWORD	LENGTHOF	intArray
arraySize			DWORD	SIZEOF		intArray
signedMarker		DWORD	0					; Manually keep track whether the integer was negative
validInputs			DWORD	10
asciiDiff			DWORD	?
appendIndex			DWORD	0					; Difference from base address to current next index
sum					SDWORD	?
average				SDWORD	?
stringArray			BYTE	30 DUP(?)
stringSum			BYTE	10 DUP(?)
stringAverage		BYTE	10 DUP(?)
intString			SDWORD	?
comma				BYTE	", ",0



.code
main PROC

; --------------------------
; Introduces the program and describes it
;	to the user. Also, provides instructions
;	to the user as well.

; --------------------------
	push	OFFSET intro_1
	push	OFFSET describe_1
	call	introduction

; --------------------------
; Prompts and obtains 10 valid inputs from the
;	user. Will also perform data validation on
;	the inputs given. The inputs are converted
;	from strings to integers and stored into an
;	array.

; --------------------------

	mov		ECX, MAXINPUT
_inputLoop:

	push	OFFSET appendIndex
	push	OFFSET asciiDiff
	push	OFFSET numberInt
	push	OFFSET signedMarker
	push	OFFSET intArray
	push	OFFSET errorMessage
	push	OFFSET promptInput
	push	OFFSET userInput_1
	push	inputLength
	push	OFFSET bytesCount
	call	readVal

	loop	_inputLoop

; --------------------------
; Performs the calculations needed for the sum
;	and the truncated average, also stores the
;	values.

; --------------------------
	push	OFFSET average
	push	OFFSET sum
	push	OFFSET intArray
	push	OFFSET arrayLength
	call	calculations
	call	CrLf

; --------------------------
; Displays the data to the user. This takes the 
;	integers and converts them into a string, the
;	strings are then displayed for the user. 

; --------------------------

	; Displays the list of valid inputs
	mDisplayString		OFFSET	numberPrompt
	mov		ECX, MAXINPUT
	mov		ESI, OFFSET intArray
_displayArrayLoop:
	mov		EAX, [ESI]
	mov		intString, EAX

	push	OFFSET stringArray
	push	OFFSET signedMarker
	push	intString
	call	writeVal

	add		ESI, 4
	cmp		ECX, 1
	je		_skipComma
	mDisplayString		OFFSET	comma
_skipComma:

	loop	_displayArrayLoop
	call	CrLf

	; Displays the sum 
	mDisplayString		OFFSET	sumPrompt
	push	OFFSET stringSum
	push	OFFSET signedMarker
	push	sum
	call	writeVal
	call	CrLf

	; Displays the truncated average
	mDisplayString		OFFSET	averagePrompt
	push	OFFSET stringAverage
	push	OFFSET signedMarker
	push	average
	call	writeVal
	call	CrLf
	call	CrLf

; --------------------------
; Displays a farewell message to the user.

; --------------------------
	mDisplayString		OFFSET	goodbyeMessage


	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------
; Name: introduction

; Procedure to introduce the program.

; Preconditions: intro_1 and describe_1 are strings that introduces and describes 
;		the program.

; Postconditions: EDX changed.

; Receives: Parameters passed by reference:
;				intro_1
;				describe_1

; Returns: None.

; ---------------------------------------------------------------------------------
introduction PROC
	push	EBP
	mov		EBP, ESP
	mDisplayString	[EBP + 12]
	call	CrLf
	mDisplayString	[EBP + 8]
	call	CrLf

	pop		EBP
	ret		8

introduction ENDP


; ---------------------------------------------------------------------------------
; Name: readVal

; Procedure that takes an string that is of signed decimal number and converts that
;		string into an integer. Essentially, an ASCII converter for only signed
;		numbers. 

; Preconditions: The parameters that are passed must exist as described below. The 
;		macros mGetString and mDisplayString must exist.

; Postconditions: EAX, EBX, ECX, EDX, ESI, EDI, and EBP are used but restored by the 
;		end, thus, unchanged after completing the procedure. 


; Receives: Parameters passed by reference:
;				appendIndex = hold the value from the starting address array to the 
;						next available index
;				errorMessage = string if an input is invalid
;				promptInput = string that prompts the user for input
;				userInput_1 = string of the user input
;				bytesCount = character count of user input
;			Parameter passed by value:
;				inputLength = maximum allocated string length for the user input

; Returns: Parameters passed by reference:
;				appendIndex = hold the value from the starting address array to the 
;						next available index
;				asciiDiff = temporarily hold a value during ASCII conversion
;				numberInt = stores the finished converted integer
;				signedMarker = acts as a flag if the input is negative
;				intArray = stores all of the valid inputs

; ---------------------------------------------------------------------------------
readVal PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	EBX
	push	ECX
	push	EDX
	push	ESI
	push	EDI

	mov		EDI, [EBP + 28]
	mov		EBX, [EBP + 44]
	mov		EDX, [EBX]
	add		EDI, EDX

; --------------------------
; Obtains a string from the user then proceeds to check
;	the first character for a sign character. Takes note
;	if so.

; --------------------------
_validateInput:
	mov		EBX, [EBP + 36]					; Clears the variable that contains the finished integer for a fresh start
	mov		EAX, 0
	mov		[EBX], EAX
	mov		EBX, [EBP + 8]

	mGetString		[EBP + 20], [EBP + 16], [EBP + 12], [EBX]

	mov		ESI, [EBP + 16]
	mov		EAX, [EBP + 8]
	mov		ECX, [EAX]
	cld										; Ensures the direction flag is clear

	; First index check						; Signed symbols such as + and - are only valid at the first index
	mov		EAX, [ESI]
	movsx	EAX, AL
	cmp		EAX, 43
	je		_posSignedNum					; Positive sign character so we can just skip this index
	cmp		EAX, 45
	je		_negNum							; Checks for negative sign
	jmp		_conversionLoop

_posSignedNum:
	add		ESI, 1
	dec		ECX
	jmp		_conversionLoop

_negNum:
	mov		EBX, [EBP + 32]
	mov		EDX, 1							; Sets a passed variable to mark that this number is negative
	mov		[EBX], EDX
	add		ESI, 1
	dec		ECX
	jmp		_conversionLoop

; --------------------------
; Furthermore performs data validations and performs the 
;	conversion from ASCII to integer data type. 

; --------------------------
_conversionLoop:
	lodsb
	; Number check
	movsx	EAX, AL
	cmp		EAX, 48
	jl		_error							; Too small of an ASCII code
	cmp		EAX, 57
	jg		_error							; Too big of an ASCII code
	; ASCII Conversion
	sub		EAX, 48
	mov		EBX, [EBP + 40]
	mov		[EBX], EAX						; Stores the difference

	mov		EDX, [EBP + 36]
	mov		EAX, [EDX]

	mov		EBX, 10
	imul	EBX	
	jo		_specialCaseCheck
	mov		EDX, [EBP + 40]
	add		EAX, [EDX]
	jo		_specialCaseCheck

	mov		EDX, [EBP + 36]
	mov		[EDX], EAX						; Digit is done, if at end, positive value is stored

	loop	_conversionLoop
	jmp		_negIntCheck

_specialCaseCheck:
	; Special case check for the lowest possible integer
	cmp		EAX, 2147483648
	jne		_error
	mov		EBX, [EBP + 32]
	mov		EDX, [EBX]
	cmp		EDX, 0
	je		_error
	neg		EAX
	mov		EDX, 0
	mov		[EBX], EDX
	jmp		_storeInt

_negIntCheck:
	; Check if negative sign is needed
	mov		EBX, [EBP + 32]
	mov		EDX, [EBX]
	cmp		EDX, 0
	je		_storeInt
	neg		EAX
	jo		_error
	mov		EDX, 0
	mov		[EBX], EDX						; Clears marker variable for signed integers

_storeInt:

	mov		EBX, [EBP + 36]
	mov		[EBX], EAX						; Stores the finished integer
	stosd

	mov		EBX, [EBP + 44]
	mov		EDX, [EBX]
	add		EDX, 4
	mov		[EBX], EDX
	jmp		_endProc

_error:
	mDisplayString	[EBP + 24]
	jmp		_validateInput

_endProc:

	pop		EDI
	pop		ESI
	pop		EDX
	pop		ECX
	pop		EBX
	pop		EAX
	pop		EBP
	ret		44

readVal ENDP


; ---------------------------------------------------------------------------------
; Name: calculations

; Procedure that performs the calculations need for the sum and the truncated mean.

; Preconditions: sum and average are variables that will store the finished 
;		calculations. In addition, arrayLength and intArray must exist and be 
;		populated.

; Postconditions: EAX, EBX, ECX, EDX, ESI, EDI, and EBP are used but restored by the 
;		end, thus, unchanged after completing the procedure. 

; Receives: Parameters passed by reference:
;				intArray
;				arrayLength

; Returns: Parameters passed by reference:
;				sum
;				average

; ---------------------------------------------------------------------------------
calculations PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	EBX
	push	ECX
	push	EDX
	push	ESI
	push	EDI

	mov		ESI, [EBP + 12]
	mov		EDX, [EBP + 8]
	mov		ECX, [EDX]
	mov		EAX, 0

_sumLoop:
	mov		EBX, [ESI]
	add		EAX, EBX
	add		ESI, 4
	loop	_sumLoop

	; Moves the value into sum variable
	mov		EDI, [EBP + 16]
	mov		[EDI], EAX

	; Average calculation
	mov		EDX, [EBP + 8]
	mov		EBX, [EDX]
	cdq
	idiv	EBX
	; Stores the average in the average variable
	mov		EDI, [EBP + 20]
	mov		[EDI], EAX

	pop		EDI
	pop		ESI
	pop		EDX
	pop		ECX
	pop		EBX
	pop		EAX
	pop		EBP
	ret		20

calculations ENDP


; ---------------------------------------------------------------------------------
; Name: writeVal

; Procedure that takes an integer and converts it to a string of ASCII codes. The
;		procedure will proceed to display that translated string of the integer. 

; Preconditions: The parameters that are passed must exist as described below.
;		The macro mDisplayString must exist.

; Postconditions: EAX, EBX, ECX, EDX, ESI, EDI, and EBP are used but restored by the 
;		end, thus, unchanged after completing the procedure. 


; Receives: Parameters passed by reference:
;				intString, sum, or average = address of the variable that contains 
;						the integer which will be converted
;			Parameter passed by value:
;				signedMarker = variable which tracks if the integer is negative

; Returns: Parameters passed by reference:
;				stringArray, stringSum, or stringAverage = address of variable to 
;						store the string from which the integer is converted into

; ---------------------------------------------------------------------------------
writeVal PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	EBX
	push	ECX
	push	EDX
	push	ESI
	push	EDI

	mov		ESI, [EBP + 8]
	mov		EDI, [EBP + 16]

	mov		EBX, [EBP + 12]					; Clears signed marker variable
	mov		EDX, 0
	mov		[EBX], EDX

	mov		ECX, 0							; Counter to determine number of stack pops needed

	mov		EAX, ESI
	cmp		EAX, 0
	jl		_negativeInt

_initialDigit:								; Evaluates if the integer is a single digit
	cmp		EAX, 10
	jl		_addFirstDigit

_conversion:								; Repeatedly divides by 10 until integer is smaller than 10
	cdq
	mov		EBX, 10
	idiv	EBX
	add		EDX, 48

	push	EDX								; Pushes the ASCII code to be stored later
	mov		EDX, 0
	inc		ECX
	cmp		EAX, 10 
	jl		_addFirstDigit
	jmp		_conversion


_addFirstDigit:
	add		EAX, 48
	push	EAX
	inc		ECX
	cmp		EAX, 43							; Checks for a positive sign
	je		_posSign

	; Negative value check
	mov		EBX, [EBP + 12]
	mov		EDX, [EBX]
	cmp		EDX, 1
	jne		_storeString

_addNegASCII:
	mov		EAX, 45
	push	EAX								; Pushes a negative sign to the stack if needed
	inc		ECX
	jmp		_storeString

_posSign:
	pop		EBX								; Removes the positive sign from the stack
	jmp		_storeString

_negativeInt:								; Marks variable for negative sign
	mov		EDX, 1
	mov		[EBX], EDX
	neg		EAX
	jmp		_initialDigit

_storeString:								; Pops and stores the ASCII code repeatedly, as needed
	pop		EAX
	stosb
	loop	_storeString
	mov		EAX, 0
	stosb									; Adds a null terminator at the end of the string

	mDisplayString	[EBP + 16]

	pop		EDI
	pop		ESI
	pop		EDX
	pop		ECX
	pop		EBX
	pop		EAX
	pop		EBP
	ret		16

writeVal ENDP



END main
