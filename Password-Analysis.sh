#!/bin/bash
#todo
#fix hex thing

makedatafolder() {
  mkdir Crackdata."$main_start_time"
  rm domains.list."$main_start_time"
  rm $hashcatfilelocation.domain.select."$main_start_time"
  rm $hashcatfilelocation.no.machine.accounts."$main_start_time"
  rm cracked.ntlm.hashes."$main_start_time"
  rm ntlm.end.time."$main_start_time"
  rm ntlm.start.time."$main_start_time"
  rm percent.ntlm.hashes."$main_start_time"
  rm percent.ntlm.hashes.pre."$main_start_time"
  rm percent.total.hashes."$main_start_time"
  rm percent.total.hashes.pre."$main_start_time"
  mv "$hashcatfilelocation".all.cracked.hashes."$main_start_time" "$hashcatfilelocation".full.cracked.hashes.list."$main_start_time"
  rm "$hashcatfilelocation".lm.hashes."$main_start_time"
  rm "$hashcatfilelocation".ntlm.hashes."$main_start_time"
  rm "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time"
  rm "$hashcatfilelocation".pipalstats."$main_start_time"
  rm "$hashcatfilelocation".targeted.domains."$main_start_time"
  cat "$hashcatfilelocation".wordlist."$main_start_time" | sort | uniq > "$hashcatfilelocation".compromised.words.list."$main_start_time"
  rm "$hashcatfilelocation".wordlist."$main_start_time"
  rm selected.domains."$main_start_time"
  rm total.cracked.hashes."$main_start_time"
  rm total.hashes."$main_start_time"
  rm total.lm.hashes."$main_start_time"
  rm total.hashes."$main_start_time"
  rm cracked.lm.hashes."$main_start_time"
  rm lm.end.time."$main_start_time"
  rm lm.start.time."$main_start_time"
  rm percent.lm.hashes."$main_start_time"
  rm percent.lm.hashes.pre."$main_start_time"
  rm "$hashcatfilelocation".lm.hashes.cracked."$main_start_time"
  cat "$hashcatfilelocation".full.cracked.hashes.list."$main_start_time" | cut -f1 -d: > "$hashcatfilelocation".compromised.users."$main_start_time"
  mv *."$main_start_time" Crackdata."$main_start_time"
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
  cat $hashcatfilelocation.targeted.domains."$main_start_time" > $hashcatfilelocation.ntlm.hashes."$main_start_time"
  cat $hashcatfilelocation.targeted.domains."$main_start_time" | wc -l > total.hashes."$main_start_time"
  cat $hashcatfilelocation.lm.hashes."$main_start_time" | wc -l > total.lm.hashes."$main_start_time"
  cat $hashcatfilelocation.ntlm.hashes."$main_start_time" | wc -l > total.hashes."$main_start_time"
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
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" /wordlists/all.wordlists.clean -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.1
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" /wordlists/all.wordlists.clean -r /tools/hashcat/rules/all.pwanalysis.rule -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.2
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" -w 3 -a 3  --increment  ?a?a?a?a?a?a?a --session "$hashcatfilelocation".ntlm.hashes.restore.4
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" /tools/hashcat/masks/* -w 3 -a 3 --session "$hashcatfilelocation".ntlm.hashes.restore.3
 end_time=$(date +"%m-%d-%Y::%H:%M")
 echo "$end_time" > ntlm.end.time."$main_start_time"
}

lmstats() {
  /tools/hashcat/hashcat64.bin -m 3000 --username --show -o "$hashcatfilelocation".lm.hashes.cracked."$main_start_time" --outfile-format 3 "$hashcatfilelocation".lm.hashes."$main_start_time"
  cat "$hashcatfilelocation".lm.hashes.cracked."$main_start_time" | wc -l > cracked.lm.hashes."$main_start_time"
}

lmtontlm() {
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" -w 3 -r /tools/hashcat/rules/lm2ntlm.rule "$hashcatfilelocation".compromised.words.list."$main_start_time"
}

ntlmstats() {
  /tools/hashcat/hashcat64.bin -m 1000 --username --show -o "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time" --outfile-format 3 "$hashcatfilelocation".ntlm.hashes."$main_start_time"
  cat "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time" | wc -l > cracked.ntlm.hashes."$main_start_time"
}

