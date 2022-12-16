# natanator
Unifi OS persistent NAT modification service

# Background

If you're like me, you'd like a way to persistently modify low-level Unifi OS networking. In my case, that's disabling IPv4 NAT, as Unifi provides no standard supported means to do this, and I have a northbound pfSense router/firewall.

tl;dr, double NAT bad.

Starting with Unifi OS 2.x, systemd is introduced. This allows the use of a simple service to disable NAT.

The following service examples use [UnifiOS 2.4.23](https://community.ui.com/releases/UniFi-OS-Dream-Machines-2-4-23/aebbba64-9e7e-4151-bcca-34ed08761f08?page=21), on a UDM Pro. Things should translate just fine to future Unifi OS 2.x and eventual 3.x releases, but I don't have a UDM Pro SE that as of this writing [supported Unifi OS 3.0.13](https://community.ui.com/releases/UniFi-OS-Dream-Machine-SE-3-0-13/cf25f68e-6906-4125-9d77-9fce05d6658a).

# Alternatives

Until recently, you could use [unifios-utilities](https://github.com/unifi-utilities/unifios-utilities) on Unifi OS 1.x releases, with a simple [boot script](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script). This is no longer possible, as chronicled [here](https://github.com/unifi-utilities/unifios-utilities/issues/416).

# Solution

Simple [bash script](natanator.sh) that disables NAT, and a systemd [service definition](natanator.service) that runs it.

# Installation

Place the [bash script](natanator.sh) in `/usr/local/bin`, and make it executable:

```
cp <natanator.sh> /usr/local/bin/natanator.sh
chmod +x /usr/local/bin/natanator.sh
```

Place the [service definition file](natanator.service) in ` /etc/systemd/system`, and modify its permissions:

```
cp <natanator.service> /etc/systemd/system/natanator.service
chmod 755 /etc/systemd/system/natanator.service
```
Reload systemd, and enable the service:

```
sudo systemctl daemon-reload
systemctl enable natanator.service
systemctl start natanator.service
```

The service disabling NAT is now persistent.

```
root@udm:~# systemctl status natanator.service
● natanator.service - Natanator
   Loaded: loaded (/etc/systemd/system/natanator.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2022-12-15 14:58:07 PST; 1h 5min ago
 Main PID: 1342 (natanator.sh)
    Tasks: 2 (limit: 4727)
   Memory: 1.1M
      CPU: 304ms
   CGroup: /system.slice/natanator.service
           ├─ 364 sleep 60
           └─1342 /bin/sh /usr/local/bin/natanator.sh

Warning: Journal has been rotated since unit was started. Log output is incomplete or unavailable.

root@udm:~# iptables -t nat -L POSTROUTING
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
ACCEPT     all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere
```

Reboot and validate persistance.
