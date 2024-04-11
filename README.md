### LOLst.sh 

LOLst.sh is a bash script that displays League of Legends player stats in your terminal.

[![asciicast](https://asciinema.org/a/WU4zCihoz1QEljc2yoCFY9OuQ.svg)](https://asciinema.org/a/WU4zCihoz1QEljc2yoCFY9OuQ)

### Requirements

You need to have `curl` installed on your system to use this script.

### Installation 
    sudo curl -sL "https://raw.githubusercontent.com/jemcv/lolst/main/lolst.sh" -o /usr/local/bin/lolst.sh && sudo chmod +x /usr/local/bin/lolst.sh

### Usage
    lolst.sh <region> <summonername-id>

### Example
    lolst.sh kr HideOnBush-Kr1

### Output
    ┝-----------------------------------------------┥
    | 📈 LOLst.sh - League of Legends Stats
    | 
    | [ Playing ]      |\__/,|   (\`
    | [ League ]     _.|o o  |_   ) ) 
    | [ >_< ]--   -(((---(((--------
    |
    | 🔎 Result for HideOnBush-Kr1: 
    | 🆔 Summoner: https://www.op.gg/summoners/kr/HideOnBush-Kr1 
    | 🎮 Level: 745 
    | 🏆 Tier: Grandmaster 
    | 🎯 LP: 573 
    | 📊 Ratio: Win Rate 60% 
    | 🏅 Ranking: 514 
    ┝-----------------------------------------------┥

### License
This script is licensed under the MIT license.
