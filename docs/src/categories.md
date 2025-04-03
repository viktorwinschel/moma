# Category Theory

This section provides a mathematical introduction to the category theory concepts implemented in MoMa.

## Category

### Mathematical Definition

A category $\mathcal{A}$ consists of
- A collection of objects $\text{Ob}(\mathcal{A})$ with identity morphisms $\exists\text{id}_A: A \to A$, $\forall A\in \mathcal{A}$
- A collection of morphisms $\text{Hom}(\mathcal{A})$, $f_1: A_1 \to A_2$ with source $A_1$ and target $A_2$
- A composition operation $\circ: \text{Hom}(A_2,A_3) \times \text{Hom}(A_1,A_2) \to \text{Hom}(A_1,A_3)$ that satisfies
  - Associativity: $(f_3\circ f_2) \circ f_1 = f_3 \circ (f_2 \circ f_1)$, $\forall f_1: A_1 \to A_2, f_2: A_2 \to A_3, f_3: A_3 \to A_4$
  - Identity: $f \circ \text{id}_{A_1} = f = \text{id}_{A_2} \circ f$, $\forall f: A_1 \to A_2$

```math
\begin{CD}
A_1 @>{f_1}>> A_2 @>{f_2}>> A_3 \\
@V{\text{id}_{A_1}}VV @V{\text{id}_{A_2}}VV @V{\text{id}_{A_3}}VV \\
A_1 @>{f_1}>> A_2 @>{f_2}>> A_3
\end{CD}
```

### Implementation

[`Category`](@ref Moma.Categories.Category),
[`Object`](@ref Moma.Categories.Object), and
[`Morphism`](@ref Moma.Categories.Morphism)
are implemented in the `Moma.Categories` module.

```julia
struct Object{T}        # an object of type T consist of
    id::Symbol          # name
    data::T             # data of type T
end

struct Morphism{S,T}    # a morphism of type (S,T) consist of
    source::Object{S}   # source Object of type S
    target::Object{T}   # target Object of type T
    map::Function       # Julia function, i.e. computation
    id::Symbol          # name
end

struct Category                 # a category consist of
    objects::Vector{Object}     # objects of type Vector of Objects
    morphisms::Vector{Morphism} # morphisms of type Vector of Morphisms
    id::Symbol                  # name
end
```

For comprehensive tests of these implementations, see the test files in the repository.

### Examples

The following examples demonstrate the basic usage with
the helper functions 
[`identity_morphism`](@ref Moma.Categories.identity_morphism),
[`compose`](@ref Moma.Categories.compose)
implemented in the `Moma.Categories` module.


```julia
using Moma
using Moma.Categories
using Test

# Test Object creation
obj1 = Object(:A, "data1")
@assert obj1.id == :A && obj1.data == "data1"
obj2 = Object(:B, "data2")
obj3 = Object(:C, "data3")

# Test Morphism creation and composition
m1 = Morphism(obj1, obj2, x -> uppercase(x), :m1)
m2 = Morphism(obj2, obj3, x -> x * "!", :m2)
@assert m1.source == obj1 && m1.target == obj2 &&
        m2.source == obj2 && m2.target == obj3 &&
        m1.name == :m1 &&
        m2.name == :m2 &&
        m1.map("test") == "TEST" &&
        m2.map("test") == "test!"

# Test composition
m3 = compose(m1, m2)
@assert m3.source == obj1 &&
        m3.target == obj3 &&
        m3.map("test") == "TEST!" &&
        m3.name == :m1_m2 # name of composite symbolically composed by _
@assert try 
        compose(m2, m1)
catch e
        e.msg 
end  == "Morphisms m2 and m1 are not composable, target of m2 C != A source of m1."

# Test identity morphism
id_morph = identity_morphism(obj1)
@assert id_morph.source == obj1 &&
        id_morph.target == obj1 &&
        id_morph.map("test") == "test" &&
        id_morph.id == :id_A  #name of identity symbolically composed by _

# Test Category creation and membership
cat1 = Category([obj1, obj2], [m1, m2], :TestCat)
@assert length(cat1.objects) == 2 &&
        length(cat1.morphisms) == 2 &&
        is_morphism_in_category(m1, cat1) &&
        cat1.id == :TestCat &&
        obj1 in cat1.objects &&
        obj2 in cat1.objects &&
        m1 in cat1.morphisms &&
        m2 in cat1.morphisms
```

