## LOLst.sh 

Welcome to the learning guide for LOLst! This document will help you understand how the script works, from basic concepts to detailed implementations. We'll break down each component of the script and explain how they work together.

### Table of Contents
- [Basic Concepts](#basic-concepts)
- [Script Structure](#script-structure)
- [Core Components](#core-components)
- [Unix Tools Deep Dive](#unix-tools-deep-dive)
- [Troubleshooting Guide](#troubleshooting-guide)
- [Additional Notes](#additional-notes)
- [Credits](#credits)

### Basic Concepts

#### What is LOLst? 
LOLst is a Bash script that fetches League of Legends player statistics from op.gg and displays them in your terminal. It's like having op.gg in your command line!

#### Key Features 
- 🚀 Fetches real-time player stats
- 🎨 Colorful terminal output
- ⏳ Loading animation
- ⚠️ Error handling
- 🌍 Region validation
- 🏅 Rank-based emoji display

### Script Structure

This section sets up the script’s environment, including color codes and the list of valid regions.

#### 1. Script Setup 
```bash
#!/bin/bash
# Colors and configuration
Color_Off='\033[0m'
Red='\033[0;31m'
Green='\033[0;32m'
# ... more colors

# Valid regions list
valid_regions=("na" "euw" "eune" "kr" "jp" ...)
```

#### 2. Main Functions 
The script is organized into several key functions:

```bash
# Function Overview
display_ascii_art()  # Shows the welcome screen
validate_inputs()    # Checks user input
loader()             # Shows loading animation
cleanup()            # Handles interruptions
fetch_data()         # Gets data from op.gg
extract_data()       # Processes the data
display_results()    # Shows the results
main()               # Orchestrates everything
```

### Core Components

#### 1. Input Validation
```bash
validate_inputs() {
    # Check if region is valid
    if [[ ! ${valid_regions[*]} =~ ${region} ]]; then
        echo -e "${Red}Error: Invalid region...${Color_Off}"
        exit 1
    fi

    # Check summoner name format
    if [[ ! $summoner_name =~ ^[a-zA-Z0-9-]+$ ]]; then
        echo -e "${Red}Error: Summoner name should only contain...${Color_Off}"
        exit 1
    fi
}
```
- Region is valid
- Summoner name uses correct characters
- Neither input is empty

#### 2. Data Fetching
```bash
fetch_data() {
    if ! curl_content=$(curl -s "$url"); then
        echo -e "${Red}Failed to fetch data from $url${Color_Off}"
        kill $loader_pid
        exit 1
    fi
    kill $loader_pid
}
```
- Uses `curl` to fetch webpage
- Silent mode (`-s`) suppresses progress and error messages
- Error handling for failed requests

#### 3. Data Extraction
```bash
extract_data() {
    # Extract tier information
    tier=$(echo "$curl_content" | grep -oP '(?<=<div class="tier">)[^<]+' | head -n 1)
    
    # Extract LP
    lp=$(echo "$curl_content" | grep -o '<div class="[^"]*lp[^"]*">[^<]*' | 
         sed -e 's/<[^>]*>//g' | head -n 1)
    
    # More extractions...
}
```
- Uses grep with regex to extract tier info.
- Extracts LP (League Points) using grep and sed.
- Cleans the output by removing html tags.

#### 4. Results Display
```bash
display_results() {
    # Rank emoji mapping
    case "$tier" in
        "iron") rank_emoji="🪓" ;;
        "bronze") rank_emoji="🥉" ;;
        # ... more ranks
    esac

    # Display formatted results
    echo -e "${Blue}| 🆔 Summoner: $summoner_name ${Color_Off}"
    echo -e "${Green}| 🎮 Level: $level ${Color_Off}"
    # ... more stats
}
```
- Displays the summoner name with formatting.
- Maps the tier to an emoji for visual representation.
- Outputs the additional stats like level, LP, and more.

#### 5. Loading Animation
```bash
loader() {
    chars="/-\|"
    while :; do
        for ((i = 0; i < ${#chars}; i++)); do
            sleep 0.1
            echo -en "${Yellow}⌛ Loading...${chars:$i:1}" "\r${Color_Off}"
        done
    done
}
```
- Creates a spinning animation for the loading state.
- Iterates through characters (/, -, \, |) to animate the loading indicator.
- Runs continuously until data fetching is completed.

#### 6. Signal Handling
```bash
cleanup() {
    echo -e "\n${Red}❌ Aborted.${Color_Off}"
    if kill -0 "$loader_pid" 2>/dev/null; then
        kill "$loader_pid"
    fi
    exit 1
}

# In main()
trap cleanup SIGINT
```
- Displays an error message when the script is aborted.
- Checks if the loader process is running, and kills it if necessary.
- Uses trap to catch SIGINT (Ctrl+C) and trigger the cleanup function.

### Unix Tools Deep Dive

#### curl
- **What it does**: Downloads web pages
- **How we use it**: `curl -s "https://www.op.gg/summoners/kr/HideOnBush-Kr1"`
- **Why it's useful**: Gets player data from op.gg

#### grep
- **What it does**: Finds patterns in text
- **How we use it**: `grep -oP '(?<=<div class="tier">)[^<]+'`
- **Why it's useful**: Extracts specific pieces of information

#### sed
- **What it does**: Modifies text streams
- **How we use it**: `sed -e 's/<[^>]*>//g'`
- **Why it's useful**: Cleans up HTML tags

#### awk
- **What it does**: Processes text
- **How we use it**: `awk '{$1=$1};1'`
- **Why it's useful**: Formats output nicely

#### tr
- **What it does**: Translates or deletes characters
- **How we use it**: `echo "$curl_content" | tr -d '\n'`
- **Why it's useful**: Transform characters to delete new line

#### head
- **What it does**: Displays the beginning of a file or stream
- **How we use it**: `echo "$curl_content" | head -n 1`
- **Why it's useful**: Limits output to the first line

### Troubleshooting Guide 

#### 1. Installation Issues 
```bash
# Problem: "lolst: command not found"
lolst: command not found

# Solution:
# Check if the script is installed:
which lolst  

# Expected output:
# /usr/local/bin/lolst

# If no output is shown, re-install the script:
sudo curl -sL "https://raw.githubusercontent.com/jemcv/lolst/main/lolst.sh" -o /usr/local/bin/lolst && sudo chmod +x /usr/local/bin/lolst
```

#### 2. Data Fetching Issues 
```bash
# Problem: No data found
No rank info found for 🆔 kr/HideOnBush

# Solutions:
# 1. Check connectivity with
ping www.op.gg

# 2. Check if op.gg is accessible in browser
# 3. Verify summoner name spelling
```

#### 3. Region Errors 
```bash
# Problem:
Error: Invalid region

# Solution:
# Use valid region from list:
lolst kr  HideOnBush-Kr1  # ✓ "kr" is a valid region
lolst xyz HideOnBush-Kr1 # x "xyz" is an invalid region
```

#### 4. Check dependencies
```bash
# Make sure all dependencies are installed:
which curl grep sed awk tr head

# If installed, you'll see something like:
/usr/bin/curl
/usr/bin/sed
/usr/bin/awk
/usr/bin/tr
/usr/bin/head

# These tools are typically pre-installed on most Linux systems.
```

#### Tips for Learning 

1. **Try These Modifications**:
   ```bash
   # Add a new color
   Purple='\033[0;35m'
   
   # Modify the loading animation
   chars="◐◓◑◒"
   ```

2. **Debug with echo**:
   ```bash
   # Add debug outputs
   echo "DEBUG: Fetching data from $url"
   echo "DEBUG: Raw tier data: $tier"
   ```

3. **Experiment with Data**:
   ```bash
   # Try different summoner names
   lolst kr T1Gumayusi-KR1
   lolst kr HideonBush-KR1
   ```

Remember: The best way to learn is by doing! Try modifying the script and see what happens.

### Additional Notes

- This script relies on op.gg's HTML structure. If op.gg changes their layout, the script may need updates.
- This script performs web scraping, so it is dependent on op.gg's availability and rate limiting.

### Credits

- Data sourced from op.gg
- League of Legends is a registered trademark of Riot Games, Inc.
- This script is not affiliated with Riot Games or op.gg. It is a tool created for educational purposes.

You can find this script on [jemcv/lolst](https://github.com/jemcv/lolst).