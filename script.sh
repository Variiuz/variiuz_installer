#!/bin/bash
# Script github.com/variiuz
# Version v1.4
# Author Variiuz
if [ -z "$BASH_VERSION" ]
then
    exec bash "$0" "$@"
fi
CMD="${0//.\/}"
VERSION="v1.4"
WORKDIR="$(pwd)"
function check_updates {
echo "Checking for Update..."
	checked=$(curl -s https://cdn.alex-is-a.ninja/share/version_inst)
	if [ $checked != $VERSION ]
	then
		read -p 'New Version available! Download now? y/n ' answer
		if [ $answer != "y" ]
		then
			show_menu "!!! Update available! Newer Version: $checked !!!"
		else
			echo "Updating from $VERSION to ${checked}..."
			curl -s -o ./$CMD "https://cdn.alex-is-a.ninja/share/variiuz_installer.sh"
			exit 0
		fi
	fi
	show_menu $1
}
function check_changelog {
	echo "Checking for Changelog..."
	checked=$(curl -s https://cdn.alex-is-a.ninja/share/changelog)
	IFS=';' read -r -a array <<< "$checked"
	for element in "${array[@]}"
	do
		echo "$element"
	done
	read -n 1 -s -r -p "Press any key to get back to the Mainmenu or use CTRL^C to quit"
	clear
	show_menu
}

if [[ $EUID -ne 0 ]]
then
	echo "This script must be run as root" 1>&2
	exit 1
fi
mkdir -p /tmp/vrs/
mkdir -p /root/.variiuzinst/
TSURL="https://files.teamspeak-services.com/releases/server/3.12.1/teamspeak3-server_linux_amd64-3.12.1.tar.bz2"
#Console Helpers
function show_mc {
	clear
	echo "========================"
	echo "Install Minecraft Server"
	echo "========================"
	echo "Please note that currently only one server per version is possible."
	echo ""
}
function show_mci {
	clear
	echo "=============================="
	echo "Installing Minecraft Server..."
	echo "=============================="
	echo "This may take some minutes..."
	echo ""
}
function show_tsi {
	clear
	echo "=============================="
	echo "Installing Teamspeak Server..."
	echo "=============================="
	echo "This may take some minutes..."
	echo ""
}
function show_ufpr {
	clear
	echo "==================="
	echo "Install Programs..."
	echo "==================="
	echo ""
}
function show_ufprm {
	clear
	echo "=========================="
	echo "Installing $1"
	echo "=========================="
	echo "This may take some time..."
	echo ""
}
#Logger
function log {
	local CURRENTDATE=`date +"%Y-%m-%d %T"`
	echo "[${CURRENTDATE}][LOG] $1"
	echo "[${CURRENTDATE}][LOG] $1" >> installer.log
}
function loglvl {
	local CURRENTDATE=`date +"%Y-%m-%d %T"`
	echo "[${CURRENTDATE}][$1] $2"
	echo "[${CURRENTDATE}][$1] $2" >> installer.log
}
#Installer Functions
function update_root {
	sh -c 'apt-get update; apt-get upgrade -y; apt-get dist-upgrade -y; apt-get autoremove -y; apt-get autoclean -y'
	echo "DONE! To make sure it really works, please run this script as sudo." 
	read -n 1 -s -r -p "Press any key to get back to the Mainmenu or use CTRL^C to quit"
	clear
	show_menu
}
function install_progs {
	show_ufpr
	echo "Please select which Program or bundle you want to install."
	echo "=========================================================="
	echo "1) Install LAMP"
	echo "2) Bundle (nano, htop, neofetch, curl, screen, figlet, fail2ban)"
	echo "3) Install Docker"
	echo "4) Install Nextcloud"
	echo "5) Install Java 8 (Minecraft)"
	echo "6) Install Java 11"
	echo "b) Back to Mainmenu"
	echo "=========================================================="
	echo $1
	read -p '> ' selector
	case $selector in
	1)
		show_ufprm "LAMP"
		inst_lamp_pre
		;;
	2)
		show_ufprm "Bundle"
		inst_bundle
		;;
	3)
		show_ufprm "Docker"
		install_docker
		;;
	4)
		clear
		install_progs "Sorry but Nextcloud is currently not available."
		;;
	5)
		show_ufprm "JRE 8"
		install_java 8
		;;
	6)
		show_ufprm "JRE 11"
		install_java 11
		;;
	b)
		clear
		show_menu
		;;
	*)
		clear
		install_progs "Not sure what you want but this option is not available."
		;;
	esac
}
function install_java {
	log "Installing JRE $1..."
	if [ -e /root/.variiuzinst/.JRE$1 ]
	then
		echo "JRE $1 has already been installed, please remove /root/.variiuzinst/.JRE${$1} for a reinstall"
		read -n 1 -s -r -p "Press any key to get back to the Installmenu or use CTRL^C to quit"
		clear
		install_progs
	fi
	log "Downloading JRE${1}..."
	apt install openjdk-$1-jre-headless -y
	touch /root/.variiuzinst/.JRE$1
	log "DONE! JRE $1 has been installed."
	read -n 1 -s -r -p "Press any key to get back to the Installmenu or use CTRL^C to quit"
	clear
	install_progs
}
function install_docker {
	log "Installing Docker..."
	if [ -e /root/.variiuzinst/.DOCKER ]
	then
		echo "DOCKER has already been installed, please remove /root/.variiuzinst/.DOCKER for a reinstall"
		read -n 1 -s -r -p "Press any key to get back to the Installmenu or use CTRL^C to quit"
		clear
		install_progs
	fi
	apt-get remove docker docker-engine docker.io containerd runc
	sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
	log "Please tell us which OS this server runs on. 'u' for Ubuntu OR 'd' for debian."
	read -p 'Please tell us which OS this server runs on (d/u): ' osd
	if [ $osd = 'd' ]
	then
		show_ufprm "Docker"
		log "Installing for Debian"
		curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
		apt-key fingerprint 0EBFCD88
		add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
		apt-get update
		apt-get install docker-ce docker-ce-cli containerd.io -y
		touch /root/.variiuzinst/.DOCKER
		log "DONE! Docker has been installed."
		read -n 1 -s -r -p "Press any key to get back to the Installmenu or use CTRL^C to quit"
		clear
		install_progs
	elif [ $osd = 'u' ]
	then
		show_ufprm "Docker"
		log "Installing for Ubuntu"
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
		apt-key fingerprint 0EBFCD88
		add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
		apt-get update
		apt-get install docker-ce docker-ce-cli containerd.io -y
		touch /root/.variiuzinst/.DOCKER
		log "DONE! Docker has been installed."
		read -n 1 -s -r -p "Press any key to get back to the Installmenu or use CTRL^C to quit"
		clear
		install_progs
	else
		log "That OS is not listed or supported."
	fi
	read -n 1 -s -r -p "Press any key to get back to the Installmenu or use CTRL^C to quit"
	clear
	install_progs
}
function install_ts {
	show_tsi
	if [ -e /root/.variiuzinst/.TS ]
	then
		echo "Teamspeak has already been installed, please remove /root/.variiuzinst/.TS for a reinstall"
		read -n 1 -s -r -p "Press any key to get back to the Mainmenu or use CTRL^C to quit"
		clear
		show_menu
	fi
	log "Downloading Teamspeak 3 Server..."
	curl -s -o /home/teamspeak/ts.tar.bz2 --create-dirs $TSURL
	log "Extracting Teamspeak 3 Server..."
	tar xfvj /home/teamspeak/ts.tar.bz2 -C /home/teamspeak
	log "Updating Directories and Files..."
	rm /home/teamspeak/ts.tar.bz2
	mv /home/teamspeak/teamspeak3-server_linux_amd64/* /home/teamspeak/
	rm -rf /home/teamspeak/teamspeak3-server_linux_amd64/
	log "Creating LICENSE file..."
	touch /home/teamspeak/.ts3server_license_accepted
	touch /root/.variiuzinst/.TS
	
	log "DONE! Please run the command 'sh /home/teamspeak/ts3server_startscript.sh start' for the Teamspeak Keys"
	log "It is not recommended to run it as root, you can give another user RWX rights to /home/teamspeak/*"
	read -n 1 -s -r -p "Press any key to get back to the Mainmenu or use CTRL^C to quit"
	show_menu
}
function inst_bundle {
	log "Installing Bundle..." 
	apt install -qq nano htop neofetch curl screen figlet fail2ban -y
	read -n 1 -s -r -p "Press any key to get back to the Installmenu or use CTRL^C to quit"
	clear
	install_progs
}
function inst_lamp {
	show_ufprm "LAMP for $1"
	log "Updating..."
	apt -qq update
	log "Installing Apache2..."
	apt install apache2 -y
	log "Installing PHP 7.4..."
	apt install php7.4 php7.4-cli php7.4-curl php7.4-gd php7.4-intl php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-xml php7.4-xsl php7.4-zip php7.4-bz2 libapache2-mod-php7.4 -y
	log "Installing MariaDB..."
	apt install mariadb-server mariadb-client -y
	touch /root/.variiuzinst/.LAMP
	
	log "DONE! Please run the command 'mysql_secure_installation' for the SQL installation."
	read -n 1 -s -r -p "Press any key to get back to the Mainmenu or use CTRL^C to quit"
	exit 0
	
#	mysql_secure_installation
}
function inst_lamp_pre {
	log "Installing (L)inux (A)apache2 (M)ySQL (P)HP..." 
	if [ -e /root/.variiuzinst/.LAMP ]
	then
		echo "LAMP has already been installed, please remove /root/.variiuzinst/.LAMP for a reinstall"
		read -n 1 -s -r -p "Press any key to get back to the Installmenu or use CTRL^C to quit"
		clear
		install_progs
	fi
	apt -qq upgrade -y
	apt -qq install ca-certificates apt-transport-https lsb-release gnupg curl nano unzip -y
	log "Please tell us which OS this server runs on. 'u' for Ubuntu OR 'd' for debian."
	read -p 'Please tell us which OS this server runs on (d/u): ' osd
	if [ $osd = 'd' ]
	then
		show_ufprm "LAMP"
		log "Installing for Debian"
		wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
		echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
		inst_lamp "Debian"
		
	elif [ $osd = 'u' ]
	then
		show_ufprm "LAMP"
		log "Installing for Ubuntu"
		apt install software-properties-common -y
		add-apt-repository ppa:ondrej/php
		inst_lamp "Ubuntu"
	else
		log "That OS is not listed or supported."
	fi
	read -n 1 -s -r -p "Press any key to get back to the Installmenu or use CTRL^C to quit"
	clear
	install_progs
}
function install_mc {
	show_mci
	log "Installing dependencies..."
	apt -qq install screen nano curl
	show_mci
	log "Trying to download server version $1..."
	URL="https://minecraft.main.mirror.deinserverhost.icu/Spigot/$1/server.jar"
	DIR=${1//./}
	if [ -d "/home/minecraftservers/$DIR" ]
	then
		loglvl "ERROR" "Directory exists, won't delete as important files could be in there."
		read -n 1 -s -r -p "Press any key to get back to the Mainmenu or use CTRL^C to quit"
		clear
		show_menu
	fi
	download=$(curl -sI $URL -w '%{content_type}' -o /tmp/vrs/$DIR/out --create-dirs )
	if [[ $download == *"application/java-archive"* ]] 
	then
		curl -s -o /home/minecraftservers/$DIR/minecraft_server.jar --create-dirs $URL
	else
		rm -r /tmp/vrs/$DIR/
		loglvl "ERROR" "Download failed, version not found: $v"
		read -n 1 -s -r -p "Press any key to get back to the Mainmenu or use CTRL^C to quit"
		clear
		show_menu
	fi
	log "Creating eula.txt..."
	
	echo "eula=true" > /home/minecraftservers/$DIR/eula.txt
	log "Creating Startfiles..."
	cat <<EOF >/home/minecraftservers/$DIR/server.properties
spawn-protection=0
generator-settings=
force-gamemode=true
allow-nether=false
gamemode=0
broadcast-console-to-ops=true
enable-query=false
player-idle-timeout=0
difficulty=1
spawn-monsters=false
op-permission-level=4
resource-pack-hash=
announce-player-achievements=false
pvp=true
snooper-enabled=true
level-type=DEFAULT
hardcore=false
enable-command-block=true
max-players=20
network-compression-threshold=256
max-world-size=29999984
server-port=25565
debug=false
server-ip=
spawn-npcs=true
allow-flight=false
level-name=world
view-distance=10
resource-pack=
spawn-animals=true
white-list=false
generate-structures=true
online-mode=true
max-build-height=256
level-seed=
use-native-transport=true
enable-rcon=false
motd=Server generated by Variiuz Installer Script
EOF
	echo "java -server -Xmx${2}G -jar /home/minecraftservers/$DIR/minecraft_server.jar" > /home/minecraftservers/$DIR/start.sh
	echo "screen -S $3 -p 0 -X stuff \"$(printf "stop")\"" > /home/minecraftservers/$DIR/mc_stop.sh
	chmod +x /home/minecraftservers/$DIR/start.sh
	echo "screen -S $3 -d -m sh /home/minecraftservers/$DIR/start.sh" > /home/minecraftservers/$DIR/mc_start.sh
	chmod +x /home/minecraftservers/$DIR/mc_start.sh
	sed -i "s/server-port=25565/server-port=${4}/g" /home/minecraftservers/$DIR/server.properties
	cd /home/minecraftservers/$DIR/
	sh mc_start.sh
	cd $WORKDIR
	show_mc
	log "DONE! Server has automatically started. It will take a few minutes to be reachable. Directory: /home/minecraftservers/$DIR/"
	log "You can use the mc_stop.sh and mc_start.sh to start/stop the server."
	read -n 1 -s -r -p "Press any key to get back to the Mainmenu or use CTRL^C to quit"
	clear
	show_menu
}
function show_menu {
	clear
	echo "==================================================================================="
	echo "Welcome to the Server Manager Script by Variiuz, please select an option from below"
	echo "==================================================================================="
	echo "1) Install Minecraft Server"
	echo "2) Update whole Server"
	echo "3) Install useful programs"
	echo "4) Install Teamspeak Server"
	echo "5) Check for updates"
	echo "6) Show Changelogs"
	echo "q) Quit"
	echo "==================================================================================="
	echo "Version: $VERSION - Script should only be used by the Server Admin."
	echo "Script tested on Ubuntu bionic and xenial"
	echo $1 
	read -p '> ' select

	case $select in
	1)
		show_mc
		echo "Currently unavailable, due to issues with the mirrior."
		clear
		show_menu
		;;
		#echo "Please select the version and give some information."
		#echo "Visit https://cdn.alex-is-a.ninja/share/minecraft_versions.txt for a list of supported Versions."
		#read -p 'Version: ' mc_version
		#read -p 'Memory in GB: ' mc_ram
		#read -p 'Screenname: ' mc_screen
		#read -p 'Port: ' mc_port
		#echo "Thanks, installing will continue after confirmation."
		#show_mc
		#echo "Please confirm these settings:"
		#echo "Version: $mc_version"
		#echo "Memory: $mc_ram GB"
		#echo "Screenname: $mc_screen"
		#echo "Port: $mc_port"
		#echo "PLEASE NOTE: This script is just for installing the server NOT maintaining/managing it!"
		#read -n 1 -s -r -p "Press any key to confirm or use CTRL^C to quit"
		#install_mc $mc_version $mc_ram $mc_screen $mc_port
		;;
	2)
		clear
		echo "=================="
		echo "Updating Server..."
		echo "=================="
		echo "This may take some time..."
		update_root
		;;
	3)
		clear
		install_progs
		;;
	4)
		clear
		echo "==========================="
		echo "Install Teamspeak Server..."
		echo "==========================="
		echo " "
		echo "Please note: This only downloads & installs it, you need to start and maintain it yourself."
		read -n 1 -s -r -p "Press any key to start or use CTRL^C to quit"
		clear
		install_ts
		;;
	5)
		clear
		echo "==========================="
		echo "Checking for Updates..."
		echo "==========================="
		echo " "
		check_updates "No updates found!"
		;;
	6)
		clear
		echo "==========================="
		echo "CHANGELOG"
		echo "==========================="
		echo " "
		check_changelog
		;;
	q)
		exit 0
		;;
	*)
		clear
		show_menu "Not sure what you want but this option is not available."
		;;
	esac
}
check_updates
