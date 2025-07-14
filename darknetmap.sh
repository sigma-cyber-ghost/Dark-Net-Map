#!/bin/bash

# ANSI Color Codes
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global Variables
SCAN_TARGET=""
SIMULATE_MODE=false
EVASION_MODE=false
REPORT_MODE=false
OUTPUT_DIR="darknet_data"
SCAN_COMPLETED=false
DEEP_SCAN=false
DECOY_COUNT=5
SCAN_DELAY="5ms"
DATA_LENGTH=24
MAX_PARALLEL=512
USE_MASSCAN=false
USE_FPING=false

# Elite ASCII Banner
banner() {
    echo -e "${CYAN}"
    cat << "EOF"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⢀⠀⠀⡀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠐⠀⠀⠂⠁⠀⠈⢀⠀⠁⠠⠀⠀⠄⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠠⠐⠀⠁⠀⠀⠀⠂⠀⠁⠀⠀⠈⢀⠀⠄⢈⠀⠄⡁⠠⠈⠀⠄⠁⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⡀⠂⠄⡈⠄⠠⠁⠄⡁⠂⠄⡁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠐⠀⠐⠈⢀⠁⠂⠄⠡⠐⠠⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠄⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠈⠠⠁⠂⠌⠡⠌⢠⠁⠆⠁⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠁⠠⠈⢀⠀⠀⠀⠀⠀⠀⢀⢀⠠⣀⠰⣠⠰⣄⣶⣤⣄⠀⠀⠐⠠⠁⠌⠒⡈⠡⠌⠠⠈⡄⠁⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠐⢀⠐⠀⠀⠀⠀⣠⠖⢑⠮⣬⣳⣭⢷⣽⣷⣮⡑⢭⡻⣷⣄⠀⠀⡁⢊⠡⡐⠡⢈⠄⠡⠐⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⠀⠂⠄⠂⠀⠀⠀⣾⠏⣰⠧⢿⣿⣿⣿⣶⣌⢻⣿⣟⡳⣽⣦⣻⡄⠀⠐⡈⢆⠡⡑⠂⠌⠠⠁⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠂⡁⠐⡀⠀⠀⣼⠏⡼⠡⢠⣿⣿⣿⣿⣿⣿⣆⢿⣿⣷⣌⠻⣿⣷⠀⠀⠌⠂⢅⠢⢁⠌⠠⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢂⠁⡐⠀⡀⠀⢠⠋⢰⠇⢠⣿⢾⣿⣿⣿⣿⣿⣿⡜⣿⣿⣿⣇⢹⡘⠆⠀⠀⢁⠢⢘⠠⢈⠐⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢂⠐⠠⠐⠀⢀⣿⠀⣾⢀⣿⣷⢸⡏⣿⣿⣿⣿⣿⣿⣼⣿⣿⣿⡆⢧⠀⠀⠀⠀⠠⢁⠊⠄⡈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⠄⡈⠐⠀⠀⣸⣻⣆⠹⡌⢻⣿⢸⣗⣾⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⣈⡁⠀⠀⠃⠀⠀⠀⠁⠀⠀⢀⣀⡀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢈⠐⠠⠁⠀⢀⣿⣿⣿⣇⣷⠀⡉⠓⠛⠋⠉⠋⠩⠝⢻⢛⠁⠀⠀⠀⠀⣀⢠⡄⠀⠀⠀⠀⠀⠀⢠⣾⣿⠇⠀⢘⠩⣤⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢈⠐⡀⠂⠀⢸⣿⣿⣿⣿⣿⡄⢧⡐⠂⠀⠀⠀⠀⠀⣸⣾⣄⡀⣀⣠⣴⣿⢸⣷⠀⠀⠀⠀⠀⠀⠸⡿⠏⢀⢤⡚⠀⣿⡾⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⠂⡐⠀⠀⣿⣿⣿⣿⣿⣿⣷⡐⢥⣿⣶⣶⣴⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⡌⣿⣿⡀⠂⢴⣶⡄⠀⠀⢰⣷⡿⠃⣸⠹⠉⣿⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⠄⠀⢸⣿⣿⣿⣿⣿⣿⣽⣧⠸⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣻⣿⣿⣄⠂⠁⠼⣥⢰⣻⡿⢁⣴⣿⠃⣴⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⠐⠀⠀⣿⣿⣿⢿⣿⣿⣿⣿⣿⡇⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠸⣿⣿⣿⣆⠐⡦⠀⣀⠋⠁⠘⠛⢃⣼⠟⡡⠔⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⢸⣿⣿⣿⣼⣿⣿⣿⣿⣿⣦⠁⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⢹⣿⣿⣿⣧⡘⣎⠻⣯⡽⠖⣀⡉⠡⠞⠀⡠⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢼⣿⣿⢋⣿⣿⣿⣿⣿⣿⡿⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠸⣿⣿⣿⣿⣧⡌⢷⣾⣿⣾⡟⠧⣄⠐⢫⢟⡶⣡⠂⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⡿⣼⣿⣿⣿⣿⣿⣿⡇⠍⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⢻⣿⣿⣿⣿⣏⡄⢿⣿⣿⢳⠈⣏⠀⠀⢫⠖⣇⠲⠀⠀⢆⠀⡀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⣿⣿⢣⣿⣿⣿⣿⣿⣿⣿⡇⡂⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠘⣿⣿⣿⣿⣿⣿⡘⣿⠇⣾⠰⠋⢰⣰⠀⡻⣜⢣⡑⡀⢘⢣⡙⢲⣤
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⡟⣼⣿⣿⣿⣿⣿⣿⣿⡇⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠘⢿⣿⣿⣿⣿⣧⠉⣴⠟⠀⣰⣿⡎⠀⠀⡝⢦⠓⡄⠀⣆⣿⣎⢮
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣞⣿⠁⣿⣿⣿⣿⣿⣿⣿⣿⡇⠰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⡘⣿⣿⣿⣿⣿⡇⠁⣰⠀⣿⣿⣧⠁⠀⠐⢪⠱⢨⠄⣿⣾⣿⣦
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣾⡟⢸⣿⣿⣿⣿⣿⣿⣿⣿⡟⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡧⢸⣿⣿⣿⡏⡰⢰⡏⣀⣿⣿⣿⡀⠀⠀⠂⠍⣆⠀⣿⣿⢾⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣿⠃⣾⣿⣿⣿⣿⣿⣿⣿⣿⣷⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣛⢿⣿⣿⣿⡟⣱⠄⣿⣿⡟⢰⢃⣟⢀⣿⣿⣿⣿⣧⠰⡀⠈⠐⠄⠂⣿⣿⣿⣻
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡟⢸⡽⢸⣿⢿⣯⢿⣿⣿⣿⣿⢠⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡻⣿⣶⣝⢿⣿⣐⠓⠾⣿⣾⢁⡟⣼⠇⣼⣿⣿⣿⢻⠇⡴⣃⠀⠀⠌⡀⢿⣿⣟⣷
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢼⡡⡏⠃⣯⢿⣏⢿⣿⣿⣿⣿⠇⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡙⣿⣿⣷⡿⣿⣿⣶⣤⡁⡞⢡⢋⣼⣿⢻⣛⡿⡘⠆⢐⡐⠀⠀⠀⠀⣿⣻⣽⣞
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣮⢱⠁⢸⢹⣮⡟⣾⣿⣿⠛⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡌⣿⣿⣿⣮⢻⣿⣿⢰⠃⢢⣾⣿⡟⢸⠁⠃⡌⠀⠀⡌⠀⠀⠀⠀⡞⢳⣿⡜
⠀⠀⠀⠀⠀⠀⠀⠀⠐⡎⠁⢠⢏⡞⣳⠲⣯⠟⠂⣠⡴⠖⢸⣿⣿⣿⣿⣿⣿⣿⣦⣉⡻⢿⣿⣿⣿⣌⢻⣿⣿⣶⠍⣁⣾⢁⣾⣿⣿⣿⢸⠀⠰⠀⠀⠀⠀⠀⠀⠀⠀⢜⡯⢶⡹
⠀⠀⠀⠀⠀⠀⠀⠀⢂⠑⠀⢃⡈⠘⠡⠟⠊⣠⠚⡕⠁⢀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡙⣿⣿⡻⣇⠹⣿⡏⣼⣷⡏⢸⣿⣿⣿⣿⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣜⢣⡝
⠀⠀⠀⠀⠀⠀⠀⠀⠠⡀⢤⢠⣈⡐⠢⢐⠢⢤⣈⣀⡙⠐⠀⣿⡿⢿⣿⣿⣿⠏⣽⣟⣯⣭⣕⡘⢿⣷⣻⣧⠹⡇⣿⣿⣷⠸⣿⣿⣿⣿⢈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⡌⢖⡸
⠀⠀⠀⠀⠀⠀⠀⠌⠴⡐⢎⠲⡰⢍⡳⢆⣀⠂⠐⡜⠴⠋⠀⡿⣝⢯⡏⡷⠀⢊⣩⣤⣤⡀⠮⠹⣌⠻⣟⠾⡧⠐⣿⣿⣿⠀⣿⣿⣿⣟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⡉⠦⡑
⠀⠀⠀⠀⠀⠀⢂⠈⡀⠁⠈⠥⠙⠦⠜⡬⠦⣍⢆⠀⠀⡀⠀⠼⠙⠞⠃⠴⠾⠿⢸⣾⣿⣿⣶⣤⡉⠙⠠⠶⣴⣃⢸⣿⣿⠀⣿⣿⣿⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⡡⢂⠥
⠀⠀⠀⠀⠀⠀⡀⠄⠐⢀⠠⠀⠀⠀⠈⠦⠱⡌⢎⡹⣂⠄⠈⢉⠻⣞⣻⠷⣶⣦⣸⣿⣳⡿⣿⣽⣟⣿⡶⣄⣀⡈⠸⣿⣿⠄⠘⣿⣿⠁⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠁⡌⠐
======================================================================
-------------------------SIGMA-CYBER-GHOST----------------------------
======================================================================
EOF
    echo -e "${NC}"
    echo -e "${GREEN}⠀⠀⠀⠀⠄⠁⠀⠐⠈⠀⠀⠠⢈⠐⠀⠀⠁⠂⠆⠐⠉⠊⠅⠀⠁⠼⠸⢻⢹⡖⣯⠾⣵⡻⡽⣯⡽⢾⡽⣻⢭⠷⠆⣿⢏⠆⢘⣹⣿⢰⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠡⢀⠡${NC}"
    echo -e "${RED}================================================================================${NC}"
    echo -e "${PURPLE}DarkNetMap v1.0 - Ultra-Fast Network Reconnaissance Engine${NC}"
    echo -e "${YELLOW}GitHub: https://github.com/sigma-cyber-ghost"
    echo -e "Telegram: https://web.telegram.org/k/#@Sigma_Cyber_Ghost${NC}"
    echo -e "${RED}================================================================================${NC}"
}

