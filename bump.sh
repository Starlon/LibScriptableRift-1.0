#!/usr/bin/bash

for file in ./*/*/*lua 
do
	sed "s/MINOR = 21/MINOR = 22/" -i $file
done
