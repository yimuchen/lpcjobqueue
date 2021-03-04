#!/usr/bin/env bash

cat <<EOF > shell
#!/usr/bin/env bash


if [ "\$1" == "" ]; then
  export COFFEA_IMAGE=coffeateam/coffea-dask:latest
else
  export COFFEA_IMAGE=\$1
fi

singularity exec -B \${PWD}:/srv -B /uscmst1b_scratch --pwd /srv \\
  /cvmfs/unpacked.cern.ch/registry.hub.docker.com/\${COFFEA_IMAGE} \\
  /bin/bash --rcfile /srv/.bashrc
EOF

cat <<EOF > .bashrc
install_env() {
  set -e
  echo "Installing shallow virtual environment in \$PWD/.env..."
  python -m venv --without-pip --system-site-packages .env
  unlink .env/lib64  # HTCondor can't transfer symlink to directory and it appears optional
  .env/bin/python -m pip install -q git+https://github.com/CoffeaTeam/lpcjobqueue.git@v0.2.0
  echo "done."
}

[[ -d .env ]] || install_env
source .env/bin/activate
alias pip="python -m pip"

export JUPYTER_PATH=/srv/.jupyter
export JUPYTER_RUNTIME_DIR=/srv/.local/share/jupyter/runtime
export JUPYTER_DATA_DIR=/srv/.local/share/jupyter
export IPYTHONDIR=/srv/.ipython
EOF

chmod u+x shell .bashrc
echo "Wrote shell and .bashrc to current directory. You can delete this file. Run ./shell to start the singularity shell"
