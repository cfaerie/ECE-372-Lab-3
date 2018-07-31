# ECE 372 Lab 3
Authors: Rachel & Ali

The objective of the lab is to guide students into figuring out how to use branching instructions
in assembly language.

Program prompts the user to "Make a selection: V,W,A,D,4,2". When the selection is made, there is a 
subroutine case to handle each character pressed. If non of those characters is pressed, the program
will output the same prompt line until a valid character is entered.

There are six cases total. The VCASE and WCASE prompt the user to enter an 8-bit value as a single 
character. 

VCASE stores the 8-bit value to the variable OP1. 

WCASE stores the 8-bit values to OP2.

ACASE will add the values stores in OP1 and OP2, outputting the SUM and printing a visual representation,
e.g. $33 + $34 = $67.

DCASE converts the contents of OP1 to decimal, and then prints it in hex and 
decimal, e.g 1B 27. 

FOURCASE prints the contents of OP1 and OP2 to look like a single address,
e.g. If OP1 is $2A and OP2 is $3B it prints $2A3B. 

TWOCASE uses the X register to store the address of OP1. Using that address, it will use left bit shifting to double the value in OP1 and store the new value in OP1.
