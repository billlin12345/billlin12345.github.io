extensions [sound]
;Bugs yet to be fixed: Timer keeps going when game is not running make no diagonal movements in snake

turtles-own [bigness life score reach hidden win? wingame? gameOver?] 
patches-own [turns]
globals [level fishes maximumFishes gameRunning winningScore timeAllowed menuOption pausedTime easyMode? controls
 timeAllowedBonus lengths lifeSnake]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to menu 
sound:start-note "seashore" 60 64
clear-patches
clear-turtles
set level 0
set speed 95
  
import-drawing "title.gif"
crt 1 [set shape "Shark" set size 6 set color grey set heading 90 set xcor 2 set ycor 0.5]
crt 1 [set shape "Turtle" set size 3.2 set color 33 set heading 90 set xcor 15 set ycor 0.8]
crt 1 [set shape "fish" set size 2 set color red set heading 90 set xcor 25 set ycor 1]
while [turtle 0 != nobody][
wait 1 - (speed / 100)

if turtle 2 != nobody [
ask turtle 2 [fd 1.1 if distance turtle 1 <= 2.5 [die]
if xcor >= 38 and ycor = 1 [set xcor 40 set ycor 39 set shape "Fish2" set heading 270]
if xcor <= 2 and ycor = 39 [set xcor 0 set ycor 1 set shape "Fish" set heading 90]]]

if turtle 1 != nobody [
ask turtle 1 [fd 1.25 if distance turtle 0 <= 4.3 [die]
if xcor >= 38 and ycor = 0.8 [set xcor 40 set ycor 39.2 set heading 270]
if xcor <= 2 and ycor = 39.2 [set xcor 0 set ycor 0.8  set heading 90]]]

ask turtle 0 [fd 1.35
if xcor >= 38 and ycor = 0.5 [set xcor 40 set ycor 38.8 set shape "Shark2" set heading 270]
if xcor <= 2 and ycor = 38.8 [set xcor 0 set ycor 0.5 set shape "Shark" set heading 90]]

if turtle 1 = nobody and turtle 2 = nobody [
wait 1
sound:stop-note "Seashore" 60
ask turtle 0 [die]]]
set speed 92

set menuOption  user-one-of "Menu" ["Play" "Easy Mode" "Other Modes" "Instructions" "Credits"] 
if menuOption  = "Play" [set controls user-one-of "Choose Control type" ["Mouse" "WASD"] set easyMode? false firstSetup]
if menuOption = "Easy Mode" [set controls user-one-of "Choose Control type" ["Mouse" "WASD"] set easyMode? true firstSetup]
if menuOption = "Other Modes" [set menuOption user-one-of "Other Modes" ["Turtle-Snake""Bonus Round" "Back to Title Screen"]]
if menuOption = "Turtle-Snake" [instructionsSnake setupSnake playSnake] 
if menuOption = "Instructions" [instructions]
if menuOption = "Bonus Round" [set controls "Mouse" firstSetup setupBonus]
if menuOption = "Back to Title Screen" [menu]
;if menuOption = "Credits" [credits]
end

;to credits
;import-drawing "credits.gif"
;play-note "127"
;end

to instructionsBonusRound
user-message (word "You have 1 minute to eat as many fishes as you can!")
end

to instructions
set menuOption  user-one-of "Menu" ["Basic Instructions" "Controls" "Different Modes" "Back to Title Screen"]  

if menuOption = "Basic Instructions" [user-message (word "Feed Bob fish and try to avoid the shark. As the shark eats, "
"it gets bigger while taking away your food supply. If the day passes, or there isn't enough fish left to eat, you will starve "
"and lose a life. The fish slowly reproduce if you're patient enough to wait. You have 5 lifes, and you have "
"to survive 10 days to win. Good luck!")]

if menuOption = "Controls" [user-message (word "You can either hold down the mousekey and use the mouse to guide Bob around, "
"or use the WASD keys to move Bob. It is highly recommended you use the mouse because it's easier to move around.")]

if menuOption = "Different Modes" [user-message (word "There are two modes, regular and easy mode. Easy mode is easier because "
"your turtle moves slightly faster, there are less score needed to go advance to the next day, the shark is smaller, and "
"there are much less fish.")]

if menuOption = "Back to Title Screen" [menu]
instructions
end

