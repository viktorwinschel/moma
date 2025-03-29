# Moma.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://viktorwinschel.github.io/moma/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://viktorwinschel.github.io/moma/dev)
[![Build Status](https://github.com/viktorwinschel/moma/workflows/CI/badge.svg)](https://github.com/viktorwinschel/moma/actions)
[![Coverage](https://codecov.io/gh/viktorwinschel/moma/branch/main/graph/badge.svg)](https://codecov.io/gh/viktorwinschel/moma)

A Julia package implementing Memory Evolutive Systems (MES) for complex system modeling and analysis.

## Installation

To install the package, use Julia's package manager:

```julia
using Pkg
Pkg.add("Moma")
```

## Features

- Basic categorical constructions (objects, morphisms, categories)
- Memory Evolutive Systems implementation
- Traffic network example demonstrating MES concepts
- Tools for analyzing complex systems using categorical methods

## Usage

Here's a basic example of creating and analyzing a traffic network using Moma:

```julia
using Moma

# Create a traffic network
network = create_traffic_network()

# Analyze traffic flow
analysis = analyze_traffic_flow(network)
println("Path length: $(analysis["path_length"])")
println("Total flow: $(analysis["total_flow"])")
println("Bottleneck capacity: $(analysis["bottleneck"])")
```

## Running Tests

To run the test suite:

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Moma.jl.git
   cd Moma.jl
   ```

2. Start Julia and activate the package environment:
   ```julia
   using Pkg
   Pkg.activate(".")
   Pkg.instantiate()
   ```

3. Run the tests:
   ```julia
   Pkg.test()
   ```

## Documentation

For detailed documentation, visit our [documentation site](https://yourusername.github.io/Moma.jl/dev/).

The documentation includes:
- Theoretical background on Memory Evolutive Systems
- API reference
- Examples and tutorials
- Detailed explanations of the implemented papers:
  - MES07: Memory Evolutive Systems
  - MES25: Human-Machine Interactions
  - MOMA25: Monetary Macro Accounting

## Development Setup

### Prerequisites
- Julia 1.6 or later
- Git

### Local Development Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/viktorwinschel/moma.git
   cd moma
   ```

2. Set up the development environment:
   ```bash
   julia setup.jl
   ```
   This will:
   - Activate the project in the current directory
   - Add Documenter as a dependency
   - Instantiate the project
   - Set up everything needed for local development

3. Start using the package:
   ```julia
   using Moma
   ```

### Manual Setup
If you prefer manual setup:
```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

## Development Workflow

### Testing
```julia
using Pkg
Pkg.test("Moma")
```

### Documentation Updates
1. Make changes to documentation in `docs/src/`
2. Build documentation locally:
   ```bash
   julia compile_docs.jl
   ```
3. Preview changes in `docs/build/index.html`

### Pushing Changes
To build documentation and push changes to remote:
```bash
julia push_remote.jl
```
This will:
- Build the documentation
- Stage all changes
- Commit with a default message
- Push to the main branch

## Project Structure
```
moma/
├── src/           # Source code
├── test/          # Test files
├── docs/          # Documentation
│   ├── src/      # Documentation source
│   └── make.jl   # Documentation build script
├── setup.jl       # Development setup script
├── compile_docs.jl # Documentation build script
└── push_remote.jl  # Remote update script
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.