#!/bin/bash
#' ---
#' title: Move PlSql Results
#' date:  2020-04-30 09:46:09
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Results and logfiles from plsql programs are moved away to no clutter database directories.
#'
#' ## Description
#' Move results and logfiles from a plsql program.
#'
#' ## Details
#' When running plsql programs, logfiles are written to directories visible from the database. Results are moved away to a local directory with this script
#'
#' ## Example
#' ./bash/move_plsql_results.sh -s <source_path> -t <target_dir>
#'
#' ## Set Directives
#' General behavior of the script is driven by the following settings
#+ bash-env-setting, eval=FALSE
set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  #  hence pipe fails if one command in pipe fails


#' ## Global Constants
#' ### Paths to shell tools
#+ shell-tools, eval=FALSE
ECHO=/bin/echo                             # PATH to echo                            #
DATE=/bin/date                             # PATH to date                            #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #

#' ### Directories
#' Installation directory of this script
#+ script-directories, eval=FALSE
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #

#' ### Files
#' This section stores the name of this script and the
#' hostname in a variable. Both variables are important for logfiles to be able to
#' trace back which output was produced by which script and on which server.
#+ script-files, eval=FALSE
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SERVER=`hostname`                          # put hostname of server in variable      #



#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -e <result_ext> -s <result_source_path> -t <result_target_dir>"
  $ECHO "  where -e <result_ext>          --  extension of result file (optional)"
  $ECHO "        -s <result_source_path>  --  path to result file (optional)"
  $ECHO "        -t <result_target_dir>   --  result target directory (optional)"
  $ECHO ""
  exit 1
}

#' ### Start Message
#' The following function produces a start message showing the time
#' when the script started and on which server it was started.
#+ start-msg-fun, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' ### End Message
#' This function produces a message denoting the end of the script including
#' the time when the script ended. This is important to check whether a script
#' did run successfully to its end.
#+ end-msg-fun, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' ### Log Message
#' Log messages formatted similarly to log4r are produced.
#+ log-msg-fun, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}


#' ## Main Body of Script
#' The main body of the script starts here.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
RESULTSRCDEFAULT="/Volumes/argus_solis/qualitas/batch/out"
RESULTSRC=""
RESULTTRGDEFAULT="$(pwd)/log"
RESULTTRG=""
RESULTEXTDEFAULT="csv_notopen"
RESULTEXT=""
RESULTJSONDEFAULT='json'
RESULTJSON=""
while getopts ":e:j:s:t:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    e)
      RESULTEXT=$OPTARG
      ;;
    j)
      RESULTJSON=$OPTARG
      ;;
    s)
      RESULTSRC=$OPTARG
      ;;
    t)
      RESULTTRG=$OPTARG
      ;;
    :)
      usage "-$OPTARG requires an argument"
      ;;
    ?)
      usage "Invalid command line argument (-$OPTARG) found"
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

#' ## Checks for Command Line Arguments
#' For non-specified command line arguments, the respective default 
#' values are assigned.
#+ argument-test, eval=FALSE
if test "$RESULTSRC" == ""; then
  RESULTSRC=$RESULTSRCDEFAULT
fi
if test "$RESULTTRG" == ""; then
  RESULTTRG=$RESULTTRGDEFAULT
fi
if test "$RESULTEXT" == ""; then
  RESULTEXT=$RESULTEXTDEFAULT
fi
if test "$RESULTJSON" == "";then
  RESULTJSON=$RESULTJSONDEFAULT
fi



#' ## Move Results
#' If the result source path is specified as a concrete file, then this file 
#' is moved to the target directory. If the result source is a directory then 
#' all files with the given extension in $RESULTEXT are moved
#+ move-results
if [ -f "$RESULTSRC" ]
then
  # check whether extension is csv_notopen
  if [ $(basename "$RESULTSRC" | cut -d '.' -f2) == "csv_notopen" ] 
  then
    RESULTBNAME=$(basename "$RESULTSRC" | cut -d '.' -f1).csv
    log_msg $SCRIPT "Moving $RESULTSRC to $RESULTTRG/$RESULTBNAME"
    mv $RESULTSRC $RESULTTRG/$RESULTBNAME
  else
    log_msg $SCRIPT "Moving $RESULTSRC to $RESULTTRG"
    mv $RESULTSRC $RESULTTRG
  fi  
elif [ -d "$RESULTSRC" ]
then
  # result files
  if [ `ls -1 "${RESULTSRC}"/*."${RESULTEXT}" 2> /dev/null | wc -l` -gt 0 ]
  then
    ls -1 "${RESULTSRC}"/*."${RESULTEXT}" | while read f
    do
      log_msg $SCRIPT "Moving $f to $RESULTTRG"
      if [ "$RESULTEXT" == "csv_notopen" ]
      then
        RESULTBNAME=$(basename "$f" | cut -d '.' -f1).csv
        log_msg $SCRIPT "Moving $f to $RESULTTRG/$RESULTBNAME"
        mv $f $RESULTTRG/$RESULTBNAME
      else
        log_msg $SCRIPT "Moving $f to $RESULTTRG"
        mv $f $RESULTTRG
      fi  
    done
  else
    log_msg $SCRIPT " * No results files matching ${RESULTSRC}"/*."${RESULTEXT} found ..."
  fi
  # json files
  if [ `ls -1 "${RESULTSRC}"/*."${RESULTJSON}" 2> /dev/null | wc -l` -gt 0 ]
  then
    ls -1 "${RESULTSRC}"/*."${RESULTJSON}" | while read f
    do
        log_msg $SCRIPT "Moving $f to $RESULTTRG"
        mv $f $RESULTTRG
    done
  else
    log_msg $SCRIPT " * No results files matching ${RESULTSRC}"/*."${RESULTJSON} found ..."
  fi
else
  log_msg $SCRIPT " * ERROR: Cannot find result source: $RESULTSRC"
fi


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