to instructionsSnake 
user-message (word "Use WASD to control Bob and move him around and eat fish while not crashing into yourself.")
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to firstSetup ;First setup for the game. 
clear-drawing
clear-patches
clear-turtles 
crt 1 [
set xcor 20
set ycor 20
set label "Bill"
set size 5
set color 33
set heading random 360
set shape "turtle"
set heading 270
set reach 1.5
fd  11]

crt 1 [
set xcor 20
set ycor 20
set life 5
set bigness 10
set label "Miranda" 
set color grey 
ifelse easyMode? = true [set size 5 set reach 2.5]
[set reach 3
set size 8.5]
set heading 90
fd 11
set gameOver? 2
set win? 2]

ifelse easyMode? = true [set fishes 5][set fishes 8]  
crt fishes [
set xcor random-xcor
set ycor random-ycor 
if ycor >= 37 [set ycor ycor - 3]
if ycor <= 3 [set ycor ycor + 2.5]
set color red
set shape "fish"
set label "Raw sushi" 
set size 3
set heading random 360
fd random 10]

ask patches [ set pcolor blue ]
ask patches [set plabel "~"]
ask patches with [pycor >= 38] [set pcolor 27]
set level 1
ifelse easyMode? = true [set maximumFishes 7 set winningScore 3] [set maximumFishes 10 set winningScore 5]
set gamerunning true
reset-timer
ifelse controls = "WASD" [set timeAllowed  45]
[set timeAllowed 25] ; 25 seconds or else you lose a life.
end 

to setupAgain ;Setup for retry.
reset-timer
ask turtle 0 [
set xcor 9
set ycor 20
show-turtle
set hidden false]

ask turtle 1 [
set xcor 31
set ycor 20
set win? 2
set gameOver? 2]

crt fishes [
set xcor random-xcor
set ycor random-ycor
if ycor >= 37 [set ycor ycor - 4]
if ycor <= 3 [set ycor ycor + 3.5]
set color red
set shape "fish"
set size 3
set heading random 360
fd random 10]

set gameRunning true
end

to setupLevel  ;Setup for next level.
set gameRunning true
ifelse easyMode? = true [set winningScore [score] of turtle 0 + 3 + (level / 3) set fishes fishes + 1 set maximumFishes maximumFishes + 1]
[set winningScore [score] of turtle 0 + 5 + (level / 4)
set fishes fishes + 1
set maximumFishes maximumFishes + 1]

ask turtle 0 [
set xcor 9
set ycor 20
set heading 270
show-turtle
set hidden false]

ask turtle 1 [
set xcor 31
set ycor 20
set heading 90
set win? 2
set gameOver? 2
set reach reach + 0.1
set size size + 0.1
if (level - 1) = 5 [show-turtle]
]

crt fishes [
set xcor random-xcor
set ycor random-ycor
if ycor >= 38 [set ycor ycor - 3]
if ycor <= 2 [set ycor ycor + 3]
set color red
set shape "fish"
set size 3
set heading random 360
fd  random 10]
reset-timer
set timeAllowed timeAllowed + 5
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setupSnake
clear-drawing
clear-patches
clear-turtles
set menuOption "Turtle-Snake"
set controls "WASD"
ask patches [
set plabel "~"
set pcolor blue]
ask patches with [pxcor <= 0.5 or pycor <= 0.5 or pxcor >= 39.5 or pycor >= 39.5][set pcolor grey set plabel ""]

crt 1 [
set shape "Turtle"
set lifeSnake 3
set size 5
set color 33
set label "Bob"
set xcor 20
set ycor 20
set color 33
set heading 0
set turns 2
set lengths 0]


crt food
[set xcor 2 + random 34
set ycor 2 + random 34
set pcolor brown
set shape "fish"
set size 3
set color red]

ask turtles with [color = red][ifelse heading <= 180 [set shape "fish"][set shape "fish2"]]
set level 1
end

to reSetupSnake
clear-turtles
set menuOption "Turtle-Snake"
crt 1 [
set shape "Turtle"
set life life - 1
set size 5
set color 33
set label "Bob"
set xcor 20
set ycor 20
set color 33
set heading 0
]
crt food
[set xcor 2 + random 34
set ycor 2 + random 34
set pcolor brown
set shape "fish"
set size 3
set color red]
ask turtles with [color = red][ifelse heading < 180 [set shape "fish"][set shape "fish2"]]
end


to playSnake  
if lifeSnake < 0 [
user-message (word "You lost all your lives. ")
ifelse user-yes-or-no? "Replay?"
[ setupSnake ]
[menu]]

