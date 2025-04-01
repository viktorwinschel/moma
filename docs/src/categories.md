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

Objects, Morphisms, and Category are implemented in the `Moma.Categories` module as:

- [`Object`](@ref Moma.Categories.Object)
- [`Morphism`](@ref Moma.Categories.Morphism)
- [`Category`](@ref Moma.Categories.Category)

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

The following examples demonstrate the basic usage with
the helper functions implemented in the `Moma.Categories` module as:

- [`identity`](@ref Moma.Categories.identity)
- [`compose`](@ref Moma.Categories.compose)

```julia
using Moma

# Test Object creation
obj1 = Object(:A, "data1")
obj2 = Object(:B, "data2")
obj3 = Object(:C, "data3")
@assert obj1.id == :A && obj1.data == "data1"
@assert obj2.id == :B && obj2.data == "data2"
@assert obj3.id == :C && obj3.data == "data3"

# Test Morphism creation and composition
m1 = Morphism(obj1, obj2, x -> uppercase(x), :m1)
m2 = Morphism(obj2, obj3, x -> x * "!", :m2)
@assert m1.source == obj1 && m1.target == obj2
@assert m2.source == obj2 && m2.target == obj3
@assert m1.name == :m1
@assert m2.name == :m2
@assert m1.map("test") == "TEST"
@assert m2.map("test") == "test!"

# Test composition
m3 = compose(m1, m2)
@assert m3.source == obj1 &&
    m3.target == obj3 &&
    m3.map("test") == "TEST!"
@assert m3.name == :m1_m2  # Check composed morphism name

# Test identity morphism
id_morph = Moma.identity(obj1)
@assert id_morph.source == obj1 &&
    id_morph.target == obj1 &&
    id_morph.map("test") == "test"
@assert id_morph.name == :id_A  # Check identity morphism name

# Test Category creation and membership
cat = Category([obj1, obj2, obj3], [m1, m2, m3], :TestCat)
@assert length(cat.objects) == 3 &&
    length(cat.morphisms) == 3 &&
    is_morphism_in_category(m1, cat)
@assert cat.name == :TestCat
@assert obj1 in cat.objects
@assert obj2 in cat.objects
@assert obj3 in cat.objects
@assert m1 in cat.morphisms
@assert m2 in cat.morphisms
@assert m3 in cat.morphisms

# Test Pattern creation and validation
pattern = create_pattern(cat, [obj1, obj2], [m1])
@assert length(pattern.objects) == 2 &&
    length(pattern.morphisms) == 1 &&
    pattern.category == cat
@assert obj1 in pattern.objects
@assert obj2 in pattern.objects
@assert m1 in pattern.morphisms

# Test binding checks
bindings = Dict(
    obj1 => Morphism(obj1, obj2, x -> uppercase(x), :bind1),
    obj2 => Moma.identity(obj2)
)
@assert check_binding(obj2, bindings, pattern)
@assert haskey(bindings, obj1)
@assert haskey(bindings, obj2)
@assert bindings[obj1].name == :bind1
@assert bindings[obj2].name == :id_B
```

For more complex examples and edge cases, see the test files in the repository.

## Functors

### Mathematical Definition

A functor $F: \mathcal{C} \to \mathcal{D}$ between categories consists of:
- An object mapping $F_{\text{ob}}: \text{Ob}(\mathcal{C}) \to \text{Ob}(\mathcal{D})$
- A morphism mapping $F_{\text{mor}}: \text{Hom}_{\mathcal{C}}(A,B) \to \text{Hom}_{\mathcal{D}}(F(A),F(B))$

```math
\begin{CD}
\mathcal{C} @>{F}>> \mathcal{D} \\
@V{\text{id}_{\mathcal{C}}}VV @V{\text{id}_{\mathcal{D}}}VV \\
\mathcal{C} @>{F}>> \mathcal{D}
\end{CD}
```

