#!/bin/sh
#================================================================
#-    Author          Udayraj Deshmukh 
#-    Version         0.1.3
#-    Created         25/05/2020
#-    Last updated    06/08/2020
#================================================================

#================= Flags and Customizations =====================
#-  choose what you want to extract in the titleElements variable
PROMPT_CONFIRM_PR_TITLE=true
PROMPT_CONFIRM_HUB_COMMAND=true
SMART_REMOTE_ORDERING=true2
#================================================================

#================================================================
##  Upcoming features: 
#-  Passing a flag to choose what to extract
#-  Remembering the last selected reference
#================================================================

# Some colors for prompts: black (0), red, green, yellow, blue, magenta, cyan, white
# https://ss64.com/bash/syntax-prompt.html
_black=$(tput setaf 0);  _red=$(tput setaf 1);  _green=$(tput setaf 2);
_yellow=$(tput setaf 3);  _blue=$(tput setaf 4);  _magenta=$(tput setaf 5);
_cyan=$(tput setaf 6);  _white=$(tput setaf 7);  _reset=$(tput sgr0);

# Args and Globals handling
if ! [ -x "$(command -v hub)" ]; then
  echo "${_red}Error: hub is not installed. Run ${_yellow}`brew install hub`${_reset}" >&2
  exit 1
fi

if [[ ! -n "$1" ]];then
    echo "${_blue}Usage: ${_yellow}git pr [owner:]branch [<message>]${_reset}"
    exit 1
fi

if [[ -n "$2" ]];then
    CUSTOM_MESSAGE="$2"
fi


# Functions/Utils
exitProgram(){
    echo "${_cyan}Goodbye!${_reset}"; 
    exit 1;
}

uniqueArray(){
    local arrayArg=("$@")
    local uniqueSep='\n' # some separator that is uncommon in array elements
    # local outSep=' ' -v ORS="$outSep" 
    printf "%s$uniqueSep" "${arrayArg[@]}" | awk -v RS="$uniqueSep" '!seen[$1]++'
}

# Flow steps
getOwnerFromUrl(){
    # Possible urls:
    # https://github.com/Owner/Repo.git
    # git@github.com:Owner/Repo.git
    echo $1 | awk -F'github.com' '{print substr($2,2)}' | cut -d/ -f 1
}
getOwnerFromRemote(){
    local url=$(git remote get-url "$1" 2> /dev/null)
    getOwnerFromUrl $url
}

getPRHead(){
    # Get current working git branch
    # CURRENT_BRANCH=$(git branch --show-current) # Requires Git 2.22+
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD) # Requires Git 1.6.3+
    # Note: renamed branch with ref by old name is not handled yet. (git branch --move will disturb this script)
    # But the zsh git prompt can point out these two separately
    PUSH_REMOTE=$(git rev-parse --symbolic-full-name --abbrev-ref @{push} 2> /dev/null); local RETURN=$?;
    if [[ ! "$RETURN" = "0" ]];then
        echo "${_red}Error: Cannot find push head${_reset}";
        echo "${_cyan}Hint: Possibly your branch '$CURRENT_BRANCH' is newly checked out. Did you forget to 'git push'?${_reset}";
        exit 1;
    fi
    # Assuming remote's name doesn't have a slash
    local pushRemote=$(echo $PUSH_REMOTE | cut -d/ -f1)
    PUSH_OWNER=$(getOwnerFromRemote $pushRemote)
    PR_HEAD="$PUSH_OWNER:$CURRENT_BRANCH"
    if [[ ! "$pushRemote" = "origin" ]]; then
        echo "${_blue}Note: Your branch is tracked from: ${_yellow}\"$PR_HEAD\"${_reset}"
    fi 
}

