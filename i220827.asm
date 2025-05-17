include irvine32.inc
include macros.inc

.386
.model flat, stdcall
.stack 4096


BUFFER_SIZE = 501

ExitProcess proto, dwExitCode:dword

;terminal height: 29
;terminal width: 119

.data
	
	str1 BYTE "Cannot create file ", 0
    str2 BYTE ", ", 0
    str3 BYTE ", ", 0
    str4 BYTE "\r\n", 0
	filename BYTE "highscores.txt", 0
    fileHandle HANDLE ?
    score DWORD ?
    level BYTE ?
    buffer BYTE 100 DUP(?) ; Adjust the size as needed
	exit_command db "Exited",0

	

	;WELCOME PAGE DATA

	screen1_welcome1 db   "                       .     .     .  .______  .          ______      _____   .        .  .______  ",10,
	                      "                       |    / \    |  |        |         /      \    /     \  |\      /|  |        ",10,
						  "                       |   /   \   |  |        |        |           |       | | \    / |  |        ",10,0
	screen1_welcome2 db	  "                       |  /     \  |  |----    |        |           |       | |  \  /  |  |-----   ",10,
					      "                       | /       \ |  |        |        |           |       | |   \/   |  |        ",10,
					      "                       |/         \|  |______  |_______  \______/    \_____/  |        |  |______  ",10,10,0
	screen1_to db         "                                                         ___  _                                     ",10,
						  "                                                          |  | |                                    ",10,
						  "                                                          '  '-'                                    ",10,10,0 
	screen1_pacman1 db    "                          _______    _______     ______     __      __   _______    ___      _        ",10, 
					      "                         |  ___  |  |  ___  |   /      \   |  \    /  | |  ___  |  |   \    | |       ",10,
					      "                         | |   | |  | |   | |  |    0  /   |   \  /   | | |   | |  | |\ \   | |       ",10,0
	screen1_pacman2 db    "                         | |___| |  | |___| |  |      /    | |\ \/ /| | | |___| |  | | \ \  | |       ",10,
					      "                         |  _____|  |  ___  |  |      \    | | \__/ | | |  ___  |  | |  \ \ | |       ",10,
					      "                         | |        | |   | |  |       \   | |      | | | |   | |  | |   \ \| |       ",10,
					      "                         |_|        |_|   |_|   \______/   |_|      |_| |_|   |_|  |_|    \___|       ",10,0
	screen1_entername db  "Enter Player Name: ",0
	screen1_username db   30 dup (?)

	;MENU SCREEN DATA

	screen2_menu db "               PRESS DESIRED NUMBER TO PROCEED!",0
	screen2_ghost1 db "               ___ ",10,"              /~ ~\",10,"              | 1 |    ENTER GAME",10,"              ",34,34,34,34,34,0
	screen2_ghost2 db "               ___ ",10,"              /~ ~\",10,"              | 2 |    READ INSTRUCTIONS",10,"              ",34,34,34,34,34,0
	screen2_ghost3 db "               ___ ",10,"              /~ ~\",10,"              | 3 |    HIGHSCORES",10,"              ",34,34,34,34,34,0
	screen2_ghost4 db "               ___ ",10,"              /~ ~\",10,"              | 4 |    EXIT",10,"              ",34,34,34,34,34,0
	screen2_choice db ?

	;INSTRUCTIONS SCREEN

	screen3_ins db "INSTRUCTIONS: ",0 
	screen3_obj db "OBJECTIVES:",10,10,0
	screen3_obj1 db "                     Explore the mazes of terror!",10,"                     Achieve the highest score possible!",10,"                     Become the ultimate PACMAN!",10,10,0
	screen3_obj2 db "                     Navigate through walls.",10,"                     Collect dots and fruit to gain score.",10,"                     Avoid ghosts to not loose lives.",10,"                     Get Pelet to pull an uno reverse on ghosts.",10,0
	screen3_ghost db "GHOST  CHARACTER / NICKNAME",0
	screen3_ghost1 db "     -SHADOW    'BLINKY'",0
	screen3_ghost2 db "     -SPEEDY    'PINKY'",0
	screen3_ghost3 db "     -BASHFUL   'INKY'",0
	screen3_ghost4 db "     -POKEY     'CLYDE'",0
	screen3_eat db "EAT     NAME       POINTS ",0
	screen3_dot db ".      DOT        10  PTS",0
	screen3_pelet db "0      PELET      50  PTS",0
	screen3_cherry db "8      CHERRY     100 PTS",0
	screen3_afraid db "AFRAID GHOSTS: 300+PTS ",0
	screen3_controls db "CONTROLS:     |W|",10,10,"                                   |A| |S| |D|",10,0 
	
	;GAME DATA
	row_level1 db "################################################################################",10
         db "#..............................................................................#",10 ;78
         db "#.###############.##########.##########.###########.##########.###############.#",10 ;7
         db "#.#             #.#        #.#        #.#         #.#        #.#             #.#",10 ;7
         db "#.#             #.#        #.##########.###########.#        #.#             #.#",10 ;7
         db "#.#             #.##########........................##########.#             #.#",10 ;28
         db "#.#             #............######################............#             #.#",10 ;26
         db "#.#             #.############                    ############.#             #.#",10 ;4
         db "#.###############.#                                          #.###############.#",10 ;4
         db "#.................############################################.................#",10 ;34
		 db "#.###############..............................................###############.#",10 ;48
         db "#.#             #.******.*******.####### ######.#*****#.******.#             #.#",10 ;8
         db "#.#             #.*####*.*#####*.#     # #    #.*#####*.####*#.#             #.#",10 ;8
         db "#.#             #.*####*.#*****#.#     # #    #.####**#.###*##.#             #.#",10 ;8
         db "#.#             #.*####*.*#####*.#     # #    #.##**###.##*###.#             #.#",10 ;8
         db "#.#             #.******.*******.##############.*******.#*####.#             #.#",10 ;8
         db "#.#             #..............................................#             #.#",10 ;48
         db "#.###############.######.########.####.#.#.####.#######.######.###############.#",10 ;11
         db "#........................#      #.#  #.#.#.#  #.#     #........................#",10 ;53
         db "#.######################.#      #.#  #.#.#.#  #.#     #.######################.#",10 ;9
         db "#.#                    #.#      #.#  #.#.#.#  #.#     #.#                    #.#",10 ;9
         db "#.######################.########.####.#.#.####.#######.######################.#",10 ;9
         db "#..............................................................................#",10 ;78
         db "################################################################################",10,0 ;500

	row_level2 db "################################################################################",10
         db "#..............................................................................#",10
         db "#.###############.##########.##########.###########.##########.###############.#",10
         db "#.#  #########  #.#        #..........#.#...........#        #.#  #########  #.#",10
         db "#.#  #.......#  #.#        #.########.#.#.#########.#        #.#  #.......#  #.#",10
         db "#.#  #.#####.#  #.##########.##..................##.##########.#  #.#####.#  #.#",10
         db "#.####.#   #.#  #...............################...............#  #.#   #.####.#",10
         db "#......#   #.#  #.########.####.#              #.####.########.#  #.#   #......#",10
         db "#.####.#   #.#  #.########.####.################.####.########.#  #.#   #.####.#",10
         db "#.#  #.#  ##.####..............................................####.##  #.#  #.#",10
         db "#.#  #.####.......******.*******.####### ######.#*****#.******.......####.#  #.#",10
         db "#.#  #......#####.*####*.*#####*.#     # #    #.*#####*.####*#.#####......#  #.#",10
         db "#.#  #.######   #.*####*.#*****#.#     # #    #.####**#.###*##.#   ######.#  #.#",10
         db "#.####.#####    #.*####*.*#####*.#     # #    #.##**###.##*###.#    #####.####.#",10
         db "#..........#    #.******.*******.##############.*******.#*####.#    #..........#",10
         db "#.########.#    #..............................................#    #.########.#",10
         db "#.#      #.#    #.######.########.####.###.####.#######.######.#    #.#      #.#",10
         db "#.#   ####.######.######.#      #.#....###....#.#     #.######.######.####   #.#",10
         db "#.#####..................#      #.#.##.###.##.#.#     #..................#####.#",10
         db "#.......################.#      #.#.##.. ..##.#.#     #.################.......#",10
         db "#.#####....#     #.......#      #.#....###....#.#     #.......#     #....#####.#",10
         db "#.########.#######.##############.####.###.####.#############.#######.########.#",10
         db "#..............................................................................#",10 ;640
         db "################################################################################",10,0
	
	row_level3 db "#################^############################################^#################",10
         db "#..............................................................................#",10
         db "#.###############.##########.##########.###########.##########.###############.#",10
         db "#.#  #########  #.#        #..........#.#...........#        #.#  #########  #.#",10
         db "#.#  #.......#  #.#        #.########X#.#X#########.#        #.#  #.......#  #.#",10
         db "#.#  #.#####.#  #.##########.##..................##.##########.#  #.#####.#  #.#",10
         db "#.####.#   #.#  #...............################...............#  #.#   #.####.#",10
         db "<......#   #.#  #.########.####.#              #.####.########.#  #.#   #......>",10
         db "#.####.#   #.#  #.########.####.################.####.########.#  #.#   #.####.#",10
         db "#.#  #.#  ##.####..............................................####.##  #.#  #.#",10
         db "#.#  #.####.......******.*******.####### ######.#*****#.******.......####.#  #.#",10
         db "#.#  #......#####.*####*.*#####*.#     # #    #.*#####*.####*#.#####......#  #.#",10
         db "#.#  #.######   #.*####*.#*****#.#     # #    #.####**#.###*##.#   ######.#  #.#",10
         db "#.####.#####    #.*####*.*#####*.#     # #    #.##**###.##*###.#    #####.####.#",10
         db "<..........#    #.******.*******.##############.*******.#*####.#    #..........>",10
         db "#.########.#    #..............................................#    #.########.#",10
         db "#.#      #.#    #.######.########.####X###X####.#######.######.#    #.#      #.#",10
         db "#.#   ####.######.######.#      #.#....###....#.#     #.######.######.####   #.#",10
         db "#.#####..................#      #.#.##.###.##.#.#     #..................#####.#",10
         db "#.......################.#      #.#.##.. ..##.#.#     #.################.......#",10
         db "#.#####....#     #.......#      #.#....###....#.#     #.......#     #....#####.#",10
         db "#.########X#######.##############.####.###.####.#############.#######X########.#",10
         db "#..............................................................................#",10
         db "################################################################################",10,0 ;634

	row1 db 24 dup (81 dup (?)) 

	;PACMAN DATA

	pac_x db 40
	pac_y db 19

	inputKey db ?
	collision db 0

	;BLINKY DATA
	bli_tx db 0
	bli_ty db 0
	bli_x db 40
	bli_y db 13
	blinkyDir db 'w'
	blinkyRC db 1
	blinkyLC db 1
	blinkyUC db 1
	blinkyDC db 1
	blinkyDistanceUp dd ?
	blinkyDistanceDown dd ?
	blinkyDistanceLeft dd ?
	blinkyDistanceRight dd ?

	;PINKYDATA
	pin_tx db 0
	pin_ty db 0
	pin_x db 40
	pin_y db 13
	pinkyDir db 'w'
	pinkyRC db 1
	pinkyLC db 1
	pinkyUC db 1
	pinkyDC db 1
	pinkyDistanceUp dd ?
	pinkyDistanceDown dd ?
	pinkyDistanceLeft dd ?
	pinkyDistanceRight dd ?

	;INKYDATA
	ink_tx db 0
	ink_ty db 0
	ink_x db 40
	ink_y db 13
	inkyDir db 'w'
	inkyRC db 1
	inkyLC db 1
	inkyUC db 1
	inkyDC db 1
	inkyDistanceUp dd ?
	inkyDistanceDown dd ?
	inkyDistanceLeft dd ?
	inkyDistanceRight dd ?

	;CLYDEDATA
	cly_tx db 0
	cly_ty db 0
	cly_x db 40
	cly_y db 13
	clydeDir db 'w'
	clydeRC db 1
	clydeLC db 1
	clydeUC db 1
	clydeDC db 1
	clydeDistanceUp dd ?
	clydeDistanceDown dd ?
	clydeDistanceLeft dd ?
	clydeDistanceRight dd ?

	;DEATH DATA
	blinkyON db ?
	pinkyON db ?
	inkyON db ?
	clydeON db ?
	lives db 3
	livesicon db "<3<3<3",0
	livesprompt db "Lives: ",0


	;AFRAID STATE
	afraid db ?
	afraid_timer db ?
	afraidblinkyty db 0
	afraidblinkytx db 80
	afraidpinkytx db 0
	afraidpinkyty db 25
	afraidinkytx db 0
	afraidinkyty db 0
	afraidclydetx db 80
	afraidclydety db 25
	pelet_x db ?
	pelet_y db ?
	numberofpelets db 4 

	;FRUIT
	fruit_x db ?
	fruit_y db ?
	numberoffruits db 10 

	outer dd ?

	currentlevel db ?
	dotseaten dw ?
	scoreStr BYTE 10 DUP(?)

	;DELAY AND SPEED DATA
	ghostouttimer db ?
	ghostspeedtimer db ?
	pacmanspeedtimer db ?
	afraidtimer dd ?

	;LEVEL1 SCORE = 3680

	;FILEHANDLING
	


