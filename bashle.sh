#! /usr/bin/bash

RESET="\033[0m"
MATCH="\e[1m"
POS="\e[4m"
WRONG="\e[2m"

function is_in_dict {
    for i in "${words[@]}"; do
        if [ "$1" = "$i" ]; then
            return 0
        fi
    done
    return 1
}


# Compare word and guess, draw hints

function compare {
    local word="$1"
    local guess="$2"

    declare -A matching_letters
    local i
    for (( i = 0; i < "${#guess}"; i++ )); do
        local word_letter="${word:$i:1}"
        local guess_letter="${guess:$i:1}"

        if [ ! "${matching_letters[$guess_letter]+abc}" ]; then
            matching_letters[$guess_letter]=0
        fi

        if [ "$guess_letter" = "$word_letter" ]; then
            matching_letters[$guess_letter]=$(( matching_letters[$guess_letter] + 1 ))
        fi
    done

    declare -A shown_wrong_pos
    for (( i = 0; i < "${#guess}"; i++ )); do
        local word_letter="${word:$i:1}"
        local guess_letter="${guess:$i:1}"

        if [ ! "${shown_wrong_pos[$guess_letter]+abc}" ]; then
            shown_wrong_pos[$guess_letter]=0
        fi

        if [ "$guess_letter" = "$word_letter" ]; then
            echo -en "${MATCH}$guess_letter${RESET}"
        else
            local shown_and_matching_letters=$(( shown_wrong_pos[$guess_letter] + matching_letters[$guess_letter] ))
            if [ "${letters[$guess_letter]+abc}" ] && [ "$shown_and_matching_letters" -lt "${letters[$guess_letter]}" ]; then
                echo -en "${POS}$guess_letter${RESET}"
                shown_wrong_pos[$guess_letter]=$(( shown_wrong_pos[$guess_letter] + 1 ))
            else
                echo -en "${WRONG}$guess_letter${RESET}"
            fi
        fi

    done

}


# Read list of words

words=()

while read -r line; do
    words+=( "$line" )
done < "$1"


# Select random word form list

num_words="${#words[@]}"
word="${words[$(( RANDOM % num_words ))]^^}"


# Show initial hint

for (( i=0; i < "${#word}"; i++ )); do
    echo -n . 
done
echo


# Create map letter occurences

declare -A letters
for (( i=0; i < "${#word}"; i++ )); do
    letter="${word:$i:1}"

    if [ ! "${letters[$letter]+abc}" ]; then
        letters[$letter]=0
    fi

    letters[$letter]="$(( letters[$letter] + 1 ))"
done


# Main loop

for (( guess_no=0; guess_no<6; guess_no++ )); do
    while true; do
        read -r guess
        guess="${guess^^}"
        
        if [ "${#guess}" -ne "${#word}" ]; then
            echo "wrong length"
            continue
        fi
        
        if ! is_in_dict "$guess"; then
            echo "word not in dictionary"
            continue
        fi

        break
    done

    compare "$word" "$guess"
    
    if [ "$guess" = "$word" ]; then
        echo
        echo "you found the word in $guess_no tries"
        exit 0
    fi

    echo
done

echo

echo "solution: $word"
