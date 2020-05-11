#!/bin/bash

echo "DNS FQDN for server :: dev.eightstudio.net"
echo -n ">>"
read DNS_DOMAIN
echo ""
check=`grep "VirtualHost \"guest.*" .jitsi-meet-cfg/prosody/conf.d/jitsi-meet.cfg.lua`
if [ -n check ];then
        cp .jitsi-meet-cfg/prosody/conf.d/jitsi-meet.cfg.lua .jitsi-meet-cfg/prosody/conf.d/jitsi-meet.cfg.lua.bak
        echo "
VirtualHost \"guest.${DNS_DOMAIN}\"
    authentication = \"anonymous\"
    c2s_require_encryption = false
        " >> .jitsi-meet-cfg/prosody/conf.d/jitsi-meet.cfg.lua

        sed -i "s/\/\/ anonymousdomain.*/anonymousdomain: 'guest.${DNS_DOMAIN}',/" .jitsi-meet-cfg/web/config.js

        echo ""
        echo ""
        sh prosody_AddUser.sh ${DNS_DOMAIN}
fi