# Usage Information
usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  ./darknetmap.sh [OPTIONS]"
    echo
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  --scan <IP/CIDR>    : Scan target (e.g., 191.125.185.128 or 192.168.1.0/24)"
    echo -e "  --simulate          : Dry-run mode with mock data"
    echo -e "  --evasion           : Enable elite evasion techniques"
    echo -e "  --report            : Generate visual network map"
    echo -e "  --deep              : Perform deep scan (OS/version detection)"
    echo -e "  --decoy <NUM>       : Set number of decoy IPs (default: 5)"
    echo -e "  --delay <TIME>      : Set scan delay (e.g., 5ms, 1s)"
    echo -e "  --datalen <BYTES>   : Set packet data length (default: 24)"
    echo -e "  --parallel <NUM>    : Set max parallel processes (default: 512)"
    echo -e "  --masscan           : Use Masscan for ultra-fast port scanning"
    echo -e "  --fping             : Use fping for host discovery"
    echo -e "  -h, --help          : Show this help"
    echo
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  ./darknetmap.sh --scan 191.125.185.128 --masscan"
    echo -e "  ./darknetmap.sh --scan 10.0.0.0/8 --evasion --deep --fping"
    echo -e "  ./darknetmap.sh --scan 192.168.1.1 --report --decoy 10 --delay 1ms --parallel 1024"
    echo
}

