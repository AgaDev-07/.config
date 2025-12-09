#!/bin/bash
source "$HOME/.config/aga/lib/require.sh"
send_notification() {
  SOUND=dialog-information
  [[ "$1" == "critical" ]] && SOUND=dialog-error
  paplay /usr/share/sounds/freedesktop/stereo/$SOUND.oga
  notify-send -u $1 -a "$2" -i "$3" "$2" "$4"
}