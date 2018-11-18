# Cothority demo for Master Blockchain Layer 1

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

## Running the demo

First you need to change the IP address in the `Makefile` to reflect the IP
address of the presenter's laptop. Then you need to run

```bash
make
```

to create the binary distributions for the presenter and the participants.
