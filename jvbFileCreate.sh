#!/bin/bash/

JVB_FOLDER=docker-jitsi-jvb
username=""

echo "version: '3'

services:
    # Frontend
    web:
        image: jitsi/web
        restart: \${RESTART_POLICY}
        ports:
            - '\${HTTP_PORT}:80'
            - '\${HTTPS_PORT}:443'
        volumes:
            - \${CONFIG}/web:/config
            - \${CONFIG}/web/letsencrypt:/etc/letsencrypt
            - \${CONFIG}/transcripts:/usr/share/jitsi-meet
        environment:
            - ENABLE_AUTH
            - ENABLE_GUESTS
            - ENABLE_LETSENCRYPT
            - ENABLE_HTTP_REDIRECT
            - ENABLE_TRANSCRIPTIONS
            - DISABLE_HTTPS
            - JICOFO_AUTH_USER
            - LETSENCRYPT_DOMAIN
            - LETSENCRYPT_EMAIL
            - PUBLIC_URL
            - XMPP_DOMAIN
            - XMPP_AUTH_DOMAIN
            - XMPP_BOSH_URL_BASE
            - XMPP_GUEST_DOMAIN
            - XMPP_MUC_DOMAIN
            - XMPP_RECORDER_DOMAIN
            - ETHERPAD_URL_BASE
            - TZ
            - JIBRI_BREWERY_MUC
            - JIBRI_PENDING_TIMEOUT
            - JIBRI_XMPP_USER
            - JIBRI_XMPP_PASSWORD
            - JIBRI_RECORDER_USER
            - JIBRI_RECORDER_PASSWORD
            - ENABLE_RECORDING
        networks:
            meet.jitsi:
                aliases:
                    - \${XMPP_DOMAIN}

    # XMPP server
    prosody:
        image: jitsi/prosody
        restart: \${RESTART_POLICY}
        ports:
            - '5222:5222'
            - '5347:5347'
            - '5280:5280'
        volumes:
            - \${CONFIG}/prosody:/config
        environment:
            - AUTH_TYPE
            - ENABLE_AUTH
            - ENABLE_GUESTS
            - GLOBAL_MODULES
            - GLOBAL_CONFIG
            - LDAP_URL
            - LDAP_BASE
            - LDAP_BINDDN
            - LDAP_BINDPW
            - LDAP_FILTER
            - LDAP_AUTH_METHOD
            - LDAP_VERSION
            - LDAP_USE_TLS
            - LDAP_TLS_CIPHERS
            - LDAP_TLS_CHECK_PEER
            - LDAP_TLS_CACERT_FILE
            - LDAP_TLS_CACERT_DIR
            - LDAP_START_TLS
            - XMPP_DOMAIN
            - XMPP_AUTH_DOMAIN
            - XMPP_GUEST_DOMAIN
            - XMPP_MUC_DOMAIN
            - XMPP_INTERNAL_MUC_DOMAIN
            - XMPP_MODULES
            - XMPP_MUC_MODULES
            - XMPP_INTERNAL_MUC_MODULES
            - XMPP_RECORDER_DOMAIN
            - JICOFO_COMPONENT_SECRET
            - JICOFO_AUTH_USER
            - JICOFO_AUTH_PASSWORD
            - JVB_AUTH_USER
            - JVB_AUTH_PASSWORD
            - JIGASI_XMPP_USER
            - JIGASI_XMPP_PASSWORD
            - JIBRI_XMPP_USER
            - JIBRI_XMPP_PASSWORD
            - JIBRI_RECORDER_USER
            - JIBRI_RECORDER_PASSWORD
            - JWT_APP_ID
            - JWT_APP_SECRET
            - JWT_ACCEPTED_ISSUERS
            - JWT_ACCEPTED_AUDIENCES
            - JWT_ASAP_KEYSERVER
            - JWT_ALLOW_EMPTY
            - JWT_AUTH_TYPE
            - JWT_TOKEN_AUTH_MODULE
            - LOG_LEVEL
            - TZ
        networks:
            meet.jitsi:
                aliases:
                    - \${XMPP_SERVER}

    # Focus component
    jicofo:
        image: jitsi/jicofo
        restart: \${RESTART_POLICY}
        volumes:
            - \${CONFIG}/jicofo:/config
        environment:
            - ENABLE_AUTH
            - XMPP_DOMAIN
            - XMPP_AUTH_DOMAIN
            - XMPP_INTERNAL_MUC_DOMAIN
            - XMPP_SERVER
            - JICOFO_COMPONENT_SECRET
            - JICOFO_AUTH_USER
            - JICOFO_AUTH_PASSWORD
            - JICOFO_RESERVATION_REST_BASE_URL
            - JVB_BREWERY_MUC
            - JIGASI_BREWERY_MUC
            - JIGASI_SIP_URI
            - JIBRI_BREWERY_MUC
            - JIBRI_PENDING_TIMEOUT
            - TZ
        depends_on:
            - prosody
        networks:
            meet.jitsi:

