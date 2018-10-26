#!/usr/bin/env sh

###############################################################################
# Lottery Numbers Retrieval for Atlantic Lottery Corporation                  #
#                                                                             #
# Version 0.1, Copyright (C) 2018 Gregory D. Horne                            #
#                                                                             #
# Licensed under the terms of the Simplified BSD Licence                      #
#                                                                             #
# Disclaimer: This application is neither affiliated with nor endorsed by the #
#             Atlantic Lottery Corporation (https://www.alc.ca)               #
###############################################################################


docker run --rm -it -e DISPLAY=$DISPLAY \
  -v ${PWD}:/home/firefox/project -v /tmp/.X11-unix:/tmp/.X11-unix \
  --net=bridge alc-in-a-box:0.1 ${1}

exit 0

