date


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# perl -MTime::HiRes=time -e 'printf "%.9f\n", time'
# If you come from bash you might have to change your $PATH.
export PATH="$HOME/bin:/usr/local/bin:$PATH:$HOME/.composer/vendor/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:/usr/local/opt/php@7.3/bin:$HOME/Library/Python/3.7/bin"

alias atom="/usr/local/bin/atom";

# Path to your oh-my-zsh installation.
export ZSH="/Users/udayrajdeshmukh7/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="agnoster"
ZSH_THEME=powerlevel10k/powerlevel10k

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git)
plugins+=(zsh-nvm)
export NVM_LAZY_LOAD=true
# export NVM_AUTO_USE=true
source $ZSH/oh-my-zsh.sh

# Note: this adds .5s to startup
#  - now the zsh-nvm plugin handles this with NVM_LAZY_LOAD=true
	# export NVM_DIR="$HOME/.nvm"
	# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
	# [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='nano'
fi

############## ############## AWESOME-BASHRC CODE BELOW ############## ##############
# <<< Made with ♥ by Udayraj >>>
GIT_USERNAME=udayraj123

myclone(){
	# Usage : 'myclone reponame' will expand to 'git clone https://github.com/yourusername/reponame' 
	git clone https://github.com/$GIT_USERNAME/$1
}
# Sequence of text colors : black (0), red, green, yellow, blue, magenta, cyan,white
# https://ss64.com/bash/syntax-prompt.html
_black=$(tput setaf 0);	_red=$(tput setaf 1);
_green=$(tput setaf 2);	_yellow=$(tput setaf 3);
_blue=$(tput setaf 4);	_magenta=$(tput setaf 5);
_cyan=$(tput setaf 6);	_white=$(tput setaf 7);
_reset=$(tput sgr0);

alias ls2="lstree"; 
alias watch="watch -d=cumulative"; # character level changes only
alias edit="open -e";
alias bashrc="sudo code -a ~/.bashrc";
#alias bashrc="sudo open -e ~/.bashrc";
alias zshrc="sudo code -a ~/.zshrc";
#alias rebash="exec bash";
alias rebash="exec zsh";
alias rezsh="exec zsh";
# alias lstree="tree -L 1 --dirsfirst -rc"
#function to print directory tree upto input level $1
lstree(){
	# shift;  COMMAND=$@; # More compatible
	COMMAND="$1 $2";
	if ([ "$COMMAND" = " " ] || [ "$COMMAND" = "" ]); then
		COMMAND="2";
	fi
	echo "$_magenta Running tree -L $COMMAND --dirsfirst -rc $_reset"
	tree -L $COMMAND --dirsfirst -rc
	echo "$_yellow Hint: use 'lstree <level> --du' to show directory sizes $_reset";
}


#function to make dir and change to it immediately
mcd(){
mkdir $1;
cd $1;
}

#lists all functions defined in this file
# echo -n "${_bold}${_blue}Functions: $_reset$_yellow";
# while read line; do
#     echo -ne "$line, ";
# done < <(grep -o '^ *\w\w*()' ~/.zshrc)
# # done < <(grep -o '^ *\w\w*()' ~/.bashrc)
# #lists all available aliases at start of terminal-
# echo -ne "\n${_bold}${_blue}Aliases: $_reset$_yellow";
# cat ~/.zshrc | awk '{if($1=="alias")printf("%s,",$2);}' | awk -F= 'BEGIN{RS=",";}{printf("%s, ",$1);}END{;}';
# echo -ne "\n$_reset";


# Important enhancements - 
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#Exports
export ZSH=/Users/udayrajdeshmukh7/.oh-my-zsh
export HOMEBREW_NO_AUTO_UPDATE=1

# PS1 with a timestamp-
# export PS1='\[$_yellow\][\D{%T}]\[$_blue\]\u\[$_green\]@\h\[$_reset\]:\[$_bold\]\[$_blue\]\W\[$_reset\]\\$ ';

export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export ANDROID_HOME=/Users/HDO/Library/Android/sdk

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

alias ka='kubectl apply -f'
alias klo='kubectl logs -f'
alias kex='kubectl exec -i -t'

alias kg='kubectl get'
alias kgpo='kubectl get pods'
alias kgpoojson='kubectl get pods -o=json'
alias kgpon='kubectl get pods --namespace '
# Note: this adds .2s to startup
# if [ /usr/local/bin/kubectl ]; then source <(kubectl completion zsh); fi

# perl -MTime::HiRes=time -e 'printf "%.9f\n", time'