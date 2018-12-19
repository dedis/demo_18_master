# ByzCoin demo for Master Blockchain Layer 1

For the Master Blockchain Layer 1 Solution Workshop in Amsterdam in '18 we
created a demo for participants to use our conodes to create a simple byzcoin
setup.

This gives a first insight into the cothority framework and the blockchain
implementation of the DEDIS lab called ByzCoin.

The presenter's laptop runs 4 + 1 conodes that build a byzcoin cothority and
must be accessible by the other participants.

The following exercises are implemented:

1. Get the status of the presenter's conodes
2. Create a collective signature using the presenter's conodes
3. Start up a conode on the participants' laptop
4. Join the main byzcoin using the participants' conodes
5. Create and transfer coins
6. Inspect some of the data structures (proof + instance)

## Preparing the demo

### Go-environment

We suppose you have a working go-environment using go-version 1.10 or above. You can check it with this command:

```bash
go version
```

Then you need to download the cothority-package and get the right version. This step has to be done only once.

```bash
make fetch_cothority
```

### IP addresses

Whenever you change IP addresses for the presenter's laptop, you will have to run the following command and then
re-create the docker-images! On my Mac I created an additional WiFi in my network preferences to fit the IP address
of the demo-place, so that I can test it at home or in the office.

```bash
make update-ip
```

### Docker-images

To create the docker images, you first need to adjust the settings for your demo in the Makefile. 
Three variables can be adjusted:

* IP - represents the IP address of the presenter's laptop. It must be accessible by all participants' laptops
* DOCKER_PREFIX - is used when creating docker images. The first part must be accessible by your account of 
https://hub.docker.com that is linked in your computer using `docker login`
* VERSION - when trying it out, be sure to increment the version whenever your participants downloaded a docker image

Then you need to run

```bash
make
```

to create the binary distributions for the presenter and the participants.

## Distributing the demo

The simplest way to distribute the docker images is using docker-hub. Set up the system using `docker login` if 
you already have a username/password, else go to https://hub.docker.com and create an account.

Once your docker installation is correctly set up to being able to connect to the docker-hub, type:

```bash
make docker_push
```

and it will send the docker-images to docker-hub.

## Starting the demo

The demo has two parts: the conodes started ont he presenter's laptop, and a set of webpages for the students
to access directly from the presenter's laptop.

### Starting the conodes

Now you're ready to start the nodes on your computer. Be sure that all firewalls installed allow incoming connections 
on the ports 7770-7781. Then type the following command:

```bash
make run-admin
```

This starts the 5 admin-conodes. 4 of them are configured to build a byzcoin-blockchain, while 1 is idle and waiting
for you to activate it.

### Starting the webpage

To start the webpages, run the following command:

```bash
make run-www
```

This supposes that python is installed and can run a local webserver for the following three services:

- http://localhost:8000/ - for the general overview of the demo
- http://localhost:9001/p/demo - an etherpad instance to have a self-hosted environment without the need for a google
doc
- http://localhost:8000/student_18_explorer/dist - a simple blockchain explorer

When presenting the demo to students, the IPs will have to be adjusted.

## Testing the demo

Follow the instructions in the presentation and check that everything is running correctly. There is a local copy
of the presentation in [slides.pdf](www/download/slides-ByzCoin-demo.pdf). The google-doc is available here:

[Google presentation](https://docs.google.com/presentation/d/1FjD_fsPAuBYOgNZN1PpLkcsmSsNOSl-r1WCRng_I1qY/edit?usp=sharing)

## Adding nodes to byzcoin

In step 4 of the demo, you will have to add the conodes of the students to the ledger. This needs to be done in the 
cothority started by 

```bash
make run-cothority
```

This command runs the cothority on the presenter's laptop, but it also links to the private key created during the
byzcoin-setup, which means, that the presenter has admin-rights to the byzcoin, while the students can only
query byzcoin up to step 5, where they get access to their coins.

In the presenter's cothority-docker, the following command can be used to add a conode:

```bash
bc_add "
PASTE PUBLIC NODE INFO HERE
"
```

The opening `"` and closing `"` are important, so that the command correctly recognizes the entry. An example would
be:

```bash
bc_add "
  Address = "tls://192.168.0.232:7772"
  Suite = "Ed25519"
  Public = "6b225f7555d0d23b12bcc20f92c05858d8a2796050b592007465ee5cdb5b2ce1"
  Description = "Conode_1"
"
```

Notice the missing `[[servers]]` which will be added automatically by the `bc_add` script.

# Comments / Feedback

If you use this demo, please leave some feedback to [Linus Gasser](mailto:linus.gasser@epfl.ch) - even if it's just to say something like:
"did a demo with 10 people, and it crashed only once".
