#!/bin/bash
#todo
#fix makedatafolder

makedatafolder() {
  mkdir crackdata."$main_start_time"
  rm domains.list."$main_start_time"
  rm $hashcatfilelocation.domain.select."$main_start_time"
  rm $hashcatfilelocation.no.machine.accounts."$main_start_time"
  mv *."$main_start_time" crackdata."$main_start_time"
}

starttime() {
  start_time=$(date +"%m-%d-%Y::%H:%M")
}

endtime() {
  end_time=$(date +"%m-%d-%Y::%H:%M")
}

fileclean() {
  cat $hashcatfilelocation | grep -v -F $ >> $hashcatfilelocation.no.machine.accounts."$main_start_time"
}

getdomains() {
  cat $hashcatfilelocation.no.machine.accounts."$main_start_time" | grep -F \\ | sort -u -t\\ -k1,1 | cut -f1 -d\\ >> $hashcatfilelocation.domain.select."$main_start_time"
  available_domains=`cat $hashcatfilelocation.domain.select."$main_start_time"`
  n=0
  for suffix in $available_domains; do
    n=$((n+1))
    echo "'$n':uniqselectorforreasons:$suffix" >> domains.list."$main_start_time"
  done
  #have user select from list
  cat domains.list."$main_start_time" | cut -f1,3 -d:
  echo "input domains seperated by ,"
  read -r selected_domains
  for i in $(echo $selected_domains | sed "s/,/ /g")
  do
    grep "'$i':uniqselectorforreasons" domains.list."$main_start_time" | cut -f3 -d: >> selected.domains."$main_start_time"
  done
  #grep domain file to hashfile
  cat $hashcatfilelocation.no.machine.accounts."$main_start_time" | grep -f selected.domains."$main_start_time" > $hashcatfilelocation.targeted.domains."$main_start_time"
}

gethashtype(){
  #seperate lm vs ntlm
  cat $hashcatfilelocation.targeted.domains."$main_start_time" | grep -v aad3b435b51404eeaad3b435b51404ee > $hashcatfilelocation.lm.hashes."$main_start_time"
  cat $hashcatfilelocation.targeted.domains."$main_start_time" | grep aad3b435b51404eeaad3b435b51404ee > $hashcatfilelocation.ntlm.hashes."$main_start_time"
  cat $hashcatfilelocation.targeted.domains."$main_start_time" | wc -l > total.hashes."$main_start_time"
  cat $hashcatfilelocation.lm.hashes."$main_start_time" | wc -l > total.lm.hashes."$main_start_time"
  cat $hashcatfilelocation.ntlm.hashes."$main_start_time" | wc -l > total.ntlm.hashes."$main_start_time"
}

cracklm() {
 start_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$start_time" > lm.start.time."$main_start_time"
 /tools/hashcat/hashcat64.bin -m 3000 "$hashcatfilelocation".lm.hashes."$main_start_time" -w 3 -a 3 -1 ?u?d?s --increment  ?1?1?1?1?1?1?1 --session "$hashcatfilelocation".lm.hashes.restore.1
 end_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$end_time" > lm.end.time."$main_start_time"
}

crackntlm() {
 start_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$start_time" > ntlm.start.time."$main_start_time"
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" /wordlists/* -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.1
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" /wordlists/* -r /tools/hashcat/rules/all.pwanalysis.rule -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.2
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" /tools/hashcat/masks/* -w 3 -a 3 --session "$hashcatfilelocation".ntlm.hashes.restore.3
 end_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$end_time" > ntlm.end.time."$main_start_time"
}

lmstats() {
  /tools/hashcat/hashcat64.bin -m 3000 --username --show -o "$hashcatfilelocation".lm.hashes.cracked."$main_start_time" --outfile-format 3 "$hashcatfilelocation".lm.hashes."$main_start_time"
  cat "$hashcatfilelocation".lm.hashes.cracked."$main_start_time" | wc -l > cracked.lm.hashes."$main_start_time"
}

ntlmstats() {
  /tools/hashcat/hashcat64.bin -m 1000 --username --show -o "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time" --outfile-format 3 "$hashcatfilelocation".ntlm.hashes."$main_start_time"
  cat "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time" | wc -l > cracked.ntlm.hashes."$main_start_time"
}

totalstats() {
  paste cracked.lm.hashes."$main_start_time" cracked.ntlm.hashes."$main_start_time" | awk '{print ($1 + $2)}' > total.cracked.hashes."$main_start_time"
  cat "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time" "$hashcatfilelocation".lm.hashes.cracked."$main_start_time" > "$hashcatfilelocation".all.cracked.hashes."$main_start_time"
  cat "$hashcatfilelocation".all.cracked.hashes."$main_start_time" | wc -l > total.cracked.hashes."$main_start_time"
}

getwordlist() {
  cat "$hashcatfilelocation".all.cracked.hashes."$main_start_time" | cut -f3 -d: > "$hashcatfilelocation".wordlist."$main_start_time"
}