# Elite Spinner Animation (optimized)
show_spinner() {
    local pid=$1
    local msg=$2
    local delay=0.1
    local spin_chars=("${RED}◐${NC}" "${GREEN}◓${NC}" "${YELLOW}◑${NC}" "${CYAN}◒${NC}")
    local index=0
    while ps -p $pid > /dev/null; do
        echo -ne "\r[${spin_chars[index]}] ${msg}..."
        index=$(( (index+1) % 4 ))
        sleep $delay
    done
    echo -ne "\r\033[K"
}

# Validate IP/CIDR format
validate_target() {
    local target=$1
    if [[ ! $target =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$ ]]; then
        echo -e "${RED}[-] Invalid target format: $target${NC}"
        return 1
    fi
    return 0
}

# Generate random IPs for decoy
generate_decoy_ips() {
    local count=$1
    local decoys=""
    for ((i=0; i<count; i++)); do
        decoys+="$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1),"
    done
    echo "${decoys%,}"
}

# Fast host discovery using fping
fast_host_discovery() {
    echo -e "${GREEN}[+] Performing Ultra-Fast Host Discovery...${NC}"
    fping -a -g $SCAN_TARGET 2>/dev/null > $OUTPUT_DIR/live_hosts.txt
    local host_count=$(wc -l < $OUTPUT_DIR/live_hosts.txt)
    echo -e "${CYAN}[*] Found $host_count live hosts${NC}"
}

