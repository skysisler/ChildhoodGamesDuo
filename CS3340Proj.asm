# Skyler Sisler
# CS3340.003 - Mazidi
# Project
# 3/5/18
# Project Description:
#	This program is an implementation of a duo of childhood games - tictactoe and hangman. Two game options are given for either one or two game players. 
#	If there are two players, tictactoe, a player vs. player game, can be played between them. If there is one player, tictactoe or hangman, a player vs. computer game, 
#	can be played. Instructions will be given at the beginning of each repsective game that is chosen. 

	.data
	
#main variables and statements

welcome:	.asciiz	"\n                                                       <~~~~~~ WELCOME TO THE CHILDHOOD GAMES DUO ~~~~~~>\n"
listGames:	.asciiz "\n                               You will have the option to play the player vs. computer game, hangman. Perfect for single players!\nYou will also have the option to play the player vs. player game, tic-tac-toe. Perfect for two players! Don't worry, single players can still play this.\n "
whatGame:	.asciiz "\nEnter '1' to play hangman or '0' to play tic-tac-toe: "
wrongChoice:	.asciiz	"\nWHOOPS. Your input wasn't a '1' or '0'. Try again!\n"

#variables and statements for hangman part

opener:        	.asciiz "\n\nYou chose to play the player vs. computer game, Hangman! Great choice!"
rules:	      	.asciiz "\nInstructions - you will enter your capitol letter guess each round to solve the word until you're hung.\n"
guess:        	.asciiz "\nEnter your capital letter guess or '0' to quit: "
numWrongGuesses:.word 	0
numRightGuesses:.word 	0
winningWord:  	.asciiz "PROJECT"
numChars:     	.word 	7
noose:         	.asciiz "\n   [~~~~~]   Word: ______\n   [     |\n         |   Misses:        \n         |\n         |\n         |\n         |\n L~~~~~~~~]\n"
badGuess:     	.asciiz "\nWHOOPS, you entered an incorrect character - capital letters only! Try again.\n"
correctWord:  	.asciiz "\nHOORAY! You guessed the word correctly - you win!!!\n"
hung:    	.asciiz "\nYOU'RE HUNG! You guessed incorrectly too many times - you lost!!!\n"

#variables and statements for tic-tac-toe part

opening: 	.asciiz "\n\nYou chose to play the player vs. player game, Tic-Tac-Toe! Great choice!"
instructions:	.asciiz "\nInstructions - players will enter the column (top #s) and row (left side #s) of where they want to place their piece."
firstPlayer:	.asciiz "\nPlayer X will make the first move!\n\n"
choices: 	.asciiz "\nEnter '1' to play again or '0' to quit: "
movePrompt: 	.asciiz "Player  , please enter your column and row placement WITHOUT SPACES: "
placeX: 	.asciiz "X"
placeO: 	.asciiz "O"
layout: 	.asciiz "  1   2   3\n1   |   |   \n ---+---+---\n2   |   |   \n ---+---+---\n3   |   |   \n\n"
invalidWarning: .asciiz "\nWHOOPS, the position you entered is invalid! Try again.\n"
filledWarning:  .asciiz "\nWHOOPS, the position you entered is filled! Try again.\n"
winner: 	.asciiz "\nPlayer   is the WINNER!!! That concludes the game.\n"
tiedGame: 	.asciiz "HOORAY, it's a TIE!!! That concludes the game.\n"
blank: 		.byte   ' '
			
	.text

#main function to navigate to which game is chosen	
main:

	#dialog box with welcome statement and game choices
	la $a0, welcome
	la $a1, listGames
	li $v0, 59
	syscall
	
	gameInput:
	#prompt user game choice
	li $v0, 4
	la $a0, whatGame
	syscall

	#read in game choice
	li $v0, 5
	syscall
	beq $v0, $0, TicTacToe	#if user's input = 0, branch to play TicTacToe
	li $t0, 1
	beq $v0, $t0, Hangman	#if user's input = 1, branch to play Hangman
	
	#if it comes here, display wront input
	li $v0, 4
	la $a0, wrongChoice
	syscall
	j gameInput	#jump to prompt for another input
	
		
