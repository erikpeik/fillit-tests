#!/bin/bash

# GITHUB: github.com/erikpeik/fillit-tests

FILLIT_PATH=`cat path.ini`
TEST_PATH=$PWD
INVALID_PATH=$PWD/invalid_tests

LBLUE='\033[1;34m'
WHITE='\033[1;37m'
GREEN='\033[0;32m'
LGREEN='\033[1;32m'
RED='\033[0;31m'

printf "${WHITE}fillit path:$(tput sgr0) $LBLUE$FILLIT_PATH\n"

function valid_compare()
{
	echo "$(tput setab 4)YOUR RESULT:$(tput sgr0)"
	echo "$($FILLIT_PATH/fillit $TEST_PATH/valid_tests/$1)"
	echo 
	echo "$(tput setab 1)COMPAIRED RESULT:$(tput sgr0)"
	cat "$TEST_PATH/compare_tests/output_$1"
}

function invalid_compare()
{
	echo "$(tput setab 4)YOUR RESULT:$(tput sgr0)"
	echo "$($FILLIT_PATH/fillit $TEST_PATH/invalid_tests/$1)"
	echo 
	echo "$(tput setab 1)COMPAIRED RESULT:$(tput sgr0)"
	echo "error"
}

function easy()
{
	if [ ! -f "$FILLIT_PATH/fillit" ]; then
		make_reclean
	fi
	cd valid_tests/
	tput sgr0
	for file in easy_*
	do
		yours=$($FILLIT_PATH/fillit $file)
		cd ..
		correct=$(<$PWD/compare_tests/output_$file)
		cd valid_tests/
		if [ "$yours" != "$correct" ]
		then
			echo -n "$(tput setaf 1)$file	: $(tput sgr0)"
			echo "$(tput setab 1)$(tput bold)FAIL$(tput sgr0)"
			valid_compare $file
		else
			echo -n "$(tput setaf 2)$file	: $(tput sgr0)"
			echo "$(tput setab 2)$(tput bold)OK!$(tput sgr0)"
		fi
		if [ $# -gt 0 ] && [ $1 -eq 1 ]; then
			time $FILLIT_PATH/fillit $PWD/$file | grep "user"
		fi
		if [ $# -gt 1 ] && [ $2 -eq 1 ]; then
			cd ..
			mkdir $PWD/valgrind_logs/ > /dev/null 2>&1
			rm -f $PWD/valgrind_logs/log_$file
			valgrind --log-file="$PWD/valgrind_logs/log_$file" $FILLIT_PATH/fillit $PWD/valid_tests/$file > /dev/null 2>&1
			cat "$PWD/valgrind_logs/log_$file" | grep -E "definitely lost|indirectly lost|possibly lost|still reachable"
			cd valid_tests/
		fi
	done
}

function medium()
{
	if [ ! -f "$FILLIT_PATH/fillit" ]; then
		make_reclean
	fi
	echo "$(tput bold)$(tput setaf 1)MEDIUM TEST $(tput setaf 0)| $(tput setaf 7)ESTIMATED TIME 10 sec$(tput sgr0) "
	yours=$($FILLIT_PATH/fillit $TEST_PATH/valid_tests/medium_0)
	correct=$(<$TEST_PATH/compare_tests/output_medium_0)
	if [ "$yours" != "$correct" ]
	then
		echo -n "$(tput setaf 1)medium_0	: $(tput sgr0)"
		echo "$(tput setab 1)$(tput bold)FAIL$(tput sgr0)"
		valid_compare medium_0
		exit 1
	else
		echo -n "$(tput setaf 2)medium_0	: $(tput sgr0)"
		echo "$(tput setab 2)$(tput bold)OK!$(tput sgr0)"
		echo 
		echo "$yours"
	fi
	echo "$(tput bold)$(tput setaf 4)Do you wan't run it again with timer? $(tput setaf 2)(yes/no)$(tput sgr0)"
	read timer
	if [ "$timer" ==  "yes" ]; then
		time $FILLIT_PATH/fillit $TEST_PATH/valid_tests/medium_0 | grep "user"
	fi
	echo "$(tput bold)$(tput setaf 4)Do you want run it with valgrind? $(tput setaf 2)(yes/no)$(tput sgr0)"
	read val
	if [ "$val" == "yes" ]; then
		mkdir $TEST_PATH/valgrind_logs/ > /dev/null 2>&1
		rm -f $TEST_PATH/valgrind_logs/log_medium_0
		valgrind --log-file="$TEST_PATH/valgrind_logs/log_medium_0" $FILLIT_PATH/fillit $TEST_PATH/valid_tests/medium_0 > /dev/null 2>&1
		cat "$TEST_PATH/valgrind_logs/log_medium_0" | grep -E "definitely lost|indirectly lost|possibly lost|still reachable"
	fi
}

function hard()
{
	if [ ! -f "$FILLIT_PATH/fillit" ]; then
		make_reclean
	fi
	echo "$(tput bold)$(tput setaf 1)HARD/MAX TEST $(tput setaf 0)| $(tput setaf 7)ESTIMATED TIME 3-5 min$(tput sgr0)"
#	yours=$($FILLIT_PATH/fillit $TEST_PATH/valid_tests/hard_max)
#	correct=$(<$TEST_PATH/compare_tests/output_hard_max)
	time $FILLIT_PATH/fillit $TEST_PATH/valid_tests/hard_max
	echo "$(tput bold)$(tput setaf 4)Do you want run it with valgrind? $(tput setaf 2)(yes/no)$(tput sgr0)"
	read val
	if [ "$val" == "yes" ]; then
		mkdir $TEST_PATH/valgrind_logs/ > /dev/null 2>&1
		rm -f $TEST_PATH/valgrind_logs/log_hard_max
		valgrind --log-file="$TEST_PATH/valgrind_logs/log_hard_max" $FILLIT_PATH/fillit $TEST_PATH/valid_tests/hard_max > /dev/null 2>&1
		cat "$TEST_PATH/valgrind_logs/log_hard_max" | grep -E "definitely lost|indirectly lost|possibly lost|still reachable"
	fi
}


function invalid()
{
	if [ ! -f "$FILLIT_PATH/fillit" ]; then
		make_reclean
	fi
	cd invalid_tests/
	tput sgr0
	for file in invalid_*
	do
		diff=$($FILLIT_PATH/fillit $PWD/$file)
#		echo $diff
		if [ "$diff" != "error" ]; then
			echo -n "$(tput setaf 1)$file	: $(tput sgr0)"
			echo "$(tput setab 1)$(tput bold)FAIL$(tput sgr0)"
		else
			echo -n "$(tput setaf 2)$file	: $(tput sgr0)"
			echo "$(tput setab 2)$(tput bold)OK!$(tput sgr0)"
		fi
		if [ $# -gt 0 ] && [ $1 -eq 1 ]; then
			mkdir $TEST_PATH/valgrind_logs/ > /dev/null 2>&1
			rm -f $TEST_PATH/valgrind_logs/log_$file
			valgrind --log-file="$TEST_PATH/valgrind_logs/log_$file" $FILLIT_PATH/fillit $TEST_PATH/invalid_tests/$file > /dev/null 2>&1
			cat "$TEST_PATH/valgrind_logs/log_$file" | grep -E "definitely lost|indirectly lost|possibly lost|still reachable"
		fi
	done
}

function make_reclean()
{	if [ ! -d "$FILLIT_PATH" ]; then
	echo "$(tput setab 1)Folder doesn't exist.$(tput sgr0)"
		exit 1
	fi
	if [ ! -f "$FILLIT_PATH/Makefile" ]; then
		echo "$(tput setab 1)Makefile doesn't exist.$(tput setab 7)"
		exit 1
	fi
	make re -C $FILLIT_PATH
	make clean -C $FILLIT_PATH
	tput setaf 7
	if [ ! -f "$FILLIT_PATH/fillit" ]; then
		echo "$(tput setab 1)Can't find fillit$(tput setab 7)"
		exit 1
	fi
}

if [ $# -eq 0 ]; then
	echo "$(tput setaf 1)No arguments provided...$(tput sgr0)"
	printf "${WHITE}./test.sh make ${GREEN}make re && make clean$(tput sgr0)\n\n"
	printf "${RED}usage: ${WHITE}/test.sh [difficulty]\n"
	printf "${WHITE}./test.sh easy [0/1 time] [0/1 valgrind] ${GREEN}run easy test files.\n"
	printf "${WHITE}./test.sh medium ${GREEN}run medium test file.\n"
	printf "${WHITE}./test.sh hard ${GREEN}run hard test file.\n"
	exit 1
fi

if [ $1 = "make" ]; then
	make_reclean
	exit 1
fi

if [ $1 = "easy" ]; then
	easy $2 $3
	exit 1
fi

if [ $1 = "invalid" ]; then
	invalid $2
	exit 1
fi

if [ $1 = "medium" ]; then
	medium $2
	exit 1
fi

if [ $1 = "hard" ]; then
	hard
	exit 1
fi
