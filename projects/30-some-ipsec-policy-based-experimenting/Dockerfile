FROM alpine:3.22
RUN apk add --no-cache bird iproute2 iputils tcpdump strongswan openssh && ssh-keygen -A
RUN echo "StrictModes no" >> /etc/ssh/sshd_config
CMD ["sleep", "infinity"]
