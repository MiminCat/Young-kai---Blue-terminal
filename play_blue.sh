#!/bin/bash

# Clear terminal
clear

# Nonaktifkan input keyboard
stty -echo  # Menonaktifkan echo input
stty -icanon  # Menonaktifkan mode kanonikal (input langsung tanpa buffering)

# Putar musik tanpa output progress
mpv --really-quiet blue_kai.mp3 --no-video &

# Simpan PID mpv
MPV_PID=$!

# Fungsi untuk mengembalikan pengaturan terminal ke normal
restore_terminal() {
  stty echo  # Mengaktifkan kembali echo input
  stty icanon  # Mengaktifkan kembali mode kanonikal
}

# Fungsi untuk menangani Ctrl+C
handle_exit() {
  echo -e "\n\033[1;35mThank you for trying the song!\033[0m"  # Warna pink
  restore_terminal
  kill $MPV_PID 2>/dev/null
  exit 0
}

# Tangkap Ctrl+C dan panggil handle_exit
trap handle_exit SIGINT

show_lyrics() {
  local start_time=$(date +%s.%N)  # Waktu mulai script
  local delay=0.05  # Delay per karakter (0.10 detik untuk efek medium)

  # Warna ANSI (pink)
  
local COLOR='\033[38;2;255;161;242m'  # Warna pink #ffa1f2
local RESET='\033[0m'  # Reset warna ke default
  # Reset warna ke default

  while read -r line; do
    [[ "$line" =~ ^#.* || -z "$line" ]] && continue

    # Ekstrak timestamp dan lirik
    timestamp=$(echo "$line" | awk '{print $1}')
    lyric=$(echo "$line" | cut -d' ' -f2-)

    # Hitung waktu tunggu sebelum menampilkan lirik
    current_time=$(date +%s.%N)
    elapsed=$(echo "$current_time - $start_time" | bc -l)
    wait_time=$(echo "$timestamp - $elapsed" | bc -l)

    # Tunggu sampai waktu yang ditentukan
    if (( $(echo "$wait_time > 0" | bc -l) )); then
      sleep "$wait_time"
    fi

    # Tampilkan lirik dengan efek ketik dan warna
    for (( i=0; i<${#lyric}; i++ )); do
      printf "${COLOR}%s${RESET}" "${lyric:$i:1}"  # Cetak satu karakter dengan warna
      sleep $delay                                 # Delay per karakter
    done
    printf "\n"  # Pindah ke baris baru setelah lirik selesai
  done < "blue_lyrics.txt"
}

show_lyrics

# Hentikan mpv setelah selesai
kill $MPV_PID 2>/dev/null
restore_terminal