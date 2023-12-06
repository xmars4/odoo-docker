#!/bin/bash

function get_latest_release_info {
    file_name="odoo_${odoo_version_code}.latest_amd64.changes"
    url="https://nightly.odoo.com/${odoo_version_code}/nightly/deb/${file_name}"
    curl -O $url

    start_line_content="Checksums-Sha1:"
    line_number=$(grep -n "$start_line_content" "$file_name" | awk -F ':' '{print $1}')
    latest_release_info_line_number=$(($line_number + 3))
    latest_release_info=$(sed -n "${latest_release_info_line_number}p" "$file_name")
    latest_release_info=$(echo "$latest_release_info" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    words=($latest_release_info)

    declare -g release_checksum=${words[0]}
    declare -g release_date=$(echo ${words[2]} | grep -o "[0-9]\{8\}")
}

function update_latest_release_to_dockerfile {
    sed -i "s/^\s*ARG ODOO_RELEASE\s*.*/ARG ODOO_RELEASE=${release_date}/g" $docker_file_path
    sed -i "s/^\s*ARG ODOO_SHA\s*.*/ARG ODOO_SHA=${release_checksum}/g" $docker_file_path
}

odoo_version_code=$1
docker_file_path=$2
get_latest_release_info
update_latest_release_to_dockerfile
