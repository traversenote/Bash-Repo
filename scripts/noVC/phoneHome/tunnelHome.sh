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
home="midas@203.97.202.230" # The username@homeAddress
homePort="6666" 			# The port required to access homeAddress
endPort="2223"				# The port number established on the home box

#############################################################################
#  Standard Variables
#############################################################################
logFile=/home/jason/scriptLogs/tunnelHome.log
NOW=$(date +"%m-%d-%y:%T")

#############################################################################
#  The actual loop. Make sure to allow user to execute it, make log file and
#  give the user actual permission to write.
#############################################################################
createTunnel() {
  /usr/bin/ssh -N -R $endPort:localhost:22 $home -p $homePort
  if [[ $? -eq 0 ]]; then
	echo $NOW >> $logFile
    echo Tunnel to jumpbox created successfully >> $logFile
  else
    echo An error occurred creating a tunnel to jumpbox. RC was $? >> $logFile
  fi
}
/bin/pidof ssh
if [[ $? -ne 0 ]]; then
	echo $NOW >>
	echo Creating new tunnel connection >> $logFile
  createTunnel
fi
