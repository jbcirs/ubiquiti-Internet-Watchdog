# Ubiquiti Internet Watchdog
Ubiquiti Bash script to monitor internet connection and auto reset device or reboot.

## Setup Ubiquiti Device

```Bash
configure
set system package repository stretch components 'main contrib non-free'
set system package repository stretch distribution stretch
set system package repository stretch url http://http.us.debian.org/debian

commit ; save

sudo apt-get update

sudo apt install nano
```

## Setup Internet Watchdog

Add InternetWatchdog to `/config/scripts/InternetWatchdog.sh`

```Bash
cd /config/scripts/
chmod +x InternetWatchdog.sh
```

Next go to `rc.local` to add it to run after startup

```Bash
sudo nano /etc/rc.local
```

Add the following to rc.local

```Bash
sudo /config/scripts/InternetWatchdog.sh
```
