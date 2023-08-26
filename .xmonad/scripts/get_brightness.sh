#!/bin/bash

# Fetch the current brightness percentage using brightnessctl
brightness_output=$(brightnessctl info)

# Extract the percentage value using grep and awk
brightness_percentage=$(echo "$brightness_output" | grep -oP '\(\K[0-9]+(?=%\))')

# Print the brightness percentage
echo $brightness_percentage

