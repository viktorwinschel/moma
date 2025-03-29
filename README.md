# Moma.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://viktorwinschel.github.io/moma/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://viktorwinschel.github.io/moma/dev)
[![Build Status](https://github.com/viktorwinschel/moma/workflows/CI/badge.svg)](https://github.com/viktorwinschel/moma/actions)
[![Coverage](https://codecov.io/gh/viktorwinschel/moma/branch/main/graph/badge.svg)](https://codecov.io/gh/viktorwinschel/moma)

A Julia package template that you can use as a starting point for your own package.

## Quick Start

### Installation
```julia
using Pkg
Pkg.add("Moma")
```

### Basic Usage
```julia
using Moma
result = example_function(5)  # Returns 10
```

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

## Documentation

### Online Documentation
- [Stable Documentation](https://viktorwinschel.github.io/moma/stable)
- [Development Documentation](https://viktorwinschel.github.io/moma/dev)

### Local Documentation
To build and preview documentation locally:
```bash
julia compile_docs.jl
```
This will:
- Activate the docs environment
- Install necessary dependencies
- Build the documentation
- Output to `docs/build/index.html`

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
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and build documentation
5. Submit a pull request

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.