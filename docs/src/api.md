# API Reference

## Modules

```@autodocs
Modules = [Moma.Categories, Moma.TrafficNetwork]
Order = [:module]
```

## Categories

### Types

```@docs
Moma.Categories.Object
Moma.Categories.Morphism
Moma.Categories.Category
Moma.Categories.Functor
Moma.Categories.NaturalTransformation
Moma.Categories.Pattern
```

### Functions

```@docs
Moma.Categories.identity
Moma.Categories.compose
Moma.Categories.create_pattern
Moma.Categories.check_binding
Moma.Categories.find_colimit
```

## Traffic Network Example

### Types

```@docs
Moma.TrafficNetwork.RoadSegment
Moma.TrafficNetwork.Junction
```

### Functions

```@docs
Moma.TrafficNetwork.create_traffic_network
Moma.TrafficNetwork.analyze_traffic_flow
``` 