# API Reference

## Overview

The `Categories` module provides implementations of fundamental category theory concepts used in Memory Evolutive Systems (MES). This includes:

- Basic categorical constructions (objects, morphisms, categories)
- Functorial mappings between categories
- Natural transformations between functors
- Pattern (diagram) creation and manipulation
- Colimit computation and verification

## Type Parameters

Many types in the module are parameterized to allow for flexible data types:

- `Object{T}`: `T` can be any type
- `Morphism{S,T}`: `S` is the source object's data type, `T` is the target object's data type
- `Memory{T}`: `T` is the type of the state data

This allows for creating categories with heterogeneous data types while maintaining type safety.


Functions in the module may throw the following errors:

- `MorphismCompositionError`: When morphisms are not composable
- `MorphismNotInCategoryError`: When morphisms don't belong to a category
- `ObjectNotInCategoryError`: When objects don't belong to a category
- `ObjectNotInCategory`: When pattern creation fails due to invalid object input.
- `MorphismNotInCategory`: When pattern creation fails due to invalid morphism input.
- `PatternMustHaveAtLeastOneObject`: When pattern has not Object.
- `PatternMustHaveAtLeastOneObject`: When find colimit fails due to no objects in pattern.
- `ErrorException`: When colimit construction fails
- `ErrorException`: When simulation parameters are invalid
- `ErrorException`: When plotting data is malformed

## Modules

Source: [`src/Categories.jl`](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl) and [`src/statespace.jl`](https://github.com/viktorwinschel/moma/blob/main/src/statespace.jl)

```@autodocs
Modules = [Moma.Categories, Moma.StateSpace]
Order = [:module]
```

## Types

### Basic Types

Source: [`src/Categories.jl`](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl) and [`src/statespace.jl`](https://github.com/viktorwinschel/moma/blob/main/src/statespace.jl)

```@docs
Moma.Categories.Object
Moma.Categories.Morphism
Moma.Categories.Category
Moma.StateSpace.TimeSeriesMemory
```

### Advanced Types

Source: [`src/Categories.jl`](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl)

```@docs
Moma.Categories.Functor
Moma.Categories.NaturalTransformation
Moma.Categories.Pattern
```

## Error Handling

Source: [`src/Categories.jl`](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl)

```@docs
Moma.Categories.ObjectNotInCategoryError
Moma.Categories.MorphismNotInCategoryError
Moma.Categories.MorphismCompositionError
Moma.Categories.PatternHasNoBindingError
Moma.Categories.PatternMustHaveAtLeastOneObject
```

## Functions

### Basic Operations

Source: [`src/Categories.jl`](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl)

```@docs
Moma.Categories.identity_morphism
Moma.Categories.compose
Moma.Categories.is_object_in_category
Moma.Categories.is_morphism_in_category
```

### Pattern and Colimit Operations

Source: [`src/Categories.jl`](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl)

```@docs
Moma.Categories.create_pattern
Moma.Categories.check_binding
Moma.Categories.find_colimit
```

### State Space Operations

Source: [`src/statespace.jl`](https://github.com/viktorwinschel/moma/blob/main/src/statespace.jl)

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