.code
main PROC
	call welcomeScreen

	menu:
	call menuScreen
	;checking which menu option is selected
	cmp screen2_choice, 2
	je instructions_jump
	jne rest

	instructions_jump:
	call instructions
	jmp menu

	rest:
	mov eax, white + (black*16)
	call settextcolor
	mov dl, 0
	mov dh, 29
	call gotoXY
	mov edx, offset exit_command
	call writestring

	cmp screen2_choice, 1
	jne quit
	gamestart:
	;call level1
	;call level2
	call level3

	cmp lives, 0
	je oh_no
	
	call won_game
	jmp menu1

	oh_no:
	call lost_game

	menu1:
	call AppendHighScore

	quit:
	invoke ExitProcess, 0

main ENDP

level1 proc
	mov currentlevel, 1
    call clrscr

	mov esi, offset row_level1
	call initializerow1

	call drawMaze

	call updatelives
	call updateScore
	call drawplayer

	gameLoop:
		cmp dotseaten, 500 
		jge level1finish
		cmp ghostouttimer, 15
		je unlocked
		inc ghostouttimer
		unlocked:
		inc ghostspeedtimer
		cmp ghostspeedtimer, 2 ;ghostspeed
		jne ghostspeedlabel
		cmp ghostouttimer, 5
		jl blinkylocked
		call BlinkyMove
		blinkylocked:
		cmp ghostouttimer, 15
		jne pinkylocked
		call PinkyMove
		pinkylocked:
		mov al, 0
		mov ghostspeedtimer, al
		ghostspeedlabel:
		inc pacmanspeedtimer
		cmp pacmanspeedtimer, 1 ;pacmanspeed
		jne gameloop
		mov al, 0
		mov pacmanspeedtimer, al
		call setNotAfraid
		call readkey
		jne takeinput
		call checkdeath
		cmp lives, 0
		je died

		processKey:

		mov eax, 50
		call Delay


		cmp inputKey, 'w'
		je upwards

		cmp inputKey, 'd'
		je rightwards

		cmp inputKey, 'a'
		je leftwards

		cmp inputKey, 's'
		je downwards

		

	jmp gameLoop

	takeinput:
    mov inputKey, al
	jmp processKey

	upwards:
    ; Handle 'w' key press
	call checkCollisionUp
	cmp collision, 1
	je keyHandled
	call updatePlayer
    dec pac_y
	call drawplayer
    jmp keyHandled

	rightwards:
	call checkCollisionRight
	cmp collision, 1
	je keyHandled
	call updatePlayer
    inc pac_x
	call drawplayer
    jmp keyHandled

	leftwards:
	call checkCollisionLeft
	cmp collision, 1
	je keyHandled
	call updatePlayer
    ; Handle 'a' key press
    dec pac_x
	call drawplayer
    jmp keyHandled

	downwards:
	call checkCollisionDown
	cmp collision, 1
	je keyHandled
	call updatePlayer
    ; Handle 's' key press
    inc pac_y
	call drawplayer

	keyHandled:
    ; Continue with game logic\

    jmp gameLoop
	
	mov dh, 25
	mov dl, 0
	call gotoxy
	call waitmsg

	level1finish:
	mov ghostouttimer, 0
	mov ghostspeedtimer, 0
	mov pacmanspeedtimer, 0
	mov dotseaten, 0
	mov lives, 3
	ret

	died:
	ret
ret
level1 endp

level2 proc
	;mov edx, offset row1
	;call writestring
	
	mov currentlevel, 2
	call resetchars

	call clrscr

	mov esi, offset row_level2
	call initializerow1

	call addfruit
	call drawMaze
	
	call updatelives
	call updateScore
	call drawplayer
	call drawPinky
	call drawBlinky

	gameLoop:
		cmp dotseaten, 640
		jge level2finish
		cmp ghostouttimer, 15
		je unlocked
		inc ghostouttimer
		unlocked:
		inc ghostspeedtimer
		cmp ghostspeedtimer, 2 ;ghostspeed
		jne ghostspeedlabel
		cmp ghostouttimer, 5
		jl blinkylocked
		call BlinkyMove
		blinkylocked:
		cmp ghostouttimer, 15
		jne pinkylocked
		call PinkyMove
		pinkylocked:
		mov al, 0
		mov ghostspeedtimer, al
		ghostspeedlabel:
		inc pacmanspeedtimer
		cmp pacmanspeedtimer, 1 ;pacmanspeed
		jne gameloop
		mov al, 0
		mov pacmanspeedtimer, al
		call setNotAfraid
		call readkey
		jne takeinput
		call checkdeath
		cmp lives, 0
		je died

		processKey:

		mov eax, 50
		call Delay


		cmp inputKey, 'w'
		je upwards

		cmp inputKey, 'd'
		je rightwards

		cmp inputKey, 'a'
		je leftwards

		cmp inputKey, 's'
		je downwards

		

	jmp gameLoop

	takeinput:
    mov inputKey, al
	jmp processKey

	upwards:
    ; Handle 'w' key press
	call checkCollisionUp
	cmp collision, 1
	je keyHandled
	call updatePlayer
    dec pac_y
	call drawplayer
    jmp keyHandled

	rightwards:
	call checkCollisionRight
	cmp collision, 1
	je keyHandled
	call updatePlayer
    inc pac_x
	call drawplayer
    jmp keyHandled

	leftwards:
	call checkCollisionLeft
	cmp collision, 1
	je keyHandled
	call updatePlayer
    ; Handle 'a' key press
    dec pac_x
	call drawplayer
    jmp keyHandled

	downwards:
	call checkCollisionDown
	cmp collision, 1
	je keyHandled
	call updatePlayer
    ; Handle 's' key press
    inc pac_y
	call drawplayer

	keyHandled:
    ; Continue with game logic\

    jmp gameLoop
	
	mov dh, 25
	mov dl, 0
	call gotoxy
	call waitmsg

	level2finish:
	mov ghostouttimer, 0
	mov ghostspeedtimer, 0
	mov pacmanspeedtimer, 0
	mov dotseaten, 0
	mov lives, 3
	ret

	died:
	ret
ret
level2 ENDP

level3 proc
	;mov edx, offset row1
	;call writestring

	
	mov currentlevel, 3
	call resetchars

	call clrscr

	mov esi, offset row_level3
	call initializerow1

	call addfruit
	call addpelets
	call drawMaze
	
	call updatelives
	call updateScore
	call drawplayer
	call drawPinky
	call drawBlinky
	call drawInky

	gameLoop:
		cmp afraidtimer, 350
		jg afraidnomore
		inc afraidtimer
		jmp stillafraid
		afraidnomore:
		mov afraidtimer, 0
		mov afraid, 0

		stillafraid:
		cmp dotseaten, 634
		jge level3finish

		cmp ghostouttimer, 50
		je unlocked
		inc ghostouttimer
		unlocked:
		inc ghostspeedtimer
		cmp ghostspeedtimer, 2 ;ghostspeed
		jne ghostspeedlabel
		cmp ghostouttimer, 5
		jl blinkylocked
		call BlinkyMove
		blinkylocked:
		cmp ghostouttimer, 15
		jl pinkylocked
		call PinkyMove
		pinkylocked:
		cmp ghostouttimer, 30
		jl inkylocked
		call inkyMove
		inkyLocked:
		cmp ghostouttimer, 50
		jl clydelocked
		call clydeMove
		clydeLocked:


		mov al, 0
		mov ghostspeedtimer, al
		ghostspeedlabel:
		inc pacmanspeedtimer
		cmp pacmanspeedtimer, 1 ;pacmanspeed
		jne gameloop
		mov al, 0
		mov pacmanspeedtimer, al
		call setNotAfraid
		cmp afraid, 1
		jne ghostsnotafraid
		call setAfraid
		ghostsnotafraid:
		call readkey
		jne takeinput
		call checkdeath
		cmp lives, 0
		je died

		processKey:

		mov eax, 100
		call Delay


		cmp inputKey, 'w'
		je upwards

		cmp inputKey, 'd'
		je rightwards

		cmp inputKey, 'a'
		je leftwards

		cmp inputKey, 's'
		je downwards

	jmp gameLoop

	takeinput:
    mov inputKey, al
	jmp processKey

	upwards:
    ; Handle 'w' key press
	call checkCollisionUp
	cmp collision, 1
	je keyHandled
	call updatePlayer
    dec pac_y
	call drawplayer
    jmp keyHandled

	rightwards:
	call checkCollisionRight
	cmp collision, 1
	je keyHandled
	call updatePlayer
    inc pac_x
	call drawplayer
    jmp keyHandled

	leftwards:
	call checkCollisionLeft
	cmp collision, 1
	je keyHandled
	call updatePlayer
    ; Handle 'a' key press
    dec pac_x
	call drawplayer
    jmp keyHandled

	downwards:
	call checkCollisionDown
	cmp collision, 1
	je keyHandled
	call updatePlayer
    ; Handle 's' key press
    inc pac_y
	call drawplayer

	keyHandled:
    ; Continue with game logic\

    jmp gameLoop
	
	mov dh, 25
	mov dl, 0
	call gotoxy
	call waitmsg

	level3finish:
	mov lives, 3
	ret

	died:
