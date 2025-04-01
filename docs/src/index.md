# MoMa: Central Banks for All and Everything

A Julia package implementing a Monetary Macro Accounting (MoMa) of Menéndez and Winschel.
To be extended with categorical tools of Memory Evolutive Systems (MES) of Ehresmann and Vanbremeersch.

The monetary theory of MoMa works for national accounting, sectors and companies
but also for within companies as holdings with subsidiaries
and down to smaller levels down like to processes of a box ordering screws.
MoMa is a multi-level accounting theory for macro accounting with different time scales
extending micro accounting aka double-entry bookkeeping.

## Overview

This documentation contain implementations and

- Basic category theoretical constructions
- Basic simulation of a MoMa national accounting
- Summaries and pdfs of MES and MoMa

## Documentation Sections

- [Categories](categories.md): Introduction to category theory concepts
- [State Space Models](state_space_models.md): Implementation of state space models using MES
- [Examples](examples.md): Usage examples and tutorials
- [Papers](papers.md): Related academic papers and references
- [API](api.md): Detailed API documentation

## Installation

```julia
using Pkg
Pkg.add("MoMa")
```

## Quick Start

```julia
using Moma

# Create objects and morphisms
A = Object(:A, "data")
B = Object(:B, "DATA")
f = Morphism(A, B, uppercase, :f)

# Create a category
C = Category([A, B], [f], :C)

# Create and simulate a state space model
t₁, s₁, time_step, evolution = create_ar_model([0.5])
memory = simulate_dynamics(t₁, s₁, time_step, evolution, 100)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 