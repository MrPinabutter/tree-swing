#!/usr/bin/env bash

CONFIG_FILE="branches.txt"

# --- function to show arrow-key menu ---
function choose_option() {
    local options=("$@")
    local selected=0
    
    # Hide cursor
    tput civis
    
    while true; do
        # Move cursor to top and clear from there
        tput cup 0 0
        tput ed
        
        echo "Select an option (use arrow keys, press Enter to confirm):"
        echo ""
        for i in "${!options[@]}"; do
            if [[ $i == $selected ]]; then
                echo "> ${options[$i]}"
            else
                echo "  ${options[$i]}"
            fi
        done

        read -rsn1 input
        if [[ $input == $'\x1b' ]]; then
            read -rsn2 -t 0.1 extra
            input+="$extra"
        fi

        case "$input" in
            $'\x1b[A') # up
                ((selected--))
                if ((selected < 0)); then selected=$((${#options[@]} - 1)); fi
                ;;
            $'\x1b[B') # down
                ((selected++))
                if ((selected >= ${#options[@]})); then selected=0; fi
                ;;
            "") # enter
                # Clear screen and show cursor
                tput clear
                tput cnorm
                # Return the selection via a variable instead of echo
                CHOSEN_OPTION="${options[$selected]}"
                return
                ;;
        esac
    done
}

# --- Load defaults from txt ---
declare -A SLUGS

if [[ ! -f $CONFIG_FILE ]]; then
    echo "branches.txt not found! Create a file like:"
    echo "dev develop"
    echo "stag staging"
    exit 1
fi

while read -r slug branch; do
  [[ -z "$slug" || -z "$branch" ]] && continue
  SLUGS[$slug]=$branch
done < "$CONFIG_FILE"

# Menu options
OPTIONS=("${!SLUGS[@]}" "other")

choose_option "${OPTIONS[@]}"
selection="$CHOSEN_OPTION"

if [[ "$selection" == "other" ]]; then
    read -p "Enter branch slug: " slug
    read -p "Enter branch name: " branch
else
    slug="$selection"
    branch="${SLUGS[$selection]}"
fi

if [[ -z "$branch" ]]; then
    echo "Branch name not found for '$slug'. Check branches.txt"
    exit 1
fi

echo "Selected slug: $slug"
echo "Selected branch: $branch"

# --- Git operations ---
current_branch=$(git rev-parse --abbrev-ref HEAD)

echo "Running: git fetch origin $branch:$branch --force"
git fetch origin "$branch:$branch" --force

echo "Running: git branch -D for-$slug/$current_branch"
git branch -D "for-$slug/$current_branch" 2>/dev/null

echo "Running: git switch -c for-$slug/$current_branch"
git switch -c "for-$slug/$current_branch"

echo "Running: git merge origin/$branch"
git merge "origin/$branch"

echo "Done!"