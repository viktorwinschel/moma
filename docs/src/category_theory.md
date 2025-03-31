# Category Theory

This section provides a mathematical introduction to the category theory concepts implemented in MoMa.

## Categories

### Mathematical Definition

A category $\mathcal{C}$ consists of:
- A collection of objects $\text{Ob}(\mathcal{C})$
- A collection of morphisms $\text{Hom}(\mathcal{C})$, where each morphism $f: A \to B$ has a source $A$ and target $B$
- For each object $A$, an identity morphism $\text{id}_A: A \to A$
- A composition operation $\circ: \text{Hom}(B,C) \times \text{Hom}(A,B) \to \text{Hom}(A,C)$ that satisfies:
  - Associativity: $(h \circ g) \circ f = h \circ (g \circ f)$ $\forall f: A \to B, g: B \to C, h: C \to D$
  - Identity: $f \circ \text{id}_A = f = \text{id}_B \circ f$ $\forall f: A \to B$

For a detailed theoretical background on categories, see [MES23: Categories and Functors](mes23.md#categories-and-functors).

```math
\begin{CD}
A @>{f}>> B @>{g}>> C \\
@V{\text{id}_A}VV @V{\text{id}_B}VV @V{\text{id}_C}VV \\
A @>{f}>> B @>{g}>> C
\end{CD}
```

### Implementation

In MoMa, categories are implemented using the following types:

- [`Object` (lines 61-65)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L61-L65)
- [`Morphism` (lines 97-102)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L97-L102)
- [`Category` (lines 114-118)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L114-L118)
- [`identity` (lines 194-196)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L194-L196)
- [`compose` (lines 231-237)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L231-L237)

```julia
# Implementation in Categories.jl
struct Object{T}
    name::Symbol
    data::T
end

struct Morphism{S,T}
    source::Object{S}
    target::Object{T}
    map::Function
    name::Symbol
end

struct Category
    objects::Vector{Object}
    morphisms::Vector{Morphism}
    name::Symbol
end
```

For comprehensive tests of these implementations, see the test files in the repository.

### Examples

The following examples demonstrate the basic usage:

```julia
using Moma.Categories

# Examples from Categories.jl docstrings and tests
A = Object(:A, "hello")           # String data
B = Object(:B, 42)               # Integer data
C = Object(:C, Point(0.0, 1.0))  # Custom type data

# Create morphisms with explicit functions
f = Morphism(A, Object(:B, "HELLO"), uppercase, :f)
g = Morphism(B, Object(:C, 43), x -> x + 1, :g)

# Create identity morphisms
id_A = identity(A)
@assert id_A.map("hello") == "hello"

# Compose compatible morphisms
h = compose(
    Morphism(A, B, x -> length(x), :h),
    Morphism(B, C, x -> Point(float(x), 0.0), :i)
)
```

For more complex examples and edge cases, see the test files in the repository.

## Functors

### Mathematical Definition

A functor $F: \mathcal{C} \to \mathcal{D}$ between categories consists of:
- An object mapping $F_{\text{ob}}: \text{Ob}(\mathcal{C}) \to \text{Ob}(\mathcal{D})$
- A morphism mapping $F_{\text{mor}}: \text{Hom}_{\mathcal{C}}(A,B) \to \text{Hom}_{\mathcal{D}}(F(A),F(B))$

For theoretical foundations and applications of functors in MES, see [MES23: Functorial Evolution](mes23.md#functorial-evolution).

### Implementation

Functors are implemented in the `Moma.Categories` module as:

- [`Functor` (lines 132-138)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L132-L138)

```julia
# Implementation in Categories.jl
struct Functor
    source::Category
    target::Category
    object_map::Dict{Object,Object}
    morphism_map::Dict{Morphism,Morphism}
    name::Symbol
end
```

### Examples

The following examples demonstrate functor creation and verification:

```julia
using Moma.Categories

# Examples from Categories.jl docstrings
src_cat = Category([A, B], [f], :source)
tgt_cat = Category([C], [identity(C)], :target)

# Define functor mappings
obj_map = Dict(A => C, B => C)
morph_map = Dict(f => identity(C))

# Create functor
F = Functor(src_cat, tgt_cat, obj_map, morph_map, :F)
```

## Natural Transformations

### Mathematical Definition

Given functors $F,G: \mathcal{C} \to \mathcal{D}$, a natural transformation $\eta: F \Rightarrow G$ consists of:
- A family of morphisms $\eta_A: F(A) \to G(A)$ $\forall A \in \text{Ob}(\mathcal{C})$

For the role of natural transformations in MES, see [MES07: Natural Transformations and System Evolution](mes07.md#natural-transformations).

Such that the naturality condition holds:
-  $G(f) \circ \eta_A = \eta_B \circ F(f)$ $\forall f: A \to B$ in $\mathcal{C}$

```math
\begin{CD}
F(A) @>{F(f)}>> F(B) \\
@V{\eta_A}VV @V{\eta_B}VV \\
G(A) @>{G(f)}>> G(B)
\end{CD}
```

### Implementation

Natural transformations are implemented in the `Moma.Categories` module as:

- [`NaturalTransformation` (lines 151-156)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L151-L156)

```julia
# Implementation in Categories.jl
struct NaturalTransformation
    source::Functor
    target::Functor
    components::Dict{Object,Morphism}
    name::Symbol
end
```

### Examples

The following examples demonstrate natural transformation creation and verification:

```julia
using Moma.Categories

# Examples from Categories.jl docstrings
components = Dict(
    A => Morphism(F.object_map[A], G.object_map[A], x -> x, :eta_A),
    B => Morphism(F.object_map[B], G.object_map[B], x -> x, :eta_B)
)

eta = NaturalTransformation(F, G, components, :eta)
```

## Patterns and Colimits

### Mathematical Definition

A pattern $P$ in a category $\mathcal{C}$ consists of:
- A diagram $D: \mathcal{J} \to \mathcal{C}$ where $\mathcal{J}$ is a small category
- Objects $D(j)$ for each $j \in \text{Ob}(\mathcal{J})$
- Morphisms $D(f): D(j) \to D(k)$ for each $f: j \to k$ in $\mathcal{J}$

For the significance of patterns and colimits in complex systems, see [MES23: Patterns and Complexity](mes23.md#patterns-and-complexity).

A colimit of pattern $P$ consists of:
- An object $\text{colim}(P)$
- A family of morphisms $\iota_j: D(j) \to \text{colim}(P)$

Such that:
-  $\iota_k \circ D(f) = \iota_j$ for all $f: j \to k$ in $\mathcal{J}$
- Universal property: For any other cocone $(C, (\gamma_j)_{j \in \mathcal{J}})$, there exists a unique $u: \text{colim}(P) \to C$ such that $u \circ \iota_j = \gamma_j$

```math
\begin{CD}
D(j) @>{D(f)}>> D(k) \\
@V{\iota_j}VV @VV{\iota_k}V \\
\text{colim}(P) @= \text{colim}(P)
\end{CD}
```

### Implementation

Patterns and colimits are implemented in the `Moma.Categories` module as:

- [`Pattern` (lines 169-174)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L169-L174)
- [`create_pattern` (lines 271-284)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L271-L284)
- [`check_binding` (lines 318-342)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L318-L342)
- [`find_colimit` (lines 384-401)](https://github.com/viktorwinschel/moma/blob/main/src/Categories.jl#L384-L401)

```julia
# Implementation in Categories.jl
struct Pattern
    category::Category
    objects::Vector{Object}
    morphisms::Vector{Morphism}
    name::Symbol
end

struct Colimit
    pattern::Pattern
    colimit_object::Object
    injections::Dict{Object,Morphism}
end
```

### Examples

The following examples demonstrate pattern and colimit creation:

```julia
using Moma.Categories

# Examples from Categories.jl docstrings
pattern = create_pattern(cat, [A, B], [f])
colimit_obj, bindings = find_colimit(pattern)
@assert check_binding(colimit_obj, bindings, pattern)
```

## Memory Evolutive Systems

### Mathematical Definition

A Memory Evolutive System (MES) consists of:
- A category $\mathcal{C}$ of components and their relationships
- A hierarchy of complexity levels through colimit formation
- A dynamic structure through time evolution

For a comprehensive introduction to MES, see [MES07: Introduction](mes07.md#introduction) and [MES23: Memory Evolutive Systems](mes23.md#memory-evolutive-systems).

The key operations include:
- Pattern formation through selection of objects and morphisms
- Colimit computation for complex component formation
- Temporal evolution through functorial transitions

### Implementation

The MES implementation builds upon the previous structures:
- Uses categories to represent system state
- Employs patterns to identify meaningful subsystems
- Computes colimits to form higher-order components
- Tracks temporal evolution through category morphisms

For example, creating a basic hierarchical structure:

```julia
# Create base level components
A = Object(:A, "base_component_1")
B = Object(:B, "base_component_2")
f = Morphism(A, B, x -> process(x), :f)

# Form a pattern
pattern = Pattern(category, [A, B], [f])

# Compute colimit for higher-order component
colimit = find_colimit(pattern)
```

### Examples

```julia
# Create base level components
neuron1 = Object(:N1, "neuron_data_1")
neuron2 = Object(:N2, "neuron_data_2")
synapse = Morphism(neuron1, neuron2, 
                  x -> "synapse_" * x, :syn)

# Create neural pattern
neural_cat = Category([neuron1, neuron2], [synapse], :neural)
pattern = create_pattern(neural_cat, [neuron1, neuron2], [synapse])

# Form higher-order component (neural assembly)
assembly, bindings = find_colimit(pattern)

# Verify the formation
@assert check_binding(assembly, bindings, pattern)
```

## Advanced Examples

### Custom Data Types

The category theory framework can be used with any custom data types. Here's an example using geometric objects:

```julia
using Moma.Categories

# Define custom data types
struct Point
    x::Float64
    y::Float64
end

struct Line
    start::Point
    ends::Point
end

# Create objects with custom data
p1 = Object(:P1, Point(0.0, 0.0))
p2 = Object(:P2, Point(1.0, 1.0))
l1 = Object(:L1, Line(Point(0.0, 0.0), Point(1.0, 1.0)))

# Create morphisms between custom objects
f = Morphism(p1, l1, p -> Line(p, Point(p.x + 1.0, p.y + 1.0)), :f)

# Create a category of geometric objects
geom_cat = Category([p1, p2, l1], [f], :Geometry)

# Create and verify patterns
geom_pattern = create_pattern(geom_cat, [p1, l1], [f])
```

### Error Handling

The framework includes comprehensive error checking to ensure categorical laws are maintained:

```julia
using Moma.Categories

# Attempting to compose incompatible morphisms
f = Morphism(A, B, x -> x, :f)
g = Morphism(C, A, x -> x, :g)
try
    compose(f, g)  # This will throw an error
catch e
    println("Error: ", e)  # "Morphisms are not composable"
end

# Attempting to create invalid patterns
try
    create_pattern(cat, [Object(:X, 0)], [])  # Object not in category
catch e
    println("Error: ", e)  # "Objects must belong to the category"
end

# Attempting to find invalid colimits
invalid_pattern = create_pattern(cat, [A, B], [])
colimit_obj, bindings = find_colimit(invalid_pattern)
try
    check_binding(Object(:bad, 0), Dict(), invalid_pattern)
catch e
    println("Error: ", e)  # Missing bindings
end
```

## Further Reading

For more detailed mathematical background and applications:
- [MES23](mes23.md): Newer developments in Memory Evolutive Systems on human-machine interaction
- [MES07](mes07.md): Memory Evolutive Systems (MES)
- [MoMa25](moma25.md) Monetary Macro Accounting (MoMa) Theory (MoMaT)
- [Papers](papers.md): Complete list of related publications and theoretical background