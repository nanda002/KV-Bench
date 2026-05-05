# KV-Bench + ZenFS on RocksDB (ZNS SSD Evaluation)

![Build](https://img.shields.io/badge/build-passing-brightgreen)
![C++](https://img.shields.io/badge/C%2B%2B-11-blue)
![Platform](https://img.shields.io/badge/OS-Linux-lightgrey)

This repository contains the setup and execution pipeline for running KVBench workloads on a Zoned Namespace (ZNS) SSD using RocksDB integrated with ZenFS. The framework evaluates application-level performance under different workload distributions and device configurations.

---

## Prerequisites

| Item | Notes |
|------|--------|
| *OS* | Linux (Ubuntu 20.04 / 22.04 recommended) |
| *Compiler* | GCC / G++ **11.x** |
| *Packages* | `libzbd`, `nvme-cli`, `cmake`, `libgflags-dev`, `libsnappy-dev`, `zlib1g-dev`, `libbz2-dev`, `liblz4-dev`, `libzstd-dev` |

Install dependencies (example on Ubuntu):

```bash
sudo apt update
sudo apt install -y libzbd-dev nvme-cli cmake libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev build-essential
```

**GCC 11 as default**

If GCC 11 is not already the default `gcc` / `g++`:

```bash
sudo apt install -y gcc-11 g++-11
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100
```

---

## Clone

```bash
git clone https://github.com/nanda002/KV-Bench.git
cd KV-Bench
```

---

## Build pipeline

### 1. RocksDB (static library)
If Rocksdb not already installed
#### Build
Download, build and install rocksdb from the [README](https://github.com/cbmary27/RocksDB-ZenFS/blob/main/README.md) for instructions

#### Link Rocksdb if already installed

If you already have RocksDB installed, you can link against it directly instead of rebuilding:
bash 
```
cd kv-bench
export rocksdbpath=/absolute/path/to/rocksdb
```

### 2. ZenFS util + linker patches + benchmark binary

ZenFS ships under `plugin/zenfs`. The benchmark needs **whole-archive** linking for `librocksdb.a` and explicit **libzbd** linkage.

bash
```
cd plugin/zenfs/util
make
```

Patch the Makefile (run from `plugin/zenfs/util` with `rocksdbpath` exported as above):

```bash
sed -i "s|\${rocksdbpath}/librocksdb.a|-Wl,--whole-archive \${rocksdbpath}/librocksdb.a -Wl,--no-whole-archive|g" Makefile
sed -i 's|-Wl,--no-whole-archive|-Wl,--no-whole-archive -lzbd|g' Makefile

make clean
make plain_benchmark
```

You should end up with a `plain_benchmark` binary in this tree (exact path follows your Makefile output).

## 3. Run the benchmark Example

Use **sudo** only if raw NVMe/ZNS access requires it. Replace paths and device names with yours.

#### Example

```bash
sudo ./plain_benchmark -E 128 --dd \
  --iwp /..path/rocksdbTest/workloads/ingestion.txt \
  --qwp /..path/rocksdbTest/workloads/ingestion.txt \
  --dw --dr \
  --fs_uri="zenfs://dev:nvmeXnX"
```
---
## Testing

For Garbage Collection:

```bash
./application-level-experiments/kv-bench_scripts/test_ft_kv.sh
```
For Dummy Pages:
```bash
./application-level-experiments/kv-bench_scripts/test_ft_pages.sh
```

For latency and bandwidth
```bash
```

---

#### Arguments (quick reference)

| Flag | Meaning |
|------|---------|
| `-E 1024` | Entry size **1024** (bytes; confirm against your workload generator). |
| `--dd` | **Direct I/O** for data path. |
| `--iwp` | **Ingestion** workload profile path. |
| `--qwp` | **Query** workload profile path. |
| `--dw` | Enable **data write** phase / path as defined by KV-Bench. |
| `--dr` | Enable **data read** phase / path as defined by KV-Bench. |
| `--fs_uri` | ZenFS backing device, e.g. `zenfs://dev:<zns-namespace>` |

Use `nvme list` / `nvme zns ...` as appropriate to confirm the correct ZNS device name.

---

## Notes

- **Workload files:** Point `--iwp` / `--qwp` at real traces or generated profiles on your machine; the sample paths above are placeholders.
- **Safety:** Double-check `--fs_uri` — ZenFS will use the given block device; wrong device names are destructive.
- **Reproducibility:** Record kernel version, `libzbd` / RocksDB / ZenFS commits, and firmware when publishing numbers.
