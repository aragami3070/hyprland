#!/usr/bin/env bash

set -uo pipefail

battery=""
for candidate in /sys/class/power_supply/BAT*; do
    if [[ -d "$candidate" ]]; then
        battery="$candidate"
        break
    fi
done

[[ -n "$battery" ]] || exit 0

read_value() {
    local file="$1"
    local value=""
    if [[ -r "$battery/$file" ]]; then
        IFS= read -r value < "$battery/$file" || true
        printf '%s' "$value"
    fi
}

capacity="$(read_value capacity)"
status="$(read_value status)"
[[ "$capacity" =~ ^[0-9]+$ ]] || exit 0

if [[ "$status" == "Charging" ]]; then
    icon=""
elif (( capacity < 20 )); then
    icon=""
elif (( capacity < 40 )); then
    icon=""
elif (( capacity < 60 )); then
    icon=""
elif (( capacity < 80 )); then
    icon=""
else
    icon=""
fi

printf '%s  %s%%\n' "$icon" "$capacity"

format_duration() {
    local minutes="$1"
    local days=$((minutes / 1440))
    local hours=$(((minutes % 1440) / 60))
    local mins=$((minutes % 60))

    if (( days > 0 )); then
        printf '%d д %d ч' "$days" "$hours"
    elif (( hours > 0 )); then
        printf '%d ч %d мин' "$hours" "$mins"
    else
        printf '%d мин' "$mins"
    fi
}

amount_now="$(read_value energy_now)"
amount_full="$(read_value energy_full)"
rate="$(read_value power_now)"

if [[ ! "$amount_now" =~ ^[0-9]+$ || ! "$amount_full" =~ ^[0-9]+$ || ! "$rate" =~ ^[0-9]+$ ]]; then
    amount_now="$(read_value charge_now)"
    amount_full="$(read_value charge_full)"
    rate="$(read_value current_now)"
fi

case "$status" in
    Full)
        printf 'Батарея полностью заряжена\n'
        ;;
    Discharging)
        if [[ "$amount_now" =~ ^[0-9]+$ && "$rate" =~ ^[0-9]+$ ]] && (( rate > 0 )); then
            minutes=$(((amount_now * 60 + rate / 2) / rate))
            printf 'Осталось примерно %s\n' "$(format_duration "$minutes")"
        else
            printf 'Оставшееся время пока неизвестно\n'
        fi
        ;;
    Charging)
        if [[ "$amount_now" =~ ^[0-9]+$ && "$amount_full" =~ ^[0-9]+$ && "$rate" =~ ^[0-9]+$ ]] && (( rate > 0 )); then
            remaining=$((amount_full > amount_now ? amount_full - amount_now : 0))
            minutes=$(((remaining * 60 + rate / 2) / rate))
            printf 'До полного заряда примерно %s\n' "$(format_duration "$minutes")"
        else
            printf 'Время до полного заряда пока неизвестно\n'
        fi
        ;;
    *)
        printf 'Состояние: %s\n' "${status:-неизвестно}"
        ;;
esac
