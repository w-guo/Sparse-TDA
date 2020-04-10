# Sparse-TDA

This code implements the Sparse-TDA method that integrates QR pivoting-based sparse sampling algorithm into persistence images to transform topological features into image pixels and identify discriminative pixel samples in the presence of noisy and redundant information. 

<p align="center">
    <img src="https://github.com/w-guo/Sparse-TDA/blob/master/Sparse_TDA_pipeline.png" width="640"> <br />
    <em> Pipeline of Sparse-TDA method for multi-way classification</em>
</p>

Please cite the following paper if you make use of the code.

```
@article{guo2018sparse,
  title={Sparse-TDA: Sparse realization of topological data analysis for multi-way classification},
  author={Guo, Wei and Manohar, Krithika and Brunton, Steven L and Banerjee, Ashis G},
  journal={IEEE Transactions on Knowledge and Data Engineering},
  volume={30},
  number={7},
  pages={1403--1408},
  year={2018},
  publisher={IEEE}
}
```

## Overview

- **[Setup](#installation)**
  - [Compiling DIPHA](#compiling-dipha)
  - [Additional 3rd party tools](#additional-3rd-party-tools)
  - [Compiling dipha-pss (optional)](#compiling-dipha-pss-(optional))
- **[Examples](#examples)**
  - [Human posture recognition](#human-posture-recognition)
  - [Image texture detection](#image-texture-detection)

## Setup

First, clone this repository and all the submodules via

```bash
git clone https://github.com/w-guo/Sparse-TDA.git
cd Sparse-TDA
git submodule update --init --recursive   
```

### Compiling DIPHA

The persistence diagrams (PDs) are computed using DIPHA which requires MPI support. You can install, e.g., OpenMPI. On MacOS, this can be simply done via

```bash
brew install open-mpi
```

Once this has finished, change into the ```code/external/dipha``` directory
and create a ```build``` directory, then use ```cmake``` to
configure the build process, e.g.,

```bash
cd code/external/dipha
mkdir build
cd build
cmake ..
make
```

### Additional 3rd party tools

For the full pipeline to work, we also need 

1. [LIBSVM](https://github.com/cjlin1/libsvm)
2. [PersistenceImages](https://github.com/w-guo/PersistenceImages/tree/322852ac4a6f401955cad7e41b5d31be2a114a5e)
3. [iso2mesh](https://github.com/fangq/iso2mesh)
4. [(Scale-Invariant) Heat-Kernel Signature](http://vision.mas.ecp.fr/Personnel/iasonas/code/sihks.zip)
5. [Completed Local Binary Pattern](http://www.comp.polyu.edu.hk/~cslzhang/code/CLBP.rar)
  
where LIBSVM, PersistenceImages and iso2mesh should be The script ```setup.m``` expects these software packages to be available under ```code/external``` 

### Compiling dipha-pss (optional)

You will need to compile ```dipha-pss``` in case you want to compute your own persistence diagrams. You can compile ```dipha-pss``` via

```bash
cd code/dipha-pss
mkdir build
cd build
cmake ..
make
```
