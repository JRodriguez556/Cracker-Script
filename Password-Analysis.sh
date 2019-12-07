#!/bin/bash
#todo
#fix hex thing

makedatafolder() {
  mkdir Crackdata."$main_start_time"
  rm domains.list."$main_start_time"
  rm $hashcatfilelocation.domain.select."$main_start_time"
  rm $hashcatfilelocation.no.machine.accounts."$main_start_time"
  mv "$hashcatfilelocation".all.cracked.hashes."$main_start_time" "$hashcatfilelocation".full.cracked.hashes.list."$main_start_time"
  rm "$hashcatfilelocation".lm.hashes."$main_start_time"
  rm "$hashcatfilelocation".ntlm.hashes."$main_start_time"
  rm "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time"
  rm "$hashcatfilelocation".pipalstats."$main_start_time"
  rm "$hashcatfilelocation".targeted.domains."$main_start_time"
  cat "$hashcatfilelocation".wordlist."$main_start_time" | sort | uniq > "$hashcatfilelocation".compromised.words.list."$main_start_time"
  rm "$hashcatfilelocation".wordlist."$main_start_time"
  rm selected.domains."$main_start_time"
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
  total_lm_hashes=$(cat $hashcatfilelocation.lm.hashes."$main_start_time" | wc -l)
  total_hashes=$(cat $hashcatfilelocation.ntlm.hashes."$main_start_time" | wc -l)
}

cracklm() {
 lm_start_time=$(date +"%m-%d-%Y::%H:%M")
 /tools/hashcat/hashcat64.bin -m 3000 "$hashcatfilelocation".lm.hashes."$main_start_time" -w 3 -a 3 -1 ?u?d?s --increment  ?1?1?1?1?1?1?1 --session "$hashcatfilelocation".lm.hashes.restore.lm
 lm_end_time=$(date +"%m-%d-%Y::%H:%M")
}

crackntlm() {
 ntlm_start_time=$(date +"%m-%d-%Y::%H:%M")
 cat /tools/hashcat/hashcat.potfile | cut -f2 -d: | sort | uniq > /tools/hashcat/potfile.words
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" /tools/hashcat/potfile.words -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.ntlmpot
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" /wordlists/all.wordlists.clean -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.1
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" /wordlists/all.wordlists.clean -r /tools/hashcat/rules/all.pwanalysis.rule -w 3 --session "$hashcatfilelocation".ntlm.hashes.restore.2
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" /tools/hashcat/masks/new.all.masks -w 3 -a 3 --session "$hashcatfilelocation".ntlm.hashes.restore.3
 ntlm_end_time=$(date +"%m-%d-%Y::%H:%M")
}

lmstats() {
  /tools/hashcat/hashcat64.bin -m 3000 --username --show -o "$hashcatfilelocation".lm.hashes.cracked."$main_start_time" --outfile-format 3 "$hashcatfilelocation".lm.hashes."$main_start_time"
  cracked_lm_hashes=$(cat "$hashcatfilelocation".lm.hashes.cracked."$main_start_time" | wc -l)
  percent_lm_hashes_pre=$(bc <<<"scale=4; $cracked_lm_hashes / $total_lm_hashes")
  percent_lm_hashes=$(bc <<<"scale=2; $percent_lm_hashes_pre * (100)")
}

lmtontlm() {
  /tools/hashcat/hashcat64.bin -m 3000 --username --show -o "$hashcatfilelocation".lm.hashes.cracked."$main_start_time" --outfile-format 3 $hashcatfilelocation
  cat "$hashcatfilelocation".lm.hashes.cracked."$main_start_time" | cut -f3 -d: > lm.words."$main_start_time"
 /tools/hashcat/hashcat64.bin -m 1000 "$hashcatfilelocation".ntlm.hashes."$main_start_time" -w 3 -r /tools/hashcat/rules/lm2ntlm.rule lm.words."$main_start_time"
}

ntlmstats() {
  /tools/hashcat/hashcat64.bin -m 1000 --username --show -o "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time" --outfile-format 3 "$hashcatfilelocation".ntlm.hashes."$main_start_time"
  cracked_ntlm_hashes=$(cat "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time" | wc -l)
  percent_ntlm_hashes_pre=$(bc <<<"scale=4; $cracked_ntml_hashes / $total_hashes")
  percent_ntlm_hashes=$(bc <<<"scale=2; $percent_ntlm_hashes_pre * (100)")
}

