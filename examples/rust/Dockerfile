# Rust Production Dockerfile
# Multi-stage build — final binary is static, ~5MB image

# Stage 1: Build
FROM rust:1.77-alpine AS builder
RUN apk add --no-cache musl-dev
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --release && rm -rf src
COPY src ./src
RUN cargo build --release

# Stage 2: Production (scratch — zero OS)
FROM scratch
COPY --from=builder /app/target/release/myapp /myapp
EXPOSE 8080
ENTRYPOINT ["/myapp"]
