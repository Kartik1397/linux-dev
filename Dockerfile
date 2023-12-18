FROM --platform=x86_64 debian:12.2-slim

RUN apt-get update

RUN apt-get install -y
RUN apt-get install -y bc
RUN apt-get install -y bison
RUN apt-get install -y build-essential
RUN apt-get install -y cpio
RUN apt-get install -y flex
RUN apt-get install -y libelf-dev
RUN apt-get install -y libncurses-dev
RUN apt-get install -y libssl-dev
RUN apt-get install -y vim-tiny
RUN apt-get install -y curl

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN apt-get install -y clang
RUN apt-get install -y lld
RUN apt-get install -y llvm

ENV PATH="/root/.cargo/bin:${PATH}"

COPY linux/scripts/min-tool-version.sh /bin/min-tool-version.sh

RUN rustup override set $(min-tool-version.sh rustc)
RUN rustup component add rust-src
RUN cargo install --locked --version $(min-tool-version.sh bindgen) bindgen

