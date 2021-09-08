# === BEGIN lib.bash ===
#
# DO NOT EDIT until the end of lib.bash, the source is lib.bash!
#

set -eu
unset BASH_ENV # .bash_env might reset the environment in subshells, which we don't want.

# shellcheck disable=SC2034
{
    pname="$(basename "$0")"
    version='lib.bash:2.0'
    verbose=0
    dry_run=0

    EX_OK=0                 # successful termination
    EX_USAGE=64             # command line usage error
    EX_DATAERR=65           # data format error
    EX_NOINPUT=66           # cannot open input
    EX_NOUSER=67            # addressee unknown
    EX_NOHOST=68            # host name unknown
    EX_UNAVAILABLE=69       # service unavailable
    EX_SOFTWARE=70          # internal software error
    EX_OSERR=71             # system error (e.g., can't fork)
    EX_OSFILE=72            # critical OS file missing
    EX_CANTCREAT=73         # can't create (user) output file
    EX_IOERR=74             # input/output error
    EX_TEMPFAIL=75          # temp failure; user is invited to retry
    EX_PROTOCOL=76          # remote error in protocol
    EX_NOPERM=77            # permission denied
    EX_CONFIG=78            # configuration error


    use_color="${COLOR_PROMPT:-false}"
    escape=''
    bold="${escape}"'[1m'
    underline="${escape}"'[4m'
    blink="${escape}"'[5m'
    invert="${escape}"'[7m'
    no_bold="${escape}"'[22m'
    no_underline="${escape}"'[24m'
    no_blink="${escape}"'[25m'
    no_invert="${escape}"'[27m'
    black="${escape}"'[30m'
    red="${escape}"'[31m'
    green="${escape}"'[32m'
    yellow="${escape}"'[33m'
    blue="${escape}"'[34m'
    magenta="${escape}"'[35m'
    cyan="${escape}"'[36m'
    white="${escape}"'[37m'
    black_back="${escape}"'[40m'
    red_back="${escape}"'[41m'
    green_back="${escape}"'[42m'
    yellow_back="${escape}"'[43m'
    blue_back="${escape}"'[44m'
    magenta_back="${escape}"'[45m'
    cyan_back="${escape}"'[46m'
    white_back="${escape}"'[47m'
    normal="${escape}"'[0m'

    # message_background="${black_back}"
    message_background=""
}

function verbose(){
    if [ $verbose -ne 0 ] ; then
	# shellcheck disable=SC2059
	( printf "$@" ; printf '\n') \
	    | sed -e '/^$/d' \
	    | while read -r line ; do
	    printf '// %s: %s\n' "${pname}" "${line}"
	done
    fi
}

function run(){
    if [ $dry_run -eq 0 ] ; then
	if [ $verbose -ne 0 ] ; then
	    verbose "%s" "$*"
	fi
	"$@"
    else
        echo "$@"
    fi
}

#
# Tests
#

success=0
failure=0

function test_reset_counter(){
    success=0
    failure=0
}

function success(){
    if [ $dry_run -eq 0 ] ; then
	success=$((success+1))
	(
	    if $use_color ; then
		printf "%s" "${green}${message_background}"
	    fi
	    printf 'Success:  '
	    # shellcheck disable=SC2059
	    printf "$@"
	    if $use_color ; then
		printf '%s\n' "${normal}"
	    else
		printf '\n'
	    fi
	) 1>&2
    fi
}

function failure(){
    if [ $dry_run -eq 0 ] ; then
	failure=$((failure+1))
	(
	    if $use_color ; then
		printf "%s" "${red}${message_background}"
	    fi
	    printf 'Failure: '
	    # shellcheck disable=SC2059
	    printf "$@"
	    if $use_color ; then
		printf '%s\n' "${normal}"
	    else
		printf '\n'
	    fi
	) 1>&2
    fi
}

