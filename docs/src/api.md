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
Modules = [Moma.Categories]
Order = [:module]
```

## Types

### Basic Types

```@docs
Moma.Categories.Object
Moma.Categories.Morphism
Moma.Categories.Category
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

## Type Parameters

Many types in the module are parameterized to allow for flexible data types:

- `Object{T}`: `T` can be any type
- `Morphism{S,T}`: `S` is the source object's data type, `T` is the target object's data type

This allows for creating categories with heterogeneous data types while maintaining type safety.

## Error Handling

Functions in the module may throw the following errors:

- `ErrorException`: When morphisms are not composable
- `ErrorException`: When objects or morphisms don't belong to a category
- `ErrorException`: When colimit construction fails
- `ErrorException`: When pattern creation fails due to invalid inputs

For more detailed mathematical background, see the [Papers](papers.md) section. 