#!/usr/bin/bash

v1=22
v2=$v1+1

for file in ./*/*/*.lua 
do
	sed "s/MINOR = $v1/MINOR = $v2/" -i $file
done

for file in ./LibScriptableLocale-1.0/*.lua
do
	sed "s/MINOR = $v1/MINOR = $v2/" -i $file
done
