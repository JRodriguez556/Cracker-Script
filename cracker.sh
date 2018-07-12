#!/bin/bash
filetype() {
  echo "Is this a hashcat file or asleap C/R?"
  echo "1: Hashcat"
  echo "2: Asleap"
##
# echo "3: Aircrack (WPA-PSK)"
##
  read -r file_type
  if [ "$file_type" = "1" ]; then
    hashcatfile
  elif [ "$file_type" = "2" ]; then
    asleapfile
##
#  elif [ "$file_type" = "3"]; then
#    aircracker
##
  else
    echo "Please try again"
    filetype
  fi
}

hashcatfile() {
  echo "Please input the path to the file you want cracked. (/full/path)"
  read -r hashcatfilelocation
  echo "What is the hashtype value (-m XXXX)?"
  echo "1000 : NTLM"
  echo "5600 : NetNTLM (Responder)"
  echo "7300 : IPMI"
  echo "2500 : WPA/WPA2"
  echo "3000 : LM"
  read -r hashtype
  start=$(date +"%m-%d-%Y::%H:%M")
  echo "Attempting to crack"
  echo "Starting"
  echo "Use 'q' to quit rules/masks you want skipped."
  sleep 3
  echo "RUNNING ALL WORDLISTS..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -w 3
  echo "RUNNING ALL WORDLISTS WITH TOP 6 RULES..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/best64.rule -w 3
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/d3ad0ne.rule -w 3
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/rockyou-30000.rule -w 3
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/combinator.rule -w 3
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/leetspeak.rule -w 3
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/unix-ninja-leetspeak.rule -w 3
  echo "RUNNING ALL RULES, THIS WILL TAKE A LONG TIME, PRESS 'q' TO SKIP..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/ALL.ALL -w 3
  echo "RUNNING ALL MAKS, THIS WILL TAKE A LONG TIME, PRESS 'q' to SKIP..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /tools/hashcat/masks/* -w 3 -a 3
  /tools/hashcat/hashcat64.bin -m "$hashtype" --username --show -o "$hashcatfilelocation".cracked."$start" --outfile-format 3 "$hashcatfilelocation"
  end=$(date +"%m-%d-%Y::%H:%M")
  echo "Done Cracking, output file is at $hashcatfilelocation.cracked.start.$start.end.$end"
  echo "Started at $start"
  echo "Ended at $end"
}

asleapfile() {
  echo "please input the Challenge"
  read -r challenge
  echo "Please input the Response"
  read -r response
  echo "Cracking with best options"
  echo "SCRIPT WILL NOT STOP ON SUCCESSFUL CRACK, PLEASE MONITOR STDOUT"
  sleep 3
  /tools/hashcat/hashcat64.bin /wordlists/* --stdout| /opt/asleap/asleap -C "$challenge" -R "$response" -W -
  /tools/hashcat/hashcat64.bin /wordlists/* -r /tools/hashcat/rules/best64.rule -w 3  --stdout| /opt/asleap/asleap -C "$challenge" -R "$response" -W -
  /tools/hashcat/hashcat64.bin /wordlists/* -r /tools/hashcat/rules/d3ad0ne.rule -w 3 --stdout| /opt/asleap/asleap -C "$challenge" -R "$response" -W -
  /tools/hashcat/hashcat64.bin /wordlists/* -r /tools/hashcat/rules/rockyou-30000.rule -w 3  --stdout| /opt/asleap/asleap -C "$challenge" -R "$response" -W -
  /tools/hashcat/hashcat64.bin /wordlists/* -r /tools/hashcat/rules/combinator.rule -w 3  --stdout| /opt/asleap/asleap -C "$challenge" -R "$response" -W -
  /tools/hashcat/hashcat64.bin /wordlists/* -r /tools/hashcat/rules/leetspeak.rule -w 3  --stdout| /opt/asleap/asleap -C "$challenge" -R "$response" -W -
  /tools/hashcat/hashcat64.bin /wordlists/* -r /tools/hashcat/rules/unix-ninja-leetspeak.rule -w 3  --stdout| /opt/asleap/asleap -C "$challenge" -R "$response" -W -
  /tools/hashcat/hashcat64.bin /tools/hashcat/masks/* -a 3 -w 3  --stdout| /opt/asleap/asleap -C "$challenge" -R "$response" -W -
  echo "done cracking"
}
##
#aircracker() {
#
#}
##
filetype