ask patches with [turns = 0 and pcolor != grey and pcolor != brown][set pcolor blue]
ask patches with [pcolor = red][set turns turns - 1]

ask turtle 0 
[set turns lengths
set pcolor red
fd 1
wait 1 - (speed / 100)]


if ([pcolor] of turtle 0 = red or [pcolor] of turtle 0 = grey) 
[ask turtle 0 [set lifeSnake lifeSnake - 1 die]
if lifeSnake >= 0 and notification? = true
[user-message (word "You lost a life!")]]

if turtle 0 = nobody [reSetupSnake stop]

ask turtle 0 [if distance  (min-one-of other turtles [distance myself])  <= 1.5
[set score score + 1 set lengths lengths + 2 ask other turtles in-radius 1.5 [set pcolor blue die]]]
if count patches with [pcolor = brown] < food 
[ask n-of (food - count patches with [pcolor = brown]) patches [set pcolor brown 
sprout 1 [set color red  set size 3 set shape "fish" set heading random 360]]]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setupBonus
reset-timer
ask turtle 0 [
facexy  20 20 
fd distancexy 20 20
set heading 270
fd 11
show-turtle
set hidden false]


ask turtle 1 [
facexy 20 20
set hidden true
hide-turtle 
fd distancexy 40 40
set heading 90
set win? 1
set gameOver? 1
if menuOption = "Bonus Round" [set level "A" ask turtle 1 [die]]
]

crt 10 [
set xcor random-xcor
set ycor random-ycor 
if ycor >= 38 [set ycor ycor - 3]
if ycor <= 2 [set ycor ycor + 3]
set color red
set shape "fish"
set size 3 
set heading random 360
fd random 10]
set gameRunning true
set timeAllowedBonus 60
bonusRound
end

to bonusRound
if level = 5 or menuOption = "Bonus Round" 
[set controls "Mouse"
user-message (word "Bonus Round! Eat as many fishes as you can!")]

ifelse any? turtles with [size = 3][ ][crt 10 [set color red set heading random 360 set xcor random-xcor 
set ycor random-ycor set size 3 set shape "fish"]]
end




to play
if turtle 0 = nobody and turtle 1 = nobody [user-message (word "Please press Start first!")]
if menuOption = "Turtle-Snake" [stop]

wait 1 - (speed / 100)
moveTurtle
moveFish
moveShark
collision
hatchFishes
checkWin
restart
levelUp
end

to moveTurtle          ;Uses mouse to control Turtle.
if controls = "Mouse"
[if mouse-down? [
ask turtle 0 [
facexy mouse-xcor mouse-ycor
ifelse easyMode? = true [fd 1.3][
fd 1]]]]
end

to moveFish              ;Moves the fishes randomly
ask turtles with [who != 0 and who != 1] [
if ycor >= 38 or ycor <= 2 [facexy 20 20 fd 1]           ;If fish is near the beach, move toward origin.
ifelse heading > 180 and heading < 360 [set shape "fish2"][set shape "fish"]]
ask turtles with [size = 3] [wiggle]
end

to moveShark
ask turtles with [who = 1]
[if ycor >= 38 or ycor <= 2 [facexy 20 20 fd 0.8]       ;If shark is near the beach, move towards origin.
ifelse random 10 = 1 [face turtle 0 fd 0.5]
[fd 1
if random 11 = 1 [rt 45] 
if random 11 = 1 [lt 45]]
ifelse heading > 180 and heading < 360 [set shape "shark2"][set shape "shark"] ;Changes orientation for shark.
]
end 

to wiggle         ;Move procedure for fishes.
  ifelse random 5 = 0 [fd 0.8]
 [fd 1]
 if random 8 = 1  [rt 45]
 if random 10 = 1 [lt 45]
 if random 20 = 1 [face turtle 0 lt 180]
end
  
to collision
   ask turtles with [who != 0 and who != 1]
   [if turtle 0 = nobody [stop]
   if distance turtle 0 <= 2 [ ask turtle 0 [set score score + 1] die]
   
   if level != 5 and menuOption != "Bonus Round"[
   if (distance turtle 1 <= [reach] of turtle 1) 
   [ask turtle 1 
   [set bigness bigness + 1 set size size + 0.05 set reach reach + 0.05 ]
   die]]]   
   
   if level != 5 [
   if turtle 0 = nobody or turtle 1 = nobody [stop] 
   ask turtle 0 [if distance turtle 1 <= [reach] of turtle 1
   [set hidden true
   hide-turtle
   ask turtle 1 [
   set gameOver? false
   set life life - 1
   set win? false
   if notification? = true[
   user-message (word "You got killed by the shark and lose a life.")]]]]]
   end 

