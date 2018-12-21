#!/bin/bash
#todo
#add stats
#add check for lm hashes
#change file names

makedatafolder() {
  mkdir crackdata
  rm domains.list.del
  rm $hashcatfilelocation.domain.select.del
  rm $hashcatfilelocation.no.machine.accounts.del
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
  available_domains=`cat $hashcatfilelocation.domain.select.del`
  n=0
  for suffix in $available_domains; do
    n=$((n+1))
    echo "'$n'uniqselectorforreasons:$suffix" >> domains.list.del
  done
  #have user select from list
  cat domains.list.del
  echo "input domains seperated by ,"
  read -r selected_domains
  for i in $(echo $selected_domains | sed "s/,/ /g")
  do
    grep "'$i'uniqselectorforreasons" domains.list.del | cut -f2 -d: >> selected.domains.del
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
}

cracklm() {
 start_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$start_time" > lm.start.time.del
 /tools/hashcat/hashcat64.bin -m 3000 "$hashcatfilelocation".lm.hashes.del -w 3 -a 3 -1 ?u?d?s --increment  ?1?1?1?1?1?1?1 --session "$hashcatfilelocation".lm.hashes.restore.1
 end_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$end_time" > lm.end.time.del
}

crackntlm() {
 start_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$start_time" > ntlm.start.time.del
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes.del /wordlists/* -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.1
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes.del /wordlists/* -r /tools/hashcat/rules/all.pwanalysis.rule -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.2
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes.del /tools/hashcat/masks/* -w 3 -a 3 --session "$hashcatfilelocation".ntlm.hashes.restore.3
 end_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$end_time" > ntlm.end.time.del
}

lmstats() {
  /tools/hashcat/hashcat64.bin -m 3000 --username --show -o "$hashcatfilelocation".lm.hashes.cracked.del --outfile-format 3 "$hashcatfilelocation".lm.hashes.del
  cat "$hashcatfilelocation".lm.hashes.cracked.del | wc -l > cracked.lm.hashes.del
}

ntlmstats() {
  /tools/hashcat/hashcat64.bin -m 1000 --username --show -o "$hashcatfilelocation".ntlm.hashes.cracked.del --outfile-format 3 "$hashcatfilelocation".ntlm.hashes.del
  cat "$hashcatfilelocation".ntlm.hashes.cracked.del | wc -l > cracked.ntlm.hashes.del
}

totalstats() {
  paste cracked.lm.hashes.del cracked.ntlm.hashes.del | awk '{print ($1 + $2)}' > total.cracked.hashes.del
  cat "$hashcatfilelocation".ntlm.hashes.cracked.del "$hashcatfilelocation".lm.hashes.cracked.del > "$hashcatfilelocation".all.cracked.hashes.del
  cat "$hashcatfilelocation".all.cracked.hashes.del | wc -l >> total.cracked.hashes.del
}

getwordlist() {
  cat "$hashcatfilelocation".all.cracked.hashes.del | cut -f3 -d: > "$hashcatfilelocation".wordlist.del
}

pipalstats() {
  /tools/pipal/pipal.rb "$hashcatfilelocation".wordlist.del > "$hashcatfilelocation".pipalstats.del
}

printstats() {
  #print targeted domains
    printf The targeted domains are \\n
    echo $(<selected.domains.del)
  #print totals HASHES
  printf \\n
  echo The Total Number of hashes obtained is:
  echo $(<total.hashes.del)
  #print total lm HASHES
  printf \\n
  echo the total number of LM hashes is:
  echo $(<total.lm.hashes.del)
  #print toal ntlm HASHES
  printf \\n
  echo The total number of NTLM Hashes is:
  echo $(<total.ntlm.hashes.del)
  #print total cracked HASHES
  printf \\n
  echo The total number of cracked hashes is:
  echo $(<total.cracked.hashes.del)
  #print total cracked lm HASHES
  printf \\n
  echo the total number of cracked lm hashes is:
  echo $(<cracked.lm.hashes.del)
  #print total cracked ntlm HASHES
  printf \\n
  echo the total number of cracked ntml hashes is:
  echo $(<cracked.ntlm.hashes.del)
  #find percent of total hashes cracked
  #find percent of total lm hashes cracked
  #find percent of total ntlm hashes cracked

  #print
}

echo "Please input the path to the file you want cracked. (/full/path)"
read -r hashcatfilelocation
fileclean
getdomains
gethashtype
lmhashcount=$(< total.lm.hashes.del)
if ((lmhashcount > 0)); then
                cracklm
                lmstats
        else
                echo NO LM HASHES
fi
crackntlm
ntlmstats
totalstats
getwordlist
printstats
makedatafolder
