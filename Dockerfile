FROM golang:alpine AS builder
RUN apk update && apk add --no-cache git
WORKDIR /go/src/xray/core
RUN git clone --progress https://github.com/XTLS/Xray-core.git . && \
    go mod download && \
    CGO_ENABLED=0 go build -o /tmp/xray -trimpath -ldflags "-s -w -buildid=" ./main

#FROM alpine
#COPY --from=builder /tmp/xray /usr/bin

#ADD xray.sh /xray.sh
#RUN chmod +x /xray.sh
#CMD /xray.sh


FROM alpine:edge
COPY --from=builder /tmp/xray /xray

RUN apk update && \
    apk add --no-cache ca-certificates caddy tor wget && \
    #wget -O Xray-linux-64.zip  https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip  && \
    #unzip Xray-linux-64.zip && \
    chmod +x /xray && \
    rm -rf /var/cache/apk/*

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh