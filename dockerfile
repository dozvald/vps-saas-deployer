FROM busybox:1.37.0

LABEL maintainer="david.ozvald@gmail.com"

WORKDIR /source
COPY . .

# Creates non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chmod +x bootstrap.sh

USER appuser

CMD ["./bootstrap.sh"]