to hatchFishes
if count turtles with [size = 3] < maximumFishes [
ask turtles with [who != 0 and who != 1]
[if distance  (min-one-of other turtles [distance myself])  <= 1.5
[ifelse level = 5 [if random 15 = 1 [hatch 1 [set heading random 360 fd 1]]]
[if random 20 = 1 [hatch 1 [set heading random 360 fd 1]]]]]]
end


to checkWin
ifelse level = "A" or menuOption = "Bonus Round" [if timeAllowedBonus - timer <= 0 and menuOption = "Bonus Round"
[user-message (word "Bonus round is over! Your score is " [score] of turtle 0.)
ifelse user-yes-or-no? "Replay?"
[set controls "Mouse" firstSetup setupBonus]
[menu]]]

[ifelse level != 5 and level != "A" [if turtle 1 = nobody [stop]
if  timeAllowed - timer <= 0 
[if turtle 0 = nobody [stop]
ask turtle 0 [set hidden true
hide-turtle]
ask turtle 1 [
set gameOver? false
set life life - 1
set win? false]
user-message (word "The day ended and you starved.")]

if turtle 0 != nobody 
[ask turtle 1 
[if (life - 1) < 0 
[ask turtle 0 [die]]]]

if turtle 0 = nobody
[ask turtle 1 [
set win? false
set gameOver? true]
user-message (word "You Lost!")]

if (not any? turtles with [size = 3]) and ([score] of turtle 0 <= winningScore) 
[ask turtle 1 [
set win? false
set gameOver? false
set life life - 1]
user-message (word "You did not have enough fish and starve for the day.")]

ifelse turtle 0 = nobody [][
ask turtle 0 [if score >= winningScore 
[user-message (word "Day " (level + 1) "!")
ask turtle 1 [set win? true
set gameover? false]]]]

if level = 10
[user-message (word "You survived 10 days! You win! Congratulations! Your score is " [score] of turtle 0"!")
;credits
ifelse user-yes-or-no? "Replay?"
[ firstSetup ]
[menu]]

if [win?] of turtle 1 = false and [gameOver?] of turtle 1 = true
[ifelse user-yes-or-no? "Replay?"
[ firstSetup ]
[menu]]]

[if timeLeft <= 0 [ask turtle 1 [user-message (word "Day " (level + 1) "!") set win? true set gameOver? false]]
ifelse any? turtles with [size = 3][ ][crt 10 [set color red set heading random 360 set xcor random-xcor
 set ycor random-ycor set size 3 set shape "fish"]]]]
end

to restart
if turtle 1 = nobody [stop]
if turtle 1 = nobody and turtle 0 = nobody [stop]
if [gameOver?] of turtle 1 = false and [win?] of turtle 1 = false 
[ask turtles with [size = 3] [die]
setupAgain]
end

to levelUp
if turtle 1 = nobody [stop]
if turtle 0 = nobody and turtle 1 = nobody [stop]
if [win?] of turtle 1 = true and [gameOver?] of turtle 1 = false
  [ask turtle 0 [set level level + 1]
ask turtles with [size = 3] [die]
ifelse level = 5 [setupBonus]
[setupLevel]]
end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to moveLeft
ifelse menuOption != "Turtle-Snake"
[ifelse turtle 0 = nobody [stop]
[if controls = "WASD"
[ifelse [heading] of turtle 0 = 90 [stop]
[ask turtle 0 
[set heading 270
if timer >= 1 [fd 1.5]
wait 1 - (speed / 100)]]]]]

[if turtle 0 = nobody or [heading] of turtle 0 = 90 [stop]
ask turtle 0 [set heading 270]
playSnake]
end

to moveRight
ifelse menuOption != "Turtle-Snake"
[ifelse turtle 0 = nobody [stop]
[if controls = "WASD"
[ifelse [heading] of turtle 0 = 270 [stop]
[ask turtle 0
[set heading 90
if timer >= 1  [fd 1.5]
wait 1 - (speed / 100)]]]]]

