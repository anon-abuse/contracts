#!/bin/bash

# Input string (in your case, a hash or any other string)
input_string="$1"

# Check if the input string is provided and its length is at least 40 characters
if [ -z "$input_string" ] || [ ${#input_string} -lt 40 ]; then
    echo "Error: Please provide a string of at least 40 characters."
    exit 1
fi

# Extract the last 40 characters
last_40_characters=${input_string: -40}

# Output the last 40 characters
echo $last_40_characters
