#!/usr/bin/env bash

# Check for config in order: current dir, home config, system config
if [[ -f "branches.txt" ]]; then
    CONFIG_FILE="branches.txt"
elif [[ -f "$HOME/.config/tree-swing/branches.txt" ]]; then
    CONFIG_FILE="$HOME/.config/tree-swing/branches.txt"
elif [[ -f "/etc/tree-swing/branches.txt" ]]; then
    CONFIG_FILE="/etc/tree-swing/branches.txt"
else
    CONFIG_FILE=""
fi

# --- Color definitions ---
COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1m"
COLOR_DIM="\033[2m"
COLOR_CYAN="\033[36m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_MAGENTA="\033[35m"
COLOR_RED="\033[31m"
COLOR_BG_CYAN="\033[46m"
COLOR_BG_GREEN="\033[42m"
COLOR_BLACK="\033[30m"

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
        
        echo -e "${COLOR_BOLD}${COLOR_CYAN}Select an option${COLOR_RESET} ${COLOR_DIM}(use arrow keys, press Enter to confirm)${COLOR_RESET}"
        echo ""
        for i in "${!options[@]}"; do
            if [[ $i == $selected ]]; then
                echo -e "${COLOR_BG_GREEN}${COLOR_BLACK}${COLOR_BOLD} ▶ ${options[$i]} ${COLOR_RESET}"
            else
                echo -e "${COLOR_DIM}   ${options[$i]}${COLOR_RESET}"
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

if [[ -z "$CONFIG_FILE" ]]; then
    echo -e "${COLOR_RED}${COLOR_BOLD}Error:${COLOR_RESET} branches.txt not found!"
    echo -e "${COLOR_YELLOW}Checked locations:${COLOR_RESET}"
    echo -e "${COLOR_DIM}  1. ./branches.txt (current directory)${COLOR_RESET}"
    echo -e "${COLOR_DIM}  2. ~/.config/tree-swing/branches.txt (home config)${COLOR_RESET}"
    echo -e "${COLOR_DIM}  3. /etc/tree-swing/branches.txt (system config)${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}Create a config file with format:${COLOR_RESET}"
    echo -e "${COLOR_DIM}dev develop${COLOR_RESET}"
    echo -e "${COLOR_DIM}stag staging${COLOR_RESET}"
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
    echo -e "${COLOR_CYAN}Enter branch slug:${COLOR_RESET} "
    read slug
    echo -e "${COLOR_CYAN}Enter branch name:${COLOR_RESET} "
    read branch
else
    slug="$selection"
    branch="${SLUGS[$selection]}"
fi

if [[ -z "$branch" ]]; then
    echo -e "${COLOR_RED}${COLOR_BOLD}Error:${COLOR_RESET} Branch name not found for '$slug'. Check $CONFIG_FILE"
    exit 1
fi

echo ""
echo -e "${COLOR_GREEN}✓${COLOR_RESET} Selected slug: ${COLOR_BOLD}${COLOR_MAGENTA}$slug${COLOR_RESET}"
echo -e "${COLOR_GREEN}✓${COLOR_RESET} Selected branch: ${COLOR_BOLD}${COLOR_BLUE}$branch${COLOR_RESET}"
echo ""

# --- Git operations ---
current_branch=$(git rev-parse --abbrev-ref HEAD)

echo -e "${COLOR_YELLOW}▶${COLOR_RESET} Running: ${COLOR_DIM}git fetch origin $branch:$branch --force${COLOR_RESET}"
git fetch origin "$branch:$branch" --force

echo -e "${COLOR_YELLOW}▶${COLOR_RESET} Running: ${COLOR_DIM}git branch -D for-$slug/$current_branch${COLOR_RESET}"
git branch -D "for-$slug/$current_branch" 2>/dev/null

echo -e "${COLOR_YELLOW}▶${COLOR_RESET} Running: ${COLOR_DIM}git switch -c for-$slug/$current_branch${COLOR_RESET}"
git switch -c "for-$slug/$current_branch"

echo -e "${COLOR_YELLOW}▶${COLOR_RESET} Running: ${COLOR_DIM}git merge origin/$branch${COLOR_RESET}"
git merge "origin/$branch"

echo ""
echo -e "${COLOR_GREEN}${COLOR_BOLD}✓ Done!${COLOR_RESET}"