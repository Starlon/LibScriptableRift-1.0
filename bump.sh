#!/usr/bin/bash

v1=20
v2=v1+1

for file in ./*/*/*.lua 
do
	sed "s/MINOR = $v1/MINOR = $v2/" -i $file
done

for file in ./Localization/*.lua
do
	sed "s/MINOR = $v1/MINOR = $v2/" -i $file
done