ret
level3 ENDP

initializerow1 proc
	mov ecx, 1944
	mov edi, offset row1

	initloop:
		mov al, [esi]
		mov [edi], al
		inc esi
		inc edi
	loop initloop

ret
initializerow1 endp

checkdeath proc
	;Blinky
	mov al, bli_x
	cmp al, pac_x
	je blinkyADDx
	blinkyYdeath:
	mov al, bli_y
	cmp al, pac_y
	je blinkyAdd
	mov blinkyON, 0
	jmp blinkynokill

	blinkyADDx:
	inc blinkyON
	jmp BlinkyYdeath

	blinkyADD:
	inc blinkyON
	cmp blinkyON, 2
	jne blinkynokill

	died: 
	cmp afraid, 1
	je blinkydie
	mov blinkyON, 0
	dec lives
	call updatelives
	mov pac_x, 40
	mov pac_y, 19

	blinkydie:
	mov blinkyON, 0
	add score, 300
	mov bli_x, 40
	mov bli_y, 13
	ret

	blinkynokill:
	mov blinkyON, 0

	;Pinky
	mov al, pin_x
	cmp al, pac_x
	je pinkyADDx
	pinkyYdeath:
	mov al, pin_y
	cmp al, pac_y
	je pinkyAdd
	mov pinkyON, 0
	jmp pinkynokill

	pinkyADDx:
	inc pinkyON
	jmp pinkyYdeath

	pinkyADD:
	inc pinkyON
	cmp pinkyON, 2
	jne pinkynokill

	diedp: 
	cmp afraid, 1
	je pinkydie
	mov pinkyON, 0
	dec lives
	call updatelives
	mov pac_x, 40
	mov pac_y, 19

	pinkydie:
	mov pinkyON, 0
	add score, 400
	mov pin_x, 40
	mov pin_y, 13
	ret

	pinkynokill:
	mov pinkyON, 0

	;inky
	mov al, ink_x
	cmp al, pac_x
	je inkyADDx
	inkyYdeath:
	mov al, ink_y
	cmp al, pac_y
	je inkyAdd
	mov inkyON, 0
	jmp inkynokill

	inkyADDx:
	inc inkyON
	jmp inkyYdeath

	inkyADD:
	inc inkyON
	cmp inkyON, 2
	jne inkynokill

	diedi: 
	cmp afraid, 1
	je inkydie
	mov inkyON, 0
	dec lives
	call updatelives
	mov pac_x, 40
	mov pac_y, 19

	inkydie:
	mov inkyON, 0
	add score, 500
	mov ink_x, 40
	mov ink_y, 13
	ret

	inkynokill:
	mov inkyON, 0

	;clyde
	mov al, cly_x
	cmp al, pac_x
	je clydeADDx
	clydeYdeath:
	mov al, cly_y
	cmp al, pac_y
	je clydeAdd
	mov clydeON, 0
	jmp clydenokill

	clydeADDx:
	inc clydeON
	jmp clydeYdeath

	clydeADD:
	inc clydeON
	cmp clydeON, 2
	jne clydenokill

	diedc: 
	cmp afraid, 1
	je clydedie
	mov clydeON, 0
	dec lives
	call updatelives
	mov pac_x, 40
	mov pac_y, 19

	clydedie:
	mov clydeON, 0
	add score, 600
	mov cly_x, 40
	mov cly_y, 13
	ret

	clydenokill:
	mov clydeON, 0
ret
checkdeath endp

setnotafraid proc
	mov al, pac_x
	mov bli_tx, al
	mov al, pac_y
	mov bli_ty, al

	mov al, pac_x
	mov pin_tx, al
	mov al, pac_y
	add al, 7
	mov pin_ty, al

	mov al, pac_x
	add al, 10
	mov ink_tx, al
	mov al, pac_y
	sub al, 7
	mov ink_ty, al

	mov al, pac_x
	add al, 20
	mov cly_tx, al
	mov al, pac_y
	add al, 10 
	mov cly_ty, al

ret
setnotafraid endp

setafraid proc
	mov al, afraidblinkytx
	mov bli_tx, al
	mov al, afraidblinkyty
	mov bli_ty, al

	mov al, afraidpinkytx
	mov pin_tx, al
	mov al, afraidpinkyty
	mov pin_ty, al

	mov al, afraidinkytx
	mov ink_tx, al
	mov al, afraidinkyty
	mov ink_ty, al

	mov al, afraidclydetx
	mov cly_tx, al
	mov al, afraidclydety
	mov cly_ty, al

ret
setafraid endp

addpelets proc
	movzx ecx, numberofpelets

	peletgenerator:
		call Randomize
		mov eax, 78
		call randomRange
		inc eax
		mov pelet_x, al
		mov eax, 22
		call randomRange
		inc eax
		mov pelet_y, al

		movzx esi, pelet_x   ; x coordinate
		movzx edx, pelet_y   ; y coordinate
		mov ebx, 81           ; assuming each row has a width of 81 characters (adjust if needed)

		; Calculate index: index = y * width + x
		imul edx, ebx         ; edx = y * width
		add edx, esi          ; edx = y * width + x

		; Load the character at the specified index
		mov al, [row1 + edx]

		; Check if the character is a '.'
		cmp al, '.'
		je dotFound

		dotNotFound:
		; Continue with your code here
		jmp peletgenerator

		dotFound:
		; Code to handle the case when a '.' is found
		mov al, '0'
		mov [row1 + edx], al

	loop peletgenerator
ret
addpelets endp

addfruit proc
	movzx ecx, numberoffruits

	fruitgenerator:
		call Randomize
		mov eax, 78
		call randomRange
		inc eax
		mov fruit_x, al
		mov eax, 22
		call randomRange
		inc eax
		mov fruit_y, al

		movzx esi, fruit_x   ; x coordinate
		movzx edx, fruit_y   ; y coordinate
		mov ebx, 81           ; assuming each row has a width of 81 characters (adjust if needed)

		; Calculate index: index = y * width + x
		imul edx, ebx         ; edx = y * width
		add edx, esi          ; edx = y * width + x

		; Load the character at the specified index
		mov al, [row1 + edx]

		; Check if the character is a '.'
		cmp al, '.'
		je dotFound

		dotNotFound:
		; Continue with your code here
		jmp fruitgenerator

		dotFound:
		; Code to handle the case when a '.' is found
		mov al, '8'
		mov [row1 + edx], al

	loop fruitgenerator

ret
addfruit endp

drawMaze proc
	mov eax, 81
	mov bl, 25
	mul bl
	mov ecx, eax
	mov esi, offset row1

	drawloop:
    mov bl, [esi]

    cmp bl, "#"
    je printWall

	cmp bl, '0'
	je printpelet

	cmp bl, '8'
	je printred

	cmp bl, 'X'
	je printcross

    jmp simple

printWall:
    mov eax, blue
    call settextcolor
    mov al, [esi]
    call writechar
    jmp nextCharacter

printpelet:
	mov eax, lightgreen
    call settextcolor
    mov al, [esi]
    call writechar
    jmp nextCharacter

printred:
	mov eax, red
    call settextcolor
    mov al, [esi]
    call writechar
    jmp nextCharacter

printcross:
	mov eax, lightblue
    call settextcolor
    mov al, [esi]
    call writechar
    jmp nextCharacter

simple:
    mov al, [esi]
    call writechar
    jmp nextCharacter

nextCharacter:
    mov eax, white + (black * 16)
    call settextcolor
    inc esi
    loop drawloop

ret
drawMaze endp

drawplayer proc
	mov dl, pac_x
	mov dh, pac_y
	call gotoxy
	mov al, 'P'
	call writechar
ret
drawplayer endp

updatelives proc
	cmp lives, 0
	je endgame

	mov eax, white + (red*16)
	call settextcolor
	mov esi, offset livesicon
	movzx ecx, lives

	mov dl, 85
	mov dh, 2
	call gotoxy

	mov edx, offset livesprompt
	call writestring

	drawlives:
		mov al, [esi]
		call writechar
		inc esi
		mov al, [esi]
		call writechar
		inc esi
	loop drawlives

	mov eax, white + (black * 16)
	call settextcolor
	mwrite "        "
	ret
	endgame:
ret
updatelives endp

updatePlayer proc
	mov dl, pac_x
	mov dh, pac_y
	call gotoxy
	mov al, ' '
	call writechar
ret 
updatePlayer endp

checkCollisionRight proc
	
	widthrow equ 81
	movzx ecx, pac_x   ; x coordinate
    movzx edx, pac_y   ; y coordinate

    ; Calculate index: index = y * width + x
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx           ; esi = y * width + x
	inc esi
    ; Load the character at the specified index
    mov al, [row1 + esi]

	mov bl, "#"
	cmp al, bl
	je collide
	mov bl, "*"
	cmp al, bl
	je collide
	mov bl, "X"
	cmp al, bl
	je collidedie
	mov bl, ">"
	cmp al, bl
	je rightteleport
	mov bl, "<"
	cmp al, bl
	je leftteleport
	mov bl, "^"
	cmp al, bl
	je upteleport


	nocollide:
	mov collision, 0
	cmp al, '.'
	jne checkfruit
	mov [row1 + esi], ' '
	inc dotseaten
	add score, 5
	call updateScore
	ret
	checkfruit:
	mov al, [row1 + esi]
	cmp al, '8'
	jne checkpelet
	mov [row1 + esi], ' '
	add score, 100
	call updateScore
	ret
	checkpelet:
	mov al, [row1 + esi]
	cmp al, '0'
	jne noscore
	mov [row1+ esi], ' '
	add score, 50
	mov afraid, 1
	mov afraidtimer, 0
	call updateScore
	ret
	noscore:
	ret

	collide:
	mov collision, 1
	ret 

	collidedie:
	mov collision, 1
	dec lives
	call drawspace
	call updatelives
	mov pac_x, 40
	mov pac_y, 19
	call drawplayer
	ret

	rightteleport:
	call drawspace
	mov collision, 1
	sub pac_x, 77
	call drawplayer
	ret

	leftteleport:
	call drawspace
	mov collision, 1
	add pac_x, 77
	call drawplayer
	ret

	upteleport:
	call drawspace
	mov collision, 1
	add pac_y, 22
	call drawplayer
