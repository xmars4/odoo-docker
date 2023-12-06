#!/bin/bash

odoo_version_code="16.0"
file_name="odoo_${odoo_version_code}.latest_amd64.changes"
url="https://nightly.odoo.com/${odoo_version_code}/nightly/deb/${file_name}"
curl -O $url

start_line_content="Checksums-Sha1:"

line_number=$(grep -n "$start_line_content" "$file_name" | awk -F ':' '{print $1}')
latest_release_info_line_number=$(($line_number + 3))
latest_release_info=$(sed -n "${latest_release_info_line_number}p" "$file_name")
latest_release_info=$(echo "$latest_release_info" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
words=($latest_release_info)

release_checksum=${words[0]}
release_date=$(echo ${words[2]} | grep -o "[0-9]\{8\}")
