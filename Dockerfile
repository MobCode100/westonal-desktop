FROM alpine:latest

RUN apk add --no-cache weston weston-backend-rdp sudo freerdp weston-shell-desktop weston-terminal font-noto
RUN sed -i "/^# %wheel ALL=(ALL:ALL) ALL$/s/#//" /etc/sudoers

ARG USER=rdp
ARG PASS=secure_123

RUN adduser $USER -D -G wheel
RUN echo "$USER:$PASS" | chpasswd

RUN su -c "winpr-makecert -rdp -path /home/$USER/.rdpcfg rdp" $USER
# Package is only used for generating rdp cert
RUN apk del --purge --no-cache freerdp

USER $USER
RUN mkdir /tmp/.xdg
RUN chmod 700 /tmp/.xdg
ENV XDG_RUNTIME_DIR=/tmp/.xdg

WORKDIR /home/$USER

CMD weston --backend=rdp-backend.so --rdp-tls-cert=/.rdpcfg/rdp.crt --rdp-tls-key=/.rdpcfg/rdp.key --socket=wayland-0