# Central Banks for All and Everything

This Julia package implements a Monetary Macro Accounting (MoMa) system of Menéndez and Winschel.
It is modeled with categorical tools of Memory Evolutive Systems (MES) of Ehresmann and Vanbremeersch.
By that we can model multi-level, hierarchical systems like micro, meso and macro economies are.

The monetary theory of MoMa works for national accounting, sectors and companies
but applies also for within companies like holdings with subsidiaries
and down to smaller levels like to processes of a box ordering screws.
MoMa theory is a multi-level accounting theory for macro accounting with different time scales
extending micro accounting aka double-entry bookkeeping. 
This can be thought of concepts of composable enterprises for a new generation of ERP (Enterpsice Resource Planing) 
systems, then EcRP systems for economic resource planing.

## Overview

This documentation contain implementations and

- Basic category theoretical constructions
- A statespace model implementation with categorical and MES tools
- Basic simulation of a MoMa national accounting
- Summaries and pdfs of MES and MoMa

## Documentation Sections

- [Categories](categories.md): Introduction to category theory concepts
- [State Space Models](state_space_models.md): Implementation of state space models using MES
- [Examples](examples.md): Usage examples and tutorials
- [Papers](papers.md): Related academic papers and references
- [API](api.md): Detailed API documentation

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

Contributions are welcome! by email to [repository owner](https://github.com/viktorwinschel)