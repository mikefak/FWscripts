#!/bin/bash

#IPTABLES Simplified - created by @mikefak
#must be ran with sudo permissions, ideal for servers looking to establish basic firewall rules with iptables along with other easy access methods of the utility.
#Version 1.1

#Info collection and iptaples implementation

#Check for root privs
uid=$(id -u)
if [[ $uid -ne 0 ]];
then
    echo "Please run as root and try again"
    exit
fi

function fwsetup () {

    read -p "Please select an option for firewall configuration" dec
	
	while true; do

		case $dec in

			1) 
				#option 1, ecomm (20, 21, 80, 443 incoming/outgoing s/d ports, 22 outgoing  )
				echo "opt1"
				;;
			
			2)
				#option 2, database (ssh, )
				echo "opt2"
				;;

			3)
				#option 3, autosetup
				echo "opt3"
				;;
			
			4)
				#custom
				echo "opt4"
				;;
		esac
	done
            
}

function ecomm() {

	echo "ecomm funct"
}

function database () {

	echo "database funct"
}


function fwautosetup() {

	#Gathers active listening ports then print output into portnums file

	echo "The setup process is designed for systems hosting servers that are prematurley baselined, proceed with caution."
	echo 'Gathering active server info...'
	netstat -plnt | grep LISTEN |  awk '{print$4}' | sed 's/.*://' > portnums	

	#Establishes confirmation, then sorts through $portnums and establishes inbound/outbound rules

	echo 
	cat portnums
	echo
	read -p "The following ports will be appended as tcp iptable chains, is this ok? (y/n): " yn

	while true; do

		case $yn in

			y)

				while read port; do
					if [[ $port -le 49153 ]] 
						then 
						iptables -A INPUT -p tcp --dport $port -m state --state NEW,ESTABLISHED -j ACCEPT
						iptables -A OUTPUT -p tcp --sport $port -m state --state ESTABLISHED -j ACCEPT
					fi
				done < portnums
				returning
				rm portnums
				break;;

			n) 
				break;;

			*) echo 'Invalid entry '$yn 
				returning
				break;;
		esac
	done

}

#inet/nonet function
function inetnonet () {

	dnsresolv=$(grep nameserver /etc/resolv.conf | awk '{print$2}')

	read -p "Internet access will be accepted/dropped through the firewall in accordance to the dns resolver (accept/drop)" ac 
	while true; do

		case $ac in 

			accept) 

					iptables -I INPUT -p udp --sport 53 -s $dnsresolv -j ACCEPT
					iptables -I OUTPUT -p udp --dport 53 -d $dnsresolv -j ACCEPT

					iptables -I INPUT -p tcp -m multiport --sports 80,443 -j ACCEPT
					iptables -I OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

					returning
					break;;
			
			drop)
					iptables -D INPUT -p udp --sport 53 -s $dnsresolv -j ACCEPT
					iptables -D OUTPUT -p udp --dport 53 -d $dnsresolv -j ACCEPT

					iptables -D INPUT -p tcp -m multiport --sports 80,443 -j ACCEPT
					iptables -D OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
		
					returning
					break;;

			*) 
				echo "Please enter a valid entry"
		esac
	done

}

#Delete fw rules 
function delete() {

	#ask to delete all rules
	echo -e 'WARNING: ANY PREEXISTING IPTABLE CHAINS RULES WILL BE DELETED, PROCEED WITH CAUTION\n'

	read -p "Would you like to delete all pre-existing iptable chain rules? This will not apply to the traffic status (y/n): " dec
	while true; do

		case $dec in

			y)
				iptables -F
				returning
				break;;
			n)
				echo 'Exiting...'
				break;;

			*)
				echo 'Invalid entry' $dec
				returning
				break;;
		esac
	done


}

#add logging to all rules in form of y/n question
function logging() {

	
	read -p "Please choose to add or remove logging to the iptables chain (add/rm): " lyn
	while true; do

		case $lyn in

			add) 
				iptables -A INPUT -j LOG 
				iptables -A OUTPUT -j LOG
				echo 'Dropped packets will now be documented in /var/log'
				returning
				break;;

			rm) 
				iptables -D INPUT -j LOG
				iptables -D OUTPUT -j LOG
				echo 'Packets will no longer be logged'
				returning
				break;;

			*)
				echo 'Invalid entry' $lyn
		esac
	done

}

#y/n for traffic
function trafficstat() {

	#ask to accept/drop traffic

	read -p 'Please choose to ACCEPT/DROP all incoming and outgoing traffic (accept/drop): ' acyn

	while true; do

		case $acyn in

			accept)
					iptables -P INPUT ACCEPT
					iptables -P OUTPUT ACCEPT
					returning
					break;;
			drop) 
					iptables -P INPUT DROP
					iptables -P OUTPUT DROP
					returning 
					break;;
			*)
				echo 'Invalid entry, please try again' $acyn
				returning
				break;;
		esac
	done

}

#list fw rules
function listfw(){

	iptables -L 
	returning

}


#Decision to save/load pre-existing fw rules. Will prompt to save with savef if never opened.
function fwsave(){

	savef=1

	read -p "Would you like to save (--> /etc/fwrules) or load (<-- /etc/fwrules) current firewall rules?  (save/load): " slyn
	while true; do
		case $slyn in

			save)
				
				iptables-save > /etc/fwrules
				returning
				break;;

			load)
				
				iptables-restore < /etc/fwrules
				returning
				break;;

			*)
				
				echo 'Invalid entry' $slyn
				returning
				break;;
		esac
	done

}

function returning(){

	read -p 'Return to main menu -->'
}

clear

while true; do

	if [[ startf -eq 0 ]]
		then 
			echo 'Welcome to iptaples simplified'
			startf=1
		else 
			clear
			echo 'Anything else?'

	fi

	echo -e '---------------------------\n1. Firewall setup\n2. Accept/Deny Internet Access\n3. Delete rules\n4. Implement Logging\n5. Traffic Status\n6. List fw rules\n7. Save/Load rules\nq. Exit\n---------------------------'
	read -p 'Plese enter a number: ' choice

	case $choice in

		1)
			fwsetup
			;;

		2)
			inetnonet
			;;

		3) 
			delete
			;;
		4) 
			logging
			;;
		5)
			trafficstat
			;;

		6)
			listfw
			;;
		7)
			fwsave
			;;
		q) 
			
			while true; do
				if [[ savef -eq 0 ]]
				then 

					read -p 'You have not saved/loaded any rules this session, would you like to save/load before exiting? (y/n): ' syn

					while true; do
						case $syn in

							y) 
								iptables-save > /etc/fwrules
								break;;
							n)
								echo 'Goodbye!'
								exit;;

							*) 
								echo 'Invalid response' $syn 
							    break;;
								
						esac
					done

				else 	
					echo 'Goodbye!'
					exit
				fi
				done
			break
	esac
done
