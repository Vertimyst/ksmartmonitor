# KDE Plasma 6 SMART Monitor Widget

![Alternative Text](/screenshots/ksmartmonitor_1.png)

A Plasma 6 widget to monitor the SMART status of your drives, displaying health status, temperature, and critical SMART attributes.

## Features

- Real-time monitoring of all detected drives
- Display of critical SMART attributes:
  - Reallocated sectors
  - Pending sectors
  - Uncorrectable sectors
  - Power-on hours
- Compact panel view with status indicator
- Detailed expanded view with per-drive information
## Prerequisites

1. **smartmontools** must be installed:
   ```bash
   # Debian/Ubuntu
   sudo apt install smartmontools
   
   # Fedora
   sudo dnf install smartmontools
   
   # Arch Linux
   sudo pacman -S smartmontools
   ```

2. **Sudo permissions** for smartctl (required to read SMART data):
   
   Create a sudoers file to allow running smartctl without password:
   ```bash
   sudo visudo -f /etc/sudoers.d/smartctl
   ```
   
   Add this line (replace `username` with your username):
   ```
   username ALL=(ALL) NOPASSWD: /usr/sbin/smartctl
   ```
   
   Or for all users:
   ```
   ALL ALL=(ALL) NOPASSWD: /usr/sbin/smartctl
   ```
   
   Save and exit. Test with:
   ```bash
   sudo smartctl -a /dev/sda
   ```

## Installation

### Method 1: Manual Installation

1. Copy the widget to the Plasma widgets directory:
   ```bash
   mkdir -p ~/.local/share/plasma/plasmoids/
   cp -r plasma-smart-monitor ~/.local/share/plasma/plasmoids/com.github.vertimyst.ksmartmonitor
   ```

2. Restart Plasma Shell:
   ```bash
   kquitapp6 plasmashell && plasmashell &
   ```
   
   Or log out and back in.

3. Add the widget to your panel or desktop:
   - Right-click on panel → "Add Widgets"
   - Search for "SMART Monitor"
   - Drag it to your panel

### Method 2: Using kpackagetool6

```bash
cd plasma-smart-monitor
kpackagetool6 -t Plasma/Applet -i .
```

To update the widget:
```bash
kpackagetool6 -t Plasma/Applet -u .
```

To remove the widget:
```bash
kpackagetool6 -t Plasma/Applet -r com.github.vertimyst.ksmartmonitor
```

## Usage

### Compact View (Panel)
- Shows a drive icon with a count of monitored drives
- Icon color changes based on drive status:
  - **Gray/Normal**: All drives healthy
  - **Orange**: Warning (high temperature or minor issues)
  - **Red**: Critical (drive failing or has errors)

### Expanded View
Click on the widget to see detailed information:
- Device name and model
- Overall health status (PASSED/WARNING/FAILING)
- Current temperature
- Critical SMART attributes
- Last update timestamp

## Security Considerations

This widget requires sudo access to read SMART data. The sudoers configuration allows running smartctl without a password. If this is a security concern:

1. Use a more restrictive sudoers rule
2. Only allow specific drives: `username ALL=(ALL) NOPASSWD: /usr/sbin/smartctl -A /dev/sda`

## License

GPL-2.0+

## Contributing

Feel free to submit issues and enhancement requests!
