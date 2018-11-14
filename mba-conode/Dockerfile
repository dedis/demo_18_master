FROM debian:stretch-slim
WORKDIR /root/
COPY conode .
COPY setup-then-start.sh .
RUN mkdir /conode_data
RUN mkdir -p .local/share .config
RUN ln -s /conode_data .local/share/conode
RUN ln -s /conode_data .config/conode

EXPOSE 7770 7771

CMD "./setup-then-start.sh"
