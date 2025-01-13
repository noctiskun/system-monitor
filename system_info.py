import tkinter as tk
from tkinter import messagebox
import platform
import psutil
import wmi
import screeninfo
from typing import Dict, List
import GPUtil
import json
from win32api import EnumDisplayDevices, EnumDisplaySettings
from win32con import ENUM_CURRENT_SETTINGS

def get_windows_version():
    try:
        w = wmi.WMI()
        os_info = w.Win32_OperatingSystem()[0]
        return os_info.Caption
    except:
        return platform.version()

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

    if platform.system() == 'Windows':
        refresh_rates = get_refresh_rates_win32()
    
    try:
        monitors = screeninfo.get_monitors()
        for monitor in monitors:
            display_info = {
                "name": monitor.name,
                "resolution": f"{monitor.width}x{monitor.height}",
                "position": f"({monitor.x}, {monitor.y})",
                "is_primary": monitor.is_primary,
            }
            
            if platform.system() == 'Windows' and monitor.name in refresh_rates:
                display_info["refresh_rate"] = f"{refresh_rates[monitor.name]['refresh_rate']}Hz"
                display_info["device_name"] = refresh_rates[monitor.name]['device_name']
                
            info["displays"].append(display_info)
    except Exception as e:
        info["displays"].append({"error": str(e)})

    try:
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
        
        if platform.system() == 'Windows':
            w = wmi.WMI()
            wmi_gpus = w.Win32_VideoController()
            
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
    # Create a simple GUI window
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    try:
        # Show starting message
        messagebox.showinfo("System Info Collector", "Starting to collect system information...")
        
        # Get system information
        system_info = get_system_info()
        
        if system_info:
            # Convert to JSON and copy to clipboard
            json_output = json.dumps(system_info, indent=2)
            root.clipboard_clear()
            root.clipboard_append(json_output)
            
            # Show success message with the information
            messagebox.showinfo("Success", 
                "System information has been collected and copied to clipboard.\n\n" +
                "Please paste this information in the survey."
            )
        else:
            messagebox.showerror("Error", "Failed to collect system information.")
    except Exception as e:
        messagebox.showerror("Error", f"An error occurred: {str(e)}")
    finally:
        root.destroy()

if __name__ == "__main__":
    main()