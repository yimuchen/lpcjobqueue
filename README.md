lpcjobqueue
===========
A dask-jobqueue plugin for the LPC Condor queue designed to work with the `coffea-dask` singularity image.


# Installation
You should not need to clone this repository.
From the working directory of your project, download and run the boostrap script:
```bash
curl -OL https://raw.githubusercontent.com/CoffeaTeam/lpcjobqueue/main/bootstrap.sh
bash bootstrap.sh
```
This creates two new files in this directory: `shell` and `.bashrc`. The `./shell`
executable can then be used to start a singularity shell with a coffea environment.
Optionally, one can choose a specific image using e.g. `./shell coffeateam/coffea-dask:coffea-dask:0.7.1-gd5339d7`.
Note the singularity environment does inherit from your calling environemnt, so
it should be "clean" (i.e. no cmsenv, LCG release, etc.)

# Usage
The singularity shell can spawn dask clusters on the LPC condor farm, using the same image for the workers
as the shell environment. Be sure your x509 grid proxy certificate is up to date before starting the shell.
The package assumes your proxy is located in your home directory (as is usual for LPC interactive nodes)

From the shell, the python environment has access to the `lpcjobqueue` package, and in particular,
the `LPCCondorCluster` class. See the class docstring for details on its many arguments.

An example of spinning up an adaptive cluster and executing some work remotely:
```python
from dask.distributed import Client
from lpcjobqueue import LPCCondorCluster


cluster = LPCCondorCluster()
cluster.adapt(minimum=0, maximum=10)
client = Client(cluster)

for future in client.map(lambda x: x * 5, range(10)):
    print(future.result())
```

The coffea `processor.run_uproot_job` function can accept the dask `client` instance.
There is a self-contained simple example of running a coffea job in `simple_example.py`,
you can run it on an LPC login node by doing:
```bash
./shell
wget https://raw.githubusercontent.com/CoffeaTeam/lpcjobqueue/main/simple_example.py
python -i simple_example.py
# wait for it to run and finish
import coffea
coffea.util.save(hists, 'simple_hists.coffea') # plot and such elsewhere / at your leisure
exit()
exit
```

The dask distributed cluster comes with a [dashboard]()
to monitor progress of jobs and some performance metrics. By default it starts on port `8787`
so if you have that port forwarded from your machine to the LPC interactive node it should
be accessible. If the dashboard port is already used on your node, you can override the default
in the `LPCCondorCluster` constructor by specifying `scheduler_options={"dashboard_address": ":12435"}`.