[if turtle 0 = nobody or [heading] of turtle 0 = 270 [stop]
ask turtle 0 [set heading 90]
playSnake]
end

to moveUp
ifelse menuOption != "Turtle-Snake"
[ifelse turtle 0 = nobody [stop]
[if controls = "WASD"
[ifelse [heading] of turtle 0 = 180 [stop][
ask turtle 0 
[set heading 0
if timer >= 1  [fd 1.5]
wait 1 - (speed / 100)]]]]]

[if turtle 0 = nobody or [heading] of turtle 0 = 180 [stop]
ask turtle 0[set heading 0]
playSnake]
end

to moveDown
ifelse menuOption != "Turtle-Snake"
[ifelse turtle 0 = nobody [stop][
if controls = "WASD"
[ifelse [heading] of turtle 0 = 0 [stop][
ask turtle 0 
[set heading 180
if timer >= 1 [fd 1.5]
wait 1 - (speed / 100)]]]]]

[if turtle 0 = nobody or [heading] of turtle 0 = 0 [stop]
ask turtle 0 [set heading 180]
playSnake]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report gameScore
ifelse level = 0 [report "N/A"] 
[ifelse menuOption = "Turtle-Snake" [report [score] of turtle 0]
[ifelse menuOption = "Bonus Round" [report [score] of turtle 0]
[ifelse [score] of turtle 0 >= 0 [report [score] of turtle 0]
[report 0]]]]
end
 
to-report livesLeft
ifelse level = "N/A" or level = 0 [report "N/A"]
[ifelse menuOption = "Turtle-Snake" and lifeSnake >= 0 [report lifeSnake]
[ifelse lifeSnake < 0 [report 0]
[ifelse menuOption = "Bonus Round" [report "N/A"]

[ifelse turtle 1 = nobody 
[report [life - 1] of turtle 0]
[report [life - 1] of turtle 1]]]]]
end

to-report levelOn
ifelse menuOption = "Turtle-Snake" or menuOption = "Bonus Round" or level <= 0
[report "N/A"]
[report level]
end


to-report ControlType
ifelse level <= 0  and menuOption != "BonusRound" [report "N/A"]
[report controls]
end

to-report menuoptions
report menuOption
end

to-report timeLeft
ifelse menuOption = "Turtle-Snake" [report "N/A"]
[ifelse level = 5 and timeAllowedBonus - timer > 0 [report timeAllowedBonus - timer]
[ifelse level = 5 and timeAllowedBonus - timer <= 0 [report 0]
[ifelse menuOption = "Bonus Round" and timeAllowedBonus - timer > 0 [report timeAllowedBonus - timer]
[ifelse menuOption = "Bonus Round" and timeAllowedBonus - timer <= 0 [report 0]
[ifelse level = "N/A" [report "N/A"]
[ifelse level <= 0 [report 0 ]
[ifelse timeAllowed - timer <= 0 [report 0]
[report timeAllowed - timer]]]]]]]]
end
@#$#@#$#@
GRAPHICS-WINDOW
262
10
805
574
-1
-1
13.0
1
12
1
1
1
0
1
0
1
0
40
0
40
0
0
1
ticks

BUTTON
3
10
66
43
Start
menu
NIL
1
T
OBSERVER
NIL
S
NIL
NIL

BUTTON
83
10
146
43
Play
play
T
1
T
OBSERVER
NIL
P
NIL
NIL

MONITOR
99
406
156
455
Score
gameScore
17
1
12

MONITOR
178
406
245
455
Lives Left
livesLeft
17
1
12

MONITOR
24
406
81
455
Day
levelOn
17
1
12

MONITOR
68
472
194
521
Time Until Day Ends
timeLeft
0
1
12

SLIDER
3
105
175
138
Speed
Speed
0
100
92
1
1
NIL
HORIZONTAL

BUTTON
101
217
164
250
Up
moveUp
T
1
T
OBSERVER
NIL
W
NIL
NIL

BUTTON
21
276
84
309
Left
moveLeft
T
1
T
OBSERVER
NIL
A
NIL
NIL

BUTTON
100
276
164
309
Down
moveDown
T
1
T
OBSERVER
NIL
S
NIL
NIL

BUTTON
185
277
248
310
Right
moveRight
T
1
T
OBSERVER
NIL
D
NIL
NIL

MONITOR
85
529
171
578
Control Type
ControlType
17
1
12

SLIDER
40
364
212
397
food
food
2
5
5
1
1
NIL
HORIZONTAL

