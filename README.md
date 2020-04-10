# Sparse-TDA

This code implements the Sparse-TDA method proposed in the following publication. 

![Pipeline](https://github.com/w-guo/Sparse-TDA/blob/master/Sparse_TDA_pipeline.png "Pipeline")

<p align="center">
    <em> Pipeline of Sparse-TDA method for multi-way classification</em>
</p>
Please cite our work if you make use of the code.

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
  - [Compiling LIBSVM](#compiling-libsvm)
  - [Additional 3rd party tools](#additional-3rd-party-tools)
  - [Compiling dipha-pss (optional)](#compiling-dipha-pss)
- **[Examples](#examples)**
  - [Human posture recognition](#human-posture-recognition)
  - [Image texture detection](#image-texture-detection)

## Setup

The persistence diagrams (PDs) are computed using DIPHA. After you have clone the repository and the submodules via

```bash
git clone https://github.com/w-guo/Sparse-TDA.git
cd Sparse-TDA
git submodule update --init --recursive   
```

### Compiling DIPHA

Prerequisites:

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
### Compiling LIBSVM
### Additional 3rd party tools

For the full pipeline to work, we also need 

1. iso2mesh
2. [(Scale-Invariant) Heat-Kernel Signature](http://vision.mas.ecp.fr/Personnel/iasonas/code/sihks.zip)
3. [Completed Local Binary Pattern](http://www.comp.polyu.edu.hk/~cslzhang/code/CLBP.rar)
  
### Compiling dipha-pss (optional)

```bash
cd code/dipha-pss
mkdir build
cd build
cmake ..
make
```