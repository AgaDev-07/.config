to_rgb() {
  local input="$1"
  if [[ -z "$input" ]]; then
    read -r input
  fi
  # -------------------------------
  # Case: rgb(x,x,x) → normalizar
  # -------------------------------
  if echo "$input" | grep -qi "^rgb"; then
    echo "$input" \
    | sed -E 's/[[:space:]]+//g' \
    | sed -E 's/RGB/rgb/i'
    return
  fi

  # -------------------------------
  # Case: #RGB → expandir
  # -------------------------------
  if echo "$input" | grep -qi "^#[0-9a-f][0-9a-f][0-9a-f]$"; then
    r="${input:1:1}"
    g="${input:2:1}"
    b="${input:3:1}"
    input="#${r}${r}${g}${g}${b}${b}"
  fi

  # -------------------------------
  # Case: #RRGGBB
  # -------------------------------
  if echo "$input" | grep -qi "^#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$"; then
    local r_hex="${input:1:2}"
    local g_hex="${input:3:2}"
    local b_hex="${input:5:2}"

    r_dec=$((16#${r_hex}))
    g_dec=$((16#${g_hex}))
    b_dec=$((16#${b_hex}))

    echo "rgb(${r_dec},${g_dec},${b_dec})"
    return
  fi

  echo "ERROR: formato no reconocido: $input" >&2
  return 1
}

to_hex() {
  local input="$1"
  if [[ -z "$input" ]]; then
    read -r input
  fi
  input="$(echo "$input" | tr 'A-Z' 'a-z')"

  # -------------------------------
  # Case: #rgb (3 digits)
  # -------------------------------
  if echo "$input" | grep -q "^#[0-9a-f]\{3\}$"; then
    echo "$input"
    return
  fi 
  # -------------------------------
  # Case: #rgba (4 digits)
  # -------------------------------
  if echo "$input" | grep -q "^#[0-9a-f]\{4\}$"; then
    echo "$input"
    return
  fi

  # -------------------------------
  # Case: #rrggbb (6 digits)
  # -------------------------------
  if echo "$input" | grep -q "^#[0-9a-f]\{6\}$"; then
    local r="${input:1:2}"
    local g="${input:3:2}"
    local b="${input:5:2}"

    # Si se puede simplificar (#aabbcc → #abc)
    if [[ "${r:0:1}" == "${r:1:1}" &&
          "${g:0:1}" == "${g:1:1}" &&
          "${b:0:1}" == "${b:1:1}" ]];
    then echo "#${r:0:1}${g:0:1}${b:0:1}"
    else echo "$input"
    fi
    return
  fi

  # -------------------------------
  # Case: #rrggbbaa (8 digits)
  # -------------------------------
  if echo "$input" | grep -q "^#[0-9a-f]\{8\}$"; then
    local r="${input:1:2}"
    local g="${input:3:2}"
    local b="${input:5:2}"
    local a="${input:7:2}"

    # try simplify (#aabbccdd → #abcd)
    if [[ "${r:0:1}" == "${r:1:1}" &&
          "${g:0:1}" == "${g:1:1}" &&
          "${b:0:1}" == "${b:1:1}" &&
          "${a:0:1}" == "${a:1:1}" ]];
    then echo "#${r:0:1}${g:0:1}${b:0:1}${a:0:1}"
    else echo "$input"
    fi
    return
  fi

  # -------------------------------
  # Case: rgb(r,g,b)
  # -------------------------------
  if echo "$input" | grep -q "^rgb"; then
    local nums
    nums=$(echo "$input" | sed -E 's/rgb|\(|\)|[[:space:]]//g')

    local r=$(echo "$nums" | cut -d',' -f1)
    local g=$(echo "$nums" | cut -d',' -f2)
    local b=$(echo "$nums" | cut -d',' -f3)

    # Full format #rrggbb
    hex=$(printf "#%02x%02x%02x" "$r" "$g" "$b")

    # try simplify
    local rr="${hex:1:2}"
    local gg="${hex:3:2}"
    local bb="${hex:5:2}"

    if [[ "${rr:0:1}" == "${rr:1:1}" &&
          "${gg:0:1}" == "${gg:1:1}" &&
          "${bb:0:1}" == "${bb:1:1}" ]];
    then echo "#${rr:0:1}${gg:0:1}${bb:0:1}"
    else echo "$hex"
    fi
    return
  fi

  echo "ERROR: formato no reconocido: $input" >&2
  return 1
}

# Converts #RGB → #RRGGBB. Keeps #RRGGBB as is.
hex_normalize() {
  local c="${1#\#}"
  if [[ ${#c} -eq 3 ]]; then echo "#${c:0:1}${c:0:1}${c:1:1}${c:1:1}${c:2:1}${c:2:1}"
  elif [[ ${#c} -eq 4 ]]; then echo "#${c:0:1}${c:0:1}${c:1:1}${c:1:1}${c:2:1}${c:2:1}${c:3:1}${c:3:1}"
  elif [[ ${#c} -eq 6 ]]; then echo "#$c"
  elif [[ ${#c} -eq 8 ]]; then echo "#$c"
  else echo "$1"   # fallback
  fi
}

# Adds alpha to a hex color (accepts #RGB, #RRGGBB, #RRGGBBAA)
# Example: hex_add_alpha "#f00" "45" → #ff000045
hex_add_alpha() {
  local color alpha
  color=$(hex_normalize "$1")
  alpha="$2"

  # Normalize alpha to 2 hex digits
  if [[ ${#alpha} -eq 1 ]]; then
    alpha="$alpha$alpha"
  fi

  # Strip alpha if already present
  local c="${color#\#}"
  if [[ ${#c} -eq 8 ]]; then
    c="${c:0:6}"
  fi

  echo "#${c}${alpha}"
}

hex_multiply() {
  local color="$1"
  local factor="$2"

  # pipeline fallback
  if [[ -z "$factor" ]]; then
    factor="$color"
    read -r color
  fi
  if [[ -z "$color" ]]; then
    read -r color
  fi

  # normalizar a #RRGGBB
  color=$(hex_normalize "$color")
  local c="${color#\#}"

  # normalizar factor a 00–FF
  factor="${factor,,}"
  if [[ ${#factor} -eq 1 ]]; then
    factor="$factor$factor"
  fi
  local f=$((16#$factor))

  # extraer canales
  local r=$((16#${c:0:2}))
  local g=$((16#${c:2:2}))
  local b=$((16#${c:4:2}))

  # multiplicar y normalizar
  local nr=$(( r * f / 255 ))
  local ng=$(( g * f / 255 ))
  local nb=$(( b * f / 255 ))

  # imprimir siempre 2 dígitos por canal
  printf "#%02x%02x%02x\n" "$nr" "$ng" "$nb"
}