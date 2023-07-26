# Automated Enum

This tool automates the enumeration part of a penetration assessment for pentesters. In short, it takes a Network ID from the user and find alive hosts in that network using `fping`. Gathers NETBIOS names of IPs with SMB ports open using `crackmapexec` and checks Null Session logins to them using `rpcclient`. Finally scans all the ports of all alive hosts and then do a detailed version, safe scripts and operating system scan using `nmap`.

## Installation

You can clone this git repository:

```bash
git clone https://github.com/bera-neser/Automated-Enum.git
cd Automated-Enum
```

Or just get the script file:

```bash
wget https://raw.githubusercontent.com/bera-neser/Automated-Enum/main/automated_enum.sh
```

## Usage

After giving execute permission to script, you must run it as superuser.

```bash
chmod u+x automated_enum.sh
sudo ./automated_enum.sh
$ Please enter the network ID (e.g. 192.168.0.0/24): 192.168.1.0/24
$ Using fping to find alive hosts...
$ ...
$ Scan done.
```

After it finishes, you will find a folder named with the Network ID that you entered contains all the outputs.

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

## License

[MIT](https://github.com/bera-neser/Automated-Enum/blob/main/LICENSE)
