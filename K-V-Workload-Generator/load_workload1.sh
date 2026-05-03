#!/bin/bash
set -euo pipefail

# Entry configuration
ENTRY_SIZE=1024
LAMBDA=0.125

# Workload sizes
PRELOAD_INSERTS=1000000

TOTAL_BENCH_OPS=3000000
BENCH_INSERTS=$((TOTAL_BENCH_OPS * 50 / 100))
BENCH_DELETES=$((TOTAL_BENCH_OPS * 10 / 100))
BENCH_QUERIES=$((TOTAL_BENCH_OPS * 15 / 100))
BENCH_UPDATES=$((TOTAL_BENCH_OPS * 25 / 100))

# Output files
PRELOAD_FILE="workload.txt"
BENCH_FILE="kvbench2_1k_4M.txt"

echo "================================================="
echo "Generating KVBench workload"
echo "ENTRY_SIZE        = ${ENTRY_SIZE}"
echo "LAMBDA            = ${LAMBDA}"
echo "PRELOAD_INSERTS   = ${PRELOAD_INSERTS}"
echo "BENCH INSERTS     = ${BENCH_INSERTS}  (50%)"
echo "BENCH DELETES     = ${BENCH_DELETES}  (10%)"
echo "BENCH QUERIES     = ${BENCH_QUERIES}  (15%)"
echo "BENCH UPDATES     = ${BENCH_UPDATES}  (25%)"
echo "TOTAL BENCH OPS   = ${TOTAL_BENCH_OPS}"
echo "================================================="
echo "Generating preload workload..."

set +e

echo "[PRELOAD] Starting load_gen..."
./load_gen \
  -I "${PRELOAD_INSERTS}" \
  -E "${ENTRY_SIZE}" \
  -L "${LAMBDA}" \
  --ID 0 \
  --OP "${PRELOAD_FILE}"
echo "[PRELOAD] Finiishing load_gen..."

PRELOAD_RC=$?
set -e

echo "Preload generator exit code: ${PRELOAD_RC}"

if [ ! -f "${PRELOAD_FILE}" ]; then
  echo "Error: ${PRELOAD_FILE} was not created"
  exit 1
fi
echo "Generating benchmark workload..."

set +e
echo "[BENCH] Staring load_gen..."
./load_gen \
  --PL \
  -I "${BENCH_INSERTS}" \
  -D "${BENCH_DELETES}" \
  -Q "${BENCH_QUERIES}" \
  -U "${BENCH_UPDATES}" \
  -Z 1.0 \
  --ID 0 \
  --ED 0 \
  --UD 0 \
  -E "${ENTRY_SIZE}" \
  -L "${LAMBDA}" \
  --OP "${BENCH_FILE}"
echo "[BENCH] FINISHING LOAD_GEN..."
BENCH_RC=$?
set -e

echo "Benchmark generator exit code: ${BENCH_RC}"

if [ ! -f "${BENCH_FILE}" ]; then
  echo "Error: ${BENCH_FILE} was not created"
  exit 1
fi

echo "================================================="
echo "Generated files:"
ls -lh "${PRELOAD_FILE}" "${BENCH_FILE}"

echo "Total size:"
du -ch "${PRELOAD_FILE}" "${BENCH_FILE}"

echo "================================================="
echo "Done!"
