if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
alias xbrew='arch -x86_64 /usr/local/bin/brew' # X86 Homebrew


export PATH=$PATH:/Users/jhill/Library/Android/sdk/platform-tools
export PATH=$PATH:/Users/jhill/Development/flutter/bin
export PATH=$PATH:/Users/jhill/bin
#  export NVM_DIR="$HOME/.nvm"
#  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
#  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm" 
eval $(thefuck --alias)
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# TODO: Fix long term to completion-dependent directories permissions
ZSH_DISABLE_COMPFIX="true"

# Path to your oh-my-zsh installation.
export ZSH="/Users/jhill/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

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
# DISABLE_UNTRACKED_FILES_DIRTY="true"

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
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git colored-man-pages colorize github jira vagrant virtualenv pip python brew macos fasd docker kubectl helm)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias stree='/Applications/SourceTree.app/Contents/Resources/stree'
alias vault-login="vault login -no-print=true -method=github username=josmo token=`cat $HOME/.local_config/github_token`"

export VAULT_ADDR=https://vault.pelo.tech:8200
export NPM_TOKEN=`cat $HOME/.local_config/npm_token`
export OPENCONNECT_USER=`cat $HOME/.local_config/vpn_user`
export OPENCONNECT_HOST=`cat $HOME/.local_config/vpn_host`


function vpn-up-gs() {
 one
 USER=v_jgrannec
 PASSWORD_ITEM=gamestop
 TOKEN_SECRET=$(op get totp "$PASSWORD_ITEM")
 AUTH_GROUP="vpn_isquad_mfa"
 PASSWORD=$(op get item $PASSWORD_ITEM | jq -r '.details.fields[] | select(.designation=="password").value')
 { printf "$PASSWORD\n"; sleep 2; printf "$TOKEN_SECRET\n"; } | sudo openconnect \
 --background \
 --pid-file="$HOME/.openconnect.pid" \
 --authgroup="$AUTH_GROUP" \
 --servercert pin-sha256:J6oHAiOd0dh4B+kgX+GvMIrPmHSR9+N4dGuOOPjeNVg= \
 --user="$USER" \
 --passwd-on-stdin \
 vpn.gamestop.com
}

function vpn-up-tmo() {
 one
 SPLIT_COMMAND=""
 AUTH_GROUP="AnyConnectVIDP"
 if [[ "$1" == "split" ]]
 then
   SPLIT_COMMAND="--script='$HOME/.local_config/vpnc-script.sh'"
 fi

  op get item tmobile | jq -r '.details.fields[] | select(.designation=="password").value' | sudo openconnect \
  --background \
  --pid-file="$HOME/.openconnect.pid" \
  --authgroup="$AUTH_GROUP" \
  --user=$OPENCONNECT_USER \
  $SPLIT_COMMAND \
  --useragent='AnyConnect Darwin_x64 3.9.04053' \
  --passwd-on-stdin \
  $OPENCONNECT_HOST
}

function vpn-split() {
  vpn-up-tmo split
}
function vpn-down() {
    if [[ -f "$HOME/.openconnect.pid" ]]; then
        sudo kill -2 $(cat "$HOME/.openconnect.pid") && rm -f "$HOME/.openconnect.pid"
    else
        echo "openconnect pid file does not exist, probably not running"
    fi
}
function unifi() {
 cd /Applications/UniFi.app/Contents/Resources
 java -jar /Applications/UniFi.app/Contents/Resources/lib/ace.jar ui
}
function one() {
 eval $(security find-generic-password -w -s "1password" | op signin grannec)
}
function wp-aws() {
 op get totp 'warbyparker aws' | aws-mfa --profile wp
}
function gs-aws() {
 PASSWORD_ITEM=gamestop
 if [ -z "$1" ];
 then
   echo "no environment specified - gs-launchpad-sandbox, gs-launchpad-preprod, or gs-launchpad-prod are options"
 else
  one
  TOKEN_SECRET=$(op get totp "$PASSWORD_ITEM")
  PASSWORD=$(op get item $PASSWORD_ITEM | jq -r '.details.fields[] | select(.designation=="password").value')
  saml2aws login --skip-prompt --password=$PASSWORD --mfa-token=$TOKEN_SECRET --session-duration=3600  --cache-saml -a $1
 fi
}

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
GPG_TTY=$(tty)
export GPG_TTY

