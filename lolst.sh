#!/bin/bash
# made by jemcv (year 2100)
# mit license

# colors for the terminal
Color_Off='\033[0m' # Reset
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Cyan='\033[0;36m'   # Cyan
Purple='\033[0;35m' # Purple
Blue='\033[0;34m'   # Blue
BWhite='\033[1;37m' # White

# ascii art
if [ "$#" -ne 2 ]; then
	echo -e "${BWhite}
 _     ___  _         _     
| |   / _ \| |st  ___| |__  
| |  | | | | |   / __| '_ \ 
| |__| |_| | |___\__ \ | | |
|_____\___/|_____|___/_| |_| by jemcv 

  lol rank stats :)${Color_Off}

"
	echo -e "Usage: lolst <region> <summonername-id>"
	echo -e "Note: The summoner name and id should be one argument, separated by a dash."
	echo -e "Example: lolst kr HideOnBush-Kr1"
	exit 1
fi

region="$1"
summoner_name="$2"

# list of valid regions
valid_regions=("na" "euw" "eune" "kr" "jp" "oce" "br" "las" "lan" "ru" "tr" "sg" "ph" "tw" "vn" "th")

# check if the provided region is valid
if [[ ! ${valid_regions[*]} =~ ${region} ]]; then
	echo -e "${Red}Error: Invalid region. Valid regions are: ${valid_regions[*]}${Color_Off}"
	exit 1
fi

# check if the summoner name is in the correct format (alphanumeric and dashes only)
if [[ ! $summoner_name =~ ^[a-zA-Z0-9-]+$ ]]; then
	echo -e "${Red}Error: Summoner name should only contain alphanumeric characters and dashes.${Color_Off}"
	exit 1
fi

# check if the summoner name and region are not empty
if [ -z "$region" ] || [ -z "$summoner_name" ]; then
	echo -e "${Red}Error: Summoner name and region must not be empty.${Color_Off}"
	exit 1
fi

url="https://www.op.gg/summoners/$region/$summoner_name"

loader() {
	chars="/-\|"
	while :; do
		for ((i = 0; i < ${#chars}; i++)); do
			sleep 0.1
			echo -en "${Yellow}⌛ Loading...${chars:$i:1}" "\r${Color_Off}"
		done
	done
}

cleanup() {
	echo -e "\n${Red}❌ Aborted.${Color_Off}"
	if kill -0 "$loader_pid" 2>/dev/null; then
		kill "$loader_pid" # kill the background process
	fi
	exit 1
}

# handle ctrl+c
trap cleanup SIGINT

loader &

# save the background process of loader PID
loader_pid=$!

# check if curl command failed
if ! curl_content=$(curl -s "$url"); then
	echo -e "${Red}Failed to fetch data from $url${Color_Off}"
	kill $loader_pid
	exit 1
fi

# kill the loader process
kill $loader_pid

# extract the relevant information
tier=$(echo "$curl_content" | grep -oP '(?<=<div class="tier">)[^<]+' | head -n 1)
lp=$(echo "$curl_content" | grep -o '<div class="[^"]*lp[^"]*">[^<]*' | sed -e 's/<[^>]*>//g' | head -n 1)
ratio=$(echo "$curl_content" | grep -oP '(?<=<div class="ratio">).*?(?=</div>)' | sed -e 's/<[^>]*>//g' | head -n 1 | tr -d '\n')
level=$(echo "$curl_content" | grep -oP '<span[^>]*>\s*\d+\s*</span>' | sed -e 's/<[^>]*>//g' | head -n 1)
ranking=$(echo "$curl_content" | tr -d '\n' | grep -oP '<span class="ranking">\K[^<]*' | awk '{$1=$1};1')

# check if tier is available
if [ -z "$tier" ]; then
	echo -e "${Red} No rank info found for 🆔 $region/$summoner_name ${Color_Off}"
else
	echo -e "${Yellow}┝-----------------------------------------------┥${Color_Off}"
	echo -e "${BWhite}| 📈 LOLst.sh - League of Legends Stats
|
| [ Playing ]      |\__/,|   (\\\`
| [ League ]     _.|o o  |_   ) )
| [ >_< ]--   -(((---(((--------
|"
	echo -e "${BWhite}| 🔎 Result for $summoner_name: ${Color_Off}"

	# add array of emojis based on ranks
	rank_text="${tier^}" # capitalize the first letter

	case "$tier" in
	"iron") rank_emoji="🪓" ;;
	"bronze") rank_emoji="🥉" ;;
	"silver") rank_emoji="🥈" ;;
	"gold") rank_emoji="🥇" ;;
	"platinum") rank_emoji="💎" ;;
	"diamond") rank_emoji="💠" ;;
	"master") rank_emoji="🌟" ;;
	"grandmaster") rank_emoji="🏆" ;;
	"challenger") rank_emoji="👑" ;;
	*)
		rank_emoji="❓"
		rank_text="Unknown Rank"
		;;
	esac

	# rank info
	echo -e "${Blue}| 🆔 Summoner: https://www.op.gg/summoners/$region/$summoner_name ${Color_Off}"
	echo -e "${Green}| 🎮 Level: $level ${Color_Off}"
	echo -e "${Yellow}| $rank_emoji Tier: $rank_text ${Color_Off}"
	echo -e "| 🎯 LP: $lp ${Color_Off}"
	echo -e "${Cyan}| 📊 Ratio: $ratio ${Color_Off}"
	echo -e "${Purple}| 🏅 Ranking: $ranking ${Color_Off}"
	echo -e "${Yellow}┝-----------------------------------------------┥${Color_Off}"
fi

# this script uses data from op.gg to provide League of Legends player info
