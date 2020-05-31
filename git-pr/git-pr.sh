#!/bin/sh
#================================================================
#-    Author          Udayraj Deshmukh 
#-    Version         0.0.10
#-    Created         25/05/2020
#-    Last updated    30/05/2020
#================================================================

# Some colors for prompts
# Sequence of text colors : black (0), red, green, yellow, blue, magenta, cyan,white
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
getOwnerFromUrl(){
    # Possible urls:
    # https://github.com/Owner/Repo.git
    # git@github.com:Owner/Repo.git
    echo $1 | awk -F'github.com' '{print substr($2,2)}' | cut -d/ -f 1
}
getOwnerFromRemote(){
    local url=$(git remote get-url "$1")
    getOwnerFromUrl $url
}

getPRHead(){
    # Get current working git branch
    local PUSH_REV=$(git rev-parse --symbolic-full-name --abbrev-ref @{push});
    # Assuming remote's name doesn't have a slash
    local pushRemote=$(echo $PUSH_REV | cut -d/ -f1)
    PUSH_OWNER=$(getOwnerFromRemote $pushRemote)
    CURRENT_BRANCH=$(echo $PUSH_REV | cut -d/ -f2-)
    PR_HEAD="$PUSH_OWNER:$CURRENT_BRANCH"
    if [[ ! "$pushRemote" = "origin" ]]; then
        echo "${_blue}Note: Your branch is tracked from: ${_yellow}\"$PR_HEAD\"${_reset}"
    fi 
}

selectOwner(){
    local ownerOptions=()
    local selectLabels=()
    for remote in $(git remote | sort); do 
        local owner=$(getOwnerFromRemote $remote)
        selectLabels+=("$owner:$PR_BRANCH")
        ownerOptions+=("$owner")
    done
    
    local SELECT_LENGTH=$(( ${#selectLabels[@]} ));
    if [[ $SELECT_LENGTH = 1 ]];then 
        SELECTED_OWNER=${ownerOptions[0]}
        echo "Selecting PR ref ${selectLabels[0]}"
    else
        title="${_cyan}Choose base to create the PR with:${_reset}"
        prompt="${_cyan}Pick an option:${_reset}"

        let "SELECT_LENGTH+=1"
        echo "$title${_yellow}"
        PS3="$prompt ${_yellow}"
        select opt in ${selectLabels[@]} "Quit"; do 
            let "index=$REPLY-1"
            SELECTED_OWNER=${ownerOptions[$index]}
            if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $SELECT_LENGTH ];then
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

    # cut returns full string in "no '/' case".
    local prBranchSuffix=$(echo $PR_BRANCH | cut -f2 -d/)
    # awk returns empty string in "no '/' case".
    local issueID=$(echo $CURRENT_BRANCH | awk -F'/' '{OFS="/";$1=""; print substr($0,2)}')
    if [[ -n "$issueID" ]] && [[ ! "$prBranchSuffix" = "$issueID" ]];then
        TITLE_PREFIX="[$prBranchSuffix][$issueID]"
    else
        TITLE_PREFIX="[$prBranchSuffix]"
    fi

    MESSAGE=$(git log --oneline -n 1 | sed 's/[^ ]* //')
    PR_TITLE="$TITLE_PREFIX $MESSAGE"
    
}

confirmTitle(){
    read -e -p "${_cyan}Change title message?${_blue}(press enter to use above): ${_reset}" REPLY
    # for Bash v4: # read -e -p "PR Title: " -i "$PR_TITLE" PR_TITLE
    echo

    if [[ ! $REPLY =~ ^[\s]*$ ]]; then
        PR_TITLE="$TITLE_PREFIX $REPLY"
    fi
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
if [[ ! -n "$CUSTOM_MESSAGE" ]];then
    confirmTitle
fi
echo "${_blue}$> ${_cyan}hub pull-request -o -b \"$PR_BASE\" -h  \"$PR_HEAD\" -m \"$PR_TITLE\"${_reset}"
read -e -p "${_cyan}Press enter to run: ${_reset}" REPLY

if [[ "$REPLY" =~ ^[\s]*$ ]]; then
    hub pull-request -o -b "$PR_BASE" -h  "$PR_HEAD" -m "$PR_TITLE"
else 
    exitProgram
fi
