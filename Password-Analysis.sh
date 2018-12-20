#!/bin/bash
filename() {
  echo "Please input the path to the file you want cracked. (/full/path)"
  read -r hashcatfilelocation
}

makedatafolder {
  mkdir crackdata
}

starttime() {
  start_time=$(date +"%m-%d-%Y::%H:%M")
}

endtime() {
  end_time=$(date +"%m-%d-%Y::%H:%M")
}

fileclean() {
  cat $hashcatfilelocation | grep -v -F $ >> $hashcatfilelocation.no.machine.accounts
}

getdomains() {
  cat $hashcatfilelocation.no.machine.accounts | grep -F \\ | sort -u -t\\ -k1,1 | cut -f1 -d\\ >> $hashcatfilelocation.domain.select
  #generate list of domains
  available_domains=`cat $hashcatfilelocation.domain.select`
  n=0
  for suffix in $available_domains; do
    n=$((n+1))
    echo "$n:$suffix" >> domains.list 
  done
  #have user select from list
  cat domains.list
  echo "input domains seperated by ,"
  read -r selected_domains
  for i in $(echo $selected_domains | sed "s/,/ /g")
  do
    grep $i domains.list | cut -f2 -d: >> selected.domains
  done
  #grep domain file to hashfile
  cat $hashcatfilelocation.no.machineaccounts | grep -f selected.domains > $hashcatfilelocation.targeted.domains
}

gethashtype(){
  #seperate lm vs ntlm
  cat $hashcatfilelocation.targeted.domains | grep -v aad3b435b51404eeaad3b435b51404ee > $hashcatfilelocation.lm.hashes
  cat $hashcatfilelocation.targeted.domains | grep aad3b435b51404eeaad3b435b51404ee > $hashcatfilelocation.ntlm.hashes
  cat $hashcatfilelocation.targeted.domains | wc -l > total.hashes
  cat $hashcatfilelocation.lm.hashes | wc -l > total.lm.hashes
  cat $hashcatfilelocation.ntlm.hashes | wc -l > total.ntlm.hashes
  #?should un/cracked lm hashes be included in ntlm cracking process
}

cracklm() {
  /tools/hashcat/hashcat64.bin -m  "$hashcatfilelocation" /wordlists/* -w 3 --session "$hashcatfilelocation".restore.1 
}


crackntlm() {
  #crack all ntlm
}

lmstats() {
  #get lm cracked stats
}


ntlmstats() {
  #get ntlm stats
}

getwordlist(){
  #generate wordlist for pipal
 }
 
pipalstats(){
  #run wordlist through pipal
 }

printstats() {
  #print all stats for user
 }
hashcat() {
  echo "Please input the path to the file you want cracked. (/full/path)"
  read -r hashcatfilelocation
  start=$(date +"%m-%d-%Y::%H:%M")
  echo "Attempting to crack"
  echo "Starting"
  echo "Use 'q' to quit rules/masks you want skipped."
  sleep 3
  echo "RUNNING ALL WORDLISTS..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -w 3 --session "$hashcatfilelocation".restore.1
  echo "RUNNING ALL WORDLISTS WITH TOP 6 RULES..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/best64.rule -w 3 --session "$hashcatfilelocation".restore.2
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/d3ad0ne.rule -w 3 --session "$hashcatfilelocation".restore.3
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/rockyou-30000.rule -w 3 --session "$hashcatfilelocation".restore.4
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/combinator.rule -w 3 --session "$hashcatfilelocation".restore.5
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/leetspeak.rule -w 3 --session "$hashcatfilelocation".restore.6
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/unix-ninja-leetspeak.rule -w 3 --session "$hashcatfilelocation".restore.7
  echo "RUNNING ALL RULES, THIS WILL TAKE A LONG TIME, PRESS 'q' TO SKIP..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /wordlists/* -r /tools/hashcat/rules/ALL.ALL -w 3 --session "$hashcatfilelocation".restore.8
  echo "RUNNING ALL MAKS, THIS WILL TAKE A LONG TIME, PRESS 'q' to SKIP..."
  /tools/hashcat/hashcat64.bin -m "$hashtype" "$hashcatfilelocation" /tools/hashcat/masks/* -w 3 -a 3 --session "$hashcatfilelocation".restore.9
  end=$(date +"%m-%d-%Y::%H:%M")
  /tools/hashcat/hashcat64.bin -m "$hashtype" --username --show -o "$hashcatfilelocation".cracked.start."$start".end."$end" --outfile-format 3 "$hashcatfilelocation"
  echo "Done Cracking, output file is at $hashcatfilelocation.cracked.start.$start.end.$end"
  echo "Started at $start"
  echo "Ended at $end"
}

hashcatfile
