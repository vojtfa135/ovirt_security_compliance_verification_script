#!/bin/bash
###############################################################################
# (c) Copyright Hewlett-Packard Development Company, L.P., 2006
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of version 2 the GNU General Public License as
#   published by the Free Software Foundation.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################
#
# PURPOSE:
# Verify pam_pwquality settings are applied

source testcase.bash || exit 2

# setup
# allow TEST_USER to write to tmpfile
pwConf=/etc/security/pwquality.conf
declare -A aConfig
randPw=""
testFailureCount=1
export TEST_USER_PW="?3Xy#?_&=RrMRF74F"
export RAND_PW=""

generatePw () {
	chars='<=>| ,;:!/."[]*&#%+012345689abcdefghiklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	if [[ $1 -gt $2 && $1 -gt 10 ]]
	then
		minNum=$1
	elif [[ $2 && $2 -gt 10 ]]
	then
		minNum=$1
	else
		minNum=10
	fi
	for (( i=1; i<=($minNum); i++ )) ; do
                randPw="${randPw}${chars:RANDOM%${#chars}:1}"
        done
}

generateMinLenPw () {
	chars='!@#$%^&*()012345689abcdefghiklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	for (( i=1; i<=($1 - 1); i++ )) ; do
		randPw="${randPw}${chars:RANDOM%${#chars}:1}"
	done
}

generateNoNumPw () {
	chars='<=>| ,;:!/."[]*&#%+abcdefghiklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	minNum=10
	if [[ $1 ]]
	then
		minNum=$1
	fi
        for (( i=1; i<=($minNum); i++ )) ; do
		randPw="${randPw}${chars:RANDOM%${#chars}:1}"
        done
}

generateMinNumPw () {
	chars='1234567890'
        for (( i=1; i<=($1); i++ )) ; do
                randPw="${randPw}${chars:RANDOM%${#chars}:1}"
        done
}

generateNoUpPw () {
        chars='<=>| ,;:!/."[]*&#%+012345689abcdefghiklmnopqrstuvwxyz'
        minNum=10
        if [[ $1 ]]
        then
                minNum=$1
        fi      
        for (( i=1; i<=($minNum); i++ )) ; do
                randPw="${randPw}${chars:RANDOM%${#chars}:1}"
        done    
}               
                
generateMinUpPw () {
      	chars='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        for (( i=1; i<=($1); i++ )) ; do
                randPw="${randPw}${chars:RANDOM%${#chars}:1}"
        done
	echo "$randPw --- $1"
}

generateNoLowPw () {
        chars='<=>| ,;:!/."[]*&#%+012345689ABCDEFGHIJKLMNOPQRSTUVWXYU'
        minNum=10
        if [[ $1 ]]
        then
                minNum=$1
        fi
        for (( i=1; i<=($minNum); i++ )) ; do
                randPw="${randPw}${chars:RANDOM%${#chars}:1}"
        done
}

generateMinLowPw () {
        chars='abcdefghiklmnopqrstuvwxyz'
        for (( i=1; i<=($1); i++ )) ; do
                randPw="${randPw}${chars:RANDOM%${#chars}:1}"
        done
}

generateNoOthPw () {
        chars='<=>| ,;:!/."[]*&#%+012345689abcdefghiklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        minNum=10
        if [[ $1 ]]
        then
                minNum=$1
        fi
        for (( i=1; i<=($minNum); i++ )) ; do
                randPw="${randPw}${chars:RANDOM%${#chars}:1}"
        done
}

generateMinOthPw () {
        chars='<=>| ,;:!/."[]*&#%+'
        for (( i=1; i<=($1); i++ )) ; do
                randPw="${randPw}${chars:RANDOM%${#chars}:1}"
        done
}

