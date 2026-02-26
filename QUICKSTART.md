# SMART Monitor Widget - Quick Start Guide

## What You'll Need

1. **KDE Plasma 6** (check with: `plasmashell --version`)
2. **smartmontools** package installed
3. **Sudo access** for smartctl command

## 5-Minute Setup

### Step 1: Install smartmontools

```bash
# Pick your distribution:
sudo apt install smartmontools      # Debian/Ubuntu
sudo dnf install smartmontools      # Fedora
sudo pacman -S smartmontools        # Arch Linux
```

### Step 2: Configure sudo access

```bash
# Create sudoers file
sudo visudo -f /etc/sudoers.d/smartctl
```

Add this line (replace `yourusername` with your actual username):
```
yourusername ALL=(ALL) NOPASSWD: /usr/sbin/smartctl
```

Save and exit (Ctrl+X, then Y, then Enter in nano).

### Step 3: Install the widget

Option A - Using the install script:
```bash
cd plasma-smart-monitor
./install.sh
```

Option B - Manual installation:
```bash
# Copy to widgets directory
mkdir -p ~/.local/share/plasma/plasmoids/
cp -r plasma-smart-monitor ~/.local/share/plasma/plasmoids/com.github.vertimyst.ksmartmonitor

# Restart Plasma
kquitapp6 plasmashell && plasmashell &
```

### Step 4: Add to your panel

1. Right-click on your panel
2. Click "Add Widgets"
3. Search for "SMART Monitor"
4. Drag it to your panel

Done! The widget will start monitoring your drives automatically.

## Understanding the Widget

### Panel View
- **Gray disk icon**: All drives healthy
- **Orange disk icon**: Warning (hot drive or minor issues)
- **Red disk icon**: Critical (drive failing)
- **Number**: Count of monitored drives

### Expanded View (click the widget)
Shows for each drive:
- Device name (e.g., /dev/sda)
- Model name
- Health status (PASSED/WARNING/FAILING)
- Temperature
- Critical attributes (bad sectors, power-on hours, etc.)

## Configuration

Right-click the widget → Configure SMART Monitor

You can adjust:
- **Update interval**: How often to check (default: 5 minutes)
- **Temperature thresholds**: When to show warnings (default: 55°C warning, 60°C critical)
- **Detailed attributes**: Show/hide additional SMART data

## Troubleshooting

### "No drives detected"
```bash
# Check if smartctl works
sudo smartctl --scan

# Test reading a specific drive
sudo smartctl -a /dev/sda
```

### "Permission denied"
- Double-check the sudoers configuration
- Make sure you used your correct username
- Test: `sudo -n smartctl --scan` (should work without password)

### Widget doesn't show up
```bash
# Check if installed correctly
ls ~/.local/share/plasma/plasmoids/com.github.vertimyst.ksmartmonitor

# Restart Plasma Shell
kquitapp6 plasmashell && plasmashell &

# Check logs for errors
journalctl -f
```

## What the Widget Monitors

The widget tracks these critical indicators:
- **Overall health**: Pass/fail from SMART self-test
- **Temperature**: Current drive temperature
- **Reallocated sectors**: Bad sectors that have been remapped
- **Pending sectors**: Sectors waiting to be reallocated
- **Uncorrectable sectors**: Sectors that couldn't be read
- **Power-on hours**: Total time the drive has been running

## Safety Notes

⚠️ This widget requires sudo access to read SMART data. The sudoers configuration is limited to only the smartctl command, which is read-only and safe.

⚠️ The widget monitors but cannot fix drive issues. If you see warnings or failures, backup your data immediately and consider replacing the drive.

## Getting Help

Check the full README.md for:
- Detailed configuration options
- Security considerations
- Advanced troubleshooting
- Customization tips