totalstats() {
  cat "$hashcatfilelocation".ntlm.hashes.cracked."$main_start_time" > "$hashcatfilelocation".all.cracked.hashes."$main_start_time"
  total_cracked_hashes=$(cat "$hashcatfilelocation".all.cracked.hashes."$main_start_time" | wc -l)
}

getwordlist() {
  cat "$hashcatfilelocation".all.cracked.hashes."$main_start_time" | cut -f3 -d: > "$hashcatfilelocation".wordlist."$main_start_time"
}

pipalstats() {
  /tools/pipal/pipal.rb "$hashcatfilelocation".wordlist."$main_start_time" > "$hashcatfilelocation".pipalstats."$main_start_time"
}

printstats() {
  stats_output_file="$hashcatfilelocation".stats."$main_start_time"

  #print targeted domains
  printf \\n
  printf \\n
  echo The Targeted Domains Are: | tee -a $output_file
  echo $(<selected.domains."$main_start_time") | tee -a $stats_output_file

  #print totals HASHES
  printf \\n | tee -a $stats_output_file
  echo The Total Number of Hashes Obtained Is: | tee -a $stats_output_file
  echo $total_hashes | tee -a $stats_output_file

  #print total lm HASHES
  printf \\n | tee -a $stats_output_file
  echo The Total Number of LM Hashes Obtained Is: | tee -a $stats_output_file
  echo $total_lm_hashes | tee -a $stats_output_file

  #print toal ntlm HASHES
  printf \\n | tee -a $stats_output_file
  echo The Total Number of NTLM Hashes Obtained Is: | tee -a $stats_output_file
  echo $total_hashes | tee -a $stats_output_file

  #print total cracked HASHES
  printf \\n | tee -a $stats_output_file
  echo The Total Number of Cracked Hashes Is: | tee -a $stats_output_file
  echo $total_cracked_hashes | tee -a $stats_output_file

  #print total cracked lm HASHES
  printf \\n | tee -a $stats_output_file
  echo The Total Number of Cracked LM Hashes Is: | tee -a $stats_output_file
  if (($total_lm_hashes > 0)); then
    echo $cracked_lm_hashes | tee -a $stats_output_file
    echo "!!!!!!WARNING!!!!!!"
    echo "!!!!!!LM HASHES FOUND!!!!!!"
    printf \\n | tee -a $stats_output_file
    echo LM Start Time: $lm_start_time | tee -a $stats_output_file
    echo LM End Time:   $lm_end_time | tee -a $stats_output_file
  else
    echo "NO LM HASHES FOUND (GOOD)" | tee -a $stats_output_file
  fi

  #print total cracked ntlm HASHES
  printf \\n | tee -a $stats_output_file
  echo The Total Number of Cracked NTLM Hashes Is: | tee -a $stats_output_file
  echo $cracked_ntlm_hashes | tee -a $stats_output_file
  printf \\n | tee -a $stats_output_file
  echo NTLM Start Time: $ntlm_start_time | tee -a $stats_output_file
  echo NTLM End Time:   $ntlm_end_time | tee -a $stats_output_file

  #find percent of total hashes cracked
  percent_total_hashes_pre=$(bc <<<"scale=4; $total_cracked_hashes / $total_hashes")
  percent_total_hashes=$(bc <<<"scale=2; $percent_total_hashes_pre * (100)")
  printf \\n | tee -a $stats_output_file
  echo The Percent of Total Hashes Cracked Is: | tee -a $stats_output_file
  echo "$percent_total_hashes%" | tee -a $stats_output_file

  #find percent of total lm hashes cracked
  printf \\n | tee -a $stats_output_file
  echo The Percent of LM Hashes Cracked Is: | tee -a $stats_output_file
  if (($total_lm_hashes > 0)); then
    echo "$percent_lm_hashes%" | tee -a $stats_output_file
  else
    echo NO LM HASHES | tee -a $stats_output_file
  fi

  #find percent of total ntlm hashes cracked
  printf \\n | tee -a $stats_output_file
  echo The Percent of NTLM Hashes Cracked Is: | tee -a $stats_output_file
  echo "$percent_ntlm_hashes%" | tee -a $stats_output_file

  #######

  printf \\n | tee -a $stats_output_file
  echo "Password Statistics:"
  printf \\n
  cat "$hashcatfilelocation".pipalstats."$main_start_time" | grep "Basic" -A 50 | grep -v Basic --color=never | tee -a $stats_output_file
  cat "$hashcatfilelocation".pipalstats."$main_start_time" | grep "One to six characters" -A 27 --color=never | tee -a $stats_output_file
  cat "$hashcatfilelocation".pipalstats."$main_start_time" | grep "Last digit" -A 90 --color=never | tee -a $stats_output_file
}