For theoretical foundations and applications of functors in MES, see [MES23: Functorial Evolution](mes23.md#functorial-evolution).

### Implementation

Functors are implemented in the `Moma.Categories` module as:

- [`Functor`](@ref Moma.Categories.Functor)

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
using Moma

# Create source and target categories
src_cat = Category([obj1, obj2], [m1], :source)
tgt_cat = Category([obj3], [identity(obj3)], :target)

# Define functor mappings
obj_map = Dict(obj1 => obj3, obj2 => obj3)
morph_map = Dict(m1 => identity(obj3))

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

- [`NaturalTransformation`](@ref Moma.Categories.NaturalTransformation)

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
using Moma

# Create components for natural transformation
components = Dict(
    obj1 => Morphism(F.object_map[obj1], G.object_map[obj1], x -> x, :eta_A),
    obj2 => Morphism(F.object_map[obj2], G.object_map[obj2], x -> x, :eta_B)
)

# Create natural transformation
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

- [`Pattern`](@ref Moma.Categories.Pattern)

```julia
# Implementation in Categories.jl
struct Pattern
    category::Category
    objects::Vector{Object}
    morphisms::Vector{Morphism}
    name::Symbol
end
```

The module provides functions for working with patterns and colimits:
- [`create_pattern`](@ref Moma.Categories.create_pattern): Creates a pattern from objects and morphisms
- [`check_binding`](@ref Moma.Categories.check_binding): Verifies if an object forms a colimit for a pattern
- [`find_colimit`](@ref Moma.Categories.find_colimit): Computes the colimit of a pattern

### Examples

The following examples demonstrate pattern creation and colimit construction:

```julia
using Moma

# Create simple objects and morphisms
a = Object(:A, 1)
b = Object(:B, 2)
f = Morphism(a, b, x -> x + 1, :f)
@assert a.id == :A && a.data == 1
@assert b.id == :B && b.data == 2
@assert f.name == :f
@assert f.map(1) == 2

# Create category and pattern
cat = Category([a, b], [f], :ColimitTest)
pat = create_pattern(cat, [a, b], [f])
@assert cat.name == :ColimitTest
@assert length(cat.objects) == 2
@assert length(cat.morphisms) == 1
@assert length(pat.objects) == 2
@assert length(pat.morphisms) == 1

# Find colimit
colimit_obj, bindings = find_colimit(pat)

# Test colimit properties
@assert colimit_obj.data == [1, 2]  # Combined data
@assert haskey(bindings, a)
@assert haskey(bindings, b)
@assert bindings[a].target == colimit_obj
@assert bindings[b].target == colimit_obj
@assert check_binding(colimit_obj, bindings, pat)
@assert colimit_obj.id == :colimit  # Check colimit object name

# Test colimit universal property
@assert bindings[a].map(a.data) == [1, 2]
@assert bindings[b].map(b.data) == [1, 2]
@assert bindings[a].name == :injection_A  # Check injection morphism names
@assert bindings[b].name == :injection_B
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
using Moma

# Create base level components
neuron1 = Object(:N1, "neuron_data_1")
neuron2 = Object(:N2, "neuron_data_2")
synapse = Morphism(neuron1, neuron2, 
                  x -> "synapse_" * x, :syn)
@assert neuron1.id == :N1 && neuron1.data == "neuron_data_1"
@assert neuron2.id == :N2 && neuron2.data == "neuron_data_2"
@assert synapse.name == :syn
@assert synapse.map("test") == "synapse_test"

# Create neural pattern
neural_cat = Category([neuron1, neuron2], [synapse], :neural)
pattern = create_pattern(neural_cat, [neuron1, neuron2], [synapse])
@assert neural_cat.name == :neural
@assert length(neural_cat.objects) == 2
@assert length(neural_cat.morphisms) == 1
@assert length(pattern.objects) == 2
@assert length(pattern.morphisms) == 1

# Form higher-order component (neural assembly)
assembly, bindings = find_colimit(pattern)

# Verify the formation
@assert check_binding(assembly, bindings, pattern)
@assert assembly.id == :colimit  # Check assembly name
@assert haskey(bindings, neuron1)
@assert haskey(bindings, neuron2)
@assert bindings[neuron1].name == :injection_N1  # Check injection morphism names
@assert bindings[neuron2].name == :injection_N2
```

## Further Reading

For more detailed mathematical background and applications:
- [MES23](mes23.md): Newer developments in Memory Evolutive Systems on human-machine interaction
- [MES07](mes07.md): Memory Evolutive Systems (MES)
- [MoMa25](moma25.md) Monetary Macro Accounting (MoMa) Theory (MoMaT)
- [Papers](papers.md): Complete list of related publications and theoretical background