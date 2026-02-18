# ===================================
# ⚙️ Configuración base de Oh My Zsh
# ===================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

# ===================================
# 🔍 Variables de entorno
# ===================================
MINECRAFT="$HOME/.var/app/com.mcpelauncher.MCPELauncher/data/mcpelauncher/games/com.mojang"
LAUNCHER="$HOME/.var/app/com.trench.trinity.launcher/data/mcpelauncher/games/com.mojang"
PATH="$HOME/.local/bin:$PATH"
# XDG
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOADS_DIR="$HOME/Downloads"
export XDG_PICTURES_DIR="$HOME/Pictures"

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
autoload -Uz compinit && compinit
source $ZSH/oh-my-zsh.sh

# ===================================
# 🧭 Prompt y funciones personalizadas
# ===================================
setopt prompt_subst  # Permite ejecutar funciones dentro del prompt

# Icono de carpeta o home
function dir_icon {
  case "$PWD" in
    "$HOME") echo  ;;
    "$HOME/.config") echo  ;;
    "$XDG_DOWNLOADS_DIR") echo  ;;
    "$XDG_PICTURES_DIR") echo 󰉏 ;;
    "$MINECRAFT"*) echo 󰍳 ;;
    *)
      git rev-parse --is-inside-work-tree &>/dev/null && echo 󰊢 || echo 
    ;;
  esac
}
parse_git_branch() {
  # Si no es repo, salir
  git rev-parse --is-inside-work-tree &>/dev/null || return

  # Obtiene todo en un solo comando
  local raw_status
  raw_status=$(git status --porcelain=2 --branch 2>/dev/null)

  # Extraer rama o HEAD
  local branch
  branch=$(echo "$raw_status" | awk '/^# branch.head/ {print $3}')
  [[ "$branch" == "(detached)" ]] && branch=$(git rev-parse --short HEAD)

  # Adelantado / atrasado
  local ahead behind
  ahead=$(echo "$raw_status" | awk '/^# branch.ab/ {print $3}' | sed 's/+//')
  behind=$(echo "$raw_status" | awk '/^# branch.ab/ {print $4}' | sed 's/-//')

  local ahead_icon behind_icon diverged_icon
  if [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
    diverged_icon="⇕"
  else
    [[ "$ahead" -gt 0 ]] && ahead_icon="⇡$ahead"
    [[ "$behind" -gt 0 ]] && behind_icon="⇣$behind"
  fi

  # Estados del working tree (staged, modified, untracked)
  local staged dirty untracked

  echo "$raw_status" | grep -q "^1 " && dirty="!"
  echo "$raw_status" | grep -q "^2 " && staged="+"
  echo "$raw_status" | grep -q "^? " && untracked="?"

  local git_status="$staged$dirty$untracked$diverged_icon$ahead_icon$behind_icon"

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
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[bad-command]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan,bold'

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
alias dra='deno run -A'

# Este alias borra pantalla y scrollback
alias clear='clear && printf "\e[3J"'

# ===================================
# 🧩 Completions
# ===================================
fpath=(~/.zsh/completions $fpath)