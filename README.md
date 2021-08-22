# Sparse-TDA

This code implements the Sparse-TDA method that integrates QR pivoting-based sparse sampling algorithm into persistence images to transform topological features into image pixels and identify discriminative pixel samples in the presence of noisy and redundant information. 

<p align="center">
    <img src="https://github.com/w-guo/wguo/blob/master/content/publication/sparse-tda/Sparse_TDA_pipeline.png" width="840"> <br />
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

- **[Setup](#setup)**
  - [Compiling DIPHA](#compiling-dipha)
  - [Additional 3rd party tools](#additional-3rd-party-tools)
  - [Compiling dipha-pss (optional)](#compiling-dipha-pss-optional)
- **[Usage](#usage)**
 

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

1. [libsvm](https://github.com/cjlin1/libsvm)
2. [PersistenceImages](https://github.com/w-guo/PersistenceImages/tree/322852ac4a6f401955cad7e41b5d31be2a114a5e) (nonlinear weighting function is added to our fork)
3. [iso2mesh](https://github.com/fangq/iso2mesh)
4. [(Scale-Invariant) Heat-Kernel Signature](http://vision.mas.ecp.fr/Personnel/iasonas/code/sihks.zip)
5. [Completed Local Binary Pattern](http://www.comp.polyu.edu.hk/~cslzhang/code/CLBP.rar)
  
where libsvm, PersistenceImages and iso2mesh should have been downloaded during the ```git submodule update``` into ```code/external```. Please follow the libsvm documentation on how to compile the MATLAB interface. Then download the last two packages and put them under ```code/external```. 

### Compiling dipha-pss (optional)

This repository also contains the code for the *persistence scale space* (PSS) kernel method that is used for comparison in our paper. The core code for computing the kernel is provided by [Roland Kwitt](https://github.com/rkwitt/persistence-learning/tree/master/code/dipha-pss), and we include a copy under ```code```. In case you want to replicate the results using the PSS kernel method, you also need to compile ```dipha-pss``` via

```bash
cd code/dipha-pss
mkdir build
cd build
cmake ..
make
```
 

## Usage

Create a ```data``` folder under this repository. The data sets used in our paper can be found at  
- [Download](http://www.cs.cf.ac.uk/shaperetrieval/download.php) SHREC14
- [Download](http://www.outex.oulu.fi/db/classification/tmp/Outex_TC_00000.tar.gz) Outex_TC_00000

Unpack the downloaded datasets to ```/data```. The essential results from our paper can be reproduced by the main scripts in the ```SHREC``` and ```Outex``` folders
- ```run_*_kernel.m```
- ```run_*_sparse.m```
- ```run_*_sparse_multiple_samples.m```
  
For example, if you want to generate the results from the Outex data set using the Spase-TDA method in Table 1 & 2, just run
```matlab
cd code/matlab
setup % load required packages
cd Outex
run_Outex_sparse
```
