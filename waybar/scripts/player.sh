max=15;

player=$(playerctl -l 2>/dev/null | head -n1)
title=$(playerctl metadata --format '{{ title }}' 2>/dev/null || echo 'Sin reproducción')
artist=$(playerctl metadata --format '{{ artist }}' 2>/dev/null || echo '')

if [[ $player == *'spotify'* ]]; then
  icon='';
elif [[ $player == *'brave'* ]]; then
    if [[ $title == *'YouTube'* ]] || [[ $artist == *'YouTube'* ]]; then
    icon=''
  else
    icon=''
  fi
elif [[ $player == *'vlc'* ]]; then
  icon='󰕼'

elif [[ $player == *'mpv'* ]]; then
  icon=''
else
  icon='🎵';
fi


if [[ ${#title} -gt $max ]]; then
  title=\"${title:0:$max}...\";
fi

echo $icon  $artist: $title