SWITCH
131
49
256
82
Notification?
Notification?
0
1
-1000

@#$#@#$#@
Bill Lin
Mr. DW- Period 6

WHAT IS IT?
-----------
	This is a game where there is a young turtle, named Bob, that is hungry for fish. As Bob wanders around the sea, he tries to eat the designated amount of fish that can stop his hunger. However, there are evil sharks that tries to eat him, while also eating some of the fish that are there. The goal is for you to help Bob avoid the shark, and also getting his fish before he dies of starvation as the day ends.
	Also, in the "others" section, there is a bonus round that you can play, along with a minigame called "Turtle-Snake," which is basically a "Turtle" version of the regular snake game.

HOW IT WORKS
------------
	Use the mouse key or the WASD keys to control where Bob moves. The shark follows Bob as best as he can. You have a limited amount of seconds to catch the designated amount. If you die, or didn't catch enough fish before the day ends, you starve and lose a life. If you starve for 3 days, you die of hunger, and the game is over.        

HOW TO USE IT
-------------
Press S to start.
Press P to Play/Pause.
If you don't want notifications, set the notification switch to off.
Hold the mouse down and move it around to move the turtle.
Or you can use the WASD keys to move, but remember to press a key again to deactivate it.
IT IS HIGHLY RECOMMENDED, HOWEVER, TO USE THE MOUSE TO MOVE!

THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
In the turtle-snake mini-game, you can use the slider to control how many fishes there are to eat.


EXTENDING THE MODEL
-------------------
The model can be further improved by making a sound system, makign the keyboard controls more stable, and making more levels.


NETLOGO FEATURES
----------------
There was a problem when I was making the fish swim the right way instead of upside down when it swims to the left. What I did was I went to the shape-editor, and duplicated the fish icon, and saved it as fish2. So when the heading is between 0 and 180, it has the fish shape, but when the heading is between 180 and 360, it uses the fish2 icon.

RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
true
0
Polygon -1 true false 131 256 87 279 86 285 120 300 150 285 180 300 214 287 212 280 166 255
Polygon -1 true false 195 165 235 181 218 205 210 224 204 254 165 240
Polygon -1 true false 45 225 77 217 103 229 114 214 78 134 60 165
Polygon -7500403 true true 136 270 77 149 81 74 119 20 146 8 160 8 170 13 195 30 210 105 212 149 166 270
Circle -16777216 true false 106 55 30

fish2
true
0
Polygon -1 true false 169 256 213 279 214 285 180 300 150 285 120 300 86 287 88 280 134 255
Polygon -1 true false 105 165 65 181 82 205 90 224 96 254 135 240
Polygon -1 true false 255 225 223 217 197 229 186 214 222 134 240 165
Polygon -7500403 true true 164 270 223 149 219 74 181 20 154 8 140 8 130 13 105 30 90 105 88 149 134 270
Circle -16777216 true false 164 55 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

shark
true
0
Polygon -7500403 true true 153 17 149 12 146 29 145 -1 138 0 119 53 107 110 117 196 133 246 134 261 99 290 112 291 142 281 175 291 185 290 158 260 154 231 164 236 161 220 156 214 160 168 164 91
Polygon -7500403 true true 161 101 166 148 164 163 154 131
Polygon -7500403 true true 108 112 83 128 74 140 76 144 97 141 112 147
Circle -16777216 true false 129 32 12
Line -16777216 false 134 78 150 78
Line -16777216 false 134 83 150 83
Line -16777216 false 134 88 150 88
Polygon -7500403 true true 125 222 118 238 130 237
Polygon -7500403 true true 157 179 161 195 156 199 152 194

shark2
true
0
Polygon -7500403 true true 147 17 151 12 154 29 155 -1 162 0 181 53 193 110 183 196 167 246 166 261 201 290 188 291 158 281 125 291 115 290 142 260 146 231 136 236 139 220 144 214 140 168 136 91
Polygon -7500403 true true 139 101 134 148 136 163 146 131
Polygon -7500403 true true 192 112 217 128 226 140 224 144 203 141 188 147
Circle -16777216 true false 159 32 12
Line -16777216 false 166 78 150 78
Line -16777216 false 166 83 150 83
Line -16777216 false 166 88 150 88
Polygon -7500403 true true 175 222 182 238 170 237
Polygon -7500403 true true 143 179 139 195 144 199 148 194

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
