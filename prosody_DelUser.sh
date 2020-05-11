#/bin/bash
if [ -n $1 ];then
        DNS_DOMAIN=$1
fi
echo "===============Initialize Prosody==============="
echo "Create Admin User "
echo -n "Id=>" && read username
echo -n "Pw=>" && read password
if [ -z $1 ];then
        echo -n "Domain=>" && read DNS_DOMAIN
else
        echo -n "Domain=>$DNS_DOMAIN"
fi

prosody_cid=`docker ps | grep prosody | cut -d " " -f 1`
if [ ${prosody_cid} ];then
        echo ""
        echo "prosody_cid=>${prosody_cid}"
        command="docker exec -it ${prosody_cid} prosodyctl --config /config/prosody.cfg.lua register ${username} ${DNS_DOMAIN} ${password}"

        echo "$command"
        $command
        echo "============================================="
else
        echo "prosody container id was not detected"
        echo "try again in machine where running prosody"
        exit 1
fi

root@ip-172-31-43-20:~/docker-jitsi-meet#
root@ip-172-31-43-20:~/docker-jitsi-meet#
root@ip-172-31-43-20:~/docker-jitsi-meet# cat prosody_DelUser.sh
if [ -n $1 ];then
        DNS_DOMAIN=$1
fi
echo "===============Initialize Prosody==============="
echo "Remove Admin User "
echo "User List Check"
echo -n "Id=>" && read username
if [ -z $1 ];then
        echo -n "Domain=>" && read DNS_DOMAIN
else
        echo -n "Domain=>$DNS_DOMAIN"
fi

prosody_cid=`docker ps | grep prosody | cut -d " " -f 1`
if [ ${prosody_cid} ];then
        echo ""

        echo "prosody_cid=>${prosody_cid}"
        command="docker exec -it ${prosody_cid} prosodyctl --config /config/prosody.cfg.lua unregister ${username} ${DNS_DOMAIN}"

        echo "============================================="
else
        echo "prosody container id was not detected"
        echo "try again in machine where running prosody"
        exit 1
fi