pipalstats() {
  /tools/pipal/pipal.rb "$hashcatfilelocation".wordlist."$main_start_time" > "$hashcatfilelocation".pipalstats."$main_start_time"
}

printstats() {
  #print targeted domains
    printf \\n
    printf \\n
    echo The targeted domains are: | tee -a ""$hashcatfilelocation"".stats
    echo $(<selected.domains."$main_start_time")| tee -a ""$hashcatfilelocation"".stats
  #print totals HASHES
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  echo The Total Number of hashes obtained is: | tee -a ""$hashcatfilelocation"".stats
  echo $(<total.hashes."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
  #print total lm HASHES
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  echo the total number of LM hashes is: | tee -a ""$hashcatfilelocation"".stats
  echo $(<total.lm.hashes."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
  #print toal ntlm HASHES
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  echo The total number of NTLM Hashes is: | tee -a ""$hashcatfilelocation"".stats
  echo $(<total.ntlm.hashes."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
  #print total cracked HASHES
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  echo The total number of cracked hashes is: | tee -a ""$hashcatfilelocation"".stats
  echo $(<total.cracked.hashes."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
  #print total cracked lm HASHES
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  echo the total number of cracked lm hashes is: | tee -a ""$hashcatfilelocation"".stats
  lmhashcount=$(< total.lm.hashes."$main_start_time")
  if ((lmhashcount > 0)); then
                  echo $(<cracked.lm.hashes."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
		  echo "!!!!!!WARNING!!!!!!"
		  echo "!!!!!!LM HASHES FOUND!!!!!!"
                  printf \\n | tee -a ""$hashcatfilelocation"".stats
                  echo LM Start time: $(<lm.start.time."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
                  echo LM End time:   $(<lm.end.time."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
          else
                  echo NO LM HASHES | tee -a ""$hashcatfilelocation"".stats
  fi
    #print total cracked ntlm HASHES
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  echo the total number of cracked ntml hashes is: | tee -a ""$hashcatfilelocation"".stats
  echo $(<cracked.ntlm.hashes."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  echo NTLM Start time: $(<ntlm.start.time."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
  echo NTLM End time:   $(<ntlm.end.time."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
  #find percent of total hashes cracked
  bc <<<"scale=4; $(<total.cracked.hashes."$main_start_time") / $(<total.hashes."$main_start_time")" > percent.total.hashes.pre."$main_start_time"
  bc <<<"scale=2; $(<percent.total.hashes.pre."$main_start_time") * (100)" > percent.total.hashes."$main_start_time"
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  echo The percent of total hashes cracked is | tee -a ""$hashcatfilelocation"".stats
  echo $(<percent.total.hashes."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
  #find percent of total lm hashes cracked
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  echo the percent of lm hashes cracked is | tee -a ""$hashcatfilelocation"".stats
  lmhashcount=$(< total.lm.hashes."$main_start_time")
  if ((lmhashcount > 0)); then
      bc <<<"scale=4; $(<cracked.lm.hashes."$main_start_time") / $(<total.lm.hashes."$main_start_time")" > percent.lm.hashes.pre."$main_start_time"
      bc <<<"scale=2; $(<percent.lm.hashes.pre."$main_start_time") * (100)" > percent.lm.hashes."$main_start_time"
      echo $(<percent.lm.hashes."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
    else
      echo NO LM HASHES | tee -a ""$hashcatfilelocation"".stats
  fi
  #find percent of total ntlm hashes cracked
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  echo the percent of ntlm hashes cracked is | tee -a ""$hashcatfilelocation"".stats
  bc <<<"scale=4; $(<cracked.ntlm.hashes."$main_start_time") / $(<total.ntlm.hashes."$main_start_time")" > percent.ntlm.hashes.pre."$main_start_time"
  bc <<<"scale=2; $(<percent.ntlm.hashes.pre."$main_start_time") * (100)" > percent.ntlm.hashes."$main_start_time"
  echo $(<percent.ntlm.hashes."$main_start_time") | tee -a ""$hashcatfilelocation"".stats
  #######
  printf \\n | tee -a ""$hashcatfilelocation"".stats
  cat "$hashcatfilelocation".pipalstats."$main_start_time" | grep "Basic" -A 50 | grep -v Basic --color=never | tee -a ""$hashcatfilelocation"".stats
  cat "$hashcatfilelocation".pipalstats."$main_start_time" | grep "One to six characters" -A 27 --color=never | tee -a ""$hashcatfilelocation"".stats
  cat "$hashcatfilelocation".pipalstats."$main_start_time" | grep "Last digit" -A 90 --color=never | tee -a "$hashcatfilelocation".stats
}

echo "Please input the path to the file you want cracked. (/full/path)"
read -r hashcatfilelocation
main_start_time=$(date +"%m-%d-%Y-%H-%M")
fileclean
getdomains
gethashtype
lmhashcount=$(< total.lm.hashes."$main_start_time")
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
pipalstats
printstats
printf \\n
makedatafolder
