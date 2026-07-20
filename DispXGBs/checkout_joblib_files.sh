#!/bin/bash
# Find invalid joblib files

find . \
  -type f \( -name '*.joblib' -o -name '*.joblib.gz' \) \
  -exec sh -c '
    for file do
      timeout 15s prlimit --as=4294967296 -- \
        python -c "import joblib,sys; joblib.load(sys.argv[1])" "$file" \
        >/dev/null 2>&1
      status=$?
      if [ "$status" -ne 0 ]; then
        printf "SUSPECT status=%s %s\n" "$status" "$file"
      fi
    done
  ' sh {} +
