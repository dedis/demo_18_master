FROM debian:stretch-slim
RUN apt-get update && apt-get install -y inetutils-ping bash vim
WORKDIR /root/
COPY bin/* ./
COPY public.toml ./
COPY bc*cfg ./
COPY bashrc .bashrc
RUN mkdir -p .local/share /conode_data; ln -s /conode_data .local/share/bcadmin