# Custom network so all services can communicate using a FQDN
networks:
    meet.jitsi:" > docker-compose.yml

echo "DNS FQDN for server :: dev.eightstudio.net"
echo -n ">>"
read DNS_DOMAIN
echo ""

echo "HTTP Port ? "
echo -n ">>"
read HTTP_PORT
echo ""


echo "HTTPS Port ? "
echo -n ">>"
read HTTPS_PORT
echo ""

rm -rf ../$JVB_FOLDER
rm -rf ./.jitsi-meet-cfg/
cp env.example .env
cp .env .env.tmp
cat .env.tmp | sed 's/CONFIG=.*/CONFIG=\.\/\.jitsi-meet-cfg/' | sed -e "s/HTTP_PORT=.*/HTTP_PORT=$HTTP_PORT/g" -e "s/HTTPS_PORT=.*/HTTPS_PORT=$HTTPS_PORT/g" -e "s/TZ=.*/TZ=Asia\/Seoul/g" -e "s/#ENABLE_HTTP_REDIRECT=.*/ENABLE_HTTP_REDIRECT=1/g" -e "s/#PUBLIC_URL=.*/PUBLIC_URL=$DNS_DOMAIN/g" -e "s/meet.jitsi/$DNS_DOMAIN/g" -e "s/#ENABLE_AUTH=.*/ENABLE_AUTH=1/g" > .env
rm .env.tmp
./gen-passwords.sh
mkdir -p ./.jitsi-meet-cfg/web
mkdir -p ./.jitsi-meet-cfg/letsencrypt
mkdir -p ./.jitsi-meet-cfg/transcripts
mkdir -p ./.jitsi-meet-cfg/prosody
mkdir -p ./.jitsi-meet-cfg/jicofo
mkdir -p ./.jitsi-meet-cfg/jigasi


mkdir ../$JVB_FOLDER
cp -r base ../$JVB_FOLDER
cp -r base-java ../$JVB_FOLDER
cp -r docker-compose.yml ../$JVB_FOLDER
cp -r jvb ../$JVB_FOLDER
cp -r .env ../$JVB_FOLDER

cp Makefile Makefile.bak
cp Makefile ../$JVB_FOLDER
cat Makefile.bak | sed 's/ jvb//' | sed 's/ jibri//' | sed 's/ etherpad//' > Makefile
rm Makefile.bak

cd ../$JVB_FOLDER
mkdir -p ./.jitsi-meet-cfg/jvb
cp Makefile Makefile.bak
cat Makefile.bak | sed 's/web prosody jicofo //' | sed 's/jigasi etherpad jibri/jvb/' | sed 's/.*docker pull etherpad.*//' > Makefile
rm Makefile.bak


ls -la

