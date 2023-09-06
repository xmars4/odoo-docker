#!/bin/bash
echo -e "Install logrotate"
sudo apt-get install -y logrotate

ODOO_LOG_PATH=$(readlink -f ../logs)

cat <<EOF > /etc/logrotate.d/odoo
$ODOO_LOG_PATH/*.log {
        daily
        rotate 10
        compress
        delaycompress
        missingok
        notifempty
        create 640 odoo odoo
}
EOF