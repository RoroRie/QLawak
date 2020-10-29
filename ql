#!/usr/bin/env bash

# Easy alias for escape codes
function echo() {
    command echo -e "${@}"
}

function help_menu() {
    echo
    echo "${BOLD}QLauncher menu${RST}"
    echo
    echo "${BOLD}USAGE:${RST} ${0} <options>"
    echo
    echo "${BOLD}EXAMPLE:${RST} ${0} -s"
    echo
    echo "${BOLD}EXAMPLE:${RST} ${0} --status"
    echo
    echo " -b | --bind:      Bind account to QQQ App"
    echo " -c | --check:     Verify Installation"
    echo " -f | --freeze:    Stop miner"
    echo " -h | --help:      Help menu"
    echo " -k | --kickoff:   Start miner"
    echo " -r | --restart:   Restart miner"
    echo " -s | --status:    Status miner"
    echo " -S | --sn:        Change Serial Number"
    echo " -u | --update:    Update QLauncher"
    echo "-so | --swapon:  Add Swap"
    echo "-sc | --swapcheck:  Check Swap"
    echo
}

function setup_variables() {
    DIRQL="$HOME/qlauncher"
    ZIP="app.tar.gz"
    BOLD="\033[1m"
    RST="\033[0m"
    QLS="$DIRQL/qlauncher.sh"
}

function bind() {
    echo
    echo "Scan the QR code below"
    echo
    qrencode "NAS-QNAP-$(cat /etc/qlauncher)" -t ANSIUTF8 -o -
    echo
    echo "You can also use the link below"
    $QLS bind
    echo
}

function check() {
    echo
    echo "Current SN : $(cat /etc/qlauncher)"
    echo
    $QLS check
    echo
}

function freeze() {
    $QLS stop
}

function kickoff() {
    $QLS start
}

function restart() {
    $QLS restart
}

function status() {
    $QLS status
}

function sn() {
    read -r -p "do you want to change the serial number? [y/N]" PROMPT
    if [[ $PROMPT =~ [yY](es)* ]]; then
       echo
       echo "Enter new serial number : "
       read -r NEWSN
       echo "Applying new serial number"
       echo "${NEWSN}" > /etc/machine-id
       echo "${NEWSN}" > /etc/qlauncher
       echo "Done."
               read -r -p "Restart QLauncher? [y/N]" PROMPT
               if [[ $PROMPT =~ [yY](es)* ]]; then
                   echo
                   $QLS restart
               else
                   echo "Done"
               fi
    else
       echo
       echo "Use default serial number"
      fi
}


function zipdl() {
    wget https://github.com/poseidon-network/qlauncher-linux/releases/latest/download/ql-linux.tar.gz -O "${ZIP}"
    tar -vxzf "${ZIP}" -C "${DIRQL}"
    echo "start QLauncher"
    kickoff
}

function update() {
    if [[ -d ${DIRQL} ]]; then
       echo "folder exist, deleting current qlauncher folder"
       freeze
       rm -rf ${DIRQL}
       mkdir ${DIRQL}
       if [[ -e ${ZIP} ]]; then
          echo
          # remove package if exist then start updating
          rm -rf "${ZIP}"
          zipdl
       else
          echo
          # seems file doesn't exist, lets start updating
          zipdl
          rm -rf "${ZIP}"
       fi
    else
       echo
       echo "QLauncher doesn't exist, read the README for how to install it"
       echo
    fi
}

function addswap() {
   read -r -p "Change default swap size? Default 1Gb [y/N]" PROMPT
    if [[ $PROMPT =~ [yY](es)* ]]; then
       echo "Enter swap size : "
       read -r SIZE
    fi 
    if ! grep -q "swapfile" /etc/fstab; then
       echo "swapfile not found. Adding swapfile."
       if [[ -z $SIZE ]]; then
          echo
          echo "Add 1G swap"
          sudo fallocate -l 1G /swapfile
       else
          echo
          echo "Add ${SIZE}G swap"
          sudo fallocate -l "${SIZE}"G /swapfile
       fi
       sudo chmod 600 /swapfile
       sudo mkswap /swapfile
       sudo cp /etc/fstab /etc/fstab.bak
       echo "/swapfile none swap sw 0 0" >> /etc/fstab
       echo "tuning swap"
       sudo sysctl vm.swappiness=10
       echo "vm.swappiness=10" >> /etc/sysctl.conf
       sudo sysctl vm.overcommit_memory=1
       echo "vm.overcommit_memory=1" >> /etc/sysctl.conf
       sudo swapon /swapfile
    else
       echo "...."
    fi
}

function scheck() {
    echo
    < /proc/meminfo grep Swap
    echo
}

function parse_parameters() {
    case "${1}" in
        "-b"|"--bind") bind  ;;
        "-c"|"--check") check ;;
        "-f"|"--freeze") freeze ;;
        "-k"|"--kickoff") kickoff ;;
        "-r"|"--restart") restart ;;
        "-s"|"--status") status ;;
        "-S"|"--sn") sn ;;
        "-so"|"--swapon") addswap ;;
        "-sc"|"--swapcheck") scheck ;;
        "-u"|"--update") update ;;

        # HELP!
        "-h"|"--help"|*) help_menu ;;
    esac
}

setup_variables
parse_parameters "${@}"
