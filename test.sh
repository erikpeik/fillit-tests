#!/bin/bash

FILLIT_PATH=`cat path.ini`
echo fillit path: $FILLIT_PATH

function main()
{
	if [ ! -f "$FILLIT_PATH/fillit" ]; then
		echo "$(tput setab 1)Can't find fillit$(tput setab 7)"
		exit 1
	fi
#	test valid "valid_tests/valid_" 14 "echo "error"" 0
	cd valid_tests/
	for file in easy_*
	do
#		echo "compere_tests/output_$file"
		yours=$($FILLIT_PATH/fillit $file)
		cd ..
#		echo "$PWD/copere_tests/output_$file" 
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
#		time $FILLIT_PATH/fillit $PWD/$file | grep "user"
#		echo "$yours"
#		echo "$correct"
	done
#	$FILLIT_PATH/fillit valid_tests/valid_7.test
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
}

if [ $# -eq 0 ]; then
	echo "$(tput setaf 1)No arguments provided...$(tput sgr0)"
	echo -n "$(tput setab 7)$(tput setaf 0)./run.test make$(tput sgr0)"
	echo "$(tput bold) make re & make clean"
	exit 1
fi

if [ $1 = "make" ]; then
	make_reclean
	exit 1
fi