ret
checkCollisionRight endp

checkCollisionUp PROC
    widthrow EQU 81
    movzx ecx, pac_x   ; x coordinate
    movzx edx, pac_y   ; y coordinate

    ; Calculate index: index = (y-1) * width + x
    dec edx              ; Move up by 1 row
    imul esi, edx, widthrow   ; esi = (y-1) * width
    add esi, ecx           ; esi = (y-1) * width + x

    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
	cmp al, bl
	je collide
	mov bl, "*"
	cmp al, bl
	je collide
	mov bl, "X"
	cmp al, bl
	je collidedie
	mov bl, ">"
	cmp al, bl
	je rightteleport
	mov bl, "<"
	cmp al, bl
	je leftteleport
	mov bl, "^"
	cmp al, bl
	je upteleport


	nocollide:
	mov collision, 0
	cmp al, '.'
	jne checkfruit
	mov [row1 + esi], ' '
	inc dotseaten
	add score, 5
	call updateScore
	ret
	checkfruit:
	mov al, [row1 + esi]
	cmp al, '8'
	jne checkpelet
	mov [row1 + esi], ' '
	add score, 100
	call updateScore
	ret
	checkpelet:
	mov al, [row1 + esi]
	cmp al, '0'
	jne noscore
	mov [row1+ esi], ' '
	add score, 50
	mov afraid, 1
	mov afraidtimer, 0
	call updateScore
	ret
	noscore:
	ret

	collide:
	mov collision, 1
	ret 

	collidedie:
	mov collision, 1
	dec lives
	call drawspace
	call updatelives
	mov pac_x, 40
	mov pac_y, 19
	call drawplayer
	ret

	rightteleport:
	call drawspace
	mov collision, 1
	sub pac_x, 77
	call drawplayer
	ret

	leftteleport:
	call drawspace
	mov collision, 1
	add pac_x, 77
	call drawplayer
	ret

	upteleport:
	call drawspace
	mov collision, 1
	add pac_y, 22
	call drawplayer
ret
checkCollisionUp ENDP

checkCollisionDown PROC
    widthrow EQU 81
    movzx ecx, pac_x   ; x coordinate
    movzx edx, pac_y   ; y coordinate

    ; Calculate index: index = (y+1) * width + x
    inc edx              ; Move down by 1 row
    imul esi, edx, widthrow   ; esi = (y+1) * width
    add esi, ecx           ; esi = (y+1) * width + x

    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
	cmp al, bl
	je collide
	mov bl, "*"
	cmp al, bl
	je collide
	mov bl, "X"
	cmp al, bl
	je collidedie
	mov bl, ">"
	cmp al, bl
	je rightteleport
	mov bl, "<"
	cmp al, bl
	je leftteleport
	mov bl, "^"
	cmp al, bl
	je upteleport


	nocollide:
	mov collision, 0
	cmp al, '.'
	jne checkfruit
	mov [row1 + esi], ' '
	add score, 5
	inc dotseaten
	call updateScore
	ret
	checkfruit:
	mov al, [row1 + esi]
	cmp al, '8'
	jne checkpelet
	mov [row1 + esi], ' '
	add score, 100
	call updateScore
	ret
	checkpelet:
	mov al, [row1 + esi]
	cmp al, '0'
	jne noscore
	mov [row1+ esi], ' '
	add score, 50
	mov afraid, 1
	mov afraidtimer, 0
	call updateScore
	ret
	noscore:
	ret

	collide:
	mov collision, 1
	ret 

	collidedie:
	mov collision, 1
	dec lives
	call drawspace
	call updatelives
	mov pac_x, 40
	mov pac_y, 19
	call drawplayer
	ret

	rightteleport:
	call drawspace
	mov collision, 1
	sub pac_x, 77
	call drawplayer
	ret

	leftteleport:
	call drawspace
	mov collision, 1
	add pac_x, 77
	call drawplayer
	ret

	upteleport:
	call drawspace
	mov collision, 1
	add pac_y, 22
	call drawplayer
ret
checkCollisionDown ENDP

checkCollisionLeft PROC
    widthrow EQU 81
    movzx ecx, pac_x   ; x coordinate
    movzx edx, pac_y   ; y coordinate

    ; Calculate index: index = y * width + (x-1)
    dec ecx              ; Move left by 1 column
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx           ; esi = y * width + (x-1)

    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
	cmp al, bl
	je collide
	mov bl, "*"
	cmp al, bl
	je collide
	mov bl, "X"
	cmp al, bl
	je collidedie
	mov bl, ">"
	cmp al, bl
	je rightteleport
	mov bl, "<"
	cmp al, bl
	je leftteleport
	mov bl, "^"
	cmp al, bl
	je upteleport


	nocollide:
	mov collision, 0
	cmp al, '.'
	jne checkfruit
	mov [row1 + esi], ' '
	add score, 5
	inc dotseaten
	call updateScore
	ret
	checkfruit:
	mov al, [row1 + esi]
	cmp al, '8'
	jne checkpelet
	mov [row1 + esi], ' '
	add score, 100
	call updateScore
	ret
	checkpelet:
	mov al, [row1 + esi]
	cmp al, '0'
	jne noscore
	mov [row1+ esi], ' '
	add score, 50
	mov afraid, 1
	mov afraidtimer, 0
	call updateScore
	ret
	noscore:
	ret

	collide:
	mov collision, 1
	ret 

	collidedie:
	mov collision, 1
	dec lives
	call drawspace
	call updatelives
	mov pac_x, 40
	mov pac_y, 19
	call drawplayer
	ret

	rightteleport:
	mov collision, 1
	call drawspace
	sub pac_x, 77
	call drawplayer
	ret

	leftteleport:
	mov collision, 1
	call drawspace
	add pac_x, 77
	call drawplayer
	ret

	upteleport:
	mov collision, 1
	call drawspace
	add pac_y, 20
	call drawplayer
ret
checkCollisionLeft ENDP

updateScore proc
	mov dh, 15
	mov dl, 100
	call gotoxy

	mwrite "Score: "
	mov eax, score
	call writeint

ret
updateScore endp

instructions proc uses eax edx
	call clrscr

	;INSTRUCTIONS
	mov eax, 7
	call setTextColor
	mov dl, 50
	mov dh, 2
	call gotoXY
	mov edx, offset screen3_ins
	call writestring
	
	;OBJECTIVE
	mov eax, 14
	call setTextColor
	mov dl, 21
	mov dh, 4
	call gotoXY
	mov edx, offset screen3_obj
	call writestring

	mov eax, 2
	call setTextColor
	mov edx, offset screen3_obj1
	call writestring

	mov eax, 11
	call setTextColor
	mov edx, offset screen3_obj2
	call writestring

	;GHOSTS
	mov eax, white 
	call settextcolor
	mov dl, 71
	mov dh, 6
	call gotoxy
	mov edx, offset screen3_ghost
	call writestring

	;GHOST1
	mov eax, red 
	call settextcolor
	mov dl, 73
	mov dh, 8
	call gotoxy
	mov eax, 64
	call writechar
	mov edx, offset screen3_ghost1
	call writestring

	;GHOST2
	mov eax, 13 
	call settextcolor
	mov dl, 73
	mov dh, 9
	call gotoxy
	mov eax, 64
	call writechar
	mov edx, offset screen3_ghost2
	call writestring

	;GHOST3
	mov eax, 3
	call settextcolor
	mov dl, 73
	mov dh, 10
	call gotoxy
	mov eax, 64
	call writechar
	mov edx, offset screen3_ghost3
	call writestring

	;GHOST4
	mov eax, 6
	call settextcolor
	mov dl, 73
	mov dh,11
	call gotoxy
	mov eax, 64
	call writechar
	mov edx, offset screen3_ghost4
	call writestring

	;AFRAID GHOSTS
	mov eax, blue
	call settextcolor
	mov dl, 73
	mov dh, 14
	call gotoxy
	mov edx, offset screen3_afraid
	call writestring
	mov eax, blue + (lightgray * 16)
	call settextcolor
	mov al, '@'
	call writechar

	;EATABLES
	mov eax, white
	call settextcolor
	mov dl, 72
	mov dh, 17
	call gotoxy
	mov edx, offset screen3_eat
	call writestring

	;DOT
	mov eax, yellow
	call settextcolor
	mov dl, 73
	mov dh, 19
	call gotoxy
	mov edx, offset screen3_dot
	call writestring
	;PELET
	mov eax, lightgreen
	call settextcolor
	mov dl, 73
	mov dh, 20
	call gotoxy
	mov edx, offset screen3_pelet
	call writestring
	;CHERRY
	mov eax, red
	call settextcolor
	mov dl, 73
	mov dh, 21
	call gotoxy
	mov edx, offset screen3_cherry
	call writestring

	;CONTROLS
	mov eax, gray
	call settextcolor
	mov dl, 25
	mov dh, 17
	call gotoxy
	mov edx, offset screen3_controls
	call writestring

	mov dl, 21
	mov dh, 24
	call gotoxy
	call waitmsg


ret
instructions ENDP
 
menuScreen proc uses eax edx
	call clrscr
	call crlf 
	call crlf
	

	;Game menu prompt
	mov eax, brown
	call SetTextColor
	mov edx, offset screen2_menu
	call writestring
	call crlf
	call crlf
	call crlf
	call crlf 
	
	
	;mov dl, 5
	;mov dh, 5
	;call gotoXY

	;blinky (game)
	mov eax, 4
	call SetTextColor
	mov edx, offset screen2_ghost1
	call writestring
	call crlf
	call crlf

	;pinky (instructions)
	mov eax, 13
	call SetTextColor
	mov edx, offset screen2_ghost2
	call writestring
	call crlf
	call crlf

	;inky (highscores)
	mov eax, 3
	call SetTextColor
	mov edx, offset screen2_ghost3
	call writestring
	call crlf
	call crlf

	;clyde (exit)
	mov eax, 6
	call SetTextColor
	mov edx, offset screen2_ghost4
	call writestring
	call crlf
	call crlf

	;choice input
	mov eax, blue
	call SetTextColor
	mov dl, 50
	mov dh, 2
	call gotoxy

	incorrect_choice:
	call readint
	;check if choice entered is greater than 4 or less than 1, if yes allow reinput
	cmp al, 4
	jg incorrect_choice
	cmp al, 1
	jl incorrect_choice
	mov screen2_choice, al