#HANGMAN PORTION
Hangman:
  
  	#welcome player to hangman
  	la $a0, opener   
    	li $v0, 4      
    	syscall         
    
	#display instructions to play
	la $a0 rules
	li $v0 4
	syscall

	#keep getting player's guess
    	rounds:
    	#display noose stand and game setup
        la $a0, noose  
      	li $v0, 4     
      	syscall       

	#store input into $a0 for displayCorrectGuesses
      	jal charGuess
      	move $a0, $v0 
      	jal displayCorrectGuesses

	#increment current num of correct guesses and store in $t7
      	lw $t7, numRightGuesses 
      	add $t7, $t7, $v0 
      	sw $t7, numRightGuesses 

	#check if guess is not in word
     	beq $v0, $zero, wrong 
      	j endWrong 
      	
      	#since incorrect guess jump and link to incorrect
      	wrong:     
        jal incorrect  
        
        #get num of incorrect guesses
      	endWrong:  
      	lw $t0, numWrongGuesses 
      	beq $t0, 6, gameOver    #if out of guesses, branch to gameOver

	#if num of correct guesses is equal to length of word, brach to gotWord to claim winner
     	lw $t0, numRightGuesses   
      	lw $t1, numChars  
      	beq $t0, $t1, gotWord   

	#if not any of above, repeat round of another guess
      	j rounds 
      	
      	#exit
    	endRounds:
  	j exit 

#incorrect function adds body parts for each respective wrong guess
incorrect:

	#store incorrect guess in $t5 and
    	la $t6, noose  
    	lw $t7, numWrongGuesses	#get to increment 
    	addi $t5, $t6, 58  
    	add $t5, $t5, $t7  
    	sb $a0, 0($t5)     	#put new miss on the board 

   	#based on incorrect guesses number, branch to respective body part to hang
    	beq $t7, 0, head
    	beq $t7, 1, torso
    	beq $t7, 2, armOne
    	beq $t7, 3, armTwo
    	beq $t7, 4, legOne
    	beq $t7, 5, legTwo
    	j stopBodyBuild	#stop building if all parts are hung

	#head for first miss
    	head:
      	addi $t5, $t6, 41 
      	li $t4, 79        #store char code for head
      	sb $t4, 0($t5)    #store head char as 'O'
      	j stopBodyBuild
      	
      	#torso for second miss
    	torso:
      	addi $t5, $t6, 70 
      	li $t4, 124       #store char code for torso part1
      	sb $t4, 0($t5)    #store torso part1 char as '|'
      	addi $t5, $t6, 81 
      	li $t4, 124       #store char code for torso part2
      	sb $t4, 0($t5)    #store torso part2 char as '|'
      	j stopBodyBuild
      	
      	#left arm for third miss
    	armOne:
      	addi $t5, $t6, 69 
      	li $t4, 92        #store char code for left arm
      	sb $t4, 0($t5)    #store left arm char as '\'
      	j stopBodyBuild
      	
      	#right arm for fourth miss
    	armTwo:
      	addi $t5, $t6, 71 
      	li $t4, 47        #store char code for right arm
      	sb $t4, 0($t5)    #store right arm char as '/'
      	j stopBodyBuild
      	
      	#left leg for fifth miss
    	legOne:
      	addi $t5, $t6, 91 
      	li $t4, 47        #store char code for left leg
      	sb $t4, 0($t5)    #store left leg char as '/'
      	j stopBodyBuild
      	
      	#right leg for sixth miss
    	legTwo:
      	addi $t5, $t6, 93 
      	li $t4, 92        #store char code for left leg
      	sb $t4, 0($t5)    #store left leg char as '\'
      	j stopBodyBuild

    	stopBodyBuild:
	#increment $t7 as num of incorrect guesses and store back
    	addi $t7, $t7, 1 
    	sw $t7, numWrongGuesses 

  	endIncorrect:
  	jr $ra