# Ultra-Fast Port Scanning with Masscan
masscan_scan() {
    echo -e "${GREEN}[+] Starting Masscan Port Sweep...${NC}"
    local rate=$(( MAX_PARALLEL * 100 ))
    masscan $SCAN_TARGET -p1-65535 --rate=$rate --wait=0 > $OUTPUT_DIR/masscan.txt 2>&1
    
    # Process Masscan results
    awk '/Discovered open port/{print $6,$4}' $OUTPUT_DIR/masscan.txt | \
        awk -F/ '{print $1,$2}' > $OUTPUT_DIR/open_ports.txt
    
    echo -e "${CYAN}[*] Masscan completed. Found $(wc -l < $OUTPUT_DIR/open_ports.txt) open ports${NC}"
}

# Network Scanner - Optimized for speed and stealth
scan_network() {
    echo -e "${GREEN}[+] Initializing Network Scan...${NC}"
    
    if $SIMULATE_MODE; then
        echo -e "${YELLOW}[!] SIMULATION MODE ACTIVATED${NC}"
        generate_mock_data
        SCAN_COMPLETED=true
        return
    fi
    
    mkdir -p $OUTPUT_DIR
    local nmap_cmd="nmap -T5 --max-rtt-timeout 100ms --min-parallelism $MAX_PARALLEL"
    
    # Use fping for host discovery if enabled
    if $USE_FPING; then
        fast_host_discovery
        nmap_cmd+=" -iL $OUTPUT_DIR/live_hosts.txt"
    else
        nmap_cmd+=" $SCAN_TARGET"
    fi
    
    # Add deep scan options
    if $DEEP_SCAN; then
        echo -e "${PURPLE}[+] DEEP SCAN ACTIVATED (OS/Service Detection)${NC}"
        nmap_cmd+=" -sV -O --version-intensity 1"
    else
        nmap_cmd+=" -sS"
    fi
    
    if $EVASION_MODE; then
        echo -e "${CYAN}[+] ENABLING ELITE EVASION TECHNIQUES${NC}"
        local decoys=$(generate_decoy_ips $DECOY_COUNT)
        nmap_cmd+=" -f --data-length $DATA_LENGTH --scan-delay $SCAN_DELAY --max-retries 1 -D $decoys --spoof-mac 0"
        echo -e "${ORANGE}[+] Using $DECOY_COUNT decoy IPs: ${decoys//,/, }${NC}"
    fi
    
    echo -e "${CYAN}[*] Command: ${nmap_cmd//--min-parallelism $MAX_PARALLEL /}${NC}"
    
    # Start scan
    ($nmap_cmd > $OUTPUT_DIR/raw_scan.txt 2>&1) &
    local nmap_pid=$!
    
    # Display spinner while scan runs
    show_spinner $nmap_pid "Scanning"
    
    wait $nmap_pid
    local exit_status=$?
    
    if [ $exit_status -ne 0 ]; then
        echo -e "${RED}[-] Scan failed! Check ${OUTPUT_DIR}/raw_scan.txt for details${NC}"
        return 1
    fi
    
    process_results
    SCAN_COMPLETED=true
}

