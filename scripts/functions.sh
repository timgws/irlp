function die_if_not_root {
    if [[ $UID -ne 0 ]]; then
        echo "you are not root. please switch to root to use this command!";
        exit 2;
    fi
}

function die_if_not_user {
    if [ -z "$1" ]; then
        die_if_not_root;
        return;
    fi

    USER=$1;
    USER_UID=`cat /etc/passwd | grep ^$USER: | cut -d: -f 3`
    if [ -z "$USER_UID" ]; then
        echo "The user $USER does not exist!";
    elif [ $UID -ne "$USER_UID" ] && [ $UID -ne 0 ]; then
        echo "you are not root, or the repeater user ($USER). please switch to use this command!";
        exit 2;
    fi
}

function restart_service {
    # note, one day this should check (properly) what distro you are on. RHEL7 is "good enough" for now...
    if [ -e "/etc/redhat-release" ]; then
        /sbin/service $1 restart
    else
        echo "I tried to restart ${1}. I failed. You should try it manually.";
    fi
}

# width:
calc_columns () {
	STAT_COL=80
	if [[ ! -t 1 ]]; then
		USECOLOR=""
	elif [[ -t 0 ]]; then
		# stty will fail when stdin isn't a terminal
		STAT_COL=$(stty size)
		# stty gives "rows cols"; strip the rows number, we just want columns
		STAT_COL=${STAT_COL##* }
	elif tput cols &>/dev/null; then
		# is /usr/share/terminfo already mounted, and TERM recognized?
		STAT_COL=$(tput cols)
	fi
	if (( STAT_COL == 0 )); then
		# if output was 0 (serial console), set default width to 80
		STAT_COL=80
		USECOLOR=""
	fi

	# we use 13 characters for our own stuff
	STAT_COL=$(( STAT_COL - 13 ))

	if [[ -t 1 ]]; then
		SAVE_POSITION="\e[s"
		RESTORE_POSITION="\e[u"
		DEL_TEXT="\e[$(( STAT_COL + 4 ))G"
	else
		SAVE_POSITION=""
		RESTORE_POSITION=""
		DEL_TEXT=""
	fi
}

calc_columns

# Prefixs
PREFIX_REG="::"
PREFIX_HL=" >"

# set colors
if [[ $USECOLOR != [nN][oO] ]]; then
    if tput setaf 0 &>/dev/null; then
        C_CLEAR=$(tput sgr0)                      # clear text
        C_MAIN=${C_CLEAR}$(tput bold)        # main text
        C_OTHER=${C_MAIN}$(tput setaf 4)     # prefix & brackets
        C_SEPARATOR=${C_MAIN}$(tput setaf 0) # separator
        C_BUSY=${C_CLEAR}$(tput setaf 6)     # busy
        C_FAIL=${C_MAIN}$(tput setaf 1)      # failed
        C_DONE=${C_MAIN}                          # completed
        C_BKGD=${C_MAIN}$(tput setaf 5)      # backgrounded
        C_H1=${C_MAIN}                            # highlight text 1
        C_H2=${C_MAIN}$(tput setaf 6)        # highlight text 2
    else
        C_CLEAR="\e[m"          # clear text
        C_MAIN="\e[;1m"         # main text
        C_OTHER="\e[1;34m"      # prefix & brackets
        C_SEPARATOR="\e[1;30m"  # separator
        C_BUSY="\e[;36m"        # busy
        C_FAIL="\e[1;31m"       # failed
        C_DONE=${C_MAIN}        # completed
        C_BKGD="\e[1;35m"       # backgrounded
        C_H1=${C_MAIN}          # highlight text 1
        C_H2="\e[1;36m"         # highlight text 2
    fi
fi

deltext() {
    printf "${DEL_TEXT}"
}

printhl() {
    printf "${C_OTHER}${PREFIX_HL} ${C_H1}${1}${C_CLEAR} \n"
}

printsep() {
    printf "\n${C_SEPARATOR}   ------------------------------\n"
}

stat_bkgd() {
    printf "${C_OTHER}${PREFIX_REG} ${C_MAIN}${1}${C_CLEAR} "
    deltext
    printf "   ${C_OTHER}[${C_BKGD}BKGD${C_OTHER}]${C_CLEAR} \n"
}

stat_busy() {
    printf "${C_OTHER}${PREFIX_REG} ${C_MAIN}${1}${C_CLEAR} "
    printf "${SAVE_POSITION}"
    deltext
    printf "   ${C_OTHER}[${C_BUSY}BUSY${C_OTHER}]${C_CLEAR} "
}

stat_append() {
    printf "${RESTORE_POSITION}"
    printf -- "${C_MAIN}${1}${C_CLEAR}"
    printf "${SAVE_POSITION}"
}

stat_done() {
    deltext
    printf "   ${C_OTHER}[${C_DONE}DONE${C_OTHER}]${C_CLEAR} \n"
}

stat_fail() {
    deltext
    printf "   ${C_OTHER}[${C_FAIL}FAIL${C_OTHER}]${C_CLEAR} \n"
}