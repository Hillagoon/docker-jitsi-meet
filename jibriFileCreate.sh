#!/bin/bash/
JIBRI_FOLDER=docker-jitsi-jibri
username=""

rm -rf ../$JIBRI_FOLDER
mkdir ../$JIBRI_FOLDER
cp -r base ../$JIBRI_FOLDER
cp -r base-java ../$JIBRI_FOLDER
cp -r docker-compose.yml ../$JIBRI_FOLDER
cp -r jibri ../$JIBRI_FOLDER
cp -r .env ../$JIBRI_FOLDER

cp Makefile ../$JIBRI_FOLDER

cd ../$JIBRI_FOLDER
mkdir -p ./.jitsi-meet-cfg/jibri
cp Makefile Makefile.bak
cat Makefile.bak | sed 's/JITSI_SERVICES .*/JITSI_SERVICES \?= base base-java jibri/'  > Makefile
rm Makefile.bak


ls -la


echo "version: '3'

services:
    jibri:
        image: jitsi/jibri
        restart: \${RESTART_POLICY}
        volumes:
            - \${CONFIG}/jibri:/config
            - /dev/shm:/dev/shm
        cap_add:
            - SYS_ADMIN
            - NET_BIND_SERVICE
        devices:
            - /dev/snd:/dev/snd
        environment:
            - XMPP_AUTH_DOMAIN
            - XMPP_INTERNAL_MUC_DOMAIN
            - XMPP_RECORDER_DOMAIN
            - XMPP_SERVER
            - XMPP_DOMAIN
            - JIBRI_XMPP_USER
            - JIBRI_XMPP_PASSWORD
            - JIBRI_BREWERY_MUC
            - JIBRI_RECORDER_USER
            - JIBRI_RECORDER_PASSWORD
            - JIBRI_RECORDING_DIR
            - JIBRI_FINALIZE_RECORDING_SCRIPT_PATH
            - JIBRI_STRIP_DOMAIN_JID
            - JIBRI_LOGS_DIR
            - DISPLAY=:0
            - TZ
            - PUBLIC_URL
            - XMPP_MUC_DOMAIN
        networks:
            meet.jitsi:

# Custom network so all services can communicate using a FQDN
networks:
    meet.jitsi:" > docker-compose.yml

echo ""
echo ""
echo "Creating 'jibriNextStep.sh' ... "
echo ""
echo ""
echo "#!/bin/bash


echo -n \"Did you Created git repogitory that named 'docker-jitsi-jibri'??[y/n]\"
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
echo '
ARG JITSI_REPO=jitsi
FROM \${JITSI_REPO}/base-java

#ARG CHROME_RELEASE=latest
#ARG CHROMEDRIVER_MAJOR_RELEASE=latest
ARG CHROME_RELEASE=78.0.3904.97
ARG CHROMEDRIVER_MAJOR_RELEASE=78

RUN \
        apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y jibri \
        && apt-cleanup

RUN \
        [ "\${CHROME_RELEASE}" = "latest" ] \
        && curl -4s https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
        && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
        && apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y google-chrome-stable \
        && apt-cleanup \
        || true

RUN \
        [ "\${CHROME_RELEASE}" != "latest" ] \
        && curl -4so /tmp/google-chrome-stable_\${CHROME_RELEASE}-1_amd64.deb http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_\${CHROME_RELEASE}-1_amd64.deb \
        && apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y /tmp/google-chrome-stable_\${CHROME_RELEASE}-1_amd64.deb \
        && apt-cleanup \
        || true

RUN \
        [ "\${CHROMEDRIVER_MAJOR_RELEASE}" = "latest" ] \
        && CHROMEDRIVER_RELEASE="\$\(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE\)" \
        || CHROMEDRIVER_RELEASE="\$\(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE_\${CHROMEDRIVER_MAJOR_RELEASE}\)" \
        && curl -4Ls https://chromedriver.storage.googleapis.com/\${CHROMEDRIVER_RELEASE}/chromedriver_linux64.zip \
        | zcat >> /usr/bin/chromedriver \
        && chmod +x /usr/bin/chromedriver \
        && chromedriver --version

RUN \
        apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y jitsi-upload-integrations jq \
        && apt-cleanup

COPY rootfs/ /

VOLUME /config
' > jibri/Dockerfile

echo \"
echo \\\"\\\$XMPP_SERVER   \\\$PUBLIC_URL
\\\$XMPP_SERVER   \\\$XMPP_AUTH_DOMAIN
\\\$XMPP_SERVER   \\\$XMPP_MUC_DOMAIN\\\" >> /etc/hosts
\" >> jibri/rootfs/etc/cont-init.d/10-config
echo ''
echo ''


echo "Creating 'jibriRun' ... "
echo \"#!/bin/bash
start_cmd='docker-compose up -d --scale jibri=3'
restart_cmd='docker-compose restart'
\\\$start_cmd
for i in 1 2 3
do
    jibri_cid=\\\`docker ps | grep jibri_\\\$i | cut -d \\\" \\\" -f 1\\\`
    command=\\\"docker exec -it \\\${jibri_cid} sed -i \\\"s/Loopback/\\\`expr \\\${i} - 1\\\`/g\\\" /home/jibri/.asoundrc\\\"

    \\\$command
done
\\\$restart_cmd
echo \" > jibriRun.sh
chmod +x jibriRun.sh
echo ''
echo ''
echo 'go next step for git upload'
echo -n \"Input Git Admin Username : \"
read username
echo \"
        git init
        git remote add docker-jitsi-jibri https://github.com/\$username/docker-jitsi-jibri
        git add .
        git add .jitsi-meet-cfg
        git add .env
        git commit -m \\\"JIBRI from docker-jitsi-meet ... Welcome\\\"
        git push docker-jitsi-jibri master
        git remote remove docker-jitsi-jibri
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

" > ../$JIBRI_FOLDER/jibriNextStep.sh

chmod +x ../$JIBRI_FOLDER/jibriNextStep.sh


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
        git commit -m \"JIBRI Component has been Move to https://github.com/$username/docker-jitsi-jibri\"
        git push docker-jitsi-meet master
        git remote remove docker-jitsi-meet
"

