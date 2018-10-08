# Distributed Gossip Protocol Implementation

Elixir implementation of the gossip protocol. A gossip protocol is a procedure or process of computer–computer communication that is based on the way social networks disseminate information or how epidemics spread. It is a communication protocol.

## Instructions

Clone the repository

```bash
git clone https://github.com/debdeepB/DistributedGossip.git
```

cd into the project directory

```bash
cd DistributedGossip
```

Now run
```bash
mix run proj2.exs nodes topology algorithm
```

nodes specify the number of the nodes in the network  
topology can be one of [line, imperfect-line, full, random-2D, 3D, torus]  
algorithm can be one of [gossip, push-sum]