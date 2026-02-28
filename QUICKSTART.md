# SMART Monitor Widget - Quick Start Guide

## What You'll Need

1. **KDE Plasma 6** (check with: `plasmashell --version`)
2. **smartmontools** package installed
3. **Build tools** (cmake, compiler, KDE development packages)

## 5-Minute Setup

### Step 1: Install Required Packages

```bash
# Arch Linux
sudo pacman -S smartmontools cmake extra-cmake-modules kauth qt6-base base-devel

# Debian/Ubuntu
sudo apt install smartmontools cmake extra-cmake-modules libkf6auth-dev qt6-base-dev build-essential

# Fedora
sudo dnf install smartmontools cmake extra-cmake-modules kf6-kauth-devel qt6-qtbase-devel gcc-c++
```

### Step 2: Build and Install

```bash
cd ksmartmonitor
mkdir build && cd build
cmake ..
make
sudo make install
```

### Step 3: Restart Plasma

```bash
kquitapp6 plasmashell && kstart plasmashell
```

### Step 4: Add the Widget

1. Right-click on your panel or desktop
2. Click "Add Widgets"
3. Search for "SMART Monitor"
4. Add it to your panel or desktop

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
The KAuth helper might not be installed correctly:

```bash
# Check if helper is installed
ls /usr/lib/kf6/kauth/smartmonitorhelper

# Test the helper directly
ksmartmonitor-cli

# Check if smartctl works
sudo smartctl --scan
```

### Build errors
Make sure you have all development packages:
```bash
# Arch
sudo pacman -S cmake extra-cmake-modules kauth qt6-base base-devel

# Debian/Ubuntu  
sudo apt install cmake extra-cmake-modules libkf6auth-dev qt6-base-dev build-essential
```

### Widget doesn't show up
```bash
# Reinstall
cd build
sudo make install

# Restart Plasma Shell
kquitapp6 plasmashell && kstart plasmashell

# Check logs for errors
journalctl -f | grep smartmonitor
```

## What the Widget Monitors

The widget tracks these critical indicators:
- **Overall health**: Pass/fail from SMART self-test
- **Temperature**: Current drive temperature
- **Reallocated sectors**: Bad sectors that have been remapped
- **Pending sectors**: Sectors waiting to be reallocated
- **Uncorrectable sectors**: Sectors that couldn't be read
- **Power-on hours**: Total time the drive has been running


## Getting Help

Check the full README.md for:
- Detailed configuration options
- Security considerations
- Advanced troubleshooting
- Customization tips
