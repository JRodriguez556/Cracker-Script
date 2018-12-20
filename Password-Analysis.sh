#!/bin/bash
makedatafolder() {
  mkdir crackdata
  mv *.del crackdata
}

starttime() {
  start_time=$(date +"%m-%d-%Y::%H:%M")
}

endtime() {
  end_time=$(date +"%m-%d-%Y::%H:%M")
}

fileclean() {
  cat $hashcatfilelocation | grep -v -F $ >> $hashcatfilelocation.no.machine.accounts.del
}

getdomains() {
  cat $hashcatfilelocation.no.machine.accounts.del | grep -F \\ | sort -u -t\\ -k1,1 | cut -f1 -d\\ >> $hashcatfilelocation.domain.select.del
  #generate list of domains
  available_domains=`cat $hashcatfilelocation.domain.select.del`
  n=0
  for suffix in $available_domains; do
    n=$((n+1))
    echo "$n:$suffix" >> domains.list.del
  done
  #have user select from list
  cat domains.list.del
  echo "input domains seperated by ,"
  read -r selected_domains
  for i in $(echo $selected_domains | sed "s/,/ /g")
  do
    grep $i domains.list.del | cut -f2 -d: >> selected.domains.del
  done
  #grep domain file to hashfile
  cat $hashcatfilelocation.no.machine.accounts.del | grep -f selected.domains.del > $hashcatfilelocation.targeted.domains.del
}

gethashtype(){
  #seperate lm vs ntlm
  cat $hashcatfilelocation.targeted.domains.del | grep -v aad3b435b51404eeaad3b435b51404ee > $hashcatfilelocation.lm.hashes.del
  cat $hashcatfilelocation.targeted.domains.del | grep aad3b435b51404eeaad3b435b51404ee > $hashcatfilelocation.ntlm.hashes.del
  cat $hashcatfilelocation.targeted.domains.del | wc -l > total.hashes.del
  cat $hashcatfilelocation.lm.hashes.del | wc -l > total.lm.hashes.del
  cat $hashcatfilelocation.ntlm.hashes.del | wc -l > total.ntlm.hashes.del
  #?should un/cracked lm hashes be included in ntlm cracking process
}

cracklm() {
 start_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$start_time" > lm.start.time.del
 /tools/hashcat/hashcat64.bin -m 3000 "$hashcatfilelocation".lm.hashes.del /wordlists/* -w 3 --session "$hashcatfilelocation".lm.hashes.restore.1
 /tools/hashcat/hashcat64.bin -m 3000 "$hashcatfilelocation".lm.hashes.del /wordlists/* -r /tools/hashcat/rules/all.pwanalysis.rule -w 3 --session "$hashcatfilelocation".lm.hashes.restore.2
 /tools/hashcat/hashcat64.bin -m 3000 "$hashcatfilelocation".lm.hashes.del /tools/hashcat/masks/* -w 3 -a 3 --session "$hashcatfilelocation".lm.hashes.restore.3
 end_time=$(date +"%m-%d-%Y::%H:%M")
 echo $"end_time" > lm.end.time.del
}

crackntlm() {
 start_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$start_time" > ntlm.start.time.del 
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes.del /wordlists/* -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.1
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes.del /wordlists/* -r /tools/hashcat/rules/all.pwanalysis.rule -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.2
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes.del /tools/hashcat/masks/* -w 3 -a 3 --session "$hashcatfilelocation".ntlm.hashes.restore.3
 end_time=$(date +"%m-%d-%Y::%H:%M")
 echo $"end_time" > ntlm.end.time.del
}

lmstats() {
  /tools/hashcat/hashcat64.bin -m 3000 --username --show -o "$hashcatfilelocation".lm.hashes.cracked --outfile-format 3 "$hashcatfilelocation".lm.hashes
  cat "$hashcatfilelocation".lm.hashes.cracked | wc -l > cracked.lm.hashes.del
}


ntlmstats() {
  /tools/hashcat/hashcat64.bin -m 1000 --username --show -o "$hashcatfilelocation".ntlm.hashes.cracked --outfile-format 3 "$hashcatfilelocation".ntlm.hashes
  cat "$hashcatfilelocation".ntlm.hashes.cracked | wc -l > cracked.ntlm.hashes.del
}

totalstats() {
  paste cracked.lm.hashes.del cracked.ntlm.hashes.del | awk '{print ($1 + $2)}' > total.cracked.hashes.del
}

#getwordlist() {
  #generate wordlist for pipal
# }
 
#pipalstats() {
#  #run wordlist through pipal
# }

#printstats() {
#  #print all stats for user
# }
echo "Please input the path to the file you want cracked. (/full/path)"
read -r hashcatfilelocation
fileclean
getdomains
gethashtype
cracklm
crackntlm
makedatafolder
