# System Info Collector: Hardware Configuration Data for Esports Research

![Hardware Info](https://img.shields.io/badge/Hardware-Info-blue)
![Python](https://img.shields.io/badge/Python-3.8+-green)
![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey)
![Status](https://img.shields.io/badge/Status-Active-success)

## 📊 Project Overview

System Info Collector is a lightweight tool that automatically detects and collects hardware configuration data for esports research. Developed for NC State University's study on how hardware configurations impact player preferences and performance across different esports titles. This tool helps survey participants easily share their system specifications with minimal effort.

## 🖥️ What Information is Collected

The tool collects only hardware-related information:

- **System**: Operating system, version
- **CPU**: Model, cores, threads, clock speed
- **Memory**: Total RAM, available memory
- **GPU**: Model, memory capacity, driver version
- **Displays**: Resolution, refresh rate, monitor model for each connected display

**No personal information** is collected. All data is immediately copied to your clipboard and is not transmitted anywhere.

## ⬇️ Download & Usage

### Method 1: Using the Executable (Recommended)

1. **Download**: Get the latest version from the [Releases Page](https://github.com/noctiskun/system-monitor/releases)
2. **Run**: Double-click the `SystemInfoCollector.exe` file
   - Note: You may see a Windows security warning. Click "More info" then "Run anyway"
3. **Complete**: A success message will appear when the data is copied to your clipboard
4. **Submit**: Paste the data into the survey field

### Method 2: Running from Source

If you prefer to run the Python script directly:

1. Clone this repository:
   git clone https://github.com/noctiskun/system-monitor.git
2. Install the required dependencies:
   pip install psutil wmi GPUtil screeninfo pywin32
3. Run the script:
   python system_info.py

## 🛠️ Technologies Used

- **Python**: Core programming language
- **psutil**: System information collection
- **wmi**: Windows Management Instrumentation integration
- **GPUtil**: GPU detection
- **screeninfo**: Display information collection
- **PyInstaller**: Executable creation
- **tkinter**: Simple GUI interface

## 🔒 Privacy & Security

- The application is **completely offline** - no internet connection is used
- All system information is only copied to your local clipboard
- The source code is open and available for inspection
- No data is saved to your computer or sent to any server

## 🧰 For Developers

### Building from Source

To create your own executable:

1. Install PyInstaller:
   pip install pyinstaller
2. Build the executable:
   pyinstaller --onefile --noconsole --name SystemInfoCollector system_info.py
3. Find the executable in the `dist` folder

### Project Structure

- `system_info.py`: Main Python script
- `setup.py`: Setup configuration
- `README.md`: This documentation
- `dist/SystemInfoCollector.exe`: Compiled executable

## 📚 Research Context

This tool was developed to support research at NC State University's esports configuration study (IRB Protocol: 25527). The research aims to understand how players configure their games across different competitive titles and how hardware setups influence these choices.

## 🤝 Contributing

Contributions are welcome! If you'd like to improve the tool:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

For questions or feedback about this tool, please contact me at [Here](ashrajpurohit@gmil.com).
