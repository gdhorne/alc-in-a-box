#!/usr/bin/env sh

###############################################################################
# Lottery Numbers Retrieval for Atlantic Lottery Corporation                  #
#                                                                             #
# Version 0.1, Copyright (C) 2018 Gregory D. Horne                            #
#                                                                             #
# Licensed under the terms of the GNU GPL v2 Licence                          #
#                                                                             #
# Disclaimer: This application is neither affiliated with nor endorsed by the #
#             Atlantic Lottery Corporation (https://www.alc.ca)               #
###############################################################################


# Configuration parameters.

start_year=2018
end_year=2018

# Archive current data after retrieving the latest updates.

archive_data()
{
  local pre_record_count=${1}
  local post_record_count=${2}

  if [[ ${pre_record_count} -lt ${post_record_count} ]]
  then
    if [[ -e ./data/alc-winning-numbers.zip ]]
    then
      zip -f ./data/alc-winning-numbers.zip ./data/alc-winning-numbers.csv > /dev/null 2>&1
      echo -e "\tArchive updated"
    else
      zip ./data/alc-winning-numbers.zip ./data/alc-winning-numbers.csv
      echo -e "\tArchive created"
    fi
  else
    echo -e "\tNo updates"
  fi

  return
}

# Initialise datastore.

initialise()
{
  if [[ ! -e ./data ]]
  then
    mkdir ./data
  fi

  if [[ ! -e ./data/alc-winning-numbers.csv ]]
  then
    touch ./data/alc-winning-numbers.csv
  fi

  return
}

# Report current record count.

record_count()
{
  echo $(wc -l ./data/alc-winning-numbers.csv | cut -d \  -f 1)
}

# Retrieves the winning numbers for the specified game and draw date.

retrieve_winning_numbers()
{
  local game=${1}
  local draw_date=${2}
  local error_count=${3}

  local numbers
  local bonus_number

  if [[ -z `grep ${draw_date} ./data/alc-winning-numbers.csv` ]]
  then
    draw_date_parameter=${draw_date:0:4}-${draw_date:4:2}-${draw_date:6:2}
    ./code/retrieve-web-page.sh "https://www.alc.ca/content/alc/en/our-games/lotto/${game}.html?date=${draw_date_parameter}"
    if [[ -e ./data/page.html ]]
    then
      awk '
        /ALC.components.GameDetailComponent/ { flag = 1; next; }
        /jQuery/ { flag = 0; } flag
      ' ./data/page.html \
      | awk '
          BEGIN { print("["); }
          /gameId/ {
            sub("gameId", "\"gameId\"", $0);
            printf("{%s", $0);
          }
          /gameData/ {
            sub("gameData", "\"gameData\"", $0);
            sub(/,$/, "},", $0);
            printf("%s\n", $0);
          }
          END {
            printf("{}\n]");
          }
        ' > ./data/alc-winning-numbers.json
      # extract winning numbers
      numbers=$(jq --raw-output '.[] | select(.gameId=="Lotto649") | .gameData | .[].draw.winning_numbers | @csv' ./data/alc-winning-numbers.json | sed 's/\"//g')
      bonus_number=$(jq '.[] | select(.gameId=="Lotto649") | .gameData | .[].draw.bonus_number' ./data/alc-winning-numbers.json | sed 's/\"//g')
      rm -f ./data/alc-winning-numbers.json
      #echo ${draw_date},${numbers},${bonus_number}
      echo ${draw_date},${numbers},${bonus_number} >> ./data/alc-winning-numbers.csv
      if [[ -z `grep ${draw_date} ./data/alc-winning-numbers.csv` ]]
      then
        echo "${draw_date}: retrieval or processing error"
        error_count=$(expr ${error_count} + 1)
      fi
      rm -rf ./data/page*
    else
      echo "${draw_date}: retrieval error"
      error_count=$(expr ${error_count} + 1)
    fi
  fi

  echo ${error_count}
}

status()
{
  local pre_record_count=${1}
  local post_record_count=${2}
  local error_count=${3}

  echo "Status:"
  echo -e "\tRecord count: ${pre_record_count} (pre-count) : ${post_record_count} (post-count)"
  echo -e "\tError count: ${error_count}"

  return
}

lotto649()
{
  local start_year=${1}
  local end_year=${2}
  local game=${3}

  local today=$(date -I | sed 's/-//g')

  eval month1=January
  eval month2=February
  eval month3=March
  eval month4=April
  eval month5=May
  eval month6=June
  eval month7=July
  eval month8=August
  eval month9=September
  eval month10=October
  eval month11=November
  eval month12=December

  local day_of_month
  local draw_date
  local error_count=0

  for year in $(seq ${start_year} ${end_year})
  do
    for i in $(seq 12)
    do
      cal $(eval echo ${month}${i}) ${year} | tail -n +2 | sed 's/   / 0 /g' | awk -f ./code/cal.awk -v cols=We,Sa | head -n -1 > ./data/raw-draw-dates
      while IFS='' read -r line || [[ -n "${line}" ]]
      do
        day_of_month=$(echo ${line} | cut -d \  -f 1 | sed 's/ //g')
        if [[ -z ${day_of_month} ]]
        then
          day_of_month=0
        fi
        draw_date=`echo "$(printf "%4d" ${year})$(printf "%02d" ${i})$(printf "%02d" ${day_of_month})"`
        if [[ ${day_of_month} -ne 0 ]] && [[ ${draw_date} -ne 0 ]] && [[ ${draw_date} -lt ${today} ]]
        then
         error_count=$(retrieve_winning_numbers ${game} ${draw_date} ${error_count})
        fi
        day_of_month=$(echo ${line} | cut -d \  -f 2 | sed 's/ //g')
        if [[ -z ${day_of_month} ]]
        then
          day_of_month=0
        fi
        draw_date=`echo "$(printf "%4d" ${year})$(printf "%02d" ${i})$(printf "%02d" ${day_of_month})"`
        if [[ ${day_of_month} -ne 0 ]] && [[ ${draw_date} -ne 0 ]] && [[ ${draw_date} -lt ${today} ]]
        then
          error_count=$(retrieve_winning_numbers ${game} ${draw_date} ${error_count})
        fi
        rm -rf ./data/alc-winning-numbers.json
      done < ./data/raw-draw-dates
      rm -f ./data/raw-draw-dates
    done
  done

  temp_file=$(mktemp)
  sort ./data/alc-winning-numbers.csv > ${temp_file}
  cp -f ${temp_file} ./data/alc-winning-numbers.csv

  echo ${error_count}
}

###############################################################################
###############################################################################

initialise

echo "Data retrieval starting"
pre_record_count=$(record_count)

error_count=$(lotto649 ${start_year} ${end_year} "lotto-6-49")

echo "Data retrieval completed"
post_record_count=$(record_count)

status ${pre_record_count} ${post_record_count} ${error_count}

archive_data ${pre_record_count} ${post_record_count}

exit 0

