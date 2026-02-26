// Parse SMART data from smartctl output
function parseSmartData(output) {
    var lines = output.split('\n');
    var drives = [];
    var currentDrive = null;
    
    for (var i = 0; i < lines.length; i++) {
        var line = lines[i].trim();
        
        // Start of a new drive
        if (line.startsWith('DRIVE:')) {
            if (currentDrive) {
                drives.push(currentDrive);
            }
            
            var drivePath = line.substring(6).trim();
            currentDrive = {
                device: drivePath,
                model: '',
                health: 'UNKNOWN',
                temperature: 0,
                type: drivePath.includes('nvme') ? 'NVME' : 'HDD',
                attributes: []
            };
            continue;
        }
        
        if (!currentDrive) continue;
        
        // Skip error lines
        if (line === 'ERROR') {
            currentDrive.health = 'ERROR';
            continue;
        }
        
        // Parse model (works for both SATA and NVMe)
        if (line.includes('Device Model:') || line.includes('Model Number:')) {
            currentDrive.model = line.split(':')[1].trim();
        }
        
        // Detect SSD/NVMe
        if (line.includes('Solid State Device') || 
            (line.includes('Rotation Rate:') && line.includes('Solid State')) ||
            currentDrive.device.includes('nvme')) {
            currentDrive.type = currentDrive.device.includes('nvme') ? 'NVME' : 'SSD';
        }
        
        // Parse health status (both SATA and NVMe formats)
        if (line.includes('SMART overall-health self-assessment test result:') ||
            line.includes('SMART Health Status:')) {
            var healthStatus = line.split(':')[1].trim();
            if (healthStatus === 'PASSED' || healthStatus === 'OK') {
                currentDrive.health = 'PASSED';
            } else {
                currentDrive.health = 'FAILING';
            }
        }
        
        // Parse temperature - SATA format
        if (line.match(/^\s*\d+\s+Temperature/i) || line.match(/^\s*\d+\s+Airflow_Temperature/i)) {
            var parts = line.split(/\s+/);
            if (parts.length >= 10) {
                var temp = parseInt(parts[9]);
                if (!isNaN(temp) && temp > 0 && temp < 100) {
                    currentDrive.temperature = Math.max(currentDrive.temperature, temp);
                }
            }
        }
        
        // Parse temperature - NVMe format
        if (line.includes('Temperature:') && !line.includes('Warning')) {
            var tempMatch = line.match(/(\d+)\s+Celsius/);
            if (tempMatch) {
                var temp = parseInt(tempMatch[1]);
                if (!isNaN(temp) && temp > 0 && temp < 100) {
                    currentDrive.temperature = temp;
                }
            }
        }
        
        // Parse critical SMART attributes (SATA)
        if (line.match(/^\s*\d+\s+/) && currentDrive.type !== 'NVME') {
            var parts = line.split(/\s+/);
            if (parts.length >= 10) {
                var attrId = parseInt(parts[0]);
                var attrName = parts[1];
                var value = parseInt(parts[3]);
                var worst = parseInt(parts[4]);
                var threshold = parseInt(parts[5]);
                var rawValue = parts[9];
                
                // Track critical attributes
                if (attrId === 5) { // Reallocated_Sector_Ct
                    currentDrive.attributes.push({
                        name: 'Reallocated Sectors',
                        value: rawValue
                    });
                    if (parseInt(rawValue) > 0) {
                        currentDrive.health = 'WARNING';
                    }
                }
                else if (attrId === 197) { // Current_Pending_Sector
                    currentDrive.attributes.push({
                        name: 'Pending Sectors',
                        value: rawValue
                    });
                    if (parseInt(rawValue) > 0) {
                        currentDrive.health = 'WARNING';
                    }
                }
                else if (attrId === 198) { // Offline_Uncorrectable
                    currentDrive.attributes.push({
                        name: 'Uncorrectable Sectors',
                        value: rawValue
                    });
                    if (parseInt(rawValue) > 0) {
                        currentDrive.health = 'WARNING';
                    }
                }
                else if (attrId === 9) { // Power_On_Hours
                    var hours = parseInt(rawValue);
                    var years = (hours / 8760).toFixed(1);
                    currentDrive.attributes.push({
                        name: 'Power On Time',
                        value: hours + ' hours (' + years + ' years)'
                    });
                }
            }
        }
        
        // Parse NVMe specific attributes
        if (currentDrive.type === 'NVME') {
            // Power on hours for NVMe
            if (line.includes('Power On Hours:')) {
                var hoursMatch = line.match(/(\d[\d,]*)/);
                if (hoursMatch) {
                    var hours = parseInt(hoursMatch[1].replace(/,/g, ''));
                    var years = (hours / 8760).toFixed(1);
                    currentDrive.attributes.push({
                        name: 'Power On Time',
                        value: hours + ' hours (' + years + ' years)'
                    });
                }
            }
            
            // Media errors for NVMe
            if (line.includes('Media and Data Integrity Errors:')) {
                var errMatch = line.match(/:\s*(\d+)/);
                if (errMatch) {
                    var errors = parseInt(errMatch[1]);
                    currentDrive.attributes.push({
                        name: 'Media Errors',
                        value: errors.toString()
                    });
                    if (errors > 0) {
                        currentDrive.health = 'WARNING';
                    }
                }
            }
            
            // Percentage used for NVMe
            if (line.includes('Percentage Used:')) {
                var usedMatch = line.match(/(\d+)%/);
                if (usedMatch) {
                    currentDrive.attributes.push({
                        name: 'Percentage Used',
                        value: usedMatch[1] + '%'
                    });
                }
            }
        }
    }
    
    // Add the last drive
    if (currentDrive) {
        drives.push(currentDrive);
    }
    
    // Filter drives based on enabled list and apply custom names
    var enabledList = root.enabledDrivesList
    var nameMap = root.driveNameMap
    
    if (enabledList.length > 0) {
        drives = drives.filter(function(drive) {
            return enabledList.indexOf(drive.device) >= 0
        })
    }
    
    // Apply custom names
    for (var i = 0; i < drives.length; i++) {
        if (nameMap[drives[i].device]) {
            drives[i].displayName = nameMap[drives[i].device]
        } else {
            drives[i].displayName = drives[i].device
        }
    }
    
    // Update the root component
    root.driveData = drives;
    root.hasError = drives.length === 0;
    if (drives.length === 0) {
        root.errorMessage = "No drives found or no permission to read SMART data";
    }
    
    console.log("Parsed", drives.length, "drives");
}
