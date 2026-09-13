if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi
autoload -Uz +X compinit && compinit
autoload -Uz +X bashcompinit && bashcompinit
eval "$(/opt/homebrew/bin/brew shellenv)"

export SOPS_AGE_KEY=$(tail -1 ~/.config/sops/age/keys.txt)
launchctl setenv SOPS_AGE_KEY $SOPS_AGE_KEY
export GOPATH=$HOME/Development/workspace
export GRAALVM_HOME=/Library/Java/JavaVirtualMachines/graalvm-ce-java17-22.3.1/Contents/Home/
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
export PATH=$PATH:$HOME/Development/flutter/bin
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.jetbrains
export PATH=$PATH:/Library/Java/JavaVirtualMachines/graalvm-ce-java17-22.3.1/Contents/Home/bin
export XDG_CONFIG_HOME=$HOME/.config
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
alias kfilt="kubectl kfilt"
eval "$(fnm env --use-on-cd)"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# TODO: Fix long term to completion-dependent directories permissions
ZSH_DISABLE_COMPFIX="true"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

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
plugins=(git colored-man-pages colorize github jira vagrant virtualenv pip python brew macos fasd docker kubectl helm aws fzf npm gradle)

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
alias vim="nvim"
alias vi="nvim"

function one() {
 eval $(security find-generic-password -w -s "1password" | op signin --account grannec)
}

function kall {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i
    kubectl -n ${1} get --ignore-not-found ${i}
  done
}


export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"


GPG_TTY=$(tty)
export GPG_TTY

source $HOME/.oh-my-zsh/custom/plugins/fzf-tab-completion/zsh/fzf-zsh-completion.sh

source $HOME/.tenv.completion.zsh
. "/Users/jhill/.deno/env"
# BEGIN_AWS_SSO_CLI

# AWS SSO requires `bashcompinit` which needs to be enabled once and
# only once in your shell.  Hence we do not include the two lines:
#
# autoload -Uz +X compinit && compinit
# autoload -Uz +X bashcompinit && bashcompinit
#
# If you do not already have these lines, you must COPY the lines
# above, place it OUTSIDE of the BEGIN/END_AWS_SSO_CLI markers
# and of course uncomment it

__aws_sso_profile_complete() {
     local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    _multi_parts : "($(/nix/store/r8z4cb7nwqdpgn6mlknqlikjshm0wgvr-aws-sso-cli-2.3.2/bin/.aws-sso-wrapped ${=_args} list --csv Profile))"
}

aws-sso-profile() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    local _sso=""
    local _profile=""

    if [ -n "$AWS_PROFILE" ]; then
        echo "Unable to assume a role while AWS_PROFILE is set"
        return 1
    fi

    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            -S|--sso)
                shift
                if [ -z "$1" ]; then
                    echo "Error: -S/--sso requires an argument"
                    return 1
                fi
                _sso="$1"
                shift
                ;;
            -*)
                echo "Unknown option: $1"
                echo "Usage: aws-sso-profile [-S|--sso <sso-instance>] <profile>"
                return 1
                ;;
            *)
                if [ -z "$_profile" ]; then
                    _profile="$1"
                else
                    echo "Error: Multiple profiles specified"
                    return 1
                fi
                shift
                ;;
        esac
    done

    if [ -z "$_profile" ]; then
        echo "Usage: aws-sso-profile [-S|--sso <sso-instance>] <profile>"
        return 1
    fi

    # Build and execute the eval command with optional SSO flag
    if [ -n "$_sso" ]; then
        eval $(/nix/store/r8z4cb7nwqdpgn6mlknqlikjshm0wgvr-aws-sso-cli-2.3.2/bin/.aws-sso-wrapped ${=_args} -S "$_sso" eval -p "$_profile")
    else
        eval $(/nix/store/r8z4cb7nwqdpgn6mlknqlikjshm0wgvr-aws-sso-cli-2.3.2/bin/.aws-sso-wrapped ${=_args} eval -p "$_profile")
    fi

    if [ "$AWS_SSO_PROFILE" != "$_profile" ]; then
        return 1
    fi
}

aws-sso-clear() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    if [ -z "$AWS_SSO_PROFILE" ]; then
        echo "AWS_SSO_PROFILE is not set"
        return 1
    fi
    eval $(/nix/store/r8z4cb7nwqdpgn6mlknqlikjshm0wgvr-aws-sso-cli-2.3.2/bin/.aws-sso-wrapped ${=_args} eval -c)
}

compdef __aws_sso_profile_complete aws-sso-profile
complete -C /nix/store/r8z4cb7nwqdpgn6mlknqlikjshm0wgvr-aws-sso-cli-2.3.2/bin/.aws-sso-wrapped aws-sso

# END_AWS_SSO_CLI

# Added by Antigravity
export PATH="/Users/jhill/.antigravity/antigravity/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/jhill/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"

# ==========================================
# MLX-LM Model Management for OpenCode
# ==========================================

# 1. Safety stop function
stop_mlx() {
    echo "Stopping any running MLX-LM servers to free up unified memory..."
    # Suppress the kill error if no process is found
    pkill -f "mlx_lm.server" 2>/dev/null && echo "Memory cleared." || echo "No server currently running."
}

# 2. Start Qwen 32B (The Daily Driver)
start_qwen() {
    stop_mlx
    echo "Starting Qwen2.5-Coder 32B (32k context)..."
    nohup mlx_lm.server --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit --port 8080 > /tmp/mlx_server.log 2>&1 &

    echo "Server spinning up. Tailing logs..."
    echo "(Press Ctrl+C to exit the log view. The server will keep running in the background.)"
    sleep 2
    tail -f /tmp/mlx_server.log
}

# 3. Start Mixtral 8x7B (The Fast Alternative)
start_mixtral() {
    stop_mlx
    echo "Starting Mixtral 8x7B Instruct (32k context)..."
    nohup mlx_lm.server --model mlx-community/Mixtral-8x7B-Instruct-v0.1-4bit --port 8080 > /tmp/mlx_server.log 2>&1 &

    echo "Server spinning up. Tailing logs..."
    echo "(Press Ctrl+C to exit the log view. The server will keep running in the background.)"
    sleep 2
    tail -f /tmp/mlx_server.log
}

# 4. Start Llama 3.1 70B (The Heavyweight)
start_llama() {
    stop_mlx
    echo "Starting Llama 3.1 70B (8k context limit)..."
    echo "WARNING: This will consume ~48GB of RAM. Close Docker/heavy browsers if possible."
    nohup mlx_lm.server --model mlx-community/Meta-Llama-3.1-70B-Instruct-4bit --port 8080 > /tmp/mlx_server.log 2>&1 &

    echo "Server spinning up. Tailing logs..."
    echo "(Press Ctrl+C to exit the log view. The server will keep running in the background.)"
    sleep 2
    tail -f /tmp/mlx_server.log
}


