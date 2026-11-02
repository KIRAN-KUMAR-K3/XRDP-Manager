# XRDP Manager

A single-file Bash utility to install, configure, troubleshoot, and manage **XRDP with the XFCE desktop** on Kali Linux, Debian, and Ubuntu.

XRDP Manager provides an interactive menu as well as command-line actions for common administration tasks. It uses the distribution-managed XRDP startup script and configures the selected user's XFCE session through `~/.xsession`.

> **Security notice:** XRDP exposes a remote login service. Do not publish TCP port 3389 directly to the internet. Prefer a trusted VPN or SSH tunnel, and restrict access at the host firewall and any cloud/network security group.

## Features

- **Install XRDP + XFCE** — installs XRDP, Xorg support, XFCE and required session components.
- **Service and port status** — checks installed packages, systemd services and the configured listening port.
- **Restart services** — restarts XRDP and the session manager when available.
- **Repair installation** — reinstalls required packages and repairs the selected user's XFCE session configuration.
- **Troubleshooting logs** — displays recent service journal entries and XRDP log files.
- **UFW access rule** — optionally allows one validated trusted client IP to reach the configured XRDP TCP port. It does not enable UFW automatically.
- **Uninstall** — removes XRDP packages after an explicit confirmation; XFCE and user session files are left in place.
- **Single-file design** — one Bash script, with no separate application files required.

## Supported systems

- Kali Linux
- Debian
- Ubuntu

The script uses APT and systemd where available. Run it on a supported system with administrative privileges.

## Requirements

- A supported Kali/Debian/Ubuntu installation
- A working APT repository and internet connection for package installation
- `sudo` or root access
- An existing Linux user account for the graphical desktop session
- systemd for the full service-management experience
- UFW and Python 3 only for the optional trusted-client firewall action

## Quick start

Clone the repository:

```bash
git clone https://github.com/KIRAN-KUMAR-K3/XRDP-Manager.git
cd XRDP-Manager
```

Make the script executable:

```bash
chmod +x xrdp-manager.sh
```

Start the interactive manager:

```bash
sudo ./xrdp-manager.sh
```

Choose **1) Install and configure XRDP + XFCE**, then enter the Linux username that should receive the desktop session when prompted.

You can also run the installer directly:

```bash
sudo ./xrdp-manager.sh install <linux-username>
```

Replace `<linux-username>` with an existing local account, for example:

```bash
sudo ./xrdp-manager.sh install iso
```

## Menu options

| Option | Action | Purpose |
| --- | --- | --- |
| `1` | Install and configure | Installs XRDP/Xorg/XFCE and configures the user's XFCE session |
| `2` | Check status | Reports package, service, IP and listening-port information |
| `3` | Restart services | Restarts XRDP and XRDP session manager |
| `4` | Repair | Reinstalls required packages and repairs the user's session |
| `5` | View logs | Shows recent XRDP journal and log-file entries |
| `6` | Allow trusted client IP | Adds a UFW rule for one client IP to the XRDP port |
| `7` | Uninstall | Stops services and purges XRDP packages after confirmation |
| `0` | Exit | Closes the manager |

## Command-line usage

The same functions are available without opening the menu:

| Command | Description |
| --- | --- |
| `sudo ./xrdp-manager.sh` | Open the interactive menu |
| `sudo ./xrdp-manager.sh install <username>` | Install and configure XRDP + XFCE for a user |
| `sudo ./xrdp-manager.sh status` | Check packages, services and port |
| `sudo ./xrdp-manager.sh restart` | Restart XRDP services |
| `sudo ./xrdp-manager.sh repair <username>` | Repair packages and a user's XFCE session |
| `sudo ./xrdp-manager.sh logs` | Display troubleshooting logs |
| `sudo ./xrdp-manager.sh firewall` | Add a UFW rule for one trusted client IP |
| `sudo ./xrdp-manager.sh uninstall` | Uninstall XRDP packages after confirmation |
| `sudo ./xrdp-manager.sh --help` | Display usage information |