## Functors

### Mathematical Definition

A functor $F: \mathcal{A} \to \mathcal{B}$ between categories consists of:
- An object mapping $F_{\text{ob}}: \text{Ob}(\mathcal{A}) \to \text{Ob}(\mathcal{B})$
- A morphism mapping $F_{\text{mor}}: \text{Hom}_{\mathcal{A}}(A_1,A_2) \to \text{Hom}_{\mathcal{B}}(F(A_1),F(A_2))$

**Preservation of Identities:** For each object $A \in \mathcal{A}$ the commutative diagram

```math
\begin{CD}
A @>{\text{id}_{A}}>> A \\
@V{F}VV @V{F}VV \\
F(A) @>{\text{id}_{F(A)}}>> F(A)
\end{CD}
```
says that the functor preserves identity $F(\text{id}_A)=\text{id}_{F(A)}$,
i.e. $F$ maps identity $\mathrm{id}_A$ to $\mathrm{id}_{F(A)}$.

**Preservation of Composition:** For a composition $A \xrightarrow{f} B \xrightarrow{g}$ the commutative diagram
```math
\begin{CD}
A @>{g\circ f}>> C \\
@V{F}VV @V{F}VV \\
F(A) @>{F(g)\circ F(f)}>> F(C)
\end{CD}
```
says that the functor $F$ preserves composition $F(g\circ f)=F(g)\circ F(f)$.

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
tgt_cat = Category([obj3], [identity_morphism(obj3)], :target)

# Define functor mappings
obj_map = Dict(obj1 => obj3, obj2 => obj3)
morph_map = Dict(m1 => identity_morphism(obj3))

# Create functor
F = Functor(src_cat, tgt_cat, obj_map, morph_map, :F)
```

## Natural Transformations

### Mathematical Definition

Given functors $F,G: \mathcal{C} \to \mathcal{D}$, a natural transformation $\eta: F \Rightarrow G$ consists of:
- A family of morphisms $\eta_A: F(A) \to G(A)$ $\forall A \in \text{Ob}(\mathcal{C})$

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
using Moma.Categories

# Create simple objects and morphisms
a = Object(:A, 1)
b = Object(:B, 2)
c = Object(:C, 3)
f = Morphism(a, b, x -> x + 1, :f)
g = Morphism(a, b, x -> x + 2, :g)
@assert a.id == :A && a.data == 1 &&
        b.id == :B && b.data == 2 &&
        c.id == :C && c.data == 3 &&
        f.name == :f &&
        f.map(1) == 2

# Create category and pattern
cat = Category([a, b], [f], :ColimitTest)
pat = create_pattern(cat, [a, b], [f])
@assert cat.name == :ColimitTest &&
        length(cat.objects) == 2 && length(cat.morphisms) == 1 &&
        length(pat.objects) == 2 && length(pat.morphisms) == 1 &&
        a in pat.objects && b in pat.objects &&
        f in pat.morphisms
        try
                create_pattern(cat, [a, c], [f])
        catch e
                e.msg
        end == "Object C must belong to the category ColimitTest" &&
        try
                create_pattern(cat, [a, b], [g])
        catch e
                e.msg
        end == "Morphism g must belong to the category ColimitTest"

# Test binding checks
bindings = Dict(
        obj1 => Morphism(obj1, obj2, x -> uppercase(x), :bind1),
        obj2 => identity_morphism(obj2)
)
@assert check_binding(obj2, bindings, pattern) &&
        haskey(bindings, obj1) &&
        haskey(bindings, obj2) &&
        bindings[obj1].name == :bind1 &&
        bindings[obj2].name == :id_B


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