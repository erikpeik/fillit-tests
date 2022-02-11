#!/bin/bash

# GITHUB: github.com/erikpeik/fillit-tests

FILLIT_PATH=`cat path.ini`
TEST_PATH=$PWD
LBLUE='\033[1;34m'
WHITE='\033[1;37m'
GREEN='\033[0;32m'
LGREEN='\033[1;32m'
RED='\033[0;31m'

printf "${WHITE}fillit path:$(tput sgr0) $LBLUE$FILLIT_PATH\n"

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
			echo "$(tput setab 2)$(tput bold)FAIL$(tput sgr0)"
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
			cat "$PWD/valgrind_logs/log_$file" | grep "lost"
			cd valid_tests/
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
	printf "${RED}usage: ${WHITE}/test.sh [difficulty] [0 = no time / 1 = with time]\n"
	printf "${WHITE}./test.sh easy [0/1] ${GREEN}run easy test files.\n"
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
	invalid
	exit 1
fi
