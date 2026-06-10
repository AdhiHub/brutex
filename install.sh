#!/usr/bin/env bash

RED='\033[1;31m'; GREEN='\033[1;32m'; CYAN='\033[1;36m'; YELLOW='\033[1;33m'; RESET='\033[0m'

REPO_URL="https://raw.githubusercontent.com/AdhiHub/brutex/main/brutex.sh"
TOOL_NAME="brutex"

detect_prefix() {
    if [ -n "$PREFIX" ] && [ -d "$PREFIX" ]; then
        echo "$PREFIX"
    else
        echo "/usr/local"
    fi
}

install_deps() {
    echo -e "${CYAN}[*] Checking dependencies...${RESET}"
    if ! command -v curl &>/dev/null; then
        echo -e "${YELLOW}[!] curl not found. Installing...${RESET}"
        if command -v apt &>/dev/null; then sudo apt update -y && sudo apt install curl -y
        elif command -v pkg &>/dev/null; then pkg install curl -y
        elif command -v yum &>/dev/null; then sudo yum install curl -y
        else echo -e "${RED}[!] Install curl manually.${RESET}"; exit 1
        fi
    fi
    echo -e "${GREEN}[+] Dependencies satisfied.${RESET}"
}

do_install() {
    local prefix bin_dir sudo_cmd=""
    prefix=$(detect_prefix)
    bin_dir="${prefix}/bin"

    if [ -z "$PREFIX" ] && [ "$(id -u)" -ne 0 ]; then
        sudo_cmd="sudo"
    fi

    echo -e "${CYAN}[*] Installing ${TOOL_NAME} to ${bin_dir}/${TOOL_NAME}...${RESET}"

    if command -v curl &>/dev/null; then
        curl -fsSL "$REPO_URL" | $sudo_cmd tee "$bin_dir/$TOOL_NAME" > /dev/null
    elif command -v wget &>/dev/null; then
        wget -qO- "$REPO_URL" | $sudo_cmd tee "$bin_dir/$TOOL_NAME" > /dev/null
    else
        echo -e "${RED}[!] curl or wget required.${RESET}"; exit 1
    fi

    $sudo_cmd chmod +x "$bin_dir/$TOOL_NAME"

    if [ -f "$bin_dir/$TOOL_NAME" ]; then
        echo -e "${GREEN}[+] ${TOOL_NAME} installed successfully!${RESET}"
        echo -e "${GREEN}[+] Run: ${TOOL_NAME}${RESET}"
    else
        echo -e "${RED}[!] Installation failed. Try: sudo curl -fsSL ${REPO_URL} -o ${bin_dir}/${TOOL_NAME}${RESET}"
        exit 1
    fi
}

main() {
    echo -e "${RED}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║       BRUTEX INSTALLER v1.1          ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${YELLOW}Use at your own risk, developer(s) assume NO liability${RESET}"
    echo ""
    install_deps
    do_install
}

main
