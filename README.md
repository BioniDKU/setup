# BioniDKU setup
**Highly powerful and flexible PowerShell script bundle** that converts your Windows 10 installation to an **IDKU** with Bionic Butter's standards.

![BioniDKU version 400_stable Main menu](https://github.com/Bionic-OSE/BioniDKU/assets/44027930/2c4d046d-d2f4-487f-b642-fe46dd512180)

## Compatibility
![BioniDKU compatibility sheet](https://github.com/Bionic-OSE/BioniDKU/assets/44027930/b25a4d99-6c4c-4b3f-ad20-ea9f43327f9c)
<sup><sub>**(*)** The incompatibility in this edition is actually a currently known issue in the script and not a limitation. Once it has been addressed it will be just as functional as other editions.</sub></sup>

## Remarks
There are things that must be done first to how "dangerous" this script is to Windows.

**1. Microsoft/Windows Defender MUST be disabled before you hit the Yes button on the confirmation prompt** (the script itself will also notice you about this once again if you forgot).
- **Why is this?** BioniDKU and all of its components are by all means NOT malware. However some tools used to make it possible are often false flagged by AVs because of "signature" problems. Particularly this comes from the launcher executable file and several other components (that will be downloaded along the way) that are made made using **BatToExe**. The good news is an AV-friendly solution is in the works! 
- Anyways, if you are doing this on Windows Server, skip the rest of the steps below, run `dism /online /disable-feature /featurename:Windows-Defender` and restart the device.
- To effectively disable Defender, go to [this link](https://zgc6v-my.sharepoint.com/:f:/g/personal/oseproductions_zgc6v_onmicrosoft_com/EmNJMTmNbrlEpsDCO6HqBv0BtIUaJ9n7IOSx9IhZVLvBTg) and download the **dControl.zip** file (Or you can get one from the internet making sure it isn't a malware). 
- On your target system, in Defender settings turn off Real time protection (and Tamper protection too if it's there).
- Now open the zip file and run **dControl.exe** inside it (no other programs or extraction needed, just double clicking and click "Run" when it asks if you want to better extract it). Password is: `sordum`
- Click **Disable Defender**, restart the device and then you can proceed. 
- Another way for the last step is if you encounter the *"Starting the script is not allowed"* message because you forgot to do this, after clicking disable, just hit Enter with nothing typed in the prompt to refresh the status. The script should then allow you to start and since it will restart the system shortly after, you get 2 problems solved at once! 

**2. A reliable internet connection is required.** If you're on a metered connection, a 1GB plan should work if you don't plan to run Windows Updates on the target system (about more than 400MB will be downloaded in total). You can go offline as soon as the script enters the 3rd phase. 