# Process Scan Results
process_results() {
    echo -e "${GREEN}[+] Processing Results...${NC}"
    
    # Extract live hosts
    grep "Nmap scan report" $OUTPUT_DIR/raw_scan.txt | awk '{print $5}' > $OUTPUT_DIR/live_hosts.txt
    
    # Extract open ports with service info
    awk '
    /Nmap scan report/ {host=$5}
    /open/ {
        port=$1
        sub("/tcp", "", port)
        sub("/udp", "", port)
        service=$3
        for(i=4;i<=NF;i++) service=service" "$i
        print host":"port":"service
    }
    ' $OUTPUT_DIR/raw_scan.txt > $OUTPUT_DIR/open_ports.txt
    
    # Extract OS detection info
    grep "Running: " $OUTPUT_DIR/raw_scan.txt | awk -F': ' '{print $2}' | sort | uniq > $OUTPUT_DIR/os_info.txt
    
    # Create summary
    echo -e "${RED}=== Network Scan Summary ===${NC}" > $OUTPUT_DIR/results.txt
    echo -e "Scanned Target: $SCAN_TARGET" >> $OUTPUT_DIR/results.txt
    echo -e "Scan Mode: $($EVASION_MODE && echo "Stealth" || echo "Aggressive")" >> $OUTPUT_DIR/results.txt
    echo -e "Scan Depth: $($DEEP_SCAN && echo "Deep" || echo "Quick")" >> $OUTPUT_DIR/results.txt
    echo -e "Live Hosts: $(wc -l < $OUTPUT_DIR/live_hosts.txt)" >> $OUTPUT_DIR/results.txt
    echo -e "Open Ports: $(wc -l < $OUTPUT_DIR/open_ports.txt)" >> $OUTPUT_DIR/results.txt
    
    echo -e "\n${RED}=== Detected OS Information ===${NC}" >> $OUTPUT_DIR/results.txt
    cat $OUTPUT_DIR/os_info.txt >> $OUTPUT_DIR/results.txt
    
    echo -e "\n${RED}=== Live Hosts ===${NC}" >> $OUTPUT_DIR/results.txt
    cat $OUTPUT_DIR/live_hosts.txt >> $OUTPUT_DIR/results.txt
    
    echo -e "\n${RED}=== Open Ports & Services ===${NC}" >> $OUTPUT_DIR/results.txt
    while IFS=: read -r host port service; do
        printf "%-18s %-10s %s\n" "$host" "$port" "$service" >> $OUTPUT_DIR/results.txt
    done < <(awk -F: '{print $1,$2,$3}' $OUTPUT_DIR/open_ports.txt)
    
    echo -e "${YELLOW}[*] Scan summary saved to $OUTPUT_DIR/results.txt${NC}"
}

