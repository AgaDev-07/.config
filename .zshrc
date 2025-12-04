# ===================================
# ⚙️ Configuración base de Oh My Zsh
# ===================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

# Corrección automática de comandos
ENABLE_CORRECTION="true"

# Cargar Oh My Zsh con tus plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    sudo
    extract
    web-search
)
source $ZSH/oh-my-zsh.sh

# ===================================
# 🧭 Prompt y funciones personalizadas
# ===================================
setopt prompt_subst  # Permite ejecutar funciones dentro del prompt

# Icono de carpeta o home
function dir_icon {
    if [[ "$PWD" == "$HOME" ]]; then
        echo "%{%B%F{white}%}%{%f%b%}"
    else
        echo "%{%B%F{cyan}%}%{%f%b%}"
    fi
}
function parse_git_branch {
	local branch
	branch=$(git symbolic-ref --short HEAD 2> /dev/null)
	if [ -n "$branch" ]; then
		echo " [$branch]"
	fi
}
# Mostrar información de repos (vcs_info)
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats ' [%b]'
zstyle ':vcs_info:git*' actionformats ' [%b|%a]'
zstyle ':vcs_info:git*' check-for-changes true

# Prompt final
PROMPT='%F{cyan}󰣇 %f %F{magenta}%n%f $(dir_icon) %F{red}%~%f${vcs_info_msg_0_} %F{yellow}$(parse_git_branch)%f %(?.%B%F{green}.%F{red})%f%b '

# ===================================
# 🔍 Variables de entorno
# ===================================
export XCURSOR_THEME=RedCursor
export XCURSOR_SIZE=24
export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# ===================================
# 🔍 Colores y resaltado
# ===================================
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF4C70,bold'
ZSH_HIGHLIGHT_STYLES[bad-command]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#00AAFF,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=#00F5CE,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#00F5CE,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#00F5CE,bold'

# ===================================
# 🧾 Historial persistente
# ===================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY       # Guarda cada comando al ejecutarse
setopt SHARE_HISTORY            # Comparte entre sesiones
setopt HIST_IGNORE_ALL_DUPS     # No duplicar comandos
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# ===================================
# 📦 Alias y utilidades
# ===================================
alias install='sudo pacman -S'
alias uninstall='sudo pacman -Rns'
alias installu='sudo pacman -U'
alias update='sudo pacman -Syu'
alias brave-browser='brave'

# Este alias borra pantalla y scrollback
alias clear='clear && printf "\e[3J"'

# ===================================
# 🧰 Paths y variables de entorno
# ===================================


# ===================================
# 🧩 Completions
# ===================================
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit
