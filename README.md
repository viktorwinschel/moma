# Moma.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://viktorwinschel.github.io/moma/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://viktorwinschel.github.io/moma/dev)
[![Build Status](https://github.com/viktorwinschel/moma/workflows/CI/badge.svg)](https://github.com/viktorwinschel/moma/actions)
[![Coverage](https://codecov.io/gh/viktorwinschel/moma/branch/main/graph/badge.svg)](https://codecov.io/gh/viktorwinschel/moma)

A Julia package template that you can use as a starting point for your own package.

## Installation

### For Users
To install Moma, use the Julia package manager:

```julia
using Pkg
Pkg.add("Moma")
```

### For Developers
To develop Moma locally:

1. Clone the repository:
   ```bash
   git clone https://github.com/viktorwinschel/moma.git
   cd moma
   ```

2. Start Julia and enter the package manager mode by pressing `]`, then:
   ```julia
   activate .
   instantiate
   ```
   
   Or use the setup script:
   ```bash
   julia setup.jl
   ```
   The `setup.jl` script will:
   - Activate the project in the current directory
   - Add Documenter as a dependency
   - Instantiate the project
   - Set up everything needed for local development

3. You can now use the package in your Julia REPL:
   ```julia
   using Moma
   ```

## Usage

```julia
using Moma

# Example usage
result = example_function(5)  # Returns 10
```

## Documentation

For more information, please visit the [documentation](https://viktorwinschel.github.io/moma/stable).

### Building Documentation Locally
To build and preview the documentation locally:

```bash
julia compile_docs.jl
```

This will:
- Activate the docs environment
- Install necessary dependencies
- Build the documentation
- Output the documentation to `docs/build/index.html`

You can then open `docs/build/index.html` in your web browser to view the documentation.

## Development

To develop Moma locally:

1. Clone the repository
2. Start Julia and enter the package manager mode by pressing `]`
3. Activate the development environment:
   ```julia
   activate .
   ```
4. Install dependencies:
   ```julia
   instantiate
   ```
5. Run tests:
   ```julia
   test
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.