selectOwner(){
    local ownerOptions=()
    local selectLabels=()
    local pushRemote=$(echo $PUSH_REMOTE | cut -f 1 -d/);
    local remoteList=$(git remote | sort)
    if [[ "$SMART_REMOTE_ORDERING" = "true" ]];then
        # Smart Feat: Re-order to show upstream first, 
        #   then current push origin(if different), then the rest. 
        #   Rest of the list is sorted alphabetically
        local smartList=$(echo -e "upstream\n$pushRemote\n$remoteList" | awk '!seen[$0]++')
    else
        local smartList=$remoteList
    fi
    for remote in $smartList; do 
        local owner=$(getOwnerFromRemote $remote)
        if [[ -n "$owner" ]];then
            selectLabels+=("$owner:$PR_BRANCH")
            ownerOptions+=("$owner")
        fi
    done
    
    local SELECT_LENGTH=$(( ${#selectLabels[@]} ));
    
    # Smart Feat: Pre-select if there is only one option
    if [[ $SELECT_LENGTH = 1 ]];then 
        SELECTED_OWNER=${ownerOptions[0]}
        echo "${_blue}Selected PR ref: ${_yellow}${selectLabels[0]}${_reset}"
    else
        title="${_cyan}Choose base to create the PR with:${_reset}"
        prompt="${_cyan}Pick an option:${_reset}"

        let "SELECT_LENGTH+=1"
        echo "$title${_yellow}"
        PS3="$prompt ${_yellow}"
        select opt in ${selectLabels[@]} "Quit"; do 
            if [ 1 -le "$REPLY" ] 2>/dev/null && [ "$REPLY" -le $SELECT_LENGTH ];then
                let "index=$REPLY-1"
                SELECTED_OWNER=${ownerOptions[$index]}
                case "$REPLY" in
                $SELECT_LENGTH )exitProgram ;;
                *) break;; #echo "Picked: $SELECTED_OWNER"; break;;
                esac;
            else
                echo "${_cyan}Wrong selection: Select any number from 1-$SELECT_LENGTH${_reset}"
            fi 
        done
    fi 
}

getPRBase(){
    # Get branch info from input =s
    local OWNER=$(echo $1 |  awk '{split($0,a,":"); print a[1]}')
    PR_BRANCH=$(echo $1 | awk '{split($0,a,":"); print a[2]}')
    
    # open option to choose owner
    if [[ ! -n "$PR_BRANCH" ]];then
        PR_BRANCH="$OWNER"
        selectOwner
        OWNER="$SELECTED_OWNER" 
    fi

    PR_BASE="$OWNER:$PR_BRANCH"
}

getPRTitle(){
    if [[ -n "$CUSTOM_MESSAGE" ]];then
        PR_TITLE="$CUSTOM_MESSAGE"
        return 0
    fi

    # Note:
    # cut returns full string in "no '/' case".
    local prBranchSuffix=$(echo $PR_BRANCH | cut -f2 -d/)
    local issueID=$(echo $CURRENT_BRANCH | cut -f2 -d/)
    # awk returns empty string in "no '/' case".
    # local issueID=$(echo $CURRENT_BRANCH | awk -F'/' '{OFS="/";$1=""; print substr($0,2)}')
    
    local titleElements=(
        # "$prBranchSuffix" # Uncomment this line if want base/track branch in the title
        "$issueID"
        # Insert any extracted string here
    )
    
    # Find unique elements in the array - avoids "[master][master]" case
    titleElements=($(uniqueArray "${titleElements[@]}"))

    # Wrap square brackets to title elements
    TITLE_PREFIX=$(printf "[%s]" "${titleElements[@]}")

    # Remove empty brackets
    TITLE_PREFIX=${TITLE_PREFIX/\[\]/""};
    
    # Get latest commit from logs
    MESSAGE=$(git log --oneline -n 1 | sed 's/[^ ]* //')

    PR_TITLE="$TITLE_PREFIX $MESSAGE"
}

confirmTitle(){
    # for Bash v4: # read -e -p "PR Title: " -i "$PR_TITLE" PR_TITLE
    read -e -p "${_cyan}Change title message?${_blue}(press enter to use above): ${_reset}" REPLY
    if [[ ! "$REPLY" =~ ^[\s]*$ ]]; then
        PR_TITLE="$TITLE_PREFIX $REPLY"
    fi
    echo
}

getCompareUrl(){
    # TODO: Case of --track different head
    COMPARE_URL=$(hub compare -u -b "$PR_BASE")
    # Use expanded controls to allow changing title/creating draft PR
    COMPARE_URL="$COMPARE_URL?expand=1"
}

# Main Body

getPRHead
getPRBase $1 $2
getPRTitle
getCompareUrl
echo "${_blue}Instant Url: ${_yellow}$COMPARE_URL${_reset}"
echo
echo -e "${_blue}* * * * Summary * * * *${_reset}"
echo -e "${_blue}Base: \t${_yellow}$PR_BASE${_reset}"
echo -e "${_blue}Head: \t${_yellow}$PR_HEAD${_reset}"
echo -e "${_blue}Title: \t${_yellow}$PR_TITLE${_reset}"
if [[ ! -n "$CUSTOM_MESSAGE" ]] && [[ "$PROMPT_CONFIRM_PR_TITLE" = "true" ]];then
    confirmTitle
fi
echo "${_blue}$> ${_cyan}hub pull-request -o -b \"$PR_BASE\" -h  \"$PR_HEAD\" -m \"$PR_TITLE\"${_reset}"

if [[ "$PROMPT_CONFIRM_HUB_COMMAND" = "true" ]];then
    read -e -p "${_cyan}Press enter to run: ${_reset}" REPLY
else 
    REPLY=""
fi

if [[ "$REPLY" =~ ^[\s]*$ ]]; then
    hub pull-request -o -b "$PR_BASE" -h  "$PR_HEAD" -m "$PR_TITLE"
else 
    exitProgram
fi