# Generate Mock Data
generate_mock_data() {
    mkdir -p $OUTPUT_DIR
    
    # Generate multiple hosts for realism
    local base_ip=${SCAN_TARGET%%/*}
    local subnet=${base_ip%.*}
    
    cat << EOF > $OUTPUT_DIR/live_hosts.txt
$subnet.1
$subnet.15
$subnet.42
$subnet.101
$subnet.178
EOF

    cat << EOF > $OUTPUT_DIR/open_ports.txt
$subnet.1:22:SSH
$subnet.1:80:HTTP
$subnet.1:443:HTTPS
$subnet.15:22:SSH
$subnet.15:3389:ms-wbt-server
$subnet.42:21:FTP
$subnet.42:445:SMB
$subnet.101:53:DNS
$subnet.101:8080:HTTP-Proxy
$subnet.178:22:SSH
$subnet.178:5900:VNC
EOF

    cat << EOF > $OUTPUT_DIR/os_info.txt
Linux 3.2 - 4.9
Windows 10
Windows Server 2016
FreeBSD 11.0-RELEASE
EOF

    cat << EOF > $OUTPUT_DIR/results.txt
=== Network Scan Summary ===
Scanned Target: $SCAN_TARGET
Scan Mode: Simulation
Scan Depth: $($DEEP_SCAN && echo "Deep" || echo "Quick")
Live Hosts: 5
Open Ports: 10

=== Detected OS Information ===
Linux 3.2 - 4.9
Windows 10
Windows Server 2016
FreeBSD 11.0-RELEASE

=== Live Hosts ===
$subnet.1
$subnet.15
$subnet.42
$subnet.101
$subnet.178

=== Open Ports & Services ===
$subnet.1            22         SSH
$subnet.1            80         HTTP
$subnet.1            443        HTTPS
$subnet.15           22         SSH
$subnet.15           3389       ms-wbt-server
$subnet.42           21         FTP
$subnet.42           445        SMB
$subnet.101          53         DNS
$subnet.101          8080       HTTP-Proxy
$subnet.178          22         SSH
$subnet.178          5900       VNC
EOF

    echo -e "${YELLOW}[*] Mock data generated in $OUTPUT_DIR${NC}"
}

# Generate Network Map - Optimized Visualization
generate_report() {
    echo -e "${GREEN}[+] Generating Network Map...${NC}"
    
    if [[ ! -f $OUTPUT_DIR/results.txt ]]; then
        echo -e "${RED}[-] No scan data found! Run scan first.${NC}"
        exit 1
    fi
    
    # Create DOT file
    cat << EOF > $OUTPUT_DIR/map.dot
digraph network_map {
    graph [bgcolor="black" fontcolor="cyan" fontsize=18 label="Sigma-Ghost-Hacking: $SCAN_TARGET" labelloc="t"];
    node [style=filled fillcolor="#111122" shape=box fontcolor="white" color="#00ff00" fontname="Courier"];
    edge [color="#33ff33" penwidth=1.5];
    rankdir=LR;
    
    // Main Target
    "$SCAN_TARGET" [label="<<B>$SCAN_TARGET</B>>" shape=hexagon color="#ff6600"];
    
    // Legend
    subgraph cluster_legend {
        label="Legend";
        bgcolor="#0d1117";
        fontcolor="white";
        margin=20;
        
        "Target" [fillcolor="#111122" shape=hexagon];
        "Open Ports" [fillcolor="#222244" shape=ellipse];
        "Target" -> "Open Ports" [style=dashed];
    }
EOF

    # Add hosts and their services
    while read -r host; do
        [[ -z $host ]] && continue
        
        # Get services for this host
        local services=$(grep "^$host:" $OUTPUT_DIR/open_ports.txt | \
            awk -F: '{printf "%s\\l", $2 " (" $3 ")"}')
        
        echo "    \"$host\" [label=\"<<B>$host</B>>\\l$services\" shape=hexagon];" >> $OUTPUT_DIR/map.dot
        echo "    \"$SCAN_TARGET\" -> \"$host\" [dir=none];" >> $OUTPUT_DIR/map.dot
    done < $OUTPUT_DIR/live_hosts.txt

    echo "}" >> $OUTPUT_DIR/map.dot
    
    # Generate PNG
    if command -v dot &>/dev/null; then
        dot -Tpng $OUTPUT_DIR/map.dot -o $OUTPUT_DIR/map.png
        echo -e "${YELLOW}[*] Network map generated: $OUTPUT_DIR/map.png${NC}"
        
        # Display ASCII preview
        if command -v img2txt &>/dev/null; then
            echo -e "\n${CYAN}==== MAP PREVIEW ====${NC}"
            img2txt -f utf8 $OUTPUT_DIR/map.png
        else
            echo -e "${YELLOW}[!] Install libcaca-utils for ASCII preview (sudo apt install caca-utils libcaca0)${NC}"
        fi
    else
        echo -e "${RED}[-] Graphviz not installed! Install with 'sudo apt install graphviz'${NC}"
    fi
}

# Argument Parsing
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --scan) 
            SCAN_TARGET="$2"
            if ! validate_target "$SCAN_TARGET"; then
                exit 1
            fi
            shift 
            ;;
        --simulate) SIMULATE_MODE=true ;;
        --evasion) EVASION_MODE=true ;;
        --report) REPORT_MODE=true ;;
        --deep) DEEP_SCAN=true ;;
        --decoy) 
            DECOY_COUNT="$2"
            if ! [[ $DECOY_COUNT =~ ^[0-9]+$ ]]; then
                echo -e "${RED}[-] Invalid decoy count: $DECOY_COUNT${NC}"
                exit 1
            fi
            shift 
            ;;
        --delay) 
            SCAN_DELAY="$2"
            if ! [[ $SCAN_DELAY =~ ^[0-9]+(ms|s)$ ]]; then
                echo -e "${RED}[-] Invalid delay format: $SCAN_DELAY. Use e.g., 5ms or 1s${NC}"
                exit 1
            fi
            shift 
            ;;
        --datalen) 
            DATA_LENGTH="$2"
            if ! [[ $DATA_LENGTH =~ ^[0-9]+$ ]]; then
                echo -e "${RED}[-] Invalid data length: $DATA_LENGTH${NC}"
                exit 1
            fi
            shift 
            ;;
        --parallel)
            MAX_PARALLEL="$2"
            if ! [[ $MAX_PARALLEL =~ ^[0-9]+$ ]]; then
                echo -e "${RED}[-] Invalid parallel count: $MAX_PARALLEL${NC}"
                exit 1
            fi
            shift
            ;;
        --masscan) USE_MASSCAN=true ;;
        --fping) USE_FPING=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo -e "${RED}[-] Unknown parameter: $1${NC}"; usage; exit 1 ;;
    esac
    shift
done

# Main Execution
clear
banner

if [[ -n "$SCAN_TARGET" ]]; then
    # Add /32 if single IP provided without subnet
    if [[ $SCAN_TARGET =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        SCAN_TARGET="$SCAN_TARGET/32"
    fi
    
    # Use Masscan if requested
    if $USE_MASSCAN; then
        masscan_scan
        SCAN_COMPLETED=true
    else
        scan_network
    fi
fi

if $REPORT_MODE; then
    if $SCAN_COMPLETED || [[ -f $OUTPUT_DIR/results.txt ]]; then
        generate_report
    else
        echo -e "${RED}[-] Scan not completed! Run scan first.${NC}"
        exit 1
    fi
fi

if [[ -z "$SCAN_TARGET" && $REPORT_MODE == false ]]; then
    usage
fi

echo -e "${GREEN}[+] Operation completed.${NC}"