#charGuess function gets character guess from user
charGuess:
	
	#prompt user for capitol letter guess    
    	la $a0, guess 
    	li $v0, 4 
    	syscall       

	#get capitol letter input and store into $t0
    	readGuess:
      	li $v0, 12    
      	syscall       
    	beq $v0, 10, readGuess #if current char is newLine, get next guessG
    	move $t0, $v0   

	#print guessed char
    	li $v0, 11   
    	li $a0, 10   
    	syscall
    	syscall      

	#check to make sure inputted char is a capitol letter
    	beq $t0, 48, exit 	
    	blt $t0, 65, badInput #if lower ascii number than 'A', branch to badInput
    	bgt $t0, 90, badInput #if higher ascii number than 'A', branch to badInput
    	j endCharGuess 	      #jump to end if input error

	#display a non-capitol letter was inputted
    	badInput:       
      	la $a0, badGuess 
      	li $v0, 4   
      	syscall           
      	j charGuess	#prompt for another guess

	#return char, then end getting char input
  	endCharGuess:
  	move $v0, $t0 
  	jr $ra       

#function shows the user's correct guesses made and forms word for each right guess
displayCorrectGuesses:

	
    	li $v0, 0  		#set return value count to 0
    	li $t0, 0  		#set iterator through word to 0
    	lw $t1, numChars 	#get length of correct word
    	la $t7, winningWord  	#get start of correct word to match against input
    	la $t6, noose  		#get start of correct letter guesses to display if correct
    
    	#for loop ends once reaches end of correct word
    	loop:
      	beq $t0, $t1, endValidity 
      	add $t2, $t0, $t7 	#$t2 is current char to put into $t3
      	lb $t3, 0($t2)    	
      	beq $t3, $a0, sameChar  #if input char matches current, branch to sameChar
      	j loopAgain   		#else loopAgain

	#put current char being checked into $t4 - char being matched from input
      	sameChar: 
        add $t2, $t6, 19 
        add $t2, $t2, $t0     
        lb $t4, 0($t2)   
        bne $t4, $t3, dontLoopAgain #if this char is display, branch to dontLoopAgain
        j loopAgain 		    #else loopAgain


	#increment count of correct guesses and reveal correct char guess in part of word
      	dontLoopAgain:
        addi $v0, $v0, 1 
        sb $t3, 0($t2)   

	#increment iterator and restart loop
    	loopAgain:
      	addi $t0, $t0, 1 
      	j loop   

    	endLooping:

endValidity:
	
	#done matching
  	jr $ra 


#player guessed correct word and won
gotWord:

	#print winning game layout   
    	la $a0, noose  
    	li $v0, 4  
    	syscall       

	#display winning statement to player and end game    
    	la $a0, correctWord
    	li $v0, 4    
    	syscall         
    	j exit         
    
#player ran out of guesses and lost	
gameOver:

	#display losing game layout    
    	la $a0, noose
    	li $v0, 4   
    	syscall       
  
  	#display losing statement to player and end game      
    	la $a0, hung
    	li $v0, 4 
    	syscall         
    	j exit         

exit:

	#quit game
  	li $v0, 10 
	syscall
		

#TIC-TAC-TOE portion			
TicTacToe:
	#welcome player to tic-tac-toe
	la $a0 opening
	li $v0 4
	syscall
	
	#display instructions to play
	la $a0 instructions
	li $v0 4
	syscall
	
	#tell players X will go first		
	la $a0 firstPlayer
	li $v0 4
	syscall

	#set all temporary registers to 0 to indicate if a move is made for each position
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0

	#set saved registers to 0 with $s5 as the counter for moves
	li $s0, 0
	li $s5, 0

	#load adresses for game board, getting moves, and claiming the winner
	la $s1, layout
	la $s2, movePrompt
	la $s3, winner

	#store user's marked positions on game board
	lb $a1, blank
	sb $a1, 14($s1)
	sb $a1, 18($s1)
	sb $a1, 22($s1)
	sb $a1, 40($s1)
	sb $a1, 44($s1)
	sb $a1, 48($s1)
	sb $a1, 66($s1)
	sb $a1, 70($s1)
	sb $a1, 74($s1)
			