ret
menuScreen ENDP

welcomeScreen proc uses eax edx

	

	;moving cursor to second line
	mov dl, 0
	mov dh, 2
	call Gotoxy

	;printing the welcome text
	mov eax, lightcyan
	call SetTextColor
	mov edx, offset screen1_welcome1
	call writestring
	mov edx, offset screen1_welcome2
	call writestring

	;printing the to text
	mov eax, cyan
	call SetTextColor
	mov edx, offset screen1_to
	call writestring

	;printing PACMAN
	mov eax, yellow
	call SetTextColor
	mov edx, offset screen1_pacman1
	call writestring
	mov edx, offset screen1_pacman2
	call writestring

	;moving cursor for entering name
	mov dl, 47
	mov dh, 23
	call gotoxy

	;displaying enter name command and inputting
	mov eax, blue
	call SetTextColor
	mov edx, offset screen1_entername
	call writestring

	mov edx, offset screen1_username
	mov ecx, 30
	call readstring

	mov eax, gray
	call SetTextColor
	mov dl, 45
	mov dh, 27
	call gotoxy
	call waitmsg

ret
welcomeScreen ENDP

drawBlinky proc uses edx

	mov dl, bli_x
	mov dh, bli_y
	call gotoxy
	cmp afraid, 1
	je setblueb
	mov eax, red
	jmp keepcolorb
	setblueb:
	mov eax, blue (gray*16)
	keepcolorb:
	call settextcolor
	mov eax, 64 ;ASCII of @
	call writechar
	mov eax, white
	call settextcolor
ret
drawBlinky endp

blinkyMove proc uses eax ebx
	mov ebx, 81
	mov eax, 0
	mov al, bli_y
	imul eax, ebx
	movzx esi, bli_x
	add eax,esi
	mov esi, offset row1
	add esi, eax
	mov cl, [esi]

	call blinkyCheck
	
    cmp blinkyDir, 'w'
    je blinkyUp

    cmp blinkyDir, 'a'
    je blinkyLeft

    cmp blinkyDir, 's'
    je blinkyDown

    cmp blinkyDir, 'd'
    je blinkyRight

    ret

blinkyUp:
    dec bli_y
    call drawBlinky
	mov dl, bli_x
	mov dh, bli_y
	inc dh
	call gotoxy
	mov al, cl
	call writechar
    ret

blinkyLeft:
    dec bli_x
    call drawBlinky
	mov dl, bli_x
	mov dh, bli_y
	inc dl
	call gotoxy
	mov al, cl
	call writechar
    ret

blinkyDown:
    inc bli_y
    call drawBlinky
	mov dl, bli_x
	mov dh, bli_y
	dec dh
	call gotoxy
	mov al, cl
	call writechar
    ret

blinkyRight:
    inc bli_x
    call drawBlinky
	mov dl, bli_x
	mov dh, bli_y
	dec dl
	call gotoxy
	mov al, cl
	call writechar
    ret
blinkyMove endp

blinkyCheck proc uses ecx

blinkyUpCheck:
	widthrow equ 81
	movzx ecx, bli_x   ; x coordinate
    movzx edx, bli_y   ; y coordinate
	dec edx
    ; Calculate index: index = y * width + x
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]


	mov bl, "#"
	cmp al, bl
	je bUC
	mov bl, "*"
	cmp al, bl
	je bUC
	mov bl, "^"
	cmp al, bl
    je bUC
	mov bl, ">"
	cmp al, bl
    je bUC
	mov bl, "<"
	cmp al, bl
    je bUC
	mov blinkyUC, 1
	jmp bucd

	bUC:
	mov blinkyUC, 0
	
	bucd:

blinkyLeftCheck:
    widthrow equ 81
    movzx ecx, bli_x   ; x coordinate
    movzx edx, bli_y   ; y coordinate
    dec ecx
    ; Calculate index: index = y * width + (x-1)
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je bLC
    mov bl, "*"
	cmp al, bl
    je bLC
	mov bl, "^"
	cmp al, bl
    je bLC
	mov bl, ">"
	cmp al, bl
    je bLC
	mov bl, "<"
	cmp al, bl
    je bLC
    mov blinkyLC, 1
	jmp blcd

    bLC:
    mov blinkyLC, 0

	blcd:

blinkyDownCheck:
    widthrow equ 81
    movzx ecx, bli_x   ; x coordinate
    movzx edx, bli_y   ; y coordinate
    inc edx
    ; Calculate index: index = y * width + x
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je bDC
    mov bl, "*"
	cmp al, bl
    je bDC
	mov bl, "^"
	cmp al, bl
    je bDC
	mov bl, ">"
	cmp al, bl
    je bDC
	mov bl, "<"
	cmp al, bl
    je bDC

    mov blinkyDC, 1
	jmp bdcd

    bDC:
    mov blinkyDC, 0

	bdcd:

blinkyRightCheck:
    widthrow equ 81
    movzx ecx, bli_x   ; x coordinate
    movzx edx, bli_y   ; y coordinate
    inc ecx
    ; Calculate index: index = y * width + (x+1)
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je bRC
    mov bl, "*"
	cmp al, bl
    je bRC
	mov bl, "^"
	cmp al, bl
    je bRC
	mov bl, ">"
	cmp al, bl
    je bRC
	mov bl, "<"
	cmp al, bl
    je bRC
    mov blinkyRC, 1

	jmp brcd 

    bRC:
    mov blinkyRC, 0

	brcd:

	cmp blinkyDir, 'w'
    je blinkyI1

    cmp blinkyDir, 'a'
    je blinkyI2

    cmp blinkyDir, 's'
    je blinkyI3

    cmp blinkyDir, 'd'
    je blinkyI4

blinkyI1:
    cmp blinkyDir, 'w'
    je setBlinkyZeroI1
    jmp doneBlinkyI

setBlinkyZeroI1:
    mov blinkyDC, 0
    jmp doneBlinkyI

blinkyI2:
    cmp blinkyDir, 'a'
    je setBlinkyZeroI2
    jmp doneBlinkyI

setBlinkyZeroI2:
    mov blinkyRC, 0
    jmp doneBlinkyI

blinkyI3:
    cmp blinkyDir, 's'
    je setBlinkyZeroI3
    jmp doneBlinkyI

setBlinkyZeroI3:
    mov blinkyUC, 0
    jmp doneBlinkyI

blinkyI4:
    cmp blinkyDir, 'd'
    je setBlinkyZeroI4
    jmp doneBlinkyI

setBlinkyZeroI4:
    mov blinkyLC, 0
    jmp doneBlinkyI

doneBlinkyI:

    ; Calculate squared distances for each direction
    call blinkyDistance

	; Choose the direction with the least squared distance
	mov ecx, blinkydistanceUp
	mov edx, blinkydistanceLeft
	mov ebx, blinkydistanceRight
	mov esi, blinkydistanceDown  ; Add this line to get the distance for the down direction
	
	blinkyupfinal:
	cmp blinkyUC, 0
	je blinkyleftfinal
	cmp ecx, edx
	jge blinkyupleft
	blinkyr1:
	cmp ecx, ebx
	jge blinkyupright
	blinkyr2:
	cmp ecx, esi
	jge blinkyupdown
	blinkyr3:
	mov blinkyDir, 'w'
	jmp donechoosing

	blinkyupleft:
	cmp blinkyLC, 0
	je blinkyr1
	jmp blinkyleftfinal

	blinkyupright:
	cmp blinkyRC, 0
	je blinkyr2
	jmp blinkyrightfinal

	blinkyupdown:
	cmp blinkyDC, 0
	je blinkyr3
	jmp blinkydownfinal

	blinkyleftfinal:
	cmp blinkyLC, 0
	je blinkyrightfinal
	cmp edx, ebx
	jge blinkyleftright
	blinkyr4:
	cmp edx, esi
	jge blinkyleftdown
	blinkyr5:
	mov blinkyDir, 'a'
	jmp donechoosing

	blinkyleftright:
	cmp blinkyRC, 0
	je blinkyr4
	jmp blinkyrightfinal

	blinkyleftdown:
	cmp blinkyDC, 0
	je blinkyr5
	jmp blinkydownfinal

	blinkyrightfinal:
	cmp blinkyRC, 0
	je blinkydownfinal
	cmp ebx, esi
	jge blinkyrightdown
	blinkyr6:
	mov blinkyDir, 'd'
	jmp donechoosing

	blinkyrightdown:
	cmp blinkyDC, 0
	je blinkyr6

	blinkydownfinal:
	mov blinkyDir, 's'


	doneChoosing:
	; Continue with other code or return if needed
ret

blinkyCheck endp

blinkyDistance proc
	mov eax, 0
    mov al, bli_tx
	mov cl, bli_x
	call comparealcl
    sub al, cl
    imul eax, eax          ; (bli_tx - bli_x)^2

	mov ebx, 0
    mov bl, bli_ty
	mov cl, bli_y
	dec cl
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (bli_ty - bli_y)^2

    add eax, ebx           ; (bli_tx - bli_x)^2 + (bli_ty - bli_y)^2
    mov blinkydistanceUp, eax

    ; Left
	mov eax, 0
    mov al, bli_tx
	mov cl, bli_x
	dec cl
	call comparealcl
    sub al, cl
    imul eax, eax          ; (bli_tx - bli_x)^2

	mov ebx, 0
    mov bl, bli_ty
	mov cl, bli_y
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (bli_ty - bli_y)^2

    add eax, ebx           ; (bli_tx - bli_x)^2 + (bli_ty - bli_y)^2
    mov blinkydistanceLeft, eax

    ; Down
	mov eax, 0
	mov al, bli_tx
	mov cl, bli_x
	call comparealcl
	sub al, cl
	imul eax, eax          ; (bli_tx - bli_x)^2

	mov ebx, 0
	mov bl, bli_ty
	mov cl, bli_y
	inc cl
	call compareblcl
	sub bl, cl
	imul ebx, ebx          ; (bli_ty - bli_y - 1)^2

	add eax, ebx           ; (bli_tx - bli_x)^2 + (bli_ty - bli_y - 1)^2
	mov blinkydistanceDown, eax


    ; Right
	mov eax, 0
    mov al, bli_tx
    mov cl, bli_x
	inc cl
	call comparealcl
	sub al, cl
    imul eax, eax          ; (bli_tx - bli_x)^2

	mov ebx, 0
    mov bl, bli_ty
	mov cl, bli_y
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (bli_ty - bli_y)^2

    add eax, ebx           ; (bli_tx - bli_x)^2 + (bli_ty - bli_y)^2
    mov blinkydistanceRight, eax

