# wmt-jetstream

An explanation of how to set up a WMT executor on Jetstream. 


## Install Python

Install a local version of Python.

	mkdir -p /opt/wmt && cd /opt/wmt
    curl https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -o miniconda.sh
    bash ./miniconda.sh -f -b -p $(pwd)/conda
    export PATH=$(pwd)/conda/bin:$PATH
    root=$(pwd)

Install some packages that will be used by the CSDMS toolchain.

    conda install numpy scipy matplotlib netcdf4


## Install the CSDMS toolchain

Using the *csdms-stack* conda channel (the Bakery)
install `cca-bocca`.
This should fetch and install
several dependencies for the CSDMS toolchain,
including `cca-babel`, `cca-spec-babel`, `ccaffeine`,
`chasm`, and `libparsifal`.

    conda install -c csdms-stack cca-bocca

Next, install PyMT.
PyMT requires `esmpy`,
which is currently only found in the *conda-forge* channel.

    conda install -c defaults -c conda-forge esmpy
    conda install -c csdms-stack pymt

Install the `babelizer`.

    conda install -c csdms-stack babelizer

Last, install `wmt-exe`.
There's an open issue, [#7](https://github.com/csdms/wmt-exe/issues/7),
with setting the URL of the WMT server associated with the executor,
so I'm choosing to install it from source.

    mkdir -p $root/opt && cd $root/opt
    git clone https://github.com/csdms/wmt-exe
    cd wmt-exe
    python setup.py develop

Edit line 176 and line 207 of **launcher.py** to use the URL
https://csdms.colorado.edu/wmt/api-analyst.


## Install CSDMS components

Each section below
describes how to install a particular CSDMS component.


### Permamodel

I only have recipes for the point versions of FNM and KuM
in the Bakery, so
clone and install `permamodel` from source.

    mkdir -p $root/opt && cd $root/opt
    git clone https://github.com/permamodel/permamodel
    cd permamodel
    python setup.py develop

Babelize all components.

    cd $root
    mkdir -p build && cd build
    bmi-babelize $root/opt/permamodel --prefix=$root/conda &>build.log &

Test a component by starting a Python session
in **$root/test**
and executing the setup and IRF methods.
```python
from pymt.components import FrostNumberModel

comp = FrostNumberModel()
comp.get_component_name()
# args = comp.setup('.')
# comp.initialize(*args)
comp.setup('.')
comp.initialize('frostnumber_model.cfg')
comp.get_start_time()
comp.get_end_time()
comp.get_current_time()
comp.update()
comp.finalize()
```


### HydroTrend

Install the Hydrotrend component from the Bakery.

    conda install -c csdms-stack csdms-hydrotrend

Test the component by starting a Python session
in **$root/test**
and executing the setup and IRF methods.
```python
from pymt.components import Hydrotrend

comp = Hydrotrend()
comp.get_component_name()
# args = comp.setup('.')
# comp.initialize(*args)
comp.setup('.')
comp.initialize(None)
comp.get_start_time()
comp.get_end_time()
comp.get_current_time()
comp.update()
comp.finalize()
```