#show the board to user
gameBoardLayout:

	#display game board
	li $v0, 4
	la $a0, layout
	syscall

	#if game board is full of moves jump to claim Tie
	beq $s5, 9, claimTie

	#else increment number of moves counter
	add $s5, $s5, 1

	#store remainder to ensure max number of moves not made yet and increment $s0
	rem $t0, $s0, 2
	add $s0, $s0, 1
	bnez $t0, SetO 	#branch to setO if remainder in t0 is not equal to 0

#load x for ready to display on board
SetX:

	#load x denotation into $a1
	lb $a1, placeX
	sb $a1, 7($s2)	#store for when player x is making a move
	sb $a1, 8($s3)	#store for when player x is winner
	j makeMoves

#load o for ready to display on board	
SetO:

	#load o denotation into $a1
	lb $a1, placeO
	sb $a1, 7($s2)	#store for when player o is making a move
	sb $a1, 8($s3)	#store for when player o is winner

#function gets move and branches to respective position to place it
makeMoves:

	#prompt user for move
	li $v0, 4
	la $a0, movePrompt
	syscall

	#get move from user and store contents into $v0
	li $v0, 5
	syscall
	move $s6, $v0

	#if move entered is one of the many positions, branch to its respective position to make move
	beq $s6, 11, pos11
	beq $s6, 12, pos12
	beq $s6, 13, pos13
	beq $s6, 21, pos21
	beq $s6, 22, pos22
	beq $s6, 23, pos23
	beq $s6, 31, pos31
	beq $s6, 32, pos32
	beq $s6, 33, pos33

	#since input didn't match any position above, display invalid move warning
	li $v0, 4
	la $a0, invalidWarning
	syscall
	j makeMoves

#function to place piece in respective inputted position
pos11:
	#if temporary registers are not equal to 0, branch to respective spot
	bnez $t1, positionTaken	#position is taken
	bnez $t0, placeO11	#or it's player o's turn

	#denote that player x has made a move and put into its position
	placeX11:
	li $t1, 1
	sb $a1, 14($s1)
	j validWinner	#check to see if move made is a winning move

	#denote that player o has made a move and put into its position
	placeO11:
	li $t1, 2
	sb $a1, 14($s1)
	j validWinner	#check to see if move made is a winning move

#function to place piece in respective inputted position
pos21:

	#if temporary registers are not equal to 0, branch to respective spot
	bnez $t2, positionTaken	#position is taken
	bnez $t0, placeO21	#or it's player o's turn

	#denote that player x has made a move and put into its position
	placeX21:
	li $t2, 1
	sb $a1, 18($s1)
	j validWinner	#check to see if move made is a winning move

	#denote that player o has made a move and put into its position
	placeO21:
	li $t2, 2
	sb $a1, 18($s1)
	j validWinner	#check to see if move made is a winning move
	
#function to place piece in respective inputted position
pos31:

	#if temporary registers are not equal to 0, branch to respective spot
	bnez $t3, positionTaken	#position is taken
	bnez $t0, placeO31	#or it's player o's turn

	#denote that player x has made a move and put into its position
	placeX31:
	li $t3, 1
	sb $a1, 22($s1)
	j validWinner	#check to see if move made is a winning move

	#denote that player o has made a move and put into its position
	placeO31:
	li $t3, 2
	sb $a1, 22($s1)
	j validWinner	#check to see if move made is a winning move

