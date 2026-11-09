#!/bin/bash
# Find invalid joblib files

eval "$(conda shell.bash hook)" || exit 1
conda activate eventdisplay_ml || exit 1
trap 'conda deactivate' EXIT

find . \
  -type f \( -name '*.joblib' -o -name '*.joblib.gz' \) \
  -exec sh -c '
    for file do
      timeout 15s prlimit --as=4294967296 -- \
        env OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 \
        "$CONDA_PREFIX/bin/python" -c "import joblib,sys; joblib.load(sys.argv[1])" "$file" \
        >/dev/null 2>&1
      status=$?
      if [ "$status" -ne 0 ]; then
        printf "SUSPECT status=%s %s\n" "$status" "$file"
      fi
    done
  ' sh {} +
