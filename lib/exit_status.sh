#!/usr/bin/env bash


# constants file, disable SC2034
# shellcheck disable=SC2034
true

# List of semi-standard exit status codes

# Sources:
#  A: http://tldp.org/LDP/abs/html/exitcodes.html#EXITCODESREF
#  B: http://www.gnu.org/software/libc/manual/html_node/Exit-Status.html
#  C: sysexits.h
EX_OK=0           # successful termination                  ## source: A
EX_SUCCESS=0      # successful termination                  ## source: A
EX_ERR=1          # Catchall for general errors             ## source: A

# Don't use. Reserved for bash
EX_SHELL=2        # Misuse of shell builtins                ## source: A

EX_USAGE=64       # command line usage error                ## source: C
EX_DATAERR=65     # data format error                       ## source: C
EX_NOINPUT=66     # cannot open input                       ## source: C
EX_NOUSER=67      # addressee unknown                       ## source: C
EX_NOHOST=68      # host name unknown                       ## source: C
EX_UNAVAILABLE=69 # service unavailable                     ## source: C
EX_SOFTWARE=70    # internal software error                 ## source: C
EX_OSERR=71       # system error (e.g., can't fork)         ## source: C
EX_OSFILE=72      # critical OS file missing                ## source: C
EX_CANTCREAT=73   # can't create (user) output file         ## source: C
EX_IOERR=74       # input/output error                      ## source: C
EX_TEMPFAIL=75    # temp failure; user is invited to retry  ## source: C
EX_PROTOCOL=76    # remote error in protocol                ## source: C
EX_NOPERM=77      # permission denied                       ## source: C
EX_CONFIG=78      # configuration error                     ## source: C

# Don't use. Reserved for bash
EX_NOEXEC=126     # Command invoked cannot execute          ## source: A
EX_NOTFOUND=127   # "command not found"                     ## source: A

# These two are in direct conflict, don't use
EX_EXIT_ERR=128   # Invalid argument to exit                ## source: A
EX_EXEC_FAIL=128  # Failed to execute subprocess            ## source: B

EX_SIGTERM=130    # Script terminated by Control-C          ## source: A


# Custom homeshick status codes (range: 79-113)
EX_AHEAD=85       # local HEAD is ahead of its upstream branch
EX_BEHIND=86      # local HEAD is behind its upstream branch
EX_TH_EXCEEDED=87 # Time since last repository update is larger than the threshhold
EX_MODIFIED=88    # local working directory has modified files
