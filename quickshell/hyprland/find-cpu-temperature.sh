#!/usr/bin/env bash

# Find a stable CPU package temperature input without relying on the hwmon
# number, which may change between boots. This runs once when Quickshell starts.

shopt -s nullglob

for wanted_label in "Package id 0" "Tctl" "CPU Temperature" "Tdie"; do
    for label_file in /sys/class/hwmon/hwmon*/temp*_label; do
        IFS= read -r sensor_label < "$label_file" || continue
        if [[ $sensor_label == "$wanted_label" ]]; then
            input_file=${label_file%_label}_input
            if [[ -r $input_file ]]; then
                printf '%s\n' "$input_file"
                exit 0
            fi
        fi
    done
done

# Fallback for drivers whose package input has no label.
for hwmon in /sys/class/hwmon/hwmon*; do
    [[ -r $hwmon/name && -r $hwmon/temp1_input ]] || continue
    IFS= read -r driver_name < "$hwmon/name" || continue
    case $driver_name in
        coretemp|k10temp|zenpower)
            printf '%s\n' "$hwmon/temp1_input"
            exit 0
            ;;
    esac
done

exit 1
