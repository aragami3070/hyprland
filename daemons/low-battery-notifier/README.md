# Low battery notifier

Checks the first `BAT*` device every 30 seconds while the user systemd manager is running. On discharge, it notifies at 14, 12, 10, 8, 6, 4, 2 and 0 percent. A reading that skips thresholds produces one notification with the current percentage. State is stored in `${XDG_STATE_HOME:-~/.local/state}/low-battery-notifier/last-threshold` and resets once the battery reaches at least 15 percent.

The full installation (`make all`) activates the timer. To install or re-run only this part, use `make setup-low-battery-notifier` from the repository root. Alternatively, activate it manually:

```sh
systemctl --user link "$HOME/.config/hyprland/daemons/low-battery-notifier/low-battery-notifier.service" "$HOME/.config/hyprland/daemons/low-battery-notifier/low-battery-notifier.timer"
systemctl --user enable --now low-battery-notifier.timer
```

Check it with `systemctl --user status low-battery-notifier.timer` and `journalctl --user -u low-battery-notifier.service`.
