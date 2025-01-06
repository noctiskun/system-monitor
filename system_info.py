import platform
import psutil
import wmi
import screeninfo
from typing import Dict, List
import GPUtil
import json
from win32api import EnumDisplayDevices, EnumDisplaySettings, GetVersionEx
from win32con import ENUM_CURRENT_SETTINGS

def get_windows_version():
    try:
        w = wmi.WMI()
        os_info = w.Win32_OperatingSystem()[0]
        return os_info.Caption    # This will return something like "Microsoft Windows 11 Pro"
    except:
        return platform.version()  # Fallback to platform.version()

def get_refresh_rates_win32():
    refresh_rates = {}
    try:
        i = 0
        while True:
            device = EnumDisplayDevices(None, i)
            if not device:
                break
            
            settings = EnumDisplaySettings(device.DeviceName, ENUM_CURRENT_SETTINGS)
            if settings:
                refresh_rates[device.DeviceName] = {
                    'refresh_rate': getattr(settings, 'DisplayFrequency', None),
                    'device_name': device.DeviceString
                }
            i += 1
    except Exception:
        pass
    return refresh_rates

def get_system_info() -> Dict:
    info = {
        "system": {
            "os": platform.system(),
            "os_version": get_windows_version() if platform.system() == "Windows" else platform.version(),
            "machine": platform.machine(),
            "processor": platform.processor(),
        },
        "cpu": {
            "physical_cores": psutil.cpu_count(logical=False),
            "total_cores": psutil.cpu_count(logical=True),
            "max_frequency": psutil.cpu_freq().max if psutil.cpu_freq() else None,
        },
        "memory": {
            "total": round(psutil.virtual_memory().total / (1024**3), 2),  # GB
            "available": round(psutil.virtual_memory().available / (1024**3), 2),  # GB
        },
        "displays": [],
        "gpu": []
    }

    # Get refresh rates using Win32 API
    if platform.system() == 'Windows':
        refresh_rates = get_refresh_rates_win32()
    
    # Get display information using screeninfo
    try:
        monitors = screeninfo.get_monitors()
        for monitor in monitors:
            display_info = {
                "name": monitor.name,
                "resolution": f"{monitor.width}x{monitor.height}",
                "position": f"({monitor.x}, {monitor.y})",
                "is_primary": monitor.is_primary,
            }
            
            # Add refresh rate from Win32 API if available
            if platform.system() == 'Windows' and monitor.name in refresh_rates:
                display_info["refresh_rate"] = f"{refresh_rates[monitor.name]['refresh_rate']}Hz"
                display_info["device_name"] = refresh_rates[monitor.name]['device_name']
                
            info["displays"].append(display_info)
    except Exception as e:
        info["displays"].append({"error": str(e)})

    # Get GPU information using both GPUtil and WMI for redundancy
    try:
        # Using GPUtil
        gpus = GPUtil.getGPUs()
        for gpu in gpus:
            gpu_info = {
                "name": gpu.name,
                "driver_version": gpu.driver,
                "memory_total": f"{gpu.memoryTotal}MB",
                "memory_used": f"{gpu.memoryUsed}MB",
                "memory_free": f"{gpu.memoryFree}MB",
                "temperature": f"{gpu.temperature}°C"
            }
            info["gpu"].append(gpu_info)
        
        # Using WMI as backup and for additional GPUs
        if platform.system() == 'Windows':
            w = wmi.WMI()
            wmi_gpus = w.Win32_VideoController()
            
            # Check if we found any GPUs not detected by GPUtil
            existing_gpu_names = {gpu["name"] for gpu in info["gpu"]}
            for wmi_gpu in wmi_gpus:
                if wmi_gpu.Name not in existing_gpu_names:
                    gpu_info = {
                        "name": wmi_gpu.Name,
                        "driver_version": wmi_gpu.DriverVersion if hasattr(wmi_gpu, 'DriverVersion') else "Unknown",
                        "memory_total": f"{round(int(wmi_gpu.AdapterRAM)/1024/1024)}MB" if hasattr(wmi_gpu, 'AdapterRAM') else "Unknown",
                        "note": "Detected via WMI"
                    }
                    info["gpu"].append(gpu_info)
                    
    except Exception as e:
        info["gpu"].append({"error": str(e)})

    # Additional Windows-specific display information using WMI
    if platform.system() == 'Windows':
        try:
            w = wmi.WMI()
            for video_controller in w.Win32_VideoController():
                if video_controller.CurrentRefreshRate:
                    info["displays"].append({
                        "name": video_controller.Name,
                        "current_refresh_rate": f"{video_controller.CurrentRefreshRate}Hz",
                        "max_refresh_rate": f"{video_controller.MaxRefreshRate}Hz" if video_controller.MaxRefreshRate else None,
                        "current_resolution": f"{video_controller.CurrentHorizontalResolution}x{video_controller.CurrentVerticalResolution}" if video_controller.CurrentHorizontalResolution else None
                    })
        except Exception as e:
            info["displays"].append({"wmi_error": str(e)})

    return info

def main():
    try:
        system_info = get_system_info()
        print(json.dumps(system_info, indent=2))
    except Exception as e:
        print(f"Error collecting system information: {str(e)}")

if __name__ == "__main__":
    main()