get_html_table_from_pipal() {
  echo "<table>"
  grep "$1" "$hashcatfilelocation".pipalstats."$main_start_time" | sed 's/^/<tr><th>/' | sed 's/$/<\/th><\/tr>/';
  grep "$1" -A 10 "$hashcatfilelocation".pipalstats."$main_start_time" | grep -v "$1" | sed 's/^/<tr><td>/' | sed "s/$2/<\/td><td>/" | sed 's/$/<\/td><\/tr>/';
  echo "</table>"
}

get_pipal_stat() {
  grep "$1" "$hashcatfilelocation".pipalstats."$main_start_time" | cut -d'=' -f2 | awk '{$1=$1};1'
}

print_html_table() {
  html_output_file="$hashcatfilelocation".html_stats."$main_start_time"
  function html_output() {
    echo "$1" | tee -a $html_output_file
  }

  html_output "<p>The tables below show statistics from the domain password analysis:</p>"
  html_output "<table>" 
  html_output "<tr><td>Total Hashes</td><td>$total_hashes</td></tr>" 
  html_output "<tr><td>Total Cracked Hashes</td><td>$total_cracked_hashes</td></tr>" 
  html_output "<tr><td>Percent of Hashes Cracked</td><td>$percent_total_hashes</td></tr>" 
  html_output "<tr><td>Total Hash Time</td><td>## Calculate Manually</td></tr>" 
  html_output "</table>" 

  if (($total_lm_hashes > 0)); then
    html_output "<table>" 
    html_output "<tr><td>Total LM Hashes</td><td>$total_lm_hashes</td></tr>" 
    html_output "<tr><td>Total LM Cracked Hashes</td><td>$cracked_lm_hashes</td></tr>" 
    html_output "<tr><td>Percent of LM Hashes Cracked</td><td>$percent_lm_hashes</td></tr>" 
    html_output "<tr><td>Total LM Hash Time</td><td>## Calculate Manually</td></tr>" 
    html_output "</table>" 
  fi

  echo $(get_html_table_from_pipal "Top 10 passwords" " = ") | tee -a $html_output_file
  echo $(get_html_table_from_pipal "Top 10 base words" " = ") | tee -a $html_output_file
  echo $(get_html_table_from_pipal "Password length (length ordered)" " = ") | tee -a $html_output_file

  html_output "<table>" 
  html_output "<tr><td>Only lowercase alpha</td><td>$(get_pipal_stat "Only lowercase alpha")</td></tr>" 
  html_output "<tr><td>Only uppercase alpha</td><td>$(get_pipal_stat "Only uppercase alpha")</td></tr>" 
  html_output "<tr><td>Only alpha</td><td>$(get_pipal_stat "Only alpha")</td></tr>" 
  html_output "<tr><td>Only numeric</td><td>$(get_pipal_stat "Only numeric")</td></tr>" 
  html_output "</table>" 

  echo $(get_html_table_from_pipal "Character sets" ": ") | tee -a $html_output_file
}

if [ "$#" -eq "0" ]; then
  echo "Please input the path to the file you want cracked. (/full/path)"
  read -r hashcatfilelocation
else
  hashcatfilelocation=$1
fi

main_start_time=$(date +"%m-%d-%Y-%H-%M")
fileclean
getdomains
gethashtype

if (($total_lm_hashes > 0)); then
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
print_html_table
printf \\n
makedatafolder

