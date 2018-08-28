FROM golang:1.10-alpine3.8 as builder

# librdkakfa
RUN apk --update --no-cache add git openssh bash g++ make
RUN git clone https://github.com/edenhill/librdkafka.git
WORKDIR ./librdkafka
RUN ./configure --prefix /usr && make && make install

ARG gopath="/go"
ENV GOPATH=${gopath}
WORKDIR $GOPATH/src/github.com/gerad/kafkalogger/

COPY . ./
RUN go build -tags static_all -o kafkalogger .

FROM alpine:3.8
WORKDIR /kafkalogger/

# add debugging libraries
RUN apk --update --no-cache add gdb
RUN ulimit -c unlimited

RUN addgroup -S gerad && adduser -S gerad gerad && chown gerad:gerad .
USER gerad
COPY --from=builder /go/src/github.com/gerad/kafkalogger/kafkalogger .

ENTRYPOINT ["./kafkalogger"]
