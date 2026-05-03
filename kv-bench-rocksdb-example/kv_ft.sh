#!/bin/bash
set -euo pipefail
#THRESHOLDS="40"
AUX_PATH="/home/femu/RocksDBFile/zenfs_aux"
DB_BENCH="/home/femu/RocksDBFile/rocksdb/db_bench"
FS_URI="zenfs://dev:nvme0n1"
ZENFS_MKFS="/home/femu/RocksDBFile/rocksdb/plugin/zenfs/util/zenfs"
RESULT_DIR="/home/femu/RocksDBFile/kv-bench/kv-bench-rocksdb-example/results"
WORKLOAD_DIR="/home/femu/RocksDBFile/kv-bench/K-V-Workload-Generator"
INGESTION_WL="$WORKLOAD_DIR/workload.txt"
QUERY_WL="$WORKLOAD_DIR/kvbench2_1k_4M.txt"

# Safety checks
if [ ! -f "$INGESTION_WL" ]; then
  echo "Error: Missing ingestion workload at $INGESTION_WL"
  exit 1
fi

if [ ! -f "$QUERY_WL" ]; then
  echo "Error: Missing query workload at $QUERY_WL"
  exit 1
fi

mkdir -p "$RESULT_DIR"

THRESHOLDS=$(seq 0 10 100)
#THRESHOLDS=

for FT in $THRESHOLDS; do

    echo "==============================================="
    echo "Running benchmark for finish_threshold=${FT}"
    echo "==============================================="
    sudo nvme zns reset-zone /dev/nvme0n1 -a
    sudo rm -rf "${AUX_PATH:?}"/*
    echo mq-deadline | sudo tee /sys/class/block/nvme0n1/queue/scheduler > /dev/null

    sudo $ZENFS_MKFS mkfs \
        --zbd=nvme0n1 \
        --aux_path="$AUX_PATH" \
        --force \
        --finish_threshold=$FT

    START_TIME=$(date +%s%N)

    LOG="$RESULT_DIR/output_ft_${FT}.log"
    echo "start_time_ns=$START_TIME" > "$LOG"

    echo "[RUN] Starting plain_benchmark at $(date)" | tee -a "$LOG"

    sudo ./plain_benchmark \
        -E 128 \
        --dd \
        -p /db \
        --iwp "$INGESTION_WL" \
        --qwp "$QUERY_WL" \
        --dw --dr \
        --fs_uri="$FS_URI" \
        >> "$LOG" 2>&1
    sudo nvme zns reset-zone /dev/nvme0n1 -a
    END_TIME=$(date +%s%N)
    echo "end_time_ns=$END_TIME" >> "$LOG"

    echo "[RUN] Finished plain_benchmark at $(date)" | tee -a "$LOG"

    echo "Finished benchmark for finish_threshold=${FT}"

done

echo "==============================================="
echo "All benchmarks completed."
echo "==============================================="
