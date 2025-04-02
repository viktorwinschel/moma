# API Reference

## Overview

The `Categories` module provides implementations of fundamental category theory concepts used in Memory Evolutive Systems (MES). This includes:

- Basic categorical constructions (objects, morphisms, categories)
- Functorial mappings between categories
- Natural transformations between functors
- Pattern (diagram) creation and manipulation
- Colimit computation and verification

## Modules

```@autodocs
Modules = [Moma.Categories, Moma.StateSpace]
Order = [:module]
```

## Types

### Basic Types

```@docs
Moma.Categories.Object
Moma.Categories.Morphism
Moma.Categories.Category
Moma.StateSpace.TimeSeriesMemory
```

### Advanced Types

```@docs
Moma.Categories.Functor
Moma.Categories.NaturalTransformation
Moma.Categories.Pattern
```

## Functions

### Basic Operations

```@docs
Moma.Categories.identity
Moma.Categories.compose
Moma.Categories.is_morphism_in_category
```

### Pattern and Colimit Operations

```@docs
Moma.Categories.create_pattern
Moma.Categories.check_binding
Moma.Categories.find_colimit
```

### State Space Operations

```@docs
Moma.StateSpace.create_ar_model
Moma.StateSpace.create_var_model
Moma.StateSpace.create_nonlinear_var_model
Moma.StateSpace.create_stochastic_nonlinear_var_model
Moma.StateSpace.simulate_dynamics
Moma.StateSpace.plot_timeseries
Moma.StateSpace.get_data
Moma.StateSpace.get_times
Moma.StateSpace.extend!
Moma.StateSpace.collect_timeseries
Moma.StateSpace.get_links
```

## Type Parameters

Many types in the module are parameterized to allow for flexible data types:

- `Object{T}`: `T` can be any type
- `Morphism{S,T}`: `S` is the source object's data type, `T` is the target object's data type
- `Memory{T}`: `T` is the type of the state data

This allows for creating categories with heterogeneous data types while maintaining type safety.

## Error Handling

Functions in the module may throw the following errors:

- `ErrorException`: When morphisms are not composable
- `ErrorException`: When objects or morphisms don't belong to a category
- `ErrorException`: When colimit construction fails
- `ErrorException`: When pattern creation fails due to invalid inputs
- `ErrorException`: When simulation parameters are invalid
- `ErrorException`: When plotting data is malformed
