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

### Required Packages

**smartmontools** must be installed:
```bash
# Debian/Ubuntu
sudo apt install smartmontools

# Fedora
sudo dnf install smartmontools

# Arch Linux
sudo pacman -S smartmontools
```

### Build Dependencies

Required to compile the KAuth helper:
```bash
# Debian/Ubuntu
sudo apt install cmake extra-cmake-modules libkf6auth-dev qt6-base-dev build-essential

# Fedora
sudo dnf install cmake extra-cmake-modules kf6-kauth-devel qt6-qtbase-devel gcc-c++

# Arch Linux
sudo pacman -S cmake extra-cmake-modules kauth qt6-base base-devel
```

## Installation

This widget uses **KAuth** for secure, privileged access to SMART data.

### Build and Install

1. **Clone or download the repository**

2. **Build the project:**
   ```bash
   cd ksmartmonitor
   mkdir build && cd build
   cmake ..
   make
   ```

3. **Install (requires root):**
   ```bash
   sudo make install
   ```

4. **Restart Plasma Shell:**
   ```bash
   kquitapp6 plasmashell && kstart plasmashell
   ```

5. **Add the widget:**
   - Right-click on panel or desktop → "Add Widgets"
   - Search for "SMART Monitor"
   - Add it to your panel or desktop

### Uninstall

```bash
cd build
sudo make uninstall
```

Or manually remove:
```bash
sudo rm /usr/lib/kf6/kauth/smartmonitorhelper
sudo rm /usr/bin/ksmartmonitor-cli
sudo rm /usr/share/polkit-1/actions/com.github.vertimyst.ksmartmonitor.policy
sudo rm -r /usr/share/plasma/plasmoids/com.github.vertimyst.ksmartmonitor
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

## License

GPL-2.0+

## Contributing

Feel free to submit issues and enhancement requests!
