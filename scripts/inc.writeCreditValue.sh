#!/bin/bash

# Creates a file for the credit value
# in the `settings` folder at:
#    settings/credit


# Set the date and time of now
NOW=`date +%Y-%m-%d.%H:%M:%S`

# The absolute path to the folder which contains all the scripts.
# Unless you are working with symlinks, leave the following line untouched.
PATHDATA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#############################################################
# $DEBUG TRUE|FALSE
# Read debug logging configuration file
. $PATHDATA/../settings/debugLogging.conf

# The absolute path to the folder which contains all the scripts.
# Unless you are working with symlinks, leave the following line untouched.
PATHDATA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ "${DEBUG_credit_controls_sh}" == "TRUE" ]; then echo "########### SCRIPT inc.writeCreditValue.sh ($NOW) ##" >> $PATHDATA/../logs/debug.log; fi
if [ "${DEBUG_credit_controls_sh}" == "TRUE" ]; then echo "VAR COMMAND: $COMMAND" >> $PATHDATA/../logs/debug.log; fi

##############################################
# CREDIT-Budget (will be changed during playback)
# 1. create a default if file does not exist
if [ ! -f $PATHDATA/../settings/credit ]; then
    echo "5" > $PATHDATA/../settings/credit
    chmod 777 $PATHDATA/../settings/credit
fi

#########################################################
# KEEP NEW VARS IN MIND
# Go through all given vars - make copy with prefix if found
NEWECREDIT=""
if [ "${DEBUG_credit_controls_sh}" == "TRUE" ]; then echo "  KEEP NEW VARS IN MIND" >> $PATHDATA/../logs/debug.log; fi
if [ "$CREDIT" ]; then NEWECREDIT="$CREDIT"; fi

CREDIT=`cat $PATHDATA/../settings/credit`

# Read the current config file (include will execute == read)
if [ "$NEWECREDIT" != "" ] && [ "$CREDIT" != "$NEWECREDIT"]
then 
    echo "${NEWECREDIT}" > "$PATHDATA/../settings/credit"
    CREDIT=`cat $PATHDATA/../settings/credit`
fi

