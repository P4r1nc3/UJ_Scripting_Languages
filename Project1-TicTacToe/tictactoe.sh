#!/bin/bash

# Initialize the board
BOARD=("-" "-" "-" "-" "-" "-" "-" "-" "-")
END_GAME=0
PLAYER="X"
WINNER=""

# Function to display the Tic-Tac-Toe board
function display_board {
    echo " ${BOARD[0]} | ${BOARD[1]} | ${BOARD[2]} "
    echo "-----------"
    echo " ${BOARD[3]} | ${BOARD[4]} | ${BOARD[5]} "
    echo "-----------"
    echo " ${BOARD[6]} | ${BOARD[7]} | ${BOARD[8]} "
}

# Function to check conditions for a win or tie
function check_condition() {
    if [[ ${END_GAME} -eq 0 ]]; then
        if [[ ${BOARD[$1]} != "-" ]] && [ "${BOARD[$1]}" == "${BOARD[$2]}" ] && [ "${BOARD[$1]}" == "${BOARD[$3]}" ]; then
            END_GAME=1
            WINNER=${PLAYER}
            echo "Player ${PLAYER} wins!"
        fi
    fi
}

# Function to check for a win
function check_winner() {
    # horizontal
    check_condition 0 1 2
    check_condition 3 4 5
    check_condition 6 7 8
    # vertical
    check_condition 0 3 6
    check_condition 1 4 7
    check_condition 2 5 8
    # cross
    check_condition 0 4 8
    check_condition 2 4 6
}

# Function to update the board
function update_board {
    local move=$1
    BOARD[$move]=$PLAYER
}

# Function to switch player
function switch_player {
    if [ "${PLAYER}" == "X" ]; then
        PLAYER="O"
    else
        PLAYER="X"
    fi
}

# Function to save the game
function save_game {
    echo "Enter the filename to save the game:"
    read -r filename
    filename="${filename}.txt"
    echo "${BOARD[@]}" > "$filename"
    echo "${PLAYER}" >> "$filename"
    echo "${END_GAME}" >> "$filename"
    echo -e "\n\nGame saved successfully to file: $filename"
    exit 0
}

# Function to restore the game
function restore_game {
    echo "Enter the filename to restore the game:"
    read -r filename
    filename="${filename}.txt"
    if [[ -f $filename ]]; then
        if [ "$(cat ${filename} | sed -n '1p')" != "" ]; then
            BOARD=($(cat ${filename} | sed -n '1p'))
        fi
        if [ "$(cat ${filename} | sed -n '2p')" != "" ]; then
            PLAYER=$(cat ${filename} | sed -n '2p')
        fi
        if [ "$(cat ${filename} | sed -n '3p')" != "" ]; then
            END_GAME=$(cat ${filename} | sed -n '3p')
        fi
    else
        END_GAME=0
    fi
}

# Function to get available moves
function get_available_moves {
    local available_moves=()
    for i in "${!BOARD[@]}"; do
        if [ "${BOARD[$i]}" == "-" ]; then
            available_moves+=("$((i+1))")
        fi
    done
    echo "${available_moves[@]}"
}

# Function to play the game against the computer
function player_vs_computer {
    while true; do
        clear
        display_board

        # Get the current player's move
        if [ "${PLAYER}" == "X" ]; then
            echo "Player ${PLAYER}'s turn. Enter a number (1-9), 'S' to save, or 'Q' to quit: "
            read -r move
        else
            # Computer's move
            available_moves=($(get_available_moves))
            if [ "${#available_moves[@]}" -eq 0 ]; then
                echo "It's a tie! The board is full."
                break
            fi
            move=${available_moves[$((RANDOM % ${#available_moves[@]}))]}
            sleep 1
            echo "Computer (O) chooses $move"
        fi

        # Check if the move is 'Q' for quitting
        if [ "$move" == "Q" ]; then
            echo "Game aborted."
            break
        fi

        # Check if the move is 'S' for saving
        if [ "$move" == "S" ]; then
            save_game
        fi

        # If not 'S' or 'Q', process the move
        if ! [[ "$move" =~ ^[1-9]$ ]] || [ "${BOARD[move-1]}" != "-" ]; then
            echo "Invalid move. Please try again."
            sleep 1
            continue
        fi

        # Update the board with the move
        update_board $((move-1))

        # Check for a win or tie
        check_winner

        # Exit the loop if the game has ended
        if [ ${END_GAME} -eq 1 ]; then
            clear
            display_board
            echo "Player ${WINNER} wins!"
            break
        fi

        # Switch to the other player
        switch_player
    done
}

# Function to play the game between two players
function player_vs_player {
    while true; do
        clear
        display_board

        # Get the current player's move
        echo "Player ${PLAYER}'s turn. Enter a number (1-9), 'S' to save, or 'Q' to quit: "
        read -r move

        # Check if the move is 'Q' for quitting
        if [ "$move" == "Q" ]; then
            echo "Game aborted."
            break
        fi

        # Check if the move is 'S' for saving
        if [ "$move" == "S" ]; then
            save_game
        fi

        # If not 'S' or 'Q', process the move
        if ! [[ "$move" =~ ^[1-9]$ ]] || [ "${BOARD[move-1]}" != "-" ]; then
            echo "Invalid move. Please try again."
            sleep 1
            continue
        fi

        # Update the board with the move
        update_board $((move-1))

        # Check for a win or tie
        check_winner

        # Exit the loop if the game has ended
        if [ ${END_GAME} -eq 1 ]; then
            clear
            display_board
            echo "Player ${WINNER} wins!"
            break
        fi

        # Switch to the other player
        switch_player
    done
}

function reset_board {
    BOARD=("-" "-" "-" "-" "-" "-" "-" "-" "-")
    END_GAME=0
    PLAYER="X"
    WINNER=""
}

# Menu
function menu {
    while true; do
        echo "Menu:"
        echo "1. New Game (Player vs Player)"
        echo "2. New Game (Player vs Computer)"
        echo "3. Load Game"
        echo "4. Quit"
        echo "Enter your choice (1-4): "
        read -r choice

        case $choice in
            1)
                player_vs_player
                ;;
            2)
                player_vs_computer
                ;;
            3)
                restore_game
                player_vs_player
                ;;
            4)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 4."
                ;;
        esac
        reset_board
    done
}

menu