totalstats() {
  cat cracked.ntlm.hashes."$main_start_time"  > total.cracked.hashes."$main_start_time"
  cat "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time" > "$hashcatfilelocation".all.cracked.hashes."$main_start_time"
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
    echo The Targeted Domains Are: | tee -a "$hashcatfilelocation".stats."$main_start_time"
    echo $(<selected.domains."$main_start_time")| tee -a "$hashcatfilelocation".stats."$main_start_time"
  #print totals HASHES
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo The Total Number of Hashes Obtained Is: | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo $(<total.hashes."$main_start_time") | tee -a "$hashcatfilelocation".stats."$main_start_time"
  #print total lm HASHES
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo The Total Number of LM Hashes Obtained Is: | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo $(<total.lm.hashes."$main_start_time") | tee -a "$hashcatfilelocation".stats."$main_start_time"
  #print toal ntlm HASHES
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo The Total Number of NTLM Hashes Obtained Is: | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo $(<total.hashes."$main_start_time") | tee -a "$hashcatfilelocation".stats."$main_start_time"
  #print total cracked HASHES
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo The Total Number of Cracked Hashes Is: | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo $(<total.cracked.hashes."$main_start_time") | tee -a "$hashcatfilelocation".stats."$main_start_time"
  #print total cracked lm HASHES
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo The Total Number of Cracked LM Hashes Is: | tee -a "$hashcatfilelocation".stats."$main_start_time"
  lmhashcount=$(< total.lm.hashes."$main_start_time")
  if ((lmhashcount > 0)); then
                  echo $(<cracked.lm.hashes."$main_start_time") | tee -a "$hashcatfilelocation".stats."$main_start_time"
		  echo "!!!!!!WARNING!!!!!!"
		  echo "!!!!!!LM HASHES FOUND!!!!!!"
                  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
                  echo LM Start Time: $(<lm.start.time."$main_start_time") | tee -a "$hashcatfilelocation".stats."$main_start_time"
                  echo LM End Time:   $(<lm.end.time."$main_start_time") | tee -a "$hashcatfilelocation".stats."$main_start_time"
          else
                  echo "NO LM HASHES FOUND (GOOD)" | tee -a "$hashcatfilelocation".stats."$main_start_time"
  fi
    #print total cracked ntlm HASHES
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo The Total Number of Cracked NTLM Hashes Is: | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo $(<cracked.ntlm.hashes."$main_start_time") | tee -a "$hashcatfilelocation".stats."$main_start_time"
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo NTLM Start Time: $(<ntlm.start.time."$main_start_time") | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo NTLM End Time:   $(<ntlm.end.time."$main_start_time") | tee -a "$hashcatfilelocation".stats."$main_start_time"
  #find percent of total hashes cracked
  bc <<<"scale=4; $(<total.cracked.hashes."$main_start_time") / $(<total.hashes."$main_start_time")" > percent.total.hashes.pre."$main_start_time"
  bc <<<"scale=2; $(<percent.total.hashes.pre."$main_start_time") * (100)" > percent.total.hashes."$main_start_time"
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo The Percent of Total Hashes Cracked Is: | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo $(<percent.total.hashes."$main_start_time")"%" | tee -a "$hashcatfilelocation".stats."$main_start_time"
  #find percent of total lm hashes cracked
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo The Percent of LM Hashes Cracked Is: | tee -a "$hashcatfilelocation".stats."$main_start_time"
  lmhashcount=$(< total.lm.hashes."$main_start_time")
  if ((lmhashcount > 0)); then
      bc <<<"scale=4; $(<cracked.lm.hashes."$main_start_time") / $(<total.lm.hashes."$main_start_time")" > percent.lm.hashes.pre."$main_start_time"
      bc <<<"scale=2; $(<percent.lm.hashes.pre."$main_start_time") * (100)" > percent.lm.hashes."$main_start_time"
      echo $(<percent.lm.hashes."$main_start_time")"%" | tee -a "$hashcatfilelocation".stats."$main_start_time"
    else
      echo NO LM HASHES | tee -a "$hashcatfilelocation".stats."$main_start_time"
  fi
  #find percent of total ntlm hashes cracked
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo The Percent of NTLM Hashes Cracked Is: | tee -a "$hashcatfilelocation".stats."$main_start_time"
  bc <<<"scale=4; $(<cracked.ntlm.hashes."$main_start_time") / $(<total.hashes."$main_start_time")" > percent.ntlm.hashes.pre."$main_start_time"
  bc <<<"scale=2; $(<percent.ntlm.hashes.pre."$main_start_time") * (100)" > percent.ntlm.hashes."$main_start_time"
  echo $(<percent.ntlm.hashes."$main_start_time")"%" | tee -a "$hashcatfilelocation".stats."$main_start_time"
  #######
  printf \\n | tee -a "$hashcatfilelocation".stats."$main_start_time"
  echo "Password Statistics:"
  printf \\n
  cat "$hashcatfilelocation".pipalstats."$main_start_time" | grep "Basic" -A 50 | grep -v Basic --color=never | tee -a "$hashcatfilelocation".stats."$main_start_time"
  cat "$hashcatfilelocation".pipalstats."$main_start_time" | grep "One to six characters" -A 27 --color=never | tee -a "$hashcatfilelocation".stats."$main_start_time"
  cat "$hashcatfilelocation".pipalstats."$main_start_time" | grep "Last digit" -A 90 --color=never | tee -a "$hashcatfilelocation".stats."$main_start_time"
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
                lmtontlm
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
