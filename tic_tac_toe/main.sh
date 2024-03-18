#!/bin/bash

width=22
height=10

function drawEmpty(){
    posX=$(($1*$width))
    posY=$(($2*$height))
    
    array=(
        "                     "
        "                     "
        "                     "
        "                     "
        "                     "
        "                     "
        "                     "
        "                     "
        "                     "
    )

    for str in "${array[@]}" 
    do
        tput cup $posY $posX
        echo "$str"
        posY=$(($posY+1))
    done
}

# $1 - position x (0-2)
# $2 - position y (0-2)
function drawO(){
    posX=$(($1*$width))
    posY=$(($2*$height))
    
    # array=(
    #     "       ******       "
    #     "    **        **    "
    #     "  **            **  "
    #     " **              ** "
    #     " **              ** "
    #     " **              ** "
    #     "  **            **  "
    #     "    **        **    "
    #     "       ******       "
    # )

    array=(
        "        *****        "
        "    **         **    "
        "  **             **  "
        " **               ** "
        " **               ** "
        " **               ** "
        "  **             **  "
        "    **         **    "
        "        *****        "
    )

    for str in "${array[@]}" 
    do
        tput cup $posY $posX
        echo "$str"
        posY=$(($posY+1))
    done
}

# $1 - position x (0-2)
# $2 - position y (0-2)
function drawX(){
    posX=$(($1*$width))
    posY=$(($2*$height))
    array=(
        " **               ** "
        "   **           **   "
        "     **       **     "
        "       **   **       "
        "         ***         "
        "       **   **       "
        "     **       **     "
        "   **           **   "
        " **               ** "
    )

    for str in "${array[@]}" 
    do
        tput cup $posY $posX
        echo "$str"
        posY=$(($posY+1))
    done
}

# $1 - MAP[][X] (0-2)
# $2 - MAP[Y][] (0-2)
function drawMapCell() {
    x=$1
    y=$2
    if [ "${MAP[$y,$x]}" == "$X" ]; then
        drawX $x $y
    fi
    if [ "${MAP[$y,$x]}" == "$O" ]; then
        drawO $x $y
    fi
    if [ "${MAP[$y,$x]}" == "$empty" ]; then
        drawEmpty $x $y
    fi
    
}

function drawMap(){
    #vertical lines
    posY=0
    posX=$(($width-1))
    for ((j=0; j<2;j++));
    do
        posY=0
        for ((i=0; i<$(($height*3-1)); i++)); 
        do
            tput cup $posY $posX
            echo "|"
            posY=$(($posY+1))
        done
        posX=$(($posX+$width))
    done

    #horizontal lines
    posY=$(($height-1))
    posX=0
    for ((j=0; j<2;j++));
    do
        posX=0
        for ((i=0; i<$(($width*3))-2; i++)); 
        do
            tput cup $posY $posX
            echo "-"
            posX=$(($posX+1))
        done
        posY=$(($posY+$height))
    done
    #draw signs
    
    for ((x=0;x<3;x++)) do
        for ((y=0;y<3;y++)) do
            drawMapCell $x $y
        done
    done
}

function getKey(){
    escape_char=$(printf "\u1b")
    read -rsn1 key # get 1 character
    if [[ $key == $escape_char ]]; then
        read -rsn2 key # read 2 more chars
    fi
    echo $key
}

# $1 - position x (0-2)
# $2 - position y (0-2)
function drawSmallX(){
    posX=$(($1*$width+5))
    posY=$(($2*$height+2))
    
    array=(
        "**       **"
        "  **   **  "
        "    ***    "
        "  **   **  "
        "**       **"
    )
    if [ ${MAP[$newSelectedFieldY,$newSelectedFieldX]} -eq $empty ]; then
    tput setaf 2
    else
        tput setaf 1
    fi
    for str in "${array[@]}" 
    do
        tput cup $posY $posX
        echo "$str"
        posY=$(($posY+1))
    done
    tput setaf 7
}

# $1 - position x (0-2)
# $2 - position y (0-2)
function drawSmallO(){
    posX=$(($1*$width+5))
    posY=$(($2*$height+2))
    
    array=(
        "    ***    "
        " **     ** "
        "**       **"
        " **     ** "
        "    ***    "
    )
    if [ ${MAP[$newSelectedFieldY,$newSelectedFieldX]} -eq $empty ]; then
        tput setaf 2
    else
        tput setaf 1
    fi
    for str in "${array[@]}" 
    do
        tput cup $posY $posX
        echo "$str"
        posY=$(($posY+1))
    done
    tput setaf 7
}

function updateSelectedField(){
    drawMapCell $selectedFieldX $selectedFieldY

    if [ $currentTurn -eq $O ]; then
        drawSmallO $newSelectedFieldX $newSelectedFieldY
    fi
    if [ $currentTurn -eq $X ]; then
        drawSmallX $newSelectedFieldX $newSelectedFieldY
    fi
    selectedFieldX=$newSelectedFieldX
    selectedFieldY=$newSelectedFieldY
}

function checkWinner(){
    sum=0
    winner=0
    #check current row
    for ((x=0;x<3;x++)); do
        sum=$(($sum+${MAP[$selectedFieldY,$x]}))
    done
    if [ $sum == $(($currentTurn*3)) ]; then
        winner=$currentTurn
    fi
    sum=0
    #check current column
    for ((y=0;y<3;y++)); do
        sum=$(($sum+${MAP[$y,$selectedFieldX]}))
    done
    if [ $sum == $(($currentTurn*3)) ]; then
        winner=$currentTurn
        
    fi
    #check diagonals
    sum=0
    for ((i=0; i<3; i++)); do
        sum=$(($sum+${MAP[$i,$i]}))
    done
    if [ $sum == $(($currentTurn*3)) ]; then
        winner=$currentTurn
        
    fi

    sum=0
    for ((i=0; i<3; i++)); do
        sum=$(($sum+${MAP[$i,$((2-$i))]}))
    done
    if [ $sum == $(($currentTurn*3)) ]; then
        winner=$currentTurn
        
    fi
    echo $winner
}

