#!/bin/bash

docker stop novnc-test
docker rm novnc-test

set -e
set -x

echo "testing host configuration"
docker run --gpus 1 nvidia/cuda nvidia-smi
lspci | grep -i NVIDIA
nvidia-smi | grep Xorg
vglrun glxinfo | grep -i NVIDIA

echo "host looks good.. proceeding"

if [ ! -d lib ]; 
then
	mkdir -p lib
	cp -av /usr/lib/x86_64-linux-gnu/libGL* lib
	cp -av /usr/lib/x86_64-linux-gnu/libEGL* lib
	cp -av /usr/lib/x86_64-linux-gnu/libnvidia* lib
	cp -av /usr/lib/x86_64-linux-gnu/libnvoptix* lib
	cp -r -av /usr/lib/x86_64-linux-gnu/vdpau lib
	#cp -r -av /usr/lib/x86_64-linux-gnu/nvidia*/xorg/* lib
fi

docker build -t novnc-test .

password=$RANDOM.$RANDOM.$RANDOM
echo "password: $password"

id=$(docker run -dP --gpus 1 \
	--name novnc-test \
	-e LD_LIBRARY_PATH=/usr/lib/host \
	-e X11VNC_PASSWORD=$password \
	-v `pwd`/lib:/usr/lib/host:ro \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	novnc-test)
hostport=$(docker port $id | cut -d " " -f 3)
echo "container $id using $hostport"

WEBSOCK_HOSTPORT=0.0.0.0:11050

docker logs -f $id &

echo "------------------------------------------------------------------------"
echo "http://$HOSTNAME:11050/vnc_lite.html?password=$password"
echo "------------------------------------------------------------------------"
/usr/local/noVNC/utils/launch.sh --listen $WEBSOCK_HOSTPORT --vnc $hostport

