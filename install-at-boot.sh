#bin/bash

IFACEINET=${1:-wlan0}
IFACELOCAL=${1:-eth0}

cp share.sh /usr/bin
SERVICEFILE=/lib/systemd/system/share-$IFACEINET-$IFACELOCAL.service
cat > $SERVICEFILE <<EOF
[Unit]
Description=Internet sharing
After=default.target

[Service]
Type=idle
ExecStart=/usr/bin/share.sh $IFACEINET $IFACELOCAL

[Install]
WantedBy=default.target
EOF

chmod 644 $SERVICEFILE
systemctl daemon-reload
systemctl enable share-$IFACEINET-$IFACELOCAL.service
