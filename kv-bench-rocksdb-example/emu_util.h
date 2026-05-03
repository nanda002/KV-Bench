#ifndef EMU_UTIL_H_
#define EMU_UTIL_H_
#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <sstream>
#include <thread>
#include <cstdio>
#include <memory>        // FIXED: added for std::unique_ptr
#include "sys/times.h"
#include "rocksdb/db.h"
#include "rocksdb/env.h"
#include "rocksdb/convenience.h"
#include "db/db_impl/db_impl.h"
#include "util/cast_util.h"
#include "emu_environment.h"
#include "workload_stats.h"
#include "aux_time.h"
using namespace rocksdb;
// RocksDB-related helper functions
// FIXED: CloseDB now takes std::unique_ptr<DB>& instead of DB*&
// unique_ptr handles delete + nullptr automatically via db.reset()
Status CloseDB(std::unique_ptr<DB> &db, const FlushOptions &flush_op);
// FIXED: ReopenDB now takes std::unique_ptr<DB>& instead of DB*&
Status ReopenDB(std::unique_ptr<DB> &db, const Options &op, const FlushOptions &flush_op);
bool CompactionMayAllComplete(DB *db);
bool FlushMemTableMayAllComplete(DB *db);
// FIXED: BackgroundJobMayAllCompelte now takes plain DB* instead of DB*&
// it doesn't own or null the pointer, so no reference needed
Status BackgroundJobMayAllCompelte(DB *db);
void printEmulationOutput(const EmuEnv* _env, const QueryTracker *track, uint16_t n = 1);
void configOptions(EmuEnv* _env, Options *op, BlockBasedTableOptions *table_op, WriteOptions *write_op, ReadOptions *read_op, FlushOptions *flush_op);
void populateQueryTracker(QueryTracker *track, DB *_db, const BlockBasedTableOptions& table_options, EmuEnv* _env);
void db_point_lookup(DB* _db, const ReadOptions *read_op, const std::string key, const int verbosity, QueryTracker *query_track);
void write_collected_throughput(std::vector<vector<double> > collected_throughputs, std::vector<std::string> names, std::string path, uint32_t interval);
int runWorkload(DB* _db, const EmuEnv* _env, Options *op,
                const BlockBasedTableOptions *table_op, const WriteOptions *write_op,
                const ReadOptions *read_op, const FlushOptions *flush_op, EnvOptions* env_op,
                const WorkloadDescriptor *wd, QueryTracker *query_track,
                std::vector<double >* throughput_collector = nullptr);
std::vector<std::string> StringSplit(std::string &str, char delim);
// Print progress bar during workload execution
inline void showProgress(const uint64_t &n, const uint64_t &count, uint64_t &mini_count) {
  if(count % (n/100) == 0){
  if (count == n || n == 0) {
   std::cout << ">OK!\n";
   return;
  }
    if(count % (n/10) == 0) {
      std::cout << ">" << ++mini_count * 10 << "%<";
      fflush(stdout);
    }
  std::cout << "=";
    fflush(stdout);
  }
}
// Hardcode command to clear system cache
inline void clearPageCache() {
  system("sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'");
}
// Sleep program for milliseconds
inline void sleep_for_ms(uint32_t ms) {
  std::this_thread::sleep_for(std::chrono::milliseconds(ms));
}
#endif /*EMU_UTIL_H_*/
