# -----------Dark-Net-Map------------
# Elite Network Reconnaissance Tool


🛠️ Features
✅ Parallel scanning (Masscan/Nmap)

✅ Stealth modes (Decoys, fragmentation)

✅ OS/Service detection

✅ Network visualization (PNG/ASCII)

# DarkNetMap 🔍👻
**Elite Network Reconnaissance Tool** by *Sigma Ghost*  

---
### 🚀 **Installation**  

git clone https://github.com/sigma-cyber-ghost/Dark-Net-Map.git  
cd Dark-Net-Map  
pip3 install -r requirements.txt

# Linux (Debian/Ubuntu)
sudo apt update
sudo apt install -y masscan fping graphviz libcaca-dev
sudo apt install caca-utils libcaca0

# macOS
brew install masscan fping graphviz libcaca

chmod +x darknetmap.sh  

# Basic scan  
./darknetmap.sh --scan <IP>  

# Deep scan + evasion  
./darknetmap.sh --scan 10.0.0.0/24 --deep --evasion  

# Ultra-fast Masscan  
./darknetmap.sh --scan <IP> --masscan --parallel 1024  

# Generate report  
./darknetmap.sh --scan <IP> --report  

### 🎯 **Scanning Example IP (91.185.185.178)**  
# These sample commands are for users with limited networking knowledge, allowing them to use the tool effectively without deep technical expertise.
# Quick scan  
./darknetmap.sh --scan 91.185.185.178  

# Deep scan (OS/services)  
./darknetmap.sh --scan 91.185.185.178 --deep  

# Stealth scan (decoy IPs + fragmentation)  
./darknetmap.sh --scan 91.185.185.178 --evasion --delay 2ms  

# Masscan (all ports, ultra-fast)  
./darknetmap.sh --scan 91.185.185.178 --masscan  

# Full recon (deep + stealth + report)  
./darknetmap.sh --scan 91.185.185.178 --deep --evasion --report  

⚠️ WARNING: DarkNetMap is a network reconnaissance utility created strictly for:

  ✔️ Authorized security assessments
  ✔️ Educational demonstration within controlled environments
  ✔️ Research on infrastructure you fully own or have explicit permission to test

❌ Unauthorized or illegal use of this tool may violate international, federal, or local laws.

🛑 The creator of DarkNetMap assumes **zero responsibility** for misuse, damage, or legal consequences resulting from its deployment.

💀 You—**the operator**—bear full responsibility for how and where this tool is used.

## 🌐 Connect With Us
[![Telegram](https://img.shields.io/badge/Telegram-Sigma_Ghost-blue?logo=telegram)](https://t.me/Sigma_Cyber_Ghost)
[![YouTube](https://img.shields.io/badge/YouTube-Sigma_Ghost-red?logo=youtube)](https://www.youtube.com/@sigma_ghost_hacking)
[![Instagram](https://img.shields.io/badge/Instagram-Safder_Khan-purple?logo=instagram)](https://www.instagram.com/safderkhan0800_/)
