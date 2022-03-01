FROM debian:bullseye-slim AS builder

WORKDIR /build

ADD . /build

RUN apt update && \
    apt install -y build-essential llvm cmake libclang1 libclang-dev curl

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    . $HOME/.cargo/env && \
    echo "export PATH=$HOME/.cargo/bin:${PATH}" >> /root/.bashrc && \
    cargo build --release

FROM redis:6.2.6-bullseye

WORKDIR /data

RUN mkdir -p "/usr/lib/redis/modules"

COPY --from=builder /build/target/release/librejson.so "/usr/lib/redis/modules/"

RUN chown -R redis:redis /usr/lib/redis/modules

CMD ["redis-server", \
     "--loadmodule", "/usr/lib/redis/modules/librejson.so"]
