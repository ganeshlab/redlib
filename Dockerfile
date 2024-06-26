####################################################################################################
## Builder
####################################################################################################
FROM rust:alpine AS builder

RUN apk add --no-cache musl-dev

WORKDIR /redlib

COPY . .

RUN cargo build --release

####################################################################################################
## Final image
####################################################################################################
FROM alpine:latest

# Import ca-certificates from builder
COPY --from=builder /usr/share/ca-certificates /usr/share/ca-certificates
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

# Copy our build
COPY --from=builder /redlib/target/release/redlib /usr/local/bin/redlib

# Use an unprivileged user.
RUN adduser --home /nonexistent --no-create-home --disabled-password redlib
USER redlib

# Tell Docker to expose port 8080
EXPOSE 8080

CMD ["redlib"]