The `install` and `repair` commands accept a username. When omitted, the script uses the invoking sudo user when available; otherwise it asks for the required account or reports an error.

## Connecting from Windows

1. Complete the installation and note the Linux machine's IP address shown by the manager.
2. Confirm that TCP port **3389** is reachable from the trusted client network.
3. On Windows, press **Win + R**, enter `mstsc`, and press Enter.
4. Enter the Linux host address with the port, for example `192.168.1.50:3389`.
5. Connect using the Linux username and that account's Linux password.
6. At the XRDP login screen, choose **Xorg** when offered, then sign in.

The Linux host and client must have network connectivity. The actual port can differ if the XRDP configuration has been changed; the manager reads the configured port for its status and firewall actions.

## Security recommendations

- **Do not expose RDP to the public internet.** Use a VPN or SSH tunnel for remote access.
- Allow TCP 3389 only from known and trusted client IP addresses.
- Use the optional UFW rule only after confirming the client IP is correct:
  `sudo ./xrdp-manager.sh firewall`
- The firewall action adds a rule but does **not** enable UFW or modify cloud firewalls, router rules, network ACLs, or security groups.
- Apply equivalent restrictions in any cloud/network security group and upstream firewall.
- Use strong, unique Linux passwords and keep the operating system and XRDP packages updated.
- Only grant desktop access to accounts that should have it.

## Troubleshooting

Run the log viewer:

```bash
sudo ./xrdp-manager.sh logs
```

Useful manual checks:

```bash
sudo systemctl status xrdp
sudo systemctl status xrdp-sesman
sudo ss -lntp | grep ':3389'
sudo journalctl -u xrdp -u xrdp-sesman -n 100 --no-pager
sudo tail -n 100 /var/log/xrdp.log
sudo tail -n 100 /var/log/xrdp-sesman.log
```

Common checks:

- Confirm the XRDP services are active.
- Confirm XRDP is listening on the configured TCP port.
- Confirm the user has a valid password and home directory.
- Confirm the user's `~/.xsession` launches the XFCE session.
- Select **Xorg** at the XRDP login screen.
- Check local firewall and upstream network rules.
- Review XRDP and session-manager logs for the exact failure.

## How it works

The manager installs the XRDP server and Xorg integration alongside XFCE. For the target account, it configures `~/.xsession` to start the XFCE session. It intentionally leaves the package-managed `/etc/xrdp/startwm.sh` in place rather than replacing the system-wide startup script.

## Uninstallation

From the interactive menu, choose **7) Uninstall XRDP**, or run:

```bash
sudo ./xrdp-manager.sh uninstall
```

The script asks for an explicit confirmation before removing the `xrdp` and `xorgxrdp` packages. It leaves XFCE, Linux user accounts, and user session files in place. Review any firewall rules separately; removing XRDP packages does not necessarily remove previously added UFW rules.

## Project structure

```text
XRDP-Manager/
└── xrdp-manager.sh
```

## Contributing

Bug reports, tested improvements, and pull requests are welcome. When reporting an issue, include:

- Linux distribution and version
- XRDP package version
- The command or menu option used
- Relevant output from `sudo ./xrdp-manager.sh logs`

Remove usernames, public IP addresses, hostnames, and other sensitive information from logs before sharing them.

## License

No license is currently specified in this repository. Unless a license is added, the source remains subject to the default copyright rules; please contact the repository owner before redistributing or modifying it publicly.

## Author

**KIRAN KUMAR K.**

- GitHub: [@KIRAN-KUMAR-K3](https://github.com/KIRAN-KUMAR-K3)
- Repository: [XRDP-Manager](https://github.com/KIRAN-KUMAR-K3/XRDP-Manager)

---

If this project helps you, consider giving the repository a ⭐ on GitHub.
