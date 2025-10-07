FROM alpine:3.22.1

LABEL maintainer="david.ozvald@gmail.com"

WORKDIR /source
COPY . .

RUN apk add --no-cache util-linux

RUN chmod +x bootstrap.sh

USER root

CMD ["./bootstrap.sh"]