ret
blinkyDistance endp

drawPinky proc uses edx
	mov dl, pin_x
	mov dh, pin_y
	call gotoxy
	cmp afraid, 1
	je setbluep
	mov eax, 13
	jmp keepcolorp
	setbluep:
	mov eax, blue (gray*16)
	keepcolorp:
	call settextcolor
	mov eax, 64 ;ASCII of @
	call writechar
	mov eax, white
	call settextcolor
ret
drawPinky endp

PinkyMove proc uses eax ebx
	mov ebx, 81
	mov eax, 0
	mov al, pin_y
	imul eax, ebx
	movzx esi, pin_x
	add eax,esi
	mov esi, offset row1
	add esi, eax
	mov cl, [esi]

	call PinkyCheck
	
    cmp PinkyDir, 'w'
    je PinkyUp

    cmp PinkyDir, 'a'
    je PinkyLeft

    cmp PinkyDir, 's'
    je PinkyDown

    cmp PinkyDir, 'd'
    je PinkyRight

    ret

PinkyUp:
    dec pin_y
    call drawPinky
	mov dl, pin_x
	mov dh, pin_y
	inc dh
	call gotoxy
	mov al, cl
	call writechar
    ret

PinkyLeft:
    dec pin_x
    call drawPinky
	mov dl, pin_x
	mov dh, pin_y
	inc dl
	call gotoxy
	mov al, cl
	call writechar
    ret

PinkyDown:
    inc pin_y
    call drawPinky
	mov dl, pin_x
	mov dh, pin_y
	dec dh
	call gotoxy
	mov al, cl
	call writechar
    ret

PinkyRight:
    inc pin_x
    call drawPinky
	mov dl, pin_x
	mov dh, pin_y
	dec dl
	call gotoxy
	mov al, cl
	call writechar
    ret
PinkyMove endp

PinkyCheck proc uses ecx

PinkyUpCheck:
	widthrow equ 81
	movzx ecx, pin_x   ; x coordinate
    movzx edx, pin_y   ; y coordinate
	dec edx
    ; Calculate index: index = y * width + x
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]


	mov bl, "#"
	cmp al, bl
	je pUC
	mov bl, "*"
	cmp al, bl
	je pUC
	mov bl, "^"
	cmp al, bl
    je pUC
	mov bl, ">"
	cmp al, bl
    je pUC
	mov bl, "<"
	cmp al, bl
    je pUC
	mov PinkyUC, 1
	jmp pucd

	pUC:
	mov PinkyUC, 0
	
	pucd:

PinkyLeftCheck:
    widthrow equ 81
    movzx ecx, pin_x   ; x coordinate
    movzx edx, pin_y   ; y coordinate
    dec ecx
    ; Calculate index: index = y * width + (x-1)
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je pLC
    mov bl, "*"
	cmp al, bl
    je pLC
	mov bl, "^"
	cmp al, bl
    je pLC
	mov bl, ">"
	cmp al, bl
    je pLC
	mov bl, "<"
	cmp al, bl
    je pLC
    mov PinkyLC, 1
	jmp plcd

    pLC:
    mov PinkyLC, 0

	plcd:

PinkyDownCheck:
    widthrow equ 81
    movzx ecx, pin_x   ; x coordinate
    movzx edx, pin_y   ; y coordinate
    inc edx
    ; Calculate index: index = y * width + x
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je pDC
    mov bl, "*"
	cmp al, bl
    je pDC
	mov bl, "^"
	cmp al, bl
    je pDC
	mov bl, ">"
	cmp al, bl
    je pDC
	mov bl, "<"
	cmp al, bl
    je pDC
    mov PinkyDC, 1
	jmp pdcd

    pDC:
    mov PinkyDC, 0

	pdcd:

PinkyRightCheck:
    widthrow equ 81
    movzx ecx, pin_x   ; x coordinate
    movzx edx, pin_y   ; y coordinate
    inc ecx
    ; Calculate index: index = y * width + (x+1)
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je pRC
    mov bl, "*"
	cmp al, bl
    je pRC
	mov bl, "^"
	cmp al, bl
    je pRC
	mov bl, ">"
	cmp al, bl
    je pRC
	mov bl, "<"
	cmp al, bl
    je pRC
    mov PinkyRC, 1

	jmp prcd 

    pRC:
    mov PinkyRC, 0

	prcd:

	cmp PinkyDir, 'w'
    je PinkyI1

    cmp PinkyDir, 'a'
    je PinkyI2

    cmp PinkyDir, 's'
    je PinkyI3

    cmp PinkyDir, 'd'
    je PinkyI4

PinkyI1:
    cmp PinkyDir, 'w'
    je setPinkyZeroI1
    jmp donePinkyI

setPinkyZeroI1:
    mov PinkyDC, 0
    jmp donePinkyI

PinkyI2:
    cmp PinkyDir, 'a'
    je setPinkyZeroI2
    jmp donePinkyI

setPinkyZeroI2:
    mov PinkyRC, 0
    jmp donePinkyI

PinkyI3:
    cmp PinkyDir, 's'
    je setPinkyZeroI3
    jmp donePinkyI

setPinkyZeroI3:
    mov PinkyUC, 0
    jmp donePinkyI

PinkyI4:
    cmp PinkyDir, 'd'
    je setPinkyZeroI4
    jmp donePinkyI

setPinkyZeroI4:
    mov PinkyLC, 0
    jmp donePinkyI

donePinkyI:

    ; Calculate squared distances for each direction
    call PinkyDistance

	; Choose the direction with the least squared distance
	mov ecx, PinkydistanceUp
	mov edx, PinkydistanceLeft
	mov ebx, PinkydistanceRight
	mov esi, PinkydistanceDown  ; Add this line to get the distance for the down direction
	
	Pinkyupfinal:
	cmp PinkyUC, 0
	je Pinkyleftfinal
	cmp ecx, edx
	jge Pinkyupleft
	Pinkyr1:
	cmp ecx, ebx
	jge Pinkyupright
	Pinkyr2:
	cmp ecx, esi
	jge Pinkyupdown
	Pinkyr3:
	mov PinkyDir, 'w'
	jmp donechoosing

	Pinkyupleft:
	cmp PinkyLC, 0
	je Pinkyr1
	jmp Pinkyleftfinal

	Pinkyupright:
	cmp PinkyRC, 0
	je Pinkyr2
	jmp Pinkyrightfinal

	Pinkyupdown:
	cmp PinkyDC, 0
	je Pinkyr3
	jmp Pinkydownfinal

	Pinkyleftfinal:
	cmp PinkyLC, 0
	je Pinkyrightfinal
	cmp edx, ebx
	jge Pinkyleftright
	Pinkyr4:
	cmp edx, esi
	jge Pinkyleftdown
	Pinkyr5:
	mov PinkyDir, 'a'
	jmp donechoosing

	Pinkyleftright:
	cmp PinkyRC, 0
	je Pinkyr4
	jmp Pinkyrightfinal

	Pinkyleftdown:
	cmp PinkyDC, 0
	je Pinkyr5
	jmp Pinkydownfinal

	Pinkyrightfinal:
	cmp PinkyRC, 0
	je Pinkydownfinal
	cmp ebx, esi
	jge Pinkyrightdown
	Pinkyr6:
	mov PinkyDir, 'd'
	jmp donechoosing

	Pinkyrightdown:
	cmp PinkyDC, 0
	je Pinkyr6

	Pinkydownfinal:
	mov PinkyDir, 's'


	doneChoosing:
	; Continue with other code or return if needed
ret

PinkyCheck endp

PinkyDistance proc
	mov eax, 0
    mov al, pin_tx
	mov cl, pin_x
	call comparealcl
    sub al, cl
    imul eax, eax          ; (pin_tx - pin_x)^2

	mov ebx, 0
    mov bl, pin_ty
	mov cl, pin_y
	dec cl
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (pin_ty - pin_y)^2

    add eax, ebx           ; (pin_tx - pin_x)^2 + (pin_ty - pin_y)^2
    mov PinkydistanceUp, eax

    ; Left
	mov eax, 0
    mov al, pin_tx
	mov cl, pin_x
	dec cl
	call comparealcl
    sub al, cl
    imul eax, eax          ; (pin_tx - pin_x)^2

	mov ebx, 0
    mov bl, pin_ty
	mov cl, pin_y
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (pin_ty - pin_y)^2

    add eax, ebx           ; (pin_tx - pin_x)^2 + (pin_ty - pin_y)^2
    mov PinkydistanceLeft, eax

    ; Down
	mov eax, 0
	mov al, pin_tx
	mov cl, pin_x
	call comparealcl
	sub al, cl
	imul eax, eax          ; (pin_tx - pin_x)^2

	mov ebx, 0
	mov bl, pin_ty
	mov cl, pin_y
	inc cl
	call compareblcl
	sub bl, cl
	imul ebx, ebx          ; (pin_ty - pin_y - 1)^2

	add eax, ebx           ; (pin_tx - pin_x)^2 + (pin_ty - pin_y - 1)^2
	mov PinkydistanceDown, eax


    ; Right
	mov eax, 0
    mov al, pin_tx
    mov cl, pin_x
	inc cl
	call comparealcl
	sub al, cl
    imul eax, eax          ; (pin_tx - pin_x)^2

	mov ebx, 0
    mov bl, pin_ty
	mov cl, pin_y
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (pin_ty - pin_y)^2

    add eax, ebx           ; (pin_tx - pin_x)^2 + (pin_ty - pin_y)^2
    mov PinkydistanceRight, eax

ret
PinkyDistance endp

drawinky proc uses edx
	mov dl, ink_x
	mov dh, ink_y
	call gotoxy
	cmp afraid, 1
	je setblueI
	mov eax, 3
	jmp keepcolorI
	setblueI:
	mov eax, blue (gray*16)
	keepcolorI:
	call settextcolor
	mov eax, 64 ;ASCII of @
	call writechar
	mov eax, white
	call settextcolor
ret
drawinky endp

inkyMove proc uses eax ebx
	mov ebx, 81
	mov eax, 0
	mov al, ink_y
	imul eax, ebx
	movzx esi, ink_x
	add eax,esi
	mov esi, offset row1
	add esi, eax
	mov cl, [esi]

	call inkyCheck
	
    cmp inkyDir, 'w'
    je inkyUp

    cmp inkyDir, 'a'
    je inkyLeft

    cmp inkyDir, 's'
    je inkyDown

    cmp inkyDir, 'd'
    je inkyRight

    ret

