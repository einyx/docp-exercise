FROM golang:latest as builder
USER ${USER}
WORKDIR /app/
COPY ./main.go ./
ENV GOARCH="amd64" \
  GOOS="linux"

ARG CERTNAME="cert" \ 
  NAME="ca" \
  DAYS="36500"

RUN apt-get -y install openssl awscli
RUN go build main.go
RUN openssl genrsa -out ca.key 4096 && \
echo "CA key generated, file ca.key. Now retype password to create cert" && \
openssl req -new -x509 -days 730 -key ca.key -out ca.crt -subj "/C=ES/ST=Barcelona/L=Barcelona/O=Global Security/OU=IT Department/CN=example.com" && \
echo "CA cert generated, file: ca.crt"
RUN echo 00 > ca.srl
RUN openssl req -new -sha256 -newkey rsa:2048 -nodes -out ${CERTNAME}.req -keyout ${CERTNAME}.key -subj "/C=ES/ST=Barcelona/L=Barcelona/O=Global Security/OU=IT Department/CN=example.com"
RUN openssl x509 -CA ${NAME}.crt -CAkey ${NAME}.key -req -in ${CERTNAME}.req -out ${CERTNAME}.pem -days ${DAYS}
RUN openssl pkcs12 -export -in ${CERTNAME}.pem -inkey ${CERTNAME}.key -certfile ${NAME}.crt -name "${CERTNAME}" -out file.p12 -passout pass:

RUN apt-get autoclean \
  && apt-get autoremove \
  && apt-get clean \
  && apt-get remove

FROM builder
COPY --from=builder . ./

ENTRYPOINT ["./main"]
