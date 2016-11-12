#!/bin/sh
echo "Service start"
/bin/bash /usr/local/bin/magento2-start.sh &
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf


