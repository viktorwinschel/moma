# Papers

This section provides an overview of the papers that form the theoretical foundation of the MOMA package.

## [MES07](mes07.md)
**Memory Evolutive Systems: Hierarhy, Emergence, Cognition**:
[pdf](assets/mes07.pdf) - A comprehensive synthesis of two decades of research on memory evolutive systems, presenting mathematical models for autonomous evolutionary systems such as biological, social, and nervous systems.

## [MES23](mes23.md)
**A Mathematical Framework for Enriching Human–Machine Interactions**:
[pdf](assets/mes23.pdf) - Analysis of human-machine interactions using MES framework.

## [MOMA25](moma25.md)
**Monetary Macro Accounting Theory (MoMaT)**:
[pdf](assets/moma25.pdf) - A monetary macro accounting theory.

### Original MOMA Simulation Files

The `src/original_moma` directory contains several files used for generating and checking simulation data
underlying the moma25 paper.

### Simulation Files
- `momascf_check.jl`: Validates the generated simulation data against expected results
- `momascf_original.jl`: Contains the original implementation of the MOMA simulation
- `momascf_v01.jl`: First version of the simulation with initial improvements
- `momascf_v02.jl`: Second version with enhanced functionality
- `momascf_v02_en.jl`: English version of v02 with additional documentation

### Associated Data Files
Each simulation file has four corresponding data files:
- `momascf_original_data.csv`: Data for the original implementation
- `momascf_v01_data.csv`: Data for version 1
- `momascf_v02_data.csv`: Data for version 2
- `momascf_v02_en_data.csv`: Data for the English version

These files demonstrate the evolution of the MOMA implementation and provide test data for the current version of the package.

### National Accounting Simulation
The following image shows an example of the basic national accounting structure used in the simulations:

![Basic National Accounting Structure](assets/bookings.png) 