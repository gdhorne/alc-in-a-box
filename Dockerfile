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


FROM alpine:3.8


MAINTAINER Gregory D. Horne < greg at gregoryhorne dot ca >

# Install Mozilla Firefox, X11 Windows, and web page retrieval and
# extraction support tools including xdotool and jq

RUN apk add --no-cache --update --upgrade \
    ca-certificates \
    dbus-x11 xvfb \
    firefox-esr ttf-freefont ttf-ubuntu-font-family gdk-pixbuf \
    xdotool jq zip

# Create a non-privleged user account under which to run the web browser
# and scripts.

RUN adduser -u 1000 -G wheel -D firefox

ADD alc /home/firefox

RUN chown -R firefox:wheel /home/firefox \
    && chmod -R 777 /home/firefox

USER firefox

VOLUME /home/firefox/project
WORKDIR /home/firefox

ENTRYPOINT ["/home/firefox/start.sh"]

