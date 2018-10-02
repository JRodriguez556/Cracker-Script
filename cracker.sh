#!/bin/bash

hashcatfile() {
  echo "Please input the path to the file you want cracked. (/full/path)"
  read -r hashcatfilelocation
  echo "What is the hashtype value (-m XXXX)?"
  echo "1000 : NTLM"
  echo "5500 : NetNTLM (Hostapd-WPE)"
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
  end=$(date +"%m-%d-%Y::%H:%M")
  /tools/hashcat/hashcat64.bin -m "$hashtype" --username --show -o "$hashcatfilelocation".cracked.start."$start".end."$end" --outfile-format 3 "$hashcatfilelocation"
  echo "Done Cracking, output file is at $hashcatfilelocation.cracked.start.$start.end.$end"
  echo "Started at $start"
  echo "Ended at $end"
}

hashcatfile
