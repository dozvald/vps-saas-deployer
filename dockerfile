FROM alpine:latest

WORKDIR /source
COPY . .
RUN chmod +x bootstrap.sh

LABEL maintainer="david.ozvald@gmail.com"

CMD ["./bootstrap.sh"]