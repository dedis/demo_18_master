FROM debian:stretch-slim
RUN apt-get update && apt-get install -y inetutils-ping bash vim nano joe less
WORKDIR /root/
COPY bin/* ./
COPY public.toml ./
COPY bc*cfg ./
COPY bashrc .bashrc
COPY msg.txt .
COPY bc_* ./
RUN mkdir -p .local/share /conode_data; ln -s /conode_data .local/share/bcadmin
