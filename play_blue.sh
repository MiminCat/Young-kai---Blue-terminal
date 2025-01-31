#!/bin/bash

clear

stty -echo  
stty -icanon 


mpv --really-quiet blue_kai.mp3 --no-video &


MPV_PID=$!


restore_terminal() {
  stty echo  
  stty icanon  
}

handle_exit() {
  echo -e "\n\033[1;35mThank you for trying the song!\033[0m"  #color pink
  restore_terminal
  kill $MPV_PID 2>/dev/null
  exit 0
}

trap handle_exit SIGINT

show_lyrics() {
  local start_time=$(date +%s.%N)  
  local delay=0.05 
  
local COLOR='\033[38;2;255;161;242m'  
local RESET='\033[0m'  
  
  while read -r line; do
    [[ "$line" =~ ^#.* || -z "$line" ]] && continue

    timestamp=$(echo "$line" | awk '{print $1}')
    lyric=$(echo "$line" | cut -d' ' -f2-)

    current_time=$(date +%s.%N)
    elapsed=$(echo "$current_time - $start_time" | bc -l)
    wait_time=$(echo "$timestamp - $elapsed" | bc -l)
    
    if (( $(echo "$wait_time > 0" | bc -l) )); then
      sleep "$wait_time"
    fi
    
    for (( i=0; i<${#lyric}; i++ )); do
      printf "${COLOR}%s${RESET}" "${lyric:$i:1}" 
      sleep $delay                                
    done
    printf "\n"  
  done < "blue_lyrics.txt"
}

show_lyrics

kill $MPV_PID 2>/dev/null
restore_terminal