#function to place piece in respective inputted position
pos12:

	#if temporary registers are not equal to 0, branch to respective spot
	bnez $t4, positionTaken	#position is taken	
	bnez $t0, placeO12	#or it's player o's turn

	#denote that player x has made a move and put into its position
	placeX12:
	li $t4, 1
	sb $a1, 40($s1)
	j validWinner	#check to see if move made is a winning move

	#denote that player o has made a move and put into its position
	placeO12:
	li $t4, 2
	sb $a1, 40($s1)
	j validWinner	#check to see if move made is a winning move

#function to place piece in respective inputted position
pos22:

	#if temporary registers are not equal to 0, branch to respective spot
	bnez $t5, positionTaken	#position is taken
	bnez $t0, placeO22	#or it's player o's turn

	#denote that player x has made a move and put into its position
	placeX22:
	li $t5, 1
	sb $a1, 44($s1)
	j validWinner	#check to see if move made is a winning move

	#denote that player o has made a move and put into its position
	placeO22:
	li $t5, 2
	sb $a1, 44($s1)
	j validWinner	#check to see if move made is a winning move

#function to place piece in respective inputted position
pos32:

	#if temporary registers are not equal to 0, branch to respective spot
	bnez $t6, positionTaken	#position is taken
	bnez $t0, placeO32	#or it's player o's turn

	#denote that player x has made a move and put into its position
	placeX32:
	li $t6, 1
	sb $a1, 48($s1)
	j validWinner	#check to see if move made is a winning move

	#denote that player o has made a move and put into its position
	placeO32:
	li $t6, 2
	sb $a1, 48($s1)
	j validWinner	#check to see if move made is a winning move

#function to place piece in respective inputted position
pos13:

	#if temporary registers are not equal to 0, branch to respective spot
	bnez $t7, positionTaken	#position is taken
	bnez $t0, placeO13	#or it's player o's turn

	#denote that player x has made a move and put into its position
	placeX13:
	li $t7, 1
	sb $a1, 66($s1)
	j validWinner	#check to see if move made is a winning move

	#denote that player o has made a move and put into its position
	placeO13:
	li $t7, 2
	sb $a1, 66($s1)
	j validWinner	#check to see if move made is a winning move

#function to place piece in respective inputted position
pos23:

	#if temporary registers are not equal to 0, branch to respective spot
	bnez $t8, positionTaken	#position is taken
	bnez $t0, placeO23	#or it's player o's turn

	#denote that player x has made a move and put into its position
	placeX23:
	li $t8, 1
	sb $a1, 70($s1)
	j validWinner	#check to see if move made is a winning move

	#denote that player o has made a move and put into its position
	placeO23:
	li $t8, 2
	sb $a1, 70($s1)
	j validWinner	#check to see if move made is a winning move

#function to place piece in respective inputted position
pos33:

	#if temporary registers are not equal to 0, branch to respective spot
	bnez $t9, positionTaken	#position is taken
	bnez $t0, placeO33	#or it's player o's turn

	#denote that player x has made a move and put into its position
	placeX33:
	li $t9, 1
	sb $a1, 74($s1)
	j validWinner	#check to see if move made is a winning move

	#denote that player o has made a move and put into its position
	placeO33:
	li $t9, 2
	sb $a1, 74($s1)
	j validWinner	#check to see if move made is a winning move

#function to check if position inserted is occupied already
positionTaken:

	#position is taken so warn user and have user try again by jumping to makeMoves
	li $v0, 4
	la $a0, filledWarning
	syscall
	j makeMoves

