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
 start_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$start_time" > lm.start.time
 /tools/hashcat/hashcat64.bin -m 3000 "$hashcatfilelocation".lm.hashes /wordlists/* -w 3 --session "$hashcatfilelocation".lm.hashes.restore.1
 /tools/hashcat/hashcat64.bin -m 3000 "$hashcatfilelocation".lm.hashes /wordlists/* -r /tools/hashcat/rules/all.pwanalysis.rule -w 3 --session "$hashcatfilelocation".lm.hashes.restore.2
 /tools/hashcat/hashcat64.bin -m 3000 "$hashcatfilelocation".lm.hashes /tools/hashcat/masks/* -w 3 -a 3 --session "$hashcatfilelocation".lm.hashes.restore.3
 end_time=$(date +"%m-%d-%Y::%H:%M")
 echo $"end_time" > lm.end.time
}

crackntlm() {
 start_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$start_time" > ntlm.start.time 
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes /wordlists/* -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.1
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes /wordlists/* -r /tools/hashcat/rules/all.pwanalysis.rule -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.2
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes /tools/hashcat/masks/* -w 3 -a 3 --session "$hashcatfilelocation".ntlm.hashes.restore.3
 end_time=$(date +"%m-%d-%Y::%H:%M")
 echo $"end_time" > ntlm.end.time
}

lmstats() {
  /tools/hashcat/hashcat64.bin -m 3000 --username --show -o "$hashcatfilelocation".lm.hashes.cracked --outfile-format 3 "$hashcatfilelocation".lm.hashes
  cat "$hashcatfilelocation".lm.hashes.cracked | wc -l > cracked.lm.hashes
}


ntlmstats() {
  /tools/hashcat/hashcat64.bin -m 1000 --username --show -o "$hashcatfilelocation".ntlm.hashes.cracked --outfile-format 3 "$hashcatfilelocation".ntlm.hashes
  cat "$hashcatfilelocation".ntlm.hashes.cracked | wc -l > cracked.ntlm.hashes
}

totalstats() {
  paste cracked.lm.hashes cracked.ntlm.hashes | awk '{print ($1 + $2)}' > total.cracked.hashes
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

filename
fileclean
getdomains
gethashtype
cracklm
crackntlm
