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


echo
echo Lottery Numbers Retrieval for Atlantic Lottery Corporation
echo

export STANDALONE=1

# If in standalone mode, then copy lottery winning numbers from host system.
if [[ -e /home/firefox/data ]]
then
  cp ./project/data/alc-winning-numbers.* ./data
fi

./code/retrieve-lottery-numbers.sh

# If in standalone mode, then copy lottery winning numbers to host system.
if [[ -e /home/firefox/data ]]
then
  cp ./data/alc-winning-numbers.* ./project/data
fi

exit 0

