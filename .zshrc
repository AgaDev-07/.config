# ===================================
# ⚙️ Configuración base de Oh My Zsh
# ===================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
MINECRAFT="$HOME/.var/app/com.mcpelauncher.MCPELauncher/data/mcpelauncher/games/com.mojang"

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
    echo 
  elif [[ "$PWD" == "$HOME/.config" ]]; then
    echo 
  elif [[ "$PWD" == "$HOME/Downloads" ]]; then
    echo 
  elif [[ "$PWD" == "$HOME/Pictures" ]]; then
    echo 󰉏
  elif [[ "$PWD" == "$MINECRAFT"* ]]; then
    echo 󰍳
  elif git rev-parse --is-inside-work-tree &>/dev/null; then
    echo 󰊢
  else
    echo 
  fi
}
function parse_git_branch() {
  local branch dirty staged untracked ahead behind diverged status

  # Detectar si estamos dentro de un repo
  git rev-parse --is-inside-work-tree &>/dev/null || return

  # Rama o commit si detached
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

  # Estado del repositorio
  staged=$(git diff --cached --quiet || echo "+")
  dirty=$(git diff --quiet || echo "!")
  untracked=$(git ls-files --others --exclude-standard | grep -q . && echo "?")

  # Adelantado o atrasado
  ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
  behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)

  [[ "$ahead" -gt 0 && "$behind" -gt 0 ]] && diverged="⇕" \
    || [[ "$ahead" -gt 0 ]] && ahead="⇡${ahead}" \
    || ahead=""

  [[ "$behind" -gt 0 && -z "$diverged" ]] && behind="⇣${behind}" \
    || behind=""

  git_status="$staged$dirty$untracked$diverged$ahead$behind"

  # Retorno final
  if [ -n "$git_status" ]; then
    echo "[$branch $git_status] "
  else
    echo "[$branch] "
  fi
}

# Prompt final
PROMPT='%F{cyan}󰣇 %f %F{magenta}%n%f %{%B%F{cyan}%}$(dir_icon)%{%f%b%} %F{red}%~%f %F{yellow}$(parse_git_branch)%f%(?.%B%F{green}.%F{red})%f%b '

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
setopt INC_APPEND_HISTORY     # Guarda cada comando al ejecutarse
setopt SHARE_HISTORY      # Comparte entre sesiones
setopt HIST_IGNORE_ALL_DUPS   # No duplicar comandos
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
. "/home/aga/.deno/env"