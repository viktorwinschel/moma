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
id_morph = identity_morphism(obj1)
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
        obj2 => identity_morphism(obj2)
)
@assert check_binding(obj2, bindings, pattern)
@assert haskey(bindings, obj1)
@assert haskey(bindings, obj2)
@assert bindings[obj1].name == :bind1
@assert bindings[obj2].name == :id_B

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