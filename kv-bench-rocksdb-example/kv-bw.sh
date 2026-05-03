#!/bin/bash

RESULT_DIR="./results"
OUTPUT="$RESULT_DIR/64_final_results.csv"
ENTRY_SIZE=64
TOTAL_OPS=3000000

echo "================================================="
echo "KVBench Metrics Extraction"
echo "Format: FT -> Duration(s) -> Throughput(ops/s) -> Latency(us/op) -> Bandwidth(MB/s)"
echo "================================================="

# header
echo "ft,duration_s,throughput_ops_s,latency_us_op,bandwidth_MB_s" > "$OUTPUT"

for ft in $(seq 0 10 100); do

    log="$RESULT_DIR/output_ft_${ft}.log"

    if [[ ! -f "$log" ]]; then
        echo "Skipping ft=$ft (missing log)"
        continue
    fi

    # ---------------- TIME ----------------
    start=$(grep "start_time_ns" "$log" | cut -d= -f2 | head -n1)
    end=$(grep "end_time_ns" "$log" | cut -d= -f2 | head -n1)

    if [[ -z "$start" || -z "$end" ]]; then
        echo "Skipping ft=$ft (missing timestamps)"
        continue
    fi

    duration_ns=$((end - start))
    duration_s=$(echo "$duration_ns / 1000000000" | bc -l)

    # ---------------- METRICS ----------------

    # KVBench sometimes prints avg latency line
    LAT=$(grep -i "micros/op" "$log" | awk '{print $1}' | tail -n1)

    # throughput
    THR=$(grep -i "ops/sec" "$log" | awk '{print $1}' | tail -n1)

    # fallback throughput
    if [[ -z "$THR" ]]; then
        THR=$(echo "$TOTAL_OPS / $duration_s" | bc -l)
    fi

    # fallback latency if missing
    if [[ -z "$LAT" ]]; then
        LAT=$(echo "($duration_s * 1000000) / $TOTAL_OPS" | bc -l)
    fi

    # ---------------- BANDWIDTH ----------------
    bytes=$((TOTAL_OPS * ENTRY_SIZE))
    BW_MBPS=$(echo "$THR * $ENTRY_SIZE / 1024 / 1024" | bc -l)

    # ---------------- OUTPUT ----------------

    echo "$ft -> $duration_s -> $THR -> $LAT -> $BW_MBPS"

    echo "$ft -> $duration_s -> $THR,$LAT,$BW_MBPS" >> "$OUTPUT"

done

echo "================================================="
echo "Done"
echo "Saved -> $OUTPUT"
