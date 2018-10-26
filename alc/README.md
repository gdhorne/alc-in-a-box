# Lottery Numbers Retrieval for Atlantic Lottery Corporation

*Disclaimer:*

*This application is neither affiliated with nor endorsed by the [Atlantic Lottery Corporation]*(https://www.alc.ca) *, with headquarters located in Moncton, New Brunswick, Canada.*

### Usage

This application requires [Alpine Linux](https://alpinelinux.org) and is intended to be run within a container. See the [repository](https://gitlab.com/gregorydhorne/alc-in-a-box) for detailed instructions.

### Caveat

For convenience historical Lotto649 winning numbers from 2009 January 07 to 2018 October 20 are included.

Atlantic Lottery Corporation reduced the number of years for which past winning numbers can be obtained. The current configuration of starting and ending years, found in the script *retrieve-lottery-numbers.sh*, are both 2018. The user can adjust the ending year but is advised not to modify the starting year. Any draw for which Atlantic Lottery Corporation does not provide the winning numbers defaults to returning the winning numbers for the most recent occurrence of the game, thereby leading to an erroneous dataset.

Only those lottery draws taking place up to, but not including, the current date will be retrieved.

License
----

GNU General Public License (GNU GPL) v2

