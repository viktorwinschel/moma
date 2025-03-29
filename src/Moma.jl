module Moma

# Export your public interface here
export example_function

"""
    example_function(x::Number)

An example function that doubles its input.

# Examples
```julia
julia> example_function(2)
4
```
"""
function example_function(x::Number)
    return 2 * x
end

end # module 