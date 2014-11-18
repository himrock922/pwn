#!/bin/sh

while true
do
	sleep 5
	echo "NEW b161-20be-f5fb-57b8 2e:10:c1:5d:4f:ad 0004b50030 0011d70030 00135c0030 000cf80000"
	echo "NEW 7602-2a21-6940-dd32 ba:ae:6e:82:64:b8 0005e90020 0004810020 0004b50030 0011d70030"
	sleep 60
	
	echo "DEL b161-20be-f5fb-57b8"
	echo "DEL 7602-2a21-6940-da32"
done
