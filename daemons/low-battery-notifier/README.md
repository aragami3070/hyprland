# Low battery notifier

Quickshell subscribes to UPower over D-Bus and starts the oneshot service only
when the battery percentage or charging state changes. There is no polling
timer and no additional resident process.

On discharge, the checker notifies at 14, 12, 10, 8, 6, 4, 2 and 0 percent.
A reading that skips thresholds produces one notification with the current
percentage. State is stored in
`${XDG_STATE_HOME:-~/.local/state}/low-battery-notifier/last-threshold` and
resets once the battery reaches at least 15 percent.

The full installation (`make all`) links the oneshot service and removes the
old timer. To install or migrate only this part, run:

```sh
make setup-low-battery-notifier
```

Restart Quickshell after changing the QML configuration:

```sh
qs -c hyprland kill
quickshell -n -d -c hyprland
```

Check invocations with
`journalctl --user -u low-battery-notifier.service`.
