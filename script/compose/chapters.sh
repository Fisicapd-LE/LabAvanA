#!/bin/bash

pwd
cd ./latex/section/$1

text="%%$1"

for f in *[!.backup]
do
	if [ -f "$f" ]
	then
		text="$text\n\n\\input{section/$1/$f}\n\\\\FloatBarrier\n"
	fi
done

printf $text > ../$1.tex


