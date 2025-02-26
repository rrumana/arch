#!/bin/bash

killall waybar && killall swaync
waybar -c ~/.config/waybar/themes/powermixup/config -s ~/.config/waybar/themes/powermixup/style.css &
swaync -c ~/.config/sncup/config.json -s ~/.config/sncup/style.css &
