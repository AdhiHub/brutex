# BRUTEX v1.0

**Multi-Service Brute-Forcer**

BruteX is a bash-based penetration testing tool for brute-forcing credentials across SSH, FTP, MySQL, and SMTP services. Uses hydra when available, with a manual fallback mode.

## One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/AdhiHub/brutex/main/install.sh | bash
```

## Features

| Feature     | Description                                     |
|-------------|-------------------------------------------------|
| SSH Brute   | Brute-force SSH login credentials               |
| FTP Brute   | Brute-force FTP login credentials               |
| MySQL Brute | Brute-force MySQL database credentials          |
| SMTP Brute  | Brute-force SMTP authentication credentials     |
| Hydra Mode  | Auto-detects hydra for faster cracking          |
| Manual Mode | Fallback using bash builtins and common tools   |
| Report      | Saves results to timestamped file               |
| CLI + Menu  | Command-line flags or interactive menu          |

## Usage

### Interactive Mode
```bash
./brutex.sh
```

### CLI Mode
```bash
# SSH brute-force
./brutex.sh --ssh 192.168.1.1 22 users.txt passwords.txt

# FTP brute-force
./brutex.sh --ftp 10.0.0.5 21 users.txt passwords.txt

# MySQL brute-force
./brutex.sh --mysql 192.168.1.1 3306 users.txt passwords.txt

# SMTP brute-force
./brutex.sh --smtp 192.168.1.1 25 users.txt passwords.txt

# Help
./brutex.sh -h
```

## Requirements

- Bash 4+
- curl
- Optional: hydra (recommended for speed), sshpass, mariadb-client

## Disclaimer

Use at your own risk, developer(s) assume NO liability. This tool is for educational purposes and authorized testing only. Unauthorized scanning of systems you do not own is illegal. You have been warned.