generateMinClassPw () {
	chars=''
	minNum=10
	if [[ $2 ]]
        then
                minNum=$2
        fi  

	if [[ $1 -eq 2 ]]
	then
		chars='<=>| ,;:!/."[[]*&#%+'
	elif [[ $1 -eq 3 ]]
	then
		chars='<=>| ,;:!/."[[]*&#%+1234567890'
	elif [[ $1 -eq 4  ]]
	then
		chars='<=>| ,;:!/."[[]*&#%+1234567890abcdefghiklmnopqrstuvwxyz'
	fi
	for (( i=1; i<=($minNum); i++ )) ; do
                randPw="${randPw}${chars:RANDOM%${#chars}:1}"
        done
}

generateMaxRepeatPw () {
	randPw='A#v'
	minNum=10
	if [[ $2 && $2 < $1 ]]
	then
		minNum=$2
	else
		minNum=$1
	fi
	for (( i=1; i<=($minNum); i++ )) ; do
                randPw="${randPw}2"
        done
}

setPw () {
	(
        expect -c '
                spawn su testuser1
                expect -nocase {assword: $} {send "$env(TEST_USER_PW)\r"}
                send "passwd\r"
                expect -nocase {(current) UNIX password: $} {send "$env(TEST_USER_PW)\r"}
                expect -nocase {ew password: $} {send "$env(RAND_PW)\r"}
        	expect -nocase {etype new password: $} {send "$env(RAND_PW)\r"}
		expect -nocase {passwd: all authentication tokens updated successfully}
	       	expect eof
                exit
        '
        )
	export TEST_USER_PW=$randPw
	export RAND_PW="${randPw}2"
}


execTest () {
	(
        expect -c '
                spawn su testuser1
                expect -nocase {assword: $} {send "$env(TEST_USER_PW)\r"}
                send "passwd\r"
                expect -nocase {(current) UNIX password: $} {send "$env(TEST_USER_PW)\r"}
                expect -nocase {ew password: $} {send "$env(RAND_PW)\r"}
                expect -nocase {BAD PASSWORD}
                expect -nocase {ew password: $} {send "$env(RAND_PW)\r"}
                expect -nocase {BAD PASSWORD}
                expect -nocase {ew password: $} {send "$env(RAND_PW)\r"}
                expect -nocase {BAD PASSWORD}
                expect -nocase {passwd: Have exhausted maximum number of retries for service}
                expect eof
                exit
        '
	)
	
	count=$(augrok -c type=USER_CHAUTHTOK msg_1=~"PAM:*chauthtok.* acct=\"testuser1\".* exe.*=.*/bin/passwd.* res=failed.*") 

	if (( $count < $testFailureCount ))
	then
		echo "last test was not successful"
		exit_fail
	fi

	testFailureCount=$(($testFailureCount + 1))
}

# For RHV only "minlen" is of importance therefore other parameters are not collected
#grep pw settings one by one
aConfig["minlen"]=$(grep -e "^[^#]minlen" $pwConf | sed 's/[^0-9]*//g')
#aConfig["dcredit"]=$(grep -e "^[^#]dcredit" $pwConf | sed 's/[^0-9-]*//g')
#aConfig["ucredit"]=$(grep -e "^[^#]ucredit" $pwConf | sed 's/[^0-9-]*//g')
#aConfig["lcredit"]=$(grep -e "^[^#]lcredit" $pwConf | sed 's/[^0-9-]*//g')
#aConfig["ocredit"]=$(grep -e "^[^#]ocredit" $pwConf | sed 's/[^0-9-]*//g')
#aConfig["minclass"]=$(grep -e "^[^#]minclass" $pwConf | sed 's/[^0-9]*//g')
#aConfig["maxrepeat"]=$(grep -e "^[^#]maxrepeat" $pwConf | sed 's/[^0-9]*//g')
#aConfig["maxclassrepeat"]=$(grep -e "^[^#]maxclassrepeat" $pwConf | sed 's/[^0-9]*//g')
#aConfig["difok"]=$(grep -e "^[^#]difok" $pwConf | sed 's/[^0-9]*//g')

append_cleanup "killall -9 -u testuser1; userdel -fr -Z testuser1"
append_cleanup "groupdel testuser1"

