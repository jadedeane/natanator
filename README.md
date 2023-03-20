# natanator
UniFi OS persistent NAT modification service

# Background

If you're like me, you'd like a way to persistently modify low-level UniFi OS networking. In my case, that's disabling IPv4 NAT, as UniFi provides no standard supported means to do this, and I have a northbound pfSense router/firewall.

tl;dr, double NAT bad.

Starting with UniFi OS 2.4.23, systemd is introduced. This allows the use of a simple service to disable NAT.

The following service examples use [UniFi OS 3.0.19](https://community.ui.com/releases/UniFi-OS-Dream-Machines-3-0-19/aae685bb-4b96-4016-9125-29e57d7f2844), on a UDM Pro (non-SE).

# Alternatives

Until recently, you could use [unifios-utilities](https://github.com/unifi-utilities/unifios-utilities) on UniFi OS 1.x releases, with a simple [boot script](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script). This is no longer possible, as chronicled [here](https://github.com/unifi-utilities/unifios-utilities/issues/416).

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
systemctl daemon-reload
systemctl enable natanator.service
systemctl start natanator.service
```

The service disabling NAT is now persistent.

```
root@udm:~# systemctl status natanator.service
● natanator.service - Natanator
     Loaded: loaded (/etc/systemd/system/natanator.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2023-03-20 10:56:35 PDT; 5s ago
   Main PID: 39805 (natanator.sh)
      Tasks: 2 (limit: 4725)
     Memory: 460.0K
        CPU: 5ms
     CGroup: /system.slice/natanator.service
             ├─39805 /bin/sh /usr/local/bin/natanator.sh
             └─39814 sleep 60

Mar 20 10:56:35 udm systemd[1]: Started Natanator.

root@udm:~# iptables -t nat -L POSTROUTING
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
```

Reboot and validate persistance.
