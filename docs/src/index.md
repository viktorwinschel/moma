# Moma.jl

A Julia package implementing Memory Evolutive Systems (MES) and related mathematical frameworks.

## Overview

Moma.jl provides implementations of:

- Memory Evolutive Systems (MES)
- Category Theory constructions
- Network Theory components
- Complex Systems analysis

## Installation

```julia
using Pkg
Pkg.add("Moma")
```

## Quick Start

```julia
using Moma

# Create basic categorical objects
A = Object(:A, "object A")
B = Object(:B, "object B")

# Create a morphism
f = Morphism(A, B, x -> x, :f)

# Create a category
C = Category([A, B], [f], :ExampleCategory)
```

## Documentation Sections

- [Examples](examples.md) - Basic categorical constructions and usage examples
- [Papers](papers.md) - Mathematical foundations and theoretical background
- [API Reference](api.md) - Detailed documentation of all functions and types 