#test

#remove user if exists
userdel -fr -Z testuser1
groupdel testuser1
#add user
useradd testuser1

#change pw of testuser1
(
	expect -c '
	spawn passwd testuser1
	expect -nocase {ew password: $} {send "$env(TEST_USER_PW)\r"}
	expect -nocase {etype new password: $} {send "$env(TEST_USER_PW)\r"}
	expect eof
	exit
	'
)

for KEY in "${!aConfig[@]}"; do
	if ! [[ ${aConfig[$KEY]} =~ ^-?[0-9]+$ ]]
	then
		unset aConfig[$KEY]
	else
	case $KEY in

		difok)
			echo "Test difok"		
			randPw=""
                        generatePw ${aConfig[$KEY]} ${aConfig["minlen"]}
                        export RAND_PW=$randPw
			setPw
                        execTest
		;;

		minlen)
			echo "Test minlen"
			randPw=""
			generateMinLenPw ${aConfig[$KEY]}
			export RAND_PW=$randPw
			execTest
		;;

		dcredit)
			echo "Test dcredit"
			randPw=""
			if [[ 0 -gt ${aConfig[$KEY]} ]]
			then
        			generateNoNumPw ${aConfig["minlen"]}
				export RAND_PW=$randPw
                        	execTest
			else
				if [[ ${aConfig["minlen"]} > ${aConfig[$KEY]} ]]
				then
					generateMinNumPw ${aConfig["minlen"]}
					export RAND_PW=$randPw
                        		execTest
				fi
			fi	
              		;;

		ucredit)
        		echo "Test ucredit"
        		randPw=""
                        if [[ 0 -gt ${aConfig[$KEY]} ]]
                        then
                                generateNoUpPw ${aConfig["minlen"]}
                                export RAND_PW=$randPw
                                execTest
                        else
                                if [[ ${aConfig["minlen"]} -gt ${aConfig[$KEY]} ]]
                                then
                                        generateMinUpPw ${aConfig["minlen"]}
                                        export RAND_PW=$randPw
                                        execTest
                                fi
                        fi
		;;

		lcredit)
        		echo "Test lcredit"
			randPw=""
                        if [[ 0 -gt ${aConfig[$KEY]} ]]
                        then
                                generateNoLowPw ${aConfig["minlen"]}
                                export RAND_PW=$randPw
                                execTest
                        else
                                if [[ ${aConfig["minlen"]} -gt ${aConfig[$KEY]} ]]
                                then
                                        generateMinLowPw ${aConfig["minlen"]}
                                        export RAND_PW=$randPw
                                        execTest
                                fi
                        fi
        	;;

		ocredit)
        		echo "Test ocredit"
        		randPw=""
                        if [[ 0 -gt ${aConfig[$KEY]} ]]
                        then
                                generateNoOthPw ${aConfig["minlen"]}
                                export RAND_PW=$randPw
                                execTest
                        else
                                if [[ ${aConfig["minlen"]} -gt ${aConfig[$KEY]} ]]
                                then
                                        generateMinOthPw ${aConfig["minlen"]}
                                        export RAND_PW=$randPw
                                        execTest
                                fi
                        fi
		;;

		minclass)
        		echo "Test minclass"
			randPw=""
			generateMinClassPw ${aConfig[$KEY]} ${aConfig["minlen"]}
			export RAND_PW=$randPw
                        execTest
        	;;

		maxrepeat)
        		echo "Test maxrepeat"
			randPw=""
                        generateMaxRepeatPw ${aConfig[$KEY]} ${aConfig["minlen"]}
                        export RAND_PW=$randPw
                        execTest
        	;;

		maxclassrepeat)
        		echo "Test maxclassrepeat"
			randPw=""
                        generateMaxRepeatPw ${aConfig[$KEY]} ${aConfig["minlen"]}
                        export RAND_PW=$randPw
                        execTest
		;;

		*)
			echo "No policy set"
			exit_error
		;;
	esac
	fi
done
