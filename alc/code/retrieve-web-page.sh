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


# Determine existence of xdotool in current environment.

if [[ ! xdotool --help &>/dev/null ]]
then
  printf "ERROR: 'xdotool' is not installed or not in the search path.\n" >&2
  printf "       PATH=${PATH}\n" >&2
  exit 1
fi

# Configuration parameters (add passing from command-line).

browser="firefox"
#destination="/home/firefox/project/data/page.html"
load_wait_time=15
save_wait_time=10
url="${1}"

if [[ ${STANDALONE} -eq 0 ]]
then
  destination="/home/firefox/project/data/page.html"
else
  destination="/home/firefox/data/page.html"
fi

# Returns 1 if input param contains any non-printable or non-ascii character, else returns 0.
# (Inspiration: http://stackoverflow.com/a/13596664/1857518)

function has_non_printable_or_non_ascii()
{
  LANG=C
  if [[ printf "%s" "${1}" | grep '[^ -~]\+' &>/dev/null ]]
  then 
    printf 1
  else
    printf 0
  fi
}

# Terminates script if any input parameter is not valid.
# Parameters: browser, destination, load wait time, save wait time, url

function validate_input()
{
  if [[ -z "${url}" ]]
  then
    printf "ERROR: URL must be specified." >&2
    exit 1
  fi

  if [[ -d "${destination}" ]]
  then
    local basedir="$(dirname "${destination}")"
    if [[ ! -d "${basedir}" ]]
    then
      printf "ERROR: Directory (%s) does not exist.\n" "${basedir}" >&2
      exit 1
    fi
  fi

  if [[ "${browser}" != "firefox" ]]
  then
    printf "ERROR: Browser (%s) is not supported\n" ${browser} >&2
    exit 1
  fi

  if [[ ! command -v ${browser} &>/dev/null ]]
  then
    printf "ERROR: Command '${browser}' not found. Verify it is installed and" >&2
    printf "       in the search path.\n" >&2
    printf "       ${browser}: %s\n" $(eval which ${browser}) >&2
    printf "       PATH=${PATH}\n" >&2
    exit 1
  fi
}

###############################################################################
###############################################################################

validate_input

# Launch web browser and wait for the page to load.

${browser} "${url}" &>/dev/null &
sleep ${load_wait_time}

# Determine web browser window identifier (numeric).

browser_wid="$(xdotool search --sync --onlyvisible --class "${browser}" | head -n 1)"

# Validate web browser window identifier; window-id must be a valid integer

wid_re="[^0-9]+$"
if [[ $(echo "${browser_wid}" | grep -E "${wid_re}") ]]
then
  printf "ERROR: X-Server window identifier (${browser_wid}) for browser\n" >&2
  printf "       is not registered.\n" >&2
  exit 1
fi

# Activate web browser window and simulate pressing CTRL+S, allowing
# 'Save As' dialogue box sufficient time to display.

xdotool windowactivate "${browser_wid}" key --clearmodifiers "ctrl+s"
sleep 1

# Resolve expected title name for save file dialog box.

if [[ ${browser} == "firefox" ]]
then
  savefile_dialog_title="Save as"
else
  savefile_dialog_title="Save file"
fi

# Determine file save dialog box window indentifier.

savefile_wid="$(xdotool search --name "$savefile_dialog_title" | head -n 1)"

if [[ $(echo "${savefile_wid}" | grep -E "${wid_re}") ]]
then
  printf "ERROR: X-Server dialgoue window identifier (${savefile_wid})\n" >&2
  printf "       for browser is not registered.\n" >&2
  exit 1
fi

##xdotool windowactivate "${savefile_wid}" key --delay 20 --clearmodifier "alt+n"

# Activate the file save dialogue and simulate typing the appropriate filename
# depending on ${destination} value: 1) directory, 2) full path, 3) empty) and
# pressing RETURN key. Retrieved webpage is saved in file named 'page.html'.

if [[ ! -z ${destination} ]]
then
  if [[ -d ${destination} ]]
  then
    # Case 1: destination is a directory
    xdotool windowactivate "${savefile_wid}" key --delay 20 --clearmodifiers "ctrl+a" "Home"
    xdotool type --delay 10 --clearmodifiers ${destination}/
  else
    # Case 2: destination is full path
    xdotool windowactivate "${savefile_wid}" key --delay 20 --clearmodifiers "ctrl+a" "BackSpace"
    xdotool type --delay 10 --clearmodifiers ${destination}
  fi
else
  # Case 3: destination is empty
	xdotool windowactivate "${savefile_wid}" key --delay 20 --clearmodifiers "ctrl+a" "BackSpace"
	xdotool type --delay 10 --clearmodifiers ${PWD}/data/page.html	
fi

sleep ${save_wait_time}

xdotool windowactivate "${savefile_wid}" key --delay 20 --clearmodifiers Return

# Wait for the file to be completely saved

sleep ${save_wait_time}

# Close the browser tab/window depending on desktop environment
# (alt+F4, ctrl+F4, or ctrl+w).

xdotool windowactivate "${browser_wid}" key --clearmodifiers "alt+F4" 

sleep $(expr ${load_wait_time} + ${save_wait_time})

exit 0

