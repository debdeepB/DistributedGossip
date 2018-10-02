# Distributed Gossip and Push-Sum Implementation



## Team

1. Debdeep Basu (UFID: 4301-3324)
2. Ali Akbar (UFID: 8498 – 3349)

## Instructions

To run just cd into the project directory and run
```bash
mix run proj2.exs nodes topology algorithm
```

nodes specify the number of the nodes in the network  
topology can be one of [line, imperfect-line, full, random-2D, 3D, torus]  
algorithm can be either [gossip, push-sum]

## What is working

All the topologies (Line, Imperfect Line, Full, Random 2D, 3D, Torus) are working fine for both Gossip and PushSum protocols.

## Largest problem instances

Line - Gossip: 500 nodes, PushSum: 400  
Imperfect Line - Gossip: 7000, PushSum: 4000  
Full - Gossip:  6000, PushSum: 1000
Random2d - Gossip: 1300, PushSum: 800  
Torus - Gossip: 1200, PushSum: 1000

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `proj2` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:proj2, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/proj2](https://hexdocs.pm/proj2).

