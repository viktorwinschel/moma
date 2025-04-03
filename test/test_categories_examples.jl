using Moma
using Moma.Categories
using Test

# Test Object creation
obj1 = Object(:A, "data1")
obj2 = Object(:B, "data2")
obj3 = Object(:C, "data3")
@assert obj1.id == :A && obj1.data == "data1" &&
        obj2.id == :B && obj2.data == "data2" &&
        obj3.id == :C && obj3.data == "data3"

# Test Morphism creation and composition
m1 = Morphism(obj1, obj2, x -> uppercase(x), :m1)
m2 = Morphism(obj2, obj3, x -> x * "!", :m2)
@assert m1.source == obj1 && m1.target == obj2 &&
        m2.source == obj2 && m2.target == obj3 &&
        m1.id == :m1 &&
        m2.id == :m2 &&
        m1.map("test") == "TEST" &&
        m2.map("test") == "test!"

# Test composition
m3 = compose(m1, m2)
@assert m3.source == obj1 &&
        m3.target == obj3 &&
        m3.map("test") == "TEST!" &&
        m3.id == :m1_m2

#compose(m2, m1) is an error, morphisms do not compose
try
        compose(m2, m1)
catch e
        println(e.msg) # gives "Morphisms m2 and m1 are not composable, target of m2 C != A source of m1."
        e.msg
end == "Morphisms m2 and m1 are not composable, target of m2 C != A source of m1."

# Test identity morphism
id_morph = identity_morphism(obj1)
@assert id_morph.source == obj1 &&
        id_morph.target == obj1 &&
        id_morph.map("test") == "test" &&
        id_morph.id == :id_A  # Check identity morphism name

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

# Create simple objects and morphisms
a = Object(:A, 1)
b = Object(:B, 2)
f = Morphism(a, b, x -> x + 1, :f)

# Create category and pattern
cat = Category([a, b], [f], :ColimitTest)
pat = create_pattern(cat, [a, b], [f])
cat.id == :ColimitTest
length(cat.objects) == 2 && length(cat.morphisms) == 1
length(pat.objects) == 2 && length(pat.morphisms) == 1

colimit_obj, bindings = find_colimit(pat)

#create_pattern(cat, [a, b, cc], [f]) is an error, object cc is not in category cat#create_pattern(cat, [a, b], [f, gg]) is an error, morphism gg is not in category cat
bindings = Dict(
        a => Morphism(a, b, x -> x + 1, :bind),
        b => identity_morphism(b)
)
cc = Object(:CC, 3)
gg = Morphism(a, b, x -> x + 2, :gg)
is_object_in_category(cc, cat)
try
        create_pattern(cat, [a, b, cc], [f])
catch e
        println(e.msg) # gives "Object CC must belong to the category ColimitTest"
        e.msg
end == "Object CC must belong to the category ColimitTest"
try
        create_pattern(cat, [a, b], [f, gg])
catch e
        println(e.msg) # gives "Morphism gg must belong to the category ColimitTest"
        e.msg
end == "Morphism gg must belong to the category ColimitTest"

# Test colimit properties
@assert colimit_obj.data == [1, 2]  # Combined data
@assert haskey(bindings, a)
@assert haskey(bindings, b)
@assert bindings[a].target == colimit_obj
@assert bindings[b].target == colimit_obj
@assert check_binding(colimit_obj, bindings, pat)
colimit_obj.id

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