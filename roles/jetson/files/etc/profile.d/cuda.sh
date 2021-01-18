# Check for bash
if [ -n "${BASH_VERSION-}" ]; then
    if [[ $PATH != */usr/local/cuda/bin* ]]; then
        export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
    fi
    if [[ $LD_LIBRARY_PATH != */usr/local/cuda/lib64* ]]; then
        export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    fi
fi
