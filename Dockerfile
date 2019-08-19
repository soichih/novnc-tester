#FROM nvidia/cuda:9.0-cudnn7-runtime-ubuntu16.04
FROM nvidia/cuda:10.1-runtime-ubuntu18.04 

EXPOSE 5900
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y vim mesa-utils tightvncserver xfce4* gnome-icon-theme tango-icon-theme
RUN apt-get remove -y xfce4-panel

ADD virtualgl_2.6.2_amd64.deb /
RUN dpkg -i /virtualgl_2.6.2_amd64.deb

RUN useradd -ms /bin/bash brainlife

ADD startvnc.sh /

ENV USER=brainlife X11VNC_PASSWORD=override

USER brainlife

RUN mkdir -p /home/brainlife/.vnc
RUN touch /home/brainlife/.Xresources
ADD xstartup /home/brainlife/.vnc/xstartup

CMD ["/startvnc.sh"]