function drawMenu(){
    posY=0 
    posX=70
    array=(
    "########################################"
    "################# MENU #################"
    "########################################"
    " Q - Quit                               "                                     
    " R - Reset game                         "
    "                                        "
    "                                        "
    "                                        "
    "                                        "
    "############# HOW TO PLAY ##############"
    " 1. Use arrow keys to select field      "
    " 2. Press enter to place O or X         "
    )

    for str in "${array[@]}"; do
        tput cup $posY $posX
        echo "$str"
        posY=$(($posY+1))
    done
    tput cup $posY $posX
    tput setaf 3
    if [ $enemy -eq $player ]; then
        echo "Currently playing against a human"
    else
        echo "Currently playing against a computer"
    fi
    tput setaf 7

}

function drawOWin() {
    posY=12 
    posX=70
    
    array=(
        "                 *****                 "
        "             **         **             "
        "           **             **           "
        "          **               **          "
        "          **               **          "
        "          **               **          "
        "           **             **           "
        "             **         **             "
        "                 *****                 "
        "                                       "
        " **           **     **     ***     ** " 
        " **           **     **     ****    ** "
        " **           **     **     ** **   ** "
        " **     *     **     **     **  **  ** "
        " **   ** **   **     **     **   ** ** "
        " ** **     ** **     **     **    **** "
        " **           **     **     **     *** "
    )
    tput setaf 3 
    for str in "${array[@]}"; do
        tput cup $posY $posX
        echo "$str"
        posY=$(($posY+1))
    done
    tput setaf 7
}

function drawXWin() {
    posY=12 
    posX=70
    
    array=(
        "          **               **          "
        "            **           **            "
        "              **       **              "
        "                **   **                "
        "                  ***                  "
        "                **   **                "
        "              **       **              "
        "            **           **            "
        "          **               **          "
        "                                       "
        " **           **     **     ***     ** " 
        " **           **     **     ****    ** "
        " **           **     **     ** **   ** "
        " **     *     **     **     **  **  ** "
        " **   ** **   **     **     **   ** ** "
        " ** **     ** **     **     **    **** "
        " **           **     **     **     *** "
    )
    tput setaf 3 
    for str in "${array[@]}"; do
        tput cup $posY $posX
        echo "$str"
        posY=$(($posY+1))
    done
    tput setaf 7
}

function resetWinnerBanner() {
    posY=12 
    posX=70
    array=(
        "                                       "
        "                                       "
        "                                       "
        "                                       "
        "                                       "
        "                                       "
        "                                       "
        "                                       "
        "                                       "
        "                                       "
        "                                       " 
        "                                       "
        "                                       "
        "                                       "
        "                                       "
        "                                       "
        "                                       "
    ) 
    for str in "${array[@]}"; do
        tput cup $posY $posX
        echo "$str"
        posY=$(($posY+1))
    done
}

function resetGame() {
    for ((x=0;x<3;x++)) do
        for ((y=0;y<3;y++)) do
            MAP[$y,$x]="$empty"
        done
    done
    drawMap
    currentTurn=$O
    winner=$empty
    resetWinnerBanner
    updateSelectedField
    drawMenu
}




#########################################
################ MAIN ###################
#########################################
selectedFieldX=0
selectedFieldY=0
newSelectedFieldX=0
newSelectedFieldY=0

declare -A MAP
empty=0
X=1
O=-1
currentTurn=$O
winner=$empty
player=0
computer=1
enemy=$player

for ((x=0;x<3;x++)) do
    for ((y=0;y<3;y++)) do
        MAP[$y,$x]="$empty"
    done
done

tput civis -- invisible
clear
drawMap
drawMenu
updateSelectedField


while true
    do
    keyPressed=$(getKey)
    #Selecting fields
    if [ $winner -eq $empty ]; then
    case $keyPressed in
        '[A') #up 
            if [ $selectedFieldY -ge 1 ]; then
            newSelectedFieldY=$(($selectedFieldY-1))   
            fi
            ;;
        '[B') #down 
            if [ $selectedFieldY -le 1 ]; then
            newSelectedFieldY=$(($selectedFieldY+1))
            fi
            ;;
        '[D') #left 
            if [ $selectedFieldX -ge 1 ]; then
            newSelectedFieldX=$(($selectedFieldX-1))
            fi
            ;;
        '[C') #right
            if [ $selectedFieldX -le 1 ]; then
            newSelectedFieldX=$(($selectedFieldX+1))
            fi
            ;;
        '') #enter
            if [ "${MAP[$selectedFieldY,$selectedFieldX]}" == "$empty" ]; then
                MAP[$selectedFieldY,$selectedFieldX]=$currentTurn          
                winner=$(checkWinner)
                      
                if [ $winner -eq $O ]; then
                    drawOWin
                fi
                if [ $winner -eq $X ]; then
                    drawXWin
                fi
                currentTurn=$(($currentTurn*-1))
            fi
            ;;
        *) ;;
    esac
    updateSelectedField
    fi
    #MENU
    case $keyPressed in
        'q') 
            echo QUITTING
            clear 
            exit 
            ;;
        'r')
            resetGame
            ;;
        'c')
            resetGame
            if [ $enemy -eq $player ]; then
                enemy=$computer
            else
                enemy=$player
            fi
            
    esac
done


