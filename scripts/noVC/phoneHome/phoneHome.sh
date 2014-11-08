#!/bin/bash
#
#############################################################################
#
#  Phone Home
#  A Reverse SSH Tunnelling Script for The Listening Post Christchurch
#  This script will call back to the home server and establish a loopback
#  allowing contact from the port on the home server.
#  This script should be /usr/sbin/phoneHome.sh
#  For more info, see the readme at /usr/sbin/phoneHomeReadme.txt
#
#############################################################################
#  Copyright 2013 by Jason Spears, All Rights Reserved
#
#  To the maximum extent permitted by applicable law, in no event shall
#  Jason Spears or affiliates be liable for any special,
#  incidental,  indirect, or consequential damages whatsoever (including,
#  without limitation, damages for loss of business profits, business interruption,
#  loss of business information, or any other pecuniary loss) arising out
#  of the use of or inability to use this software product or the provision
#  of or failure to provide support services, even if Jason Spears
#  has been advised of the possibility of such damages.
#
#  THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
#  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
#  PURPOSE.
#
#  http:#www.sr-studio.com
#  jspears@sr-studio.com
#
#############################################################################
#############################################################################
#
#############################################################################
#############################################################################
#Variable Declaration Area
#############################################################################
# Home Address
#############################################################################
home="midas@203.97.202.230"
homePort="6666"
forwardedPort="665"
thisPort="2222"

#############################################################################
#  Standard Variables
#############################################################################
logfile=/var/log/phoneHome.log
NOW=$(date +"%m-%d-%y:%T")

#############################################################################
#############################################################################
# Functions
#############################################################################
createTunnel() {
  echo $NOW >> $logFile
  echo "Starting Phone Home Service." >> $logFile
  /usr/bin/ssh -N -R $thisPort:localhost:$forwardedPort $home -p $homePort
  if [[ $? -eq 0 ]]; then
    echo Tunnel home created successfully >> $logFile
  else
    echo An error occurred creating a tunnel to home base. RC was $? >> $logFile
  fi
}

#############################################################################
# The Service
#############################################################################
case "$1" in
	start)
		createTunnel
		;;
	stop)
		echo "Stopping Phone Home Service" >> $logFile
		echo "Stopping Phone Home Service: "
		/bin/pidof ssh
		`kill $?`
		;;
	restart)
		echo "Restart Called" >> $logFile
		echo -n "Restarting Phone Home Service: "
		$0 stop
		$0 start
		;;
	status)
		/bin/pidof ssh
		if [[ $? -ne 0 ]]; then
			echo "The Service Appears to be running."
		else
			echo "There does not appear to be any ssh service up."
		fi
		;;
	*)
		echo -n "Usage sshTunnel {start|stop|restart|status}"
		exit 1
		;;
esac