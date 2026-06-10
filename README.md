# BRUTEX — Multi-Service Brute-Forcer

**Brute-force login credentials on SSH, FTP, MySQL, and SMTP servers.**

Part of the **AdhiHub** security toolkit.

---

## What It Does

| Service | What It Attacks |
|---------|----------------|
| SSH (port 22) | Tries username + password combos against SSH servers |
| FTP (port 21) | Tries username + password combos against FTP servers |
| MySQL (port 3306) | Tries username + password combos against MySQL databases |
| SMTP (port 25/587) | Tries username + password combos against SMTP auth |

Uses **hydra** if installed (faster). Falls back to manual bash-based connection attempts otherwise.

---

## One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/AdhiHub/brutex/main/install.sh | bash
```

After install:

```bash
brutex
```

---

## How to Use

### Method 1: Interactive Menu

```bash
brutex
```

Pick the service, enter the target IP, port, and wordlist paths.

### Method 2: Command Line

```bash
# SSH brute-force
brutex --ssh 192.168.1.1 22 users.txt passwords.txt

# FTP brute-force
brutex --ftp 10.0.0.5 21 users.txt passwords.txt

# MySQL brute-force
brutex --mysql 192.168.1.100 3306 users.txt passwords.txt

# SMTP brute-force
brutex --smtp mail.target.com 25 users.txt passwords.txt

# Help
brutex -h
```

---

## Wordlist Format

- **Userlist:** one username per line
- **Passlist:** one password per line

Example `users.txt`:
```
admin
root
user
```

Example `passwords.txt`:
```
123456
password
admin123
```

---

## Requirements

- **Linux** or **Termux** (Android)
- curl
- Optional: hydra (recommended), sshpass, mariadb-client

---

## Run Without Installing

```bash
git clone https://github.com/AdhiHub/brutex.git
cd brutex
chmod +x brutex.sh
./brutex.sh
```

---

> **⚠️ DISCLAIMER: FOR EDUCATIONAL PURPOSES ONLY**
>
> Use at your own risk. Developer(s) assume NO liability.
> Only attack servers you own or have explicit written permission to test.
> Unauthorized brute-forcing is illegal in most jurisdictions.