#function to check if move inputted is a winning move of three in a row
validWinner:

	#based on player - if a winning move was made with three in a row, branch to claim winner
	and $s7, $t1, $t2	
	and $s7, $s7, $t3
	bnez $s7, claimWinner

	#based on player - if a winning move was made with three in a row, branch to claim winner
	and $s7, $t4, $t5
	and $s7, $s7, $t6
	bnez $s7, claimWinner

	#based on player - if a winning move was made with three in a row, branch to claim winner
	and $s7, $t7, $t8
	and $s7, $s7, $t9
	bnez $s7, claimWinner

	#based on player - if a winning move was made with three in a row, branch to claim winner
	and $s7, $t1, $t4
	and $s7, $s7, $t7
	bnez $s7, claimWinner

	#based on player - if a winning move was made with three in a row, branch to claim winner
	and $s7, $t2, $t5
	and $s7, $s7, $t8
	bnez $s7, claimWinner

	#based on player - if a winning move was made with three in a row, branch to claim winner
	and $s7, $t3, $t6
	and $s7, $s7, $t9
	bnez $s7, claimWinner

	#based on player - if a winning move was made with three in a row, branch to claim winner
	and $s7, $t1, $t5
	and $s7, $s7, $t9
	bnez $s7, claimWinner

	#based on player - if a winning move was made with three in a row, branch to claim winner
	and $s7, $t7, $t5
	and $s7, $s7, $t3
	bnez $s7, claimWinner
	
	#since the move made was not a winning move, jump back to gameBoardLayout to prompt next player for move
	j gameBoardLayout

#function to claim winner after three in a row
claimWinner:

	#display the winning board
	li $v0, 4
	la $a0, layout
	syscall

	#claim rightful player the winner
	li $v0, 4
	la $a0, winner
	syscall
	
	#jump to show choices user can make
	j Choices

#function to claim tie if no player got three in a row
claimTie:

	#display it is a tied game
	li $v0, 4
	la $a0, tiedGame
	syscall

#choices for player after first game ends - quit or play again
Choices:

	#list choices to user - play again =1 or quit=0
	li $v0, 4
	la $a0, choices
	syscall

	#if input read in is not equal to 0 (it's a 1), branch to play again
	li $v0, 5
	syscall
	bne $v0, 0, TicTacToe

	#else quit
	li $v0, 10
	syscall
	
##############################################################################################################################


#Test Entrance 1:

	#Enter '1' to play hangman or '0' to play tic-tac-toe: 1
	
	#You chose to play the player vs. computer game, Hangman! Great choice!
	#Instructions - you will enter your capitol letter guess each round to solve the word until you're hung.
	
	
#   [~~~~~]   Word: ______
#   [     |
#         |   Misses:        
#         |
#         |
#         |
#         |
# L~~~~~~~~]

	#Enter your capital letter guess or '0' to quit: L


#   [~~~~~]   Word: ______
#   [     |
#   O     |   Misses:L       
#         |
#         |
#         |
#         |
# L~~~~~~~~]

	#Enter your capital letter guess or '0' to quit: K


#   [~~~~~]   Word: ______
#   [     |
#   O     |   Misses:LK      
#   |     |
#   |     |
#         |
#         |
# L~~~~~~~~]

	#Enter your capital letter guess or '0' to quit: J


#   [~~~~~]   Word: __J___
#   [     |
#   O     |   Misses:LK      
#   |     |
#   |     |
#         |
#         |
# L~~~~~~~~]

	#Enter your capital letter guess or '0' to quit: O


#   [~~~~~]   Word: _OJ___
#   [     |
#   O     |   Misses:LK      
#   |     |
#   |     |
#         |
#         |
# L~~~~~~~~]

	#Enter your capital letter guess or '0' to quit: H


#   [~~~~~]   Word: _OJ___
#   [     |
#   O     |   Misses:LKH     
#  \|     |
#   |     |
#         |
#         |
# L~~~~~~~~]

#Enter your capital letter guess or '0' to quit: U


#   [~~~~~]   Word: _OJ___
#   [     |
#   O     |   Misses:LKHU    
#  \|/    |
#   |     |
#         |
#         |
# L~~~~~~~~]

	#Enter your capital letter guess or '0' to quit: Y


#   [~~~~~]   Word: _OJ___
#   [     |
#   O     |   Misses:LKHUY   
#  \|/    |
#   |     |
#  /      |
#         |
# L~~~~~~~~]

	#Enter your capital letter guess or '0' to quit: G


