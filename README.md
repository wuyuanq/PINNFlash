# PINNFlash

> Physics-Informed Neural Network (PINN) framework for accelerating pressure–temperature (PT) flash calculations.

## Overview

PINNFlash combines thermodynamic flash calculations with physics-informed neural networks (PINNs). Instead of learning only from labeled flash data, the neural network is constrained by thermodynamic equilibrium equations, improving accuracy, robustness, and extrapolation while reducing the amount of required training data.

This repository contains:
- Fortran programs for generating reference PT flash data.
- TensorFlow/Python code for training PINN models.
- Fortran inference code for integrating trained networks into simulation workflows.
- MATLAB scripts for post-processing and visualization.

---

## Repository Layout

```text
PINNFlash/
├── GenerateTrueFlashData_2c/      # Generate two-component reference data
├── GenerateTrueFlashData_3c/      # Generate three-component reference data
├── train.py                       # Main training script
├── PT_flash.py                    # PINN model definition
├── globalData.py                  # Hyperparameters and configuration
├── testNN.F90                     # Fortran neural-network inference
├── RST_getEquResidual.F90         # Thermodynamic residual evaluation
├── RST_plot.m                     # Visualization
├── RST_plot_NP.m                  # Comparison plots
└── Makefile
```

## Workflow

```text
Generate Reference Flash Data (Fortran)
                 │
                 ▼
         Prepare Training Dataset
                 │
                 ▼
     Train Physics-Informed Network
                 │
                 ▼
        Validate Prediction Error
                 │
                 ▼
      Deploy Network for PT Flash
```

## Main Components

### Reference Data Generation
`GenerateTrueFlashData_2c/` and `GenerateTrueFlashData_3c/` contain standalone Fortran implementations that generate high-fidelity PT flash solutions for binary and ternary systems.

### Neural Network Training
`train.py` trains the PINN. Network architecture and training parameters are configured in `globalData.py`.

### Physics Constraints
`RST_getEquResidual.F90` evaluates thermodynamic equilibrium residuals that are incorporated into the PINN loss function.

### Deployment
`testNN.F90` demonstrates how a trained neural network can be called from Fortran for fast flash prediction.

## Installation

### Python
- Python 3.8+
- TensorFlow
- NumPy
- SciPy
- Matplotlib

Install dependencies:

```bash
pip install tensorflow numpy scipy matplotlib
```

### Fortran

Compile the data generators or inference programs using:

```bash
make
```

An Intel Fortran or GNU Fortran compiler is recommended.

## Typical Workflow

1. Generate reference flash data using the 2-component or 3-component generator.
2. Configure training parameters in `globalData.py`.
3. Run

```bash
python train.py
```

4. Evaluate the trained model.
5. Integrate the trained network into simulation through `testNN.F90`.

## Related Publication

Wu, Y., Sun, S.

**Removing the Performance Bottleneck of Pressure–Temperature Flash Calculations during Both the Online and Offline Stages by Using Physics-informed Neural Networks.**

*Physics of Fluids*, 2023.

If this repository contributes to your research, please cite the above publication.

## Future Improvements

- GPU-accelerated training
- Multi-component fluid systems
- Automatic differentiation for thermodynamic properties
- Distributed training
- Coupling with compositional reservoir simulators

## License

MIT license.

## Author

**Dr. Yuanqing Wu**

King Abdullah University of Science and Technology (KAUST)
