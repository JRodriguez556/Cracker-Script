#!/bin/bash
#todo add potfile words

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
  echo "1731 : MSSQL (2012)"
  echo " 132 : MSSQL (2005)"
  read -r hashtype
  start=$(date +"%m-%d-%Y::%H:%M")
  echo "Attempting to crack"
  echo "Starting"
  echo "Use 'q' to quit rules/masks you want skipped."
  sleep 3
  echo "RUNNNG POTFILE WORDS"
  cat /tools/hashcat/hashcat.potfile | cut -f2 -d: | sort | uniq > /tools/hashcat/potfile.words
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /tools/hashcat/potfile.words -w 3 --session "$hashcatfilelocation".restore.0
  echo "RUNNING ALL WORDLISTS..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/all.wordlists.clean -w 3 --session "$hashcatfilelocation".restore.1
  echo "RUNNING ALL WORDLISTS WITH TOP 6 RULES..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/all.wordlists.clean -r /tools/hashcat/rules/best64.rule -w 3 --session "$hashcatfilelocation".restore.2
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/all.wordlists.clean -r /tools/hashcat/rules/d3ad0ne.rule -w 3 --session "$hashcatfilelocation".restore.3
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/all.wordlists.clean -r /tools/hashcat/rules/rockyou-30000.rule -w 3 --session "$hashcatfilelocation".restore.4
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/all.wordlists.clean -r /tools/hashcat/rules/combinator.rule -w 3 --session "$hashcatfilelocation".restore.5
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/all.wordlists.clean -r /tools/hashcat/rules/leetspeak.rule -w 3 --session "$hashcatfilelocation".restore.6
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/all.wordlists.clean -r /tools/hashcat/rules/unix-ninja-leetspeak.rule -w 3 --session "$hashcatfilelocation".restore.7
  echo "RUNNING ALL RULES, THIS WILL TAKE A LONG TIME, PRESS 'q' TO SKIP..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/all.wordlists.clean -r /tools/hashcat/rules/all.pwanalysis.rule -w 3 --session "$hashcatfilelocation".restore.8
  echo "RUNNING ALL MAKS, THIS WILL TAKE A LONG TIME, PRESS 'q' to SKIP..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /tools/hashcat/masks/all.masks.clean -w 3 -a 3 --session "$hashcatfilelocation".restore.9
  end=$(date +"%m-%d-%Y::%H:%M")
  /tools/hashcat/hashcat64.bin -m "$hashtype" --username --show -o "$hashcatfilelocation".cracked.start."$start".end."$end" --outfile-format 3 "$hashcatfilelocation"
  echo "Done Cracking, output file is at $hashcatfilelocation.cracked.start.$start.end.$end"
  echo "Started at $start"
  echo "Ended at $end"
}

hashcatfile
