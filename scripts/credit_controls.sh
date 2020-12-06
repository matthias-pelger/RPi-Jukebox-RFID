#!/bin/bash

# This shell script contains all the functionality to control
# the credit system during playback and the like.
# This script is called from the web app and the bash script.
# The purpose is to have all credit logic in one place, this
# makes further development and potential replacement of
# the crediy system easier.

# Set the date and time of now
NOW=`date +%Y-%m-%d.%H:%M:%S`

# USAGE EXAMPLES:
#
# add one credit:
# ./credit_controls.sh -c=addcredit
#
# add 10 credits:
# ./credit_controls.sh -c=addcredit -v=10
#
# VALID COMMANDS:
# addcredit
# reducecredit

# The absolute path to the folder whjch contains all the scripts.
# Unless you are working with symlinks, leave the following line untouched.
PATHDATA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#############################################################
# $DEBUG TRUE|FALSE
# Read debug logging configuration file
. ${PATHDATA}/../settings/debugLogging.conf

if [ "${DEBUG_credit_controls_sh}" == "TRUE" ]; then echo "########### SCRIPT credit_controls.sh ($NOW) ##" >> ${PATHDATA}/../logs/debug.log; fi

###########################################################
# Read global configuration file (and create is not exists)
# create the global configuration file from single files - if it does not exist
if [ ! -f ${PATHDATA}/../settings/global.conf ]; then
    . ${PATHDATA}/inc.writeGlobalConfig.sh
fi
. ${PATHDATA}/../settings/global.conf
###########################################################

###########################################################
# Get/Update current Credit Value (and create is not exists)
. ${PATHDATA}/inc.writeCreditValue.sh

#############################################################
# Get args from command line (see Usage above)
# Read the args passed on by the command line
# see following file for details:
. ${PATHDATA}/inc.readArgsFromCommandLine.sh

if [ "${DEBUG_credit_controls_sh}" == "TRUE" ]; then echo "VAR COMMAND: ${COMMAND}" >> ${PATHDATA}/../logs/debug.log; fi
if [ "${DEBUG_credit_controls_sh}" == "TRUE" ]; then echo "VAR VALUE: ${VALUE}" >> ${PATHDATA}/../logs/debug.log; fi


function dbg {
  if [ "${DEBUG_credit_controls_sh}" == "TRUE" ]; then
    echo "$1" >> ${PATHDATA}/../logs/debug.log;
  fi
}

AUDIO_FOLDERS_PATH=$(cat "${PATHDATA}/../settings/Audio_Folders_Path")

CURRENT_SONG_INFO=$(echo -e "currentsong\nclose" | nc -w 1 localhost 6600)
CURRENT_SONG_FILE=$(echo "$CURRENT_SONG_INFO" | grep -o -P '(?<=file: ).*')
CURRENT_SONG_FILE_ABS="${AUDIO_FOLDERS_PATH}/${CURRENT_SONG_FILE}"
dbg "current file: $CURRENT_SONG_FILE_ABS"

# SHUFFLE_STATUS=$(echo -e status\\nclose | nc -w 1 localhost 6600 | grep -o -P '(?<=random: ).*')

case $COMMAND in
    addcredit)
        ADD=1
        if [ "$VALUE" ]; then ADD=$VALUE; fi
        let CREDIT+=$ADD
        ;;
    reducecredit)
        REDUCE=1
        if [ "$VALUE" ]; then REDUCE=$VALUE; fi
        let CREDIT-=$REDUCE
        ;;
    playing)
        if [ "$CURRENT_SONG_INFO" -neq "$LAST_SONG_INFO" ]
        then
            let CREDIT-=1
            # Check for existing credit
            . $PATHDATA/credit_controls.sh -c=status
            if [ "$CREDITOK" == "FALSE" ]
            then
                . $PATHDATA/playout_controls.sh -c=playerstop
            fi
        fi
        LAST_SONG_INFO="$CURRENT_SONG_INFO"
        ;;
    status)
        # check for credit and return true or false...
        CREDITOK="TRUE"
        if [ "$CREDITTRIGGER" == "ON" ] && [ "$CREDIT" < 1 ]
        then
            CREDITOK="FALSE"
            #play audio file... outofcredit
        fi
        ;;
    *)
        echo Unknown COMMAND $COMMAND VALUE $VALUE
        if [ "${DEBUG_playout_controls_sh}" == "TRUE" ]; then echo "Unknown COMMAND ${COMMAND} VALUE ${VALUE}" >> ${PATHDATA}/../logs/debug.log; fi
        ;;
esac

# Update credit value (to not loose it on shutdown/restart or failures)
. ${PATHDATA}/inc.writeCreditValue.sh
