#!/bin/bash/

cp ./.jitsi-meet-cfg/web/config.js ./.jitsi-meet-cfg/web/config.js.origin && cp ./.jitsi-meet-cfg/web/config.js ./.jitsi-meet-cfg/web/config.js.tmp
cat ./.jitsi-meet-cfg/web/config.js.tmp | sed \
's/        enabled:.*/        enabled: false,/' > ./.jitsi-meet-cfg/web/config.js && cp ./.jitsi-meet-cfg/web/config.js ./.jitsi-meet-cfg/web/config.js.tmp
cat ./.jitsi-meet-cfg/web/config.js.tmp | sed \
's/    \/\/ resolution: .*/\
    resolution: 1080,\
    constraints: {\
        video: {\
            aspectRatio: 16 \/ 9,\
            height: {\
                ideal: 1080,\
                max: 1080,\
                min: 240\
            }\
        }\
    },/' > ./.jitsi-meet-cfg/web/config.js && cp ./.jitsi-meet-cfg/web/config.js ./.jitsi-meet-cfg/web/config.js.tmp
cat ./.jitsi-meet-cfg/web/config.js.tmp | sed \
's/    \/\/ desktopSharingFrameRate/\
    desktopSharingFrameRate: {\
        min: 60,\
        max: 60\
    },\
    \/\/ desktopSharingFrameRate/' | sed \
's/    \/\/ fileRecordingsServiceEnabled: .*/    fileRecordingsServiceEnabled: true,/' | sed \
's/    \/\/ fileRecordingsServiceSharingEnabled: .*/    fileRecordingsServiceSharingEnabled: true,/' | sed \
's/    \/\/ fileRecordingsEnabled: .*/    fileRecordingsEnabled: true,/' | sed \
's/    \/\/ startWithAudioMuted: .*/    startWithAudioMuted: true,/' | sed \
's/    \/\/ startScreenSharing: .*/    startScreenSharing: false,/' | sed \
"s/makeJsonParserHappy: 'even if last key had a trailing comma'/makeJsonParserHappy: 'even if last key had a trailing comma',\n\
    hiddenDomain: 'recorder.meet.jitsi'/" > ./.jitsi-meet-cfg/web/config.js && rm -f ./.jitsi-meet-cfg/web/config.js.tmp

diff ./.jitsi-meet-cfg/web/config.js ./.jitsi-meet-cfg/web/config.js.origin


sed -i "s# 'sharedvideo',# /\*'sharedvideo'\*/,#"