inkyUp:
    dec ink_y
    call drawinky
	mov dl, ink_x
	mov dh, ink_y
	inc dh
	call gotoxy
	mov al, cl
	call writechar
    ret

inkyLeft:
    dec ink_x
    call drawinky
	mov dl, ink_x
	mov dh, ink_y
	inc dl
	call gotoxy
	mov al, cl
	call writechar
    ret

inkyDown:
    inc ink_y
    call drawinky
	mov dl, ink_x
	mov dh, ink_y
	dec dh
	call gotoxy
	mov al, cl
	call writechar
    ret

inkyRight:
    inc ink_x
    call drawinky
	mov dl, ink_x
	mov dh, ink_y
	dec dl
	call gotoxy
	mov al, cl
	call writechar
    ret
inkyMove endp

inkyCheck proc uses ecx

inkyUpCheck:
	widthrow equ 81
	movzx ecx, ink_x   ; x coordinate
    movzx edx, ink_y   ; y coordinate
	dec edx
    ; Calculate index: index = y * width + x
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]


	mov bl, "#"
	cmp al, bl
	je IUC
	mov bl, "*"
	cmp al, bl
	je IUC
	mov bl, "^"
	cmp al, bl
    je IUC
	mov bl, ">"
	cmp al, bl
    je IUC
	mov bl, "<"
	cmp al, bl
    je IUC
	mov inkyUC, 1
	jmp Iucd

	IUC:
	mov inkyUC, 0
	
	Iucd:

inkyLeftCheck:
    widthrow equ 81
    movzx ecx, ink_x   ; x coordinate
    movzx edx, ink_y   ; y coordinate
    dec ecx
    ; Calculate index: index = y * width + (x-1)
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je ILC
    mov bl, "*"
	cmp al, bl
    je ILC
	mov bl, "^"
	cmp al, bl
    je ILC
	mov bl, ">"
	cmp al, bl
    je ILC
	mov bl, "<"
	cmp al, bl
    je ILC
    mov inkyLC, 1
	jmp Ilcd

    ILC:
    mov inkyLC, 0

	Ilcd:

inkyDownCheck:
    widthrow equ 81
    movzx ecx, ink_x   ; x coordinate
    movzx edx, ink_y   ; y coordinate
    inc edx
    ; Calculate index: index = y * width + x
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je IDC
    mov bl, "*"
	cmp al, bl
    je IDC
	mov bl, "^"
	cmp al, bl
    je IDC
	mov bl, ">"
	cmp al, bl
    je IDC
	mov bl, "<"
	cmp al, bl
    je IDC
    mov inkyDC, 1
	jmp Idcd

    IDC:
    mov inkyDC, 0

	Idcd:

inkyRightCheck:
    widthrow equ 81
    movzx ecx, ink_x   ; x coordinate
    movzx edx, ink_y   ; y coordinate
    inc ecx
    ; Calculate index: index = y * width + (x+1)
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je IRC
    mov bl, "*"
	cmp al, bl
    je IRC
	mov bl, "^"
	cmp al, bl
    je IRC
	mov bl, ">"
	cmp al, bl
    je IRC
	mov bl, "<"
	cmp al, bl
    je IRC
    mov inkyRC, 1

	jmp Ircd 

    IRC:
    mov inkyRC, 0

	Ircd:

	cmp inkyDir, 'w'
    je inkyI1

    cmp inkyDir, 'a'
    je inkyI2

    cmp inkyDir, 's'
    je inkyI3

    cmp inkyDir, 'd'
    je inkyI4

inkyI1:
    cmp inkyDir, 'w'
    je setinkyZeroI1
    jmp doneinkyI

setinkyZeroI1:
    mov inkyDC, 0
    jmp doneinkyI

inkyI2:
    cmp inkyDir, 'a'
    je setinkyZeroI2
    jmp doneinkyI

setinkyZeroI2:
    mov inkyRC, 0
    jmp doneinkyI

inkyI3:
    cmp inkyDir, 's'
    je setinkyZeroI3
    jmp doneinkyI

setinkyZeroI3:
    mov inkyUC, 0
    jmp doneinkyI

inkyI4:
    cmp inkyDir, 'd'
    je setinkyZeroI4
    jmp doneinkyI

setinkyZeroI4:
    mov inkyLC, 0
    jmp doneinkyI

doneinkyI:

    ; Calculate squared distances for each direction
    call inkyDistance

	; Choose the direction with the least squared distance
	mov ecx, inkydistanceUp
	mov edx, inkydistanceLeft
	mov ebx, inkydistanceRight
	mov esi, inkydistanceDown  ; Add this line to get the distance for the down direction
	
	inkyupfinal:
	cmp inkyUC, 0
	je inkyleftfinal
	cmp ecx, edx
	jge inkyupleft
	inkyr1:
	cmp ecx, ebx
	jge inkyupright
	inkyr2:
	cmp ecx, esi
	jge inkyupdown
	inkyr3:
	mov inkyDir, 'w'
	jmp donechoosing

	inkyupleft:
	cmp inkyLC, 0
	je inkyr1
	jmp inkyleftfinal

	inkyupright:
	cmp inkyRC, 0
	je inkyr2
	jmp inkyrightfinal

	inkyupdown:
	cmp inkyDC, 0
	je inkyr3
	jmp inkydownfinal

	inkyleftfinal:
	cmp inkyLC, 0
	je inkyrightfinal
	cmp edx, ebx
	jge inkyleftright
	inkyr4:
	cmp edx, esi
	jge inkyleftdown
	inkyr5:
	mov inkyDir, 'a'
	jmp donechoosing

	inkyleftright:
	cmp inkyRC, 0
	je inkyr4
	jmp inkyrightfinal

	inkyleftdown:
	cmp inkyDC, 0
	je inkyr5
	jmp inkydownfinal

	inkyrightfinal:
	cmp inkyRC, 0
	je inkydownfinal
	cmp ebx, esi
	jge inkyrightdown
	inkyr6:
	mov inkyDir, 'd'
	jmp donechoosing

	inkyrightdown:
	cmp inkyDC, 0
	je inkyr6

	inkydownfinal:
	mov inkyDir, 's'


	doneChoosing:
	; Continue with other code or return if needed
ret

inkyCheck endp

inkyDistance proc
	mov eax, 0
    mov al, ink_tx
	mov cl, ink_x
	call comparealcl
    sub al, cl
    imul eax, eax          ; (ink_tx - ink_x)^2

	mov ebx, 0
    mov bl, ink_ty
	mov cl, ink_y
	dec cl
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (ink_ty - ink_y)^2

    add eax, ebx           ; (ink_tx - ink_x)^2 + (ink_ty - ink_y)^2
    mov inkydistanceUp, eax

    ; Left
	mov eax, 0
    mov al, ink_tx
	mov cl, ink_x
	dec cl
	call comparealcl
    sub al, cl
    imul eax, eax          ; (ink_tx - ink_x)^2

	mov ebx, 0
    mov bl, ink_ty
	mov cl, ink_y
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (ink_ty - ink_y)^2

    add eax, ebx           ; (ink_tx - ink_x)^2 + (ink_ty - ink_y)^2
    mov inkydistanceLeft, eax

    ; Down
	mov eax, 0
	mov al, ink_tx
	mov cl, ink_x
	call comparealcl
	sub al, cl
	imul eax, eax          ; (ink_tx - ink_x)^2

	mov ebx, 0
	mov bl, ink_ty
	mov cl, ink_y
	inc cl
	call compareblcl
	sub bl, cl
	imul ebx, ebx          ; (ink_ty - ink_y - 1)^2

	add eax, ebx           ; (ink_tx - ink_x)^2 + (ink_ty - ink_y - 1)^2
	mov inkydistanceDown, eax


    ; Right
	mov eax, 0
    mov al, ink_tx
    mov cl, ink_x
	inc cl
	call comparealcl
	sub al, cl
    imul eax, eax          ; (ink_tx - ink_x)^2

	mov ebx, 0
    mov bl, ink_ty
	mov cl, ink_y
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (ink_ty - ink_y)^2

    add eax, ebx           ; (ink_tx - ink_x)^2 + (ink_ty - ink_y)^2
    mov inkydistanceRight, eax

ret
inkyDistance endp

drawclyde proc uses edx
	mov dl, cly_x
	mov dh, cly_y
	call gotoxy
	cmp afraid, 1
	je setblueC
	mov eax, 6
	jmp keepcolorC
	setblueC:
	mov eax, blue (gray*16)
	keepcolorC:
	call settextcolor
	mov eax, 64 ;ASCII of @
	call writechar
	mov eax, white
	call settextcolor
ret
drawclyde endp

clydeMove proc uses eax ebx
	mov ebx, 81
	mov eax, 0
	mov al, cly_y
	imul eax, ebx
	movzx esi, cly_x
	add eax,esi
	mov esi, offset row1
	add esi, eax
	mov cl, [esi]

	call clydeCheck
	
    cmp clydeDir, 'w'
    je clydeUp

    cmp clydeDir, 'a'
    je clydeLeft

    cmp clydeDir, 's'
    je clydeDown

    cmp clydeDir, 'd'
    je clydeRight

    ret

clydeUp:
    dec cly_y
    call drawclyde
	mov dl, cly_x
	mov dh, cly_y
	inc dh
	call gotoxy
	mov al, cl
	call writechar
    ret

clydeLeft:
    dec cly_x
    call drawclyde
	mov dl, cly_x
	mov dh, cly_y
	inc dl
	call gotoxy
	mov al, cl
	call writechar
    ret

clydeDown:
    inc cly_y
    call drawclyde
	mov dl, cly_x
	mov dh, cly_y
	dec dh
	call gotoxy
	mov al, cl
	call writechar
    ret

clydeRight:
    inc cly_x
    call drawclyde
	mov dl, cly_x
	mov dh, cly_y
	dec dl
	call gotoxy
	mov al, cl
	call writechar
    ret
clydeMove endp

clydeCheck proc uses ecx

clydeUpCheck:
	widthrow equ 81
	movzx ecx, cly_x   ; x coordinate
    movzx edx, cly_y   ; y coordinate
	dec edx
    ; Calculate index: index = y * width + x
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]


	mov bl, "#"
	cmp al, bl
	je CUC
	mov bl, "*"
	cmp al, bl
	je CUC
	mov bl, "^"
	cmp al, bl
    je CUC
	mov bl, ">"
	cmp al, bl
    je CUC
	mov bl, "<"
	cmp al, bl
    je CUC
	mov clydeUC, 1
	jmp Cucd

	CUC:
	mov clydeUC, 0
	
	Cucd:

