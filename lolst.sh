#!/bin/bash
# made by jemcv (year 2100)
# mit license

# colors for the terminal
Color_Off='\033[0m' # Reset
Black='\033[0;30m'  # Black
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Cyan='\033[0;36m'   # Cyan
Purple='\033[0;35m' # Purple
Blue='\033[0;34m'   # Blue
BWhite='\033[1;37m' # White
BBlack='\033[1;30m' # Black

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
	echo -e "${White}Usage: lolst <region> <summonername-id>${Color_Off}"
	echo -e "${White}Note: The summoner name and id should be one argument, separated by a dash.${Color_Off}"
	echo -e "${White}Example: lolst kr HideOnBush-Kr1${Color_Off}"
	exit 1
fi

region="$1"
summoner_name="$2"

# list of valid regions
valid_regions=("na" "euw" "eune" "kr" "jp" "oce" "br" "las" "lan" "ru" "tr" "sg" "ph" "tw" "vn" "th")

# check if the provided region is valid
if [[ ! " ${valid_regions[@]} " =~ " ${region} " ]]; then
	echo -e "${Red}Error: Invalid region. Valid regions are: ${valid_regions[@]}${Color_Off}"
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

# run the curl command
curl_content=$(curl -s "$url")

# check if curl command failed
if [ $? -ne 0 ]; then
	echo -e "${Red}Failed to fetch data from $url${Color_Off}"
	kill $loader_pid
	exit 1
fi

# kill the loader process
kill $loader_pid

# while 'pup' could be an alternative to this, it isn't installed by default. therefore, we're using Unix tools like 'grep', 'sed', and 'awk'.
tier=$(echo "$curl_content" | grep -o '<div class="[^"]*tier[^"]*">[^<]*</div>' | sed -e 's/<[^>]*>//g')
lp=$(echo "$curl_content" | grep -o '<div class="[^"]*lp[^"]*">[^<]*' | sed -e 's/<[^>]*>//g' | head -n 1)
ratio=$(echo "$curl_content" | grep -oP '(?<=<div class="ratio">).*?(?=</div>)' | sed -e 's/<[^>]*>//g' | head -n 1 | tr -d '\n')
level=$(echo "$curl_content" | grep -oP '<span[^>]*>\s*\d+\s*</span>' | sed -e 's/<[^>]*>//g')
ranking=$(echo "$curl_content" | tr -d '\n' | grep -oP '<span class="ranking">\K[^<]*' | awk '{$1=$1};1')
# 'tr -d n' command is crucial here because the fetched data has a new line within this span tag, which cannot be detected by 'grep' and 'awk' for removing trailing spaces.

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
	declare -A rank_to_emoji
	rank_to_emoji=(
		["iron"]="🪓"
		["bronze"]="🥉"
		["silver"]="🥈"
		["gold"]="🥇"
		["platinum"]="💎"
		["diamond"]="💠"
		["master"]="🌟"
		["grandmaster"]="🏆"
		["challenger"]="👑"
	)

	rank_text=$(echo "${tier^}") # capitalize the first letter
	rank_emoji=${rank_to_emoji["$tier"]}

	if [ -z "$rank_emoji" ]; then # -z is for checking if its empty string
		rank_emoji="❓"
		rank_text="Unknown Rank"
	fi

	# rank info
	echo -e "${Blue}| 🆔 Summoner: https://www.op.gg/summoners/$region/$summoner_name ${Color_Off}"
	echo -e "${Green}| 🎮 Level: $level ${Color_Off}"
	echo -e "${Yellow}| $rank_emoji Tier: $rank_text ${Color_Off}"
	echo -e "${White}| 🎯 LP: $lp ${Color_Off}"
	echo -e "${Cyan}| 📊 Ratio: $ratio ${Color_Off}"
	echo -e "${Purple}| 🏅 Ranking: $ranking ${Color_Off}"
	echo -e "${Yellow}┝-----------------------------------------------┥${Color_Off}"
fi

# this script uses data from op.gg to provide League of Legends player info
