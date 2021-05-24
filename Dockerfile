FROM rust:1.43 AS builder
WORKDIR /todo

# Cargo.tomlのみを先にイメージに追加する
COPY Cargo.toml Cargo.toml

# ビルドするために何もしないソースコードを入れておく
RUN mkdir src
RUN echo "fn main() {}" > src/main.rs

# ビルド
RUN cargo build --release

# アプリケーションのコードをコピーする
COPY ./src ./src
COPY ./templates ./templates

# 上のビルドの生成物のうち、アプリケーションのもののみを削除し、ビルドする
RUN rm -f target/release/deps/todo*
RUN cargo build --release

# 新しくリリース用のイメージを用意
FROM debian:10.4

# builderイメージからtodoだけ取り出す
COPY --from=builder /todo/target/release/todo /usr/local/bin/todo
CMD ["todo"]
