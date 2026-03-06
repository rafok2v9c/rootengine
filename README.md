# ROOTENGINE

Advanced Linux system lockdown tool with security monitoring neutralization capabilities.

## Example Session

```bash
$ sudo ./rootengine.sh

██████╗  ██████╗  ██████╗ ████████╗███████╗███╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝████╗  ██║██╔════╝ ██║████╗  ██║██╔════╝
██████╔╝██║   ██║██║   ██║   ██║   █████╗  ██╔██╗ ██║██║  ███╗██║██╔██╗ ██║█████╗  
██╔══██╗██║   ██║██║   ██║   ██║   ██╔══╝  ██║╚██╗██║██║   ██║██║██║╚██╗██║██╔══╝  
██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████╗██║ ╚████║╚██████╔╝██║██║ ╚████║███████╗
╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝

Select execution mode:

1) Aggressive Mode - Maximum Lockdown
2) Backdoor Mode - Attacker Access Preserved

Enter your choice (1 or 2): _
```

---

## !!!DISCLAIMER!!!

**THIS TOOL IS FOR EDUCATIONAL AND AUTHORIZED SECURITY TESTING ONLY.**

* Use ONLY in controlled test environments, VMs, or authorized systems
* Author are NOT responsible for any damage, data loss, or legal consequences
* Unauthorized use may be ILLEGAL in your jurisdiction
* You accept FULL RESPONSIBILITY for your actions

**WARNING: Makes IRREVERSIBLE system modifications. Always create snapshots before running.**

---

## SECURITY WARNING

**CRITICAL LEGAL NOTICE:**

* **Authorized Use Only** - Use ONLY on systems you own or have written authorization
* **No Warranty** - Software provided "AS IS" with no liability for damages
* **Full Responsibility** - By using this tool, you accept ALL consequences

---

## Overview

ROOTENGINE neutralizes security monitoring solutions while maintaining web service availability. Advanced system lockdown with dual operating modes.

### Features

* IDS/IPS neutralization (Snort, Suricata, Zeek, Fail2ban)
* SIEM/SOAR disruption (Splunk, Elastic, QRadar, Graylog)
* Monitoring shutdown (Nagios, Zabbix, Prometheus, Datadog)
* Log encryption/deletion
* Admin access blocking (SSH, FTP, console)
* Web service protection (Apache, Nginx, Lighttpd)
* Multiple persistence mechanisms

---

## Compatibility

### Supported OS

* Ubuntu, Debian, Fedora, Linux Mint
* Arch Linux, Manjaro, openSUSE
* Pop!_OS, Kali Linux, AlmaLinux and other Debian based OS

### Requirements

* root/sudo access
* Bash 4.0+

---

## Installation

```bash
git clone https://github.com/rafok2v9c/rootengine.git
cd rootengine
chmod +x rootengine.sh
```

---

### Basic Usage

```bash
sudo ./rootengine.sh --help
or
sudo ./rootengine.sh
```

---

## Operating Modes

### Mode 1: Aggressive

Complete system lockdown with maximum restrictions.

**What happens:**
* All security monitoring neutralized
* User accounts isolated
* Terminals destroyed
* System binaries sabotaged
* Authentication broken
* Web services protected and running (The attacker's index.html should always be visible.)

**Result:** System totally locked, only web accessible from outside.

---

### Mode 2: Backdoor

System lockdown while maintaining backdoor access.

**What happens:**
* Security monitoring neutralized
* Server Admin access blocked
* Logs deleted
* Web services protected
* Backdoor shells established

**Use responsibly and legally.**