function test_run(){
    # test_run 'test a=%s' 42 -- test a -eq 42
    local message=()
    local command=()
    local expect_message=1
    for arg ; do
	if [ "$arg"  = "--" ] ; then
	    expect_message=0
	elif [ $expect_message -eq 0 ] ; then
	    command[${#command[@]}]="$arg"
	else
	    message[${#message[@]}]="$arg"
	fi
    done
    local format="${message[0]}"
    message=("${message[@]:1}")
    # unset message[0] # warning this doesn't change the index of the other elements!
    if [ $dry_run -eq 0 ] ; then
	printf '# Testing: '
	printf "${format}" "${message[@]}"
	printf '\n'
	echo "${command[@]}"
    else
	if run "${command[@]}" ; then
	    success "${format}" "${message[@]}"
	else
	    failure "Cannot ${format}" "${message[@]}"
	fi
    fi
}

function test_results(){
    if [ $dry_run -eq 0 ] ; then
	printf 'Total successes %6d\n' $success
	printf 'Total failures  %6d\n' $failure
	printf -- '----------------------\n'
	printf 'Total tests    %7d\n' $(( failure + success ))
    fi
}

#
# Messages
#

function error(){
    local dry=''
    if [ $dry_run -ne 0 ] ; then
	dry='# '
    fi
    (
	if $use_color ; then
	    printf "%s" "${red}${message_background}"
	fi
	printf '%s%s error: ' "${dry}" "${pname}"
	# shellcheck disable=SC2059
	printf "$@"
	if $use_color ; then
	    printf '%s\n' "${normal}"
	else
	    printf '\n'
	fi
    ) 1>&2
}

function warning(){
    local dry=''
    if [ $dry_run -ne 0 ] ; then
	dry='# '
    fi
	(
		if $use_color ; then
			printf "%s" "${yellow}${message_background}"
		fi
		printf '%s%s warning: ' "${dry}"  "${pname}"
		# shellcheck disable=SC2059
		printf "$@"
		if $use_color ; then
			printf '%s\n' "${normal}"
		else
			printf '\n'
		fi
	) 1>&2
}

function warn(){
	warning "$@"
}

function info(){
    local dry=''
    if [ $dry_run -ne 0 ] ; then
	dry='# '
    fi
	(
		if $use_color ; then
			printf "%s" "${green}${message_background}"
		fi
		printf '%s%s info: ' "${dry}"  "${pname}"
		# shellcheck disable=SC2059
		printf "$@"
		if $use_color ; then
			printf '%s\n' "${normal}"
		else
			printf '\n'
		fi
	) 1>&2
}

function debug(){
    local dry=''
    if [ $dry_run -ne 0 ] ; then
	dry='# '
    fi
	(
		if $use_color ; then
			printf "%s" "${magenta}${message_background}"
		fi
		printf '%s%s debug: ' "${dry}"  "${pname}"
		# shellcheck disable=SC2059
		if $use_color ; then
			printf '%s\n' "${normal}"
		else
			printf '\n'
		fi
	) 1>&2
}

function test_log_messages(){
    debug "Testing Log Messages"
    info  "Testing Log Messages"
    warn  "Testing Log Messages"
    error "Testing Log Messages"
}


#
# Options & arguments
#


options_flags=()
options_command=()
options_help=()

function define_option(){
    local flags="$1"
    local command
    local help
    shift
    while [ "$1" != "--" ] ; do
        flags="${flags}|$1"
        shift
    done
    shift
    command="$1"
    help="$2"
    options_flags[${#options_flags[@]}]="$flags"
    options_command[${#options_command[@]}]="$command" 
    options_help[${#options_help[@]}]="$help"
}

arguments_name=()
arguments_command=()
arguments_help=()

# define_arguments file set_file 'Input file'

function define_arguments(){
    local name="$1"
    local command="$2"
    local help="$3"
    arguments_name[${#arguments_name[@]}]="${name}"
    arguments_command[${#arguments_command[@]}]="${command}"
    arguments_help[${#arguments_help[@]}]="${help}"
}

function usage(){
    printf '%s usage:\n\n' "${pname}"
    local blank=" \\"$'\n'"    ${pname//?/ }"
    local prefix="    ${pname}"
    for flags in "${options_flags[@]}" ; do
        printf '%s [%s]' "${prefix}" "${flags}"
        prefix="${blank}"
    done
    if [ "${#options_arguments[@]}" -ne 0 ] ; then
        printf '%s' "${prefix}"
        for argument in "${options_arguments[@]}" ; do
            printf '%s ' "${argument}"
        done
        printf '\n'
    fi
    printf '\n\n'
    local i=0
    while [ $i -lt ${#options_flags[@]} ] ; do
        printf '    %-32s %s\n' "${options_flags[i]}" "${options_help[i]}"
        i=$(( i + 1 ))
    done
}

function help(){
    usage
    # TODO: protect exit from interactive shells.
    exit $EX_USAGE
}

function set_verbose(){
    verbose=1
}

function set_dry_run(){
    dry_run=1
}

function print_version(){
    printf '%s version %s\n' "${pname}" "${version}"
}

define_option -h --help help -- help           'Print this help.'
define_option -v --verbose   -- set_verbose    'Print more messages.'
define_option -n --dry-run   -- set_dry_run    'Print the commands, do not run them.'
define_option -V --version   -- print_version  'Print the version.'

function parse_options(){
    true
}


#
# === END lib.bash ===
