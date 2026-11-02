}

show_logs() {
    say "Recent XRDP service logs..."
    if is_systemd; then
        journalctl -u xrdp -u xrdp-sesman -n 100 --no-pager 2>&1 || true
    fi
    for logfile in /var/log/xrdp.log /var/log/xrdp-sesman.log; do
        if [[ -r "$logfile" ]]; then
            echo
            echo "--- $logfile (last 80 lines) ---"
            tail -n 80 "$logfile"
        fi
    done
    echo
    echo "--- Manager log: $LOG_FILE (last 40 lines) ---"
    tail -n 40 "$LOG_FILE" 2>/dev/null || true
}

allow_client_ip() {
    local client_ip port
    port="$(get_xrdp_port)"
    command -v ufw >/dev/null 2>&1 || die "UFW is not installed. Use your active firewall's equivalent rule instead."
    command -v python3 >/dev/null 2>&1 || die "python3 is required to validate the client IP address."

    read -r -p "Enter the trusted client IP address (not 0.0.0.0/0): " client_ip
    [[ -n "$client_ip" ]] || die "No client IP supplied."
    python3 -c 'import ipaddress,sys; ip=ipaddress.ip_address(sys.argv[1]); print("Validated:", ip)' "$client_ip" || die "Invalid IP address. Enter one IPv4 or IPv6 address, without a CIDR range."

    echo
    warn "This adds a UFW rule for $client_ip to TCP port $port only. It does NOT enable UFW."
    warn "Also restrict port $port in any cloud/network security group. Never expose RDP to the entire internet."
    read -r -p "Add this firewall rule? Type YES to confirm: " confirmation
    [[ "$confirmation" == "YES" ]] || { say "Cancelled; no firewall rule added."; return; }

    ufw allow from "$client_ip" to any port "$port" proto tcp
    say "UFW rule added for $client_ip on TCP/$port."
    ufw status numbered || true
}

uninstall_xrdp() {
    echo "This will stop and remove XRDP and xorgxrdp packages."
    echo "XFCE, your Linux user account, and the user's ~/.xsession file will be left untouched."
    read -r -p "Type REMOVE to continue: " confirmation
    [[ "$confirmation" == "REMOVE" ]] || { say "Uninstall cancelled."; return; }

    say "Stopping and disabling XRDP..."
    if is_systemd; then
        systemctl disable --now xrdp 2>/dev/null || true
        if has_sesman_unit; then
            systemctl disable --now xrdp-sesman 2>/dev/null || true
        fi
    elif command -v service >/dev/null 2>&1; then
        service xrdp stop 2>/dev/null || true
    fi

    say "Purging XRDP packages..."
    apt-get purge -y xrdp xorgxrdp
    say "XRDP packages removed. XFCE and user session files were preserved."
}

show_menu() {
    while true; do
        echo
        echo "=========================================="
        echo "             $APP_NAME"
        echo "=========================================="
        echo "  1) Install and configure XRDP + XFCE"
        echo "  2) Check XRDP status and port"
        echo "  3) Restart XRDP services"
        echo "  4) Repair packages and XFCE session"
        echo "  5) View troubleshooting logs"
        echo "  6) Allow one trusted client IP (UFW)"
        echo "  7) Uninstall XRDP (confirmation required)"
        echo "  0) Exit"
        echo "=========================================="
        read -r -p "Select an option: " choice
        case "$choice" in
            1) install_xrdp "" ;;
            2) show_status ;;
            3) restart_xrdp ;;
            4) repair_xrdp "" ;;
            5) show_logs ;;
            6) allow_client_ip ;;
            7) uninstall_xrdp ;;
            0) say "Exiting."; break ;;
            *) warn "Invalid option. Choose 0-7." ;;
        esac
    done
}

usage() {
    cat <<EOF
$APP_NAME - one-file XRDP + XFCE management utility

Usage:
  sudo bash $0                         Open interactive menu
  sudo bash $0 install [username]      Install and configure XRDP + XFCE
  sudo bash $0 status                  Check packages, services and port
  sudo bash $0 restart                 Restart XRDP services
  sudo bash $0 repair [username]       Reinstall required packages and repair session
  sudo bash $0 logs                    Show troubleshooting logs
  sudo bash $0 firewall                Add a UFW allow rule for one trusted client IP
  sudo bash $0 uninstall               Remove XRDP packages (asks for confirmation)

Supported: Kali Linux, Debian and Ubuntu with APT.
EOF
}

case "${1:-menu}" in
    menu)      show_menu ;;
    install)   install_xrdp "${2:-}" ;;
    status)    show_status ;;
    restart)   restart_xrdp ;;
    repair)    repair_xrdp "${2:-}" ;;
    logs)      show_logs ;;
    firewall)  allow_client_ip ;;
    uninstall) uninstall_xrdp ;;
    -h|--help|help) usage ;;
    *) usage; die "Unknown command: ${1}" ;;
esac
