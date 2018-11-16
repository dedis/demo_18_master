FROM mba-conode:1

WORKDIR /root/
COPY co1/*.toml co1/
COPY co2/*.toml co2/
COPY co3/*.toml co3/
COPY co4/*.toml co4/
COPY co5/*.toml co5/
COPY public.toml .
COPY run_conodes.sh .
COPY bcadmin .

# local - run this as a set of local nodes in the docker
# 4 - number of nodes to run
# 2 - debug-level: 0 - none .. 5 - a lot
# -wait - don't return from script when all nodes are started
CMD ["./run_conodes.sh" ]