#   [~~~~~]   Word: _OJ___
#   [     |
#   O     |   Misses:LKHUYG  
#  \|/    |
#   |     |
#  / \    |
#         |
# L~~~~~~~~]

	#YOU'RE HUNG! You guessed incorrectly too many times - you lost!!!
	
##############################################################################################################################
	
#Test Entrace 2:

#Enter '1' to play hangman or '0' to play tic-tac-toe: 0


#You chose to play the player vs. player game, Tic-Tac-Toe! Great choice!
#Instructions - players will enter the column (top #s) and row (left side #s) of where they want to place their piece.
#Player X will make the first move!

#  1   2   3
#1   |   |   
# ---+---+---
#2   |   |   
# ---+---+---
#3   |   |   

#Player X, please enter your column and row placement WITHOUT SPACES: 11
#  1   2   3
#1 X |   |   
# ---+---+---
#2   |   |   
# ---+---+---
#3   |   |   

#Player O, please enter your column and row placement WITHOUT SPACES: 22
#  1   2   3
#1 X |   |   
# ---+---+---
#2   | O |   
# ---+---+---
#3   |   |   

#Player X, please enter your column and row placement WITHOUT SPACES: 31
#  1   2   3
#1 X |   | X 
# ---+---+---
#2   | O |   
# ---+---+---
#3   |   |   

#Player O, please enter your column and row placement WITHOUT SPACES: 12
#  1   2   3
#1 X |   | X 
# ---+---+---
#2 O | O |   
# ---+---+---
#3   |   |   

#Player X, please enter your column and row placement WITHOUT SPACES: 33
#  1   2   3
#1 X |   | X 
# ---+---+---
#2 O | O |   
# ---+---+---
#3   |   | X 

#Player O, please enter your column and row placement WITHOUT SPACES: 32
#  1   2   3
#1 X |   | X 
# ---+---+---
#2 O | O | O 
# ---+---+---
#3   |   | X 


#Player O is the WINNER!!! That concludes the game.

#Enter '1' to play again or '0' to quit: 0

##############################################################################################################################
	
#Test Entrance 3:	

#Enter '1' to play hangman or '0' to play tic-tac-toe: 1


#You chose to play the player vs. computer game, Hangman! Great choice!
#Instructions - you will enter your capitol letter guess each round to solve the word until you're hung.

#   [~~~~~]   Word: ______
#   [     |
#         |   Misses:        
#         |
#         |
#         |
#         |
# L~~~~~~~~]

#Enter your capital letter guess or '0' to quit: P


#   [~~~~~]   Word:P______
#   [     |
#         |   Misses:        
#         |
#         |
#         |
#         |
# L~~~~~~~~]

#Enter your capital letter guess or '0' to quit: R


#   [~~~~~]   Word:PR_____
#   [     |
#         |   Misses:        
#         |
#         |
#         |
#         |
# L~~~~~~~~]

#Enter your capital letter guess or '0' to quit: O


#   [~~~~~]   Word:PRO____
#   [     |
#         |   Misses:        
#         |
#         |
#         |
#         |
# L~~~~~~~~]

#Enter your capital letter guess or '0' to quit: J


#   [~~~~~]   Word:PROJ___
#   [     |
#         |   Misses:        
#         |
#         |
#         |
#         |
# L~~~~~~~~]

#Enter your capital letter guess or '0' to quit: E


#   [~~~~~]   Word:PROJE__
#   [     |
#         |   Misses:        
#         |
#         |
#         |
#         |
# L~~~~~~~~]

#Enter your capital letter guess or '0' to quit: C


#   [~~~~~]   Word:PROJEC_
#   [     |
#         |   Misses:        
#         |
#         |
#         |
#         |
# L~~~~~~~~]

#Enter your capital letter guess or '0' to quit: O


#   [~~~~~]   Word:PROJECT
#   [     |
#         |   Misses:        
#         |
#         |
#         |
#         |
# L~~~~~~~~]

#HOORAY! You guessed the word correctly - you win!!!
	
	
##############################################################################################################################
	
	
	
	
	
	
