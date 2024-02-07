# AutomationScritp_for_Open5GS_Installation-Configuration

Open5GS is a open source implementation for 5G Core and EPC which is widely used for establishing private LTE and 5G network. Automation script for installing and configuring this core in Ubuntu machines has been developed. Basically, two different scripts for Ubuntu 22 and Ubntu 20 have been developed where an user just need to specify the MCC, MNC, TAC and the host machine's IP for complete installation and configuration.

# INSTRUCTION
Follow the below steps for successful installation and configuration of Open5GS core in your ubuntu machine.

**1.** Make a .env file in any directory you prefer. I have choosen /home/ashiq directory.

    nano .env
    
Make the content of .env as below as per your specification.

    MACHINE_IP="192.168.0.252"
    M_C_C="001"
    M_N_C="01"
    T_A_C="1"
**2.** Locate autoOpen5gs_20.sh or autoOpen5gs_22.sh in the previous directory i.e. in the directory of .env file.

Note: autoOpen5gs_20.sh is for Ubuntu 20 machine and autoOpen5gs_22.sh is for Ubuntu 22 machine.

**3.** Give permission and run the script'

***For Ubuntu 20***

    sudo chmod +x autoOpen5gs_20.sh
    sudo ./autoOpen5gs_20.sh

***For Ubuntu 22***

    sudo chmod +x autoOpen5gs_22.sh
    sudo ./autoOpen5gs_22.sh


