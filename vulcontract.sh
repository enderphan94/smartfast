#!/bin/bash

if [ "$1" == "-h" ] || [ "$1" == "" ]
then
	echo -e "\e[33m"
	echo "-f  : file.sol"
	echo "-d  : code folder"
	echo -e "\e[97m"
	exit 0
fi

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -f|--filename)
    FILENAME="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--directory)
    DIRECTORY="$2"
    shift # past argument
    shift # past value
    ;;
    esac
done

set -- "${POSITIONAL[@]}"
file=${FILENAME}
dir=${DIRECTORY}


#searching (){

#}

declare -A arr

#AccessControl
#txt.origin https://medium.com/coinmonks/solidity-tx-origin-attacks-58211ad95514
#TODO: https://github.com/crytic/not-so-smart-contracts/tree/master/unprotected_function

#Arthmetic
#TODO: check for uint

#DOS
#TODO: ALL

#RaceCondition
#TODO: ALL

#ShortAddress
#TODO: ALL
arr["Reetrancy"]="call.value"
arr+=(["Access-Control"]="tx.origin" ["Arthmetic"]="uint8" ["Unchecked-Return-Values-For-Low-Level-Calls"]="call" ["Bad-Randomness"]="block.number" ["Time-Manipulation"]="block.timestamp" ["Hard-coded-Address"]="^0x\w{40}")

if [ ! -z "$file" ]
then
	for key in ${!arr[@]}; do
		#echo ${arr[${key}]}
		if [ "${key}" = "Bad-Randomness" ]
		then
			if sift -w  -e "${arr[${key}]}" -e "blockNumber" $file
			then
				echo "[-] Warning : ${key} vul might be found"
			else
				echo "[+] OK : ${key}"
			fi

		else if [ "${key}" = "Unchecked-Return-Values-For-Low-Level-Calls" ]
                then
                        if sift -w -e "${arr[${key}]}" -e "callcode" -e "delegatecall" -e "send" $file
                        then
                                echo "[-] Warning : ${key} vul might be found"
                        else
                                echo "[+] OK : ${key}"
                        fi
		else if [ "${key}" = "Hard-coded-Address" ]
                then
			echo "${arr[${key}]}"
                        if sift -w -e "${arr[${key}]}" $file
                        then
                                echo "[-] Warning : ${key} vul might be found"
                        else
                                echo "[+] OK : ${key}"
                        fi
		else if [ "${key}" = "Time-Manipulation" ]
                then
                        if sift -w -e "${arr[${key}]}" -e "[0-9]{10}" $file
                        then
                                echo "[-] Warning : ${key} vul might be found"
                        else
                                echo "[+] OK : ${key}"
                        fi
                else if sift -w  "${arr[${key}]}" $file
		then
			echo "[-] Warning : ${key} vul might be found"
		else
			echo "[+] OK : ${key}"
		fi
		fi
		fi
		fi
		fi
	done

fi