echo "
version: '3'
services:
    # Video bridge
    jvb:
        image: jitsi/jvb
        ports:
            - '\${JVB_PORT}:\${JVB_PORT}/udp'
            - '\${JVB_TCP_PORT}:\${JVB_TCP_PORT}'
        volumes:
            - \${CONFIG}/jvb:/config
        environment:
            - DOCKER_HOST_ADDRESS
            - XMPP_AUTH_DOMAIN
            - XMPP_INTERNAL_MUC_DOMAIN
            - XMPP_SERVER
            - JVB_AUTH_USER
            - JVB_AUTH_PASSWORD
            - JVB_BREWERY_MUC
            - JVB_PORT
            - JVB_TCP_HARVESTER_DISABLED
            - JVB_TCP_PORT
            - JVB_STUN_SERVERS
            - JVB_ENABLE_APIS
            - TZ
            - PUBLIC_URL
            - XMPP_AUTH_DOMAIN
            - XMPP_MUC_DOMAIN
        networks:
            meet.jitsi:

# Custom network so all services can communicate using a FQDN
networks:
    meet.jitsi:
" > docker-compose.yml


echo ""
echo ""
echo "Creating 'jvbNextStep.sh' ... "
echo ""
echo ""
echo "#!/bin/bash


echo -n \"Did you Created git repogitory that named 'docker-jitsi-jvb'??[y/n]\"
read answer
if [ \"\$answer\" = \"n\"  ]
then
        echo \"try again after Created repogitory\"
        exit 1
fi

echo 'jitsi/web Server IP :: check IP'
echo 'try this >> ifconfig | grep -A 3 -e ^eth -e ^ens | grep "inet "'
echo 'IP Address ?'
echo -n '>> '
read IPAddr

cp .env .env.tmp
cat .env.tmp | sed \"s/XMPP_SERVER=.*/XMPP_SERVER=\$IPAddr/\" > .env
rm -rf .env.tmp

echo ''
echo \"

echo \\\"\\\$XMPP_SERVER   \\\$PUBLIC_URL
\\\$XMPP_SERVER   \\\$XMPP_AUTH_DOMAIN
\\\$XMPP_SERVER   \\\$XMPP_MUC_DOMAIN\\\" >> /etc/hosts
\" >> jvb/rootfs/etc/cont-init.d/10-config

echo \"
echo \\\"org.jitsi.videobridge.TRUST_BWE=true\\\">> /config/sip-communicator.properties
\" >> jvb/rootfs/etc/cont-init.d/10-config


echo ''
echo ''
echo ''
echo ''
echo 'go next step for git upload'
echo -n \"Input Git Admin Username : \"
read username
echo \"
        git init
        git remote add docker-jitsi-jvb https://github.com/\$username/docker-jitsi-jvb
        git add .
        git add .jitsi-meet-cfg
        git add .env
        git commit -m \\\"JVB from docker-jitsi-meet ... Welcome\\\"
        git push docker-jitsi-jvb master
        git remote remove docker-jitsi-jvb
\"

echo ''
echo ''
echo ''
echo ''
echo ''
echo \"try next step is build docker images -> try 'make' command\"
echo \"you must try it PC where you wanna install with created Files\"
echo ''
echo ''
echo ''
echo ''
echo ''
echo ''
echo ''

" > ../$JVB_FOLDER/jvbNextStep.sh

chmod +x ../$JVB_FOLDER/jvbNextStep.sh


echo ""
echo ""
echo "JVB Docker Makefile has been created, "
echo ""
echo ""
echo ""
echo ""
echo "go next step for git upload"
echo "Creating git upload command"
echo -n "Input Git Admin Username : "
read username
echo "
        git init
        git remote add docker-jitsi-meet https://github.com/$username/docker-jitsi-meet
        git add .
        git add .jitsi-meet-cfg
        git commit -m \"JVB Component has been Move to https://github.com/$username/docker-jitsi-jvb\"
        git push docker-jitsi-meet master
        git remote remove docker-jitsi-meet
"

