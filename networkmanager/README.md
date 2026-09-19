# SSU DNS dispatcher hook

`dispatcher.d/90-ssu-dns` runs only on NetworkManager events. When a Wi-Fi
connection whose actual SSID starts with `ssu_internet` goes up, gets a new
DHCPv4 lease, or is reapplied, it replaces only the first `nameserver` in
`/etc/resolv.conf` with `8.8.8.8`. Other DNS servers and the `search` line are
left untouched.

There is no resident process, polling loop, or timer. NetworkManager starts its
D-Bus-activated dispatcher only when an event needs to be handled.

Install or update the hook with:

```sh
make setup-ssu-dns
```

To verify the last invocation:

```sh
journalctl -t ssu-dns -n 20
```

To remove it:

```sh
sudo rm /etc/NetworkManager/dispatcher.d/90-ssu-dns
```