clydeLeftCheck:
    widthrow equ 81
    movzx ecx, cly_x   ; x coordinate
    movzx edx, cly_y   ; y coordinate
    dec ecx
    ; Calculate index: index = y * width + (x-1)
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je CLC1
    mov bl, "*"
	cmp al, bl
    je CLC1
	mov bl, "^"
	cmp al, bl
    je CLC1
	mov bl, ">"
	cmp al, bl
    je CLC1
	mov bl, "<"
	cmp al, bl
    je CLC1
    mov clydeLC, 1
	jmp Clcd

    CLC1:
    mov clydeLC, 0

	Clcd:

clydeDownCheck:
    widthrow equ 81
    movzx ecx, cly_x   ; x coordinate
    movzx edx, cly_y   ; y coordinate
    inc edx
    ; Calculate index: index = y * width + x
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je CDC
    mov bl, "*"
	cmp al, bl
    je CDC
	mov bl, "^"
	cmp al, bl
    je CDC
	mov bl, ">"
	cmp al, bl
    je CDC
	mov bl, "<"
	cmp al, bl
    je CDC
    mov clydeDC, 1
	jmp Cdcd

    CDC:
    mov clydeDC, 0

	Cdcd:

clydeRightCheck:
    widthrow equ 81
    movzx ecx, cly_x   ; x coordinate
    movzx edx, cly_y   ; y coordinate
    inc ecx
    ; Calculate index: index = y * width + (x+1)
    imul esi, edx, widthrow   ; esi = y * width
    add esi, ecx  
    ; Load the character at the specified index
    mov al, [row1 + esi]

    mov bl, "#"
    cmp al, bl
    je CRC
    mov bl, "*"
	cmp al, bl
    je CRC
	mov bl, "^"
	cmp al, bl
    je CRC
	mov bl, ">"
	cmp al, bl
    je CRC
	mov bl, "<"
	cmp al, bl
    je CRC
    mov clydeRC, 1

	jmp Crcd 

    CRC:
    mov clydeRC, 0

	Crcd:

	cmp clydeDir, 'w'
    je clydeI1

    cmp clydeDir, 'a'
    je clydeI2

    cmp clydeDir, 's'
    je clydeI3

    cmp clydeDir, 'd'
    je clydeI4

clydeI1:
    cmp clydeDir, 'w'
    je setclydeZeroI1
    jmp doneclydeI

setclydeZeroI1:
    mov clydeDC, 0
    jmp doneclydeI

clydeI2:
    cmp clydeDir, 'a'
    je setclydeZeroI2
    jmp doneclydeI

setclydeZeroI2:
    mov clydeRC, 0
    jmp doneclydeI

clydeI3:
    cmp clydeDir, 's'
    je setclydeZeroI3
    jmp doneclydeI

setclydeZeroI3:
    mov clydeUC, 0
    jmp doneclydeI

clydeI4:
    cmp clydeDir, 'd'
    je setclydeZeroI4
    jmp doneclydeI

setclydeZeroI4:
    mov clydeLC, 0
    jmp doneclydeI

doneclydeI:

    ; Calculate squared distances for each direction
    call clydeDistance

	; Choose the direction with the least squared distance
	mov ecx, clydedistanceUp
	mov edx, clydedistanceLeft
	mov ebx, clydedistanceRight
	mov esi, clydedistanceDown  ; Add this line to get the distance for the down direction
	
	clydeupfinal:
	cmp clydeUC, 0
	je clydeleftfinal
	cmp ecx, edx
	jge clydeupleft
	clyder1:
	cmp ecx, ebx
	jge clydeupright
	clyder2:
	cmp ecx, esi
	jge clydeupdown
	clyder3:
	mov clydeDir, 'w'
	jmp donechoosing

	clydeupleft:
	cmp clydeLC, 0
	je clyder1
	jmp clydeleftfinal

	clydeupright:
	cmp clydeRC, 0
	je clyder2
	jmp clyderightfinal

	clydeupdown:
	cmp clydeDC, 0
	je clyder3
	jmp clydedownfinal

	clydeleftfinal:
	cmp clydeLC, 0
	je clyderightfinal
	cmp edx, ebx
	jge clydeleftright
	clyder4:
	cmp edx, esi
	jge clydeleftdown
	clyder5:
	mov clydeDir, 'a'
	jmp donechoosing

	clydeleftright:
	cmp clydeRC, 0
	je clyder4
	jmp clyderightfinal

	clydeleftdown:
	cmp clydeDC, 0
	je clyder5
	jmp clydedownfinal

	clyderightfinal:
	cmp clydeRC, 0
	je clydedownfinal
	cmp ebx, esi
	jge clyderightdown
	clyder6:
	mov clydeDir, 'd'
	jmp donechoosing

	clyderightdown:
	cmp clydeDC, 0
	je clyder6

	clydedownfinal:
	mov clydeDir, 's'


	doneChoosing:
	; Continue with other code or return if needed
ret

clydeCheck endp

clydeDistance proc
	mov eax, 0
    mov al, cly_tx
	mov cl, cly_x
	call comparealcl
    sub al, cl
    imul eax, eax          ; (cly_tx - cly_x)^2

	mov ebx, 0
    mov bl, cly_ty
	mov cl, cly_y
	dec cl
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (cly_ty - cly_y)^2

    add eax, ebx           ; (cly_tx - cly_x)^2 + (cly_ty - cly_y)^2
    mov clydedistanceUp, eax

    ; Left
	mov eax, 0
    mov al, cly_tx
	mov cl, cly_x
	dec cl
	call comparealcl
    sub al, cl
    imul eax, eax          ; (cly_tx - cly_x)^2

	mov ebx, 0
    mov bl, cly_ty
	mov cl, cly_y
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (cly_ty - cly_y)^2

    add eax, ebx           ; (cly_tx - cly_x)^2 + (cly_ty - cly_y)^2
    mov clydedistanceLeft, eax

    ; Down
	mov eax, 0
	mov al, cly_tx
	mov cl, cly_x
	call comparealcl
	sub al, cl
	imul eax, eax          ; (cly_tx - cly_x)^2

	mov ebx, 0
	mov bl, cly_ty
	mov cl, cly_y
	inc cl
	call compareblcl
	sub bl, cl
	imul ebx, ebx          ; (cly_ty - cly_y - 1)^2

	add eax, ebx           ; (cly_tx - cly_x)^2 + (cly_ty - cly_y - 1)^2
	mov clydedistanceDown, eax


    ; Right
	mov eax, 0
    mov al, cly_tx
    mov cl, cly_x
	inc cl
	call comparealcl
	sub al, cl
    imul eax, eax          ; (cly_tx - cly_x)^2

	mov ebx, 0
    mov bl, cly_ty
	mov cl, cly_y
	call compareblcl
    sub bl, cl
    imul ebx, ebx          ; (cly_ty - cly_y)^2

    add eax, ebx           ; (cly_tx - cly_x)^2 + (cly_ty - cly_y)^2
    mov clydedistanceRight, eax

ret
clydeDistance endp

comparealcl proc uses ebx
	cmp al, cl
	jl changealcl
	ret 
	changealcl:
	mov bl, al
	mov al, cl
	mov cl, bl
ret
comparealcl endp

compareblcl proc uses eax
	cmp bl, cl
	jl changeblcl
	ret 
	changeblcl:
	mov al, cl
	mov cl, bl
	mov bl, al
ret
compareblcl endp

resetchars proc
	mov pac_x, 40
	mov pac_y, 19

	mov bli_x, 40
	mov bli_y, 13

	mov pin_x, 40
	mov pin_y, 13
ret
resetchars endp

drawspace proc
	mov dl, pac_x
	mov dh, pac_y
	call gotoxy
	mov al, ' '
	call writechar
ret
drawspace endp

won_game proc
	call clrscr

	mov dl, 20
	mov dh, 5
	call gotoxy
	mov eax, magenta
	call settextcolor
	mwrite "Congratulations! You beat the game!"

	mov dl, 20
	mov dh, 7
	call gotoxy
	mov eax, brown
	call settextcolor
	mwrite "Name: "
	mov edx, offset screen1_username
	mov ecx, 30
	call writestring

	mov dl, 20
	mov dh, 9
	call gotoxy
	mov eax, cyan
	call settextcolor
	mwrite "Score: "
	mov eax, score
	call writeint

	mov dl, 20
	mov dh, 11
	call gotoxy
	mov eax, red
	call settextcolor
	mwrite "Level: "
	mov al, currentlevel
	call writeint

	mov dl, 20
	mov dh, 20
	call gotoxy

	call waitmsg
	call waitmsg
	call waitmsg
ret
won_game endp

lost_game proc
	call clrscr

	mov dl, 20
	mov dh, 5
	call gotoxy
	mov eax, magenta
	call settextcolor
	mwrite "Sorry but you couldn't survive the nightmare :( MOYE MOYE"

	mov dl, 20
	mov dh, 7
	call gotoxy
	mov eax, brown
	call settextcolor
	mwrite "Name: "
	mov edx, offset screen1_username
	mov ecx, 30
	call writestring

	mov dl, 20
	mov dh, 9
	call gotoxy
	mov eax, cyan
	call settextcolor
	mwrite "Score: "
	mov eax, score
	call writeint

	mov dl, 20
	mov dh, 11
	call gotoxy
	mov eax, red
	call settextcolor
	mwrite "Level: "
	mov al, currentlevel
	call writeint

	mov dl, 20
	mov dh, 20
	call gotoxy

	call waitmsg
	call waitmsg
	call waitmsg
ret
lost_game endp

OpenFileForAppend PROC
    mov edx, OFFSET filename
    invoke CreateFile, edx, FILE_APPEND_DATA, FILE_SHARE_READ, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov fileHandle, eax
    ret
OpenFileForAppend ENDP

; Procedure to close the file
cf1 PROC
    invoke CloseHandle, fileHandle
    ret
cf1 ENDP

; Procedure to append a new line with screen1_username, score, and level
AppendHighScore PROC
    ; Open the file for appending
    call OpenFileForAppend
    
    ; Check for errors
    cmp fileHandle, INVALID_HANDLE_VALUE
    je  OpenFileError

    ; Append the data to the file
    call WTF1
	call WTF2
    
    ; Close the file
    call cf1
    ret

    OpenFileError:
    ret
AppendHighScore ENDP

; Procedure to write data to the file
WTF1 PROC
    ; Write the buffer to the file
    mov eax, fileHandle
    mov edx, OFFSET screen1_username
    mov ecx, 30
	call WriteToFile
    ret
WTF1 ENDP

WTf2 PROC
    ; Write the buffer to the file
	mov eax, score
	call writeint
	
    mov eax, fileHandle
	call WriteToFile
    ret
WTF2 ENDP



end main