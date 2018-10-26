# Lottery Numbers Retrieval for Atlantic Lottery Corporation in a Box

*Disclaimer:*

*This application is neither affiliated with nor endorsed by the [Atlantic Lottery Corporation]*(https://www.alc.ca) *, with headquarters located in Moncton, New Brunswick, Canada.*

*Lottery Numbers Retrieval for Atlantic Lottery Corporation in a Box*, hereinafter referred to as *ALC in a Box* or * alc-in-a-box*,  provides script execution within a Docker container running Alpine Linux. The container definition build file and data retrieval scripts may be obtained from the project [repository](https://gitlab.com/gregorydhorne/alc-in-a-box).

By default, the non-standalone version of the container image only provides an environment and relies on the data retrieval scripts being accessible from the host computer system.

To build the standalone or non-standalone version see the relevant instructions in the **Pre-built Container** or  **Build Container from Scratch** sections.

Obtain a copy of the data subdirectory from this [repository](https://gitlab.com/gregorydhorne/alc). Put it in a directory, which will be the current working directory, on the host computer system. The winning lottery numbers file, *./data/alc-winning-numbers.csv*:
- will be copied into the container instance and the updated file copied back to the host computer system as soon as the script *alc.sh* is invoked (standalone mode), or
- will be read and updated on the host computer system when the user either passes the script, *start.sh*, as an argument to *alc.sh* or types the command inside in the container instance (non-standalone mode).

#### Prerequisites

[Docker](https://docker.com) and [Git](https://git-scm.com) must be installed on the computer. Instructions specific to the operating system of the computer are available at the respective websites. A compatible X11 Windows system or equivalent must be installed on the host computer system capable of running an instantiated instance of this container.

#### Pre-built Container

A pre-built image of the container configured to run in a self-contained standalone mode is available from the Docker Hub [repository](https://hub.docker.com/r/gdhorne/alc-in-a-box).

**Standalone**

```sh
$ docker pull alc-in-a-box
```

Alternatively, build the container image from scratch in one of two configurations as described below.

#### Build Container from Scratch

To build the container image from scratch choose either the standalone or non-standalone configuration. Review the 
**Prerequisites** section. The default configuration is standalone mode, that is STANDALONE=1 in the start script, *start.sh*..

**Non-Standalone**
```sh
$ git clone https://gitlab.com/gdhorne/alc-in-a-box.git
$ cd alc-in-a-box
$ cp Dockerfile.nonstandalone Dockerfile
$ sed 's/STANDALONE=1/STANDALONE=0/' alc/startup.sh > alc/new_startup.sh
$ mv alc/new_startup.sh alc/startup.sh
$ docker build --tag alc:0.1 .
```

**Standalone**
```sh
$ git clone https://gitlab.com/gdhorne/alc-in-a-box.git
$ cd alc-in-a-box
$ cp Dockerfile.standalone Dockerfile
$ docker build --tag alc:0.1 .
```

If the container image build is successful, continue with the next section. In the event an error occurs, verify the preceding commands were typed correctly and all requisite software, in the **Prerequisites** section, has been installed in accordance with the operating system running on the host computer system.

### Usage

The default configuration is standalone mode which prevents the user from directly accessing the internals of the container.

While you can use alc-in-a-box interactively within the container by passing it a script which retrieves the lottery numbers from the Atlantic Lottery Corporation website, it is recommended that you use it in the manner described in the table below. The shell script, alc.sh, uses the PWD environment variable as the working directory. This script, *alc.sh*, can be executed from any directory, but the current directory is where the working files (code and data) are expected to reside.

For example, *alc.sh* could be saved to your ${HOME} directory, and if the PATH contains the HOME directory and if the current directory contains your scripts and other files, then the commands in the table will execute successfully.

**Non-Standalone**

   | Action | Command |
   | ------ | ------ |
   | Execute a script | $ alc.sh start.sh |
   | Interactive Shell | $ alc.sh |

The host path in the script, *alc.sh*, can be modified to suit the file system location of the data retrieval scripts. Subdirectories *code*, containing processing scripts except *start.sh*, and *data*, containing the winning lottery numbers and any temporary files, must be present. A cloned repository already has the necessary directory structure.

**Standalone**

   | Action | Command |
   | ------ | ------- |
   | Execute a script | $ alc.sh |

The processing scripts run automatically and the winning lottery number archive will be copied into the container before fetching any newer lottery results, and then copied from to the host system by default. In standalone mode the user cannot access the internals of the container.

#### Data 

For convenience historical Lotto649 winning numbers from 2009 January 07 to 2018 October 20 are included.

Atlantic Lottery Corporation reduced the number of years for which past winning numbers can be obtained. The current configuration of starting and ending years, found in the script *retrieve-lottery-numbers.sh*, are both 2018. The user can adjust the ending year but is advised not to modify the starting year. Any draw for which Atlantic Lottery Corporation does not provide the winning numbers defaults to returning the winning numbers for the most recent occurrence of the game, thereby leading to an erroneous dataset.

Only those lottery draws taking place up to, but not including, the current date will be retrieved.

Licenses
----

Simplified 2-Clause BSD, see individual files    
GNU General Public License (GNU GPL) v2, see individual files

Inclusion of multiple licenses does not imply nor infer, directly nor indirectly, dual licensing of the software.
