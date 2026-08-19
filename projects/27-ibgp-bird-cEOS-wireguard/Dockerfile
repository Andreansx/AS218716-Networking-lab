FROM alpine:3.22
RUN apk add --no-cache wireguard-tools bird iproute2 tcpdump mtr bind-tools iputils-tracepath iputils-ping
RUN mkdir -p /run/bird
CMD ["sleep", "infinity"]
