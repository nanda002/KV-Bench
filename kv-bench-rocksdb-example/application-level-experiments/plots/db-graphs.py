import matplotlib.pyplot as plt
import numpy as np

# DB bench

ft = [0,10,20,30,40,50,60,70,80,90,100]
occ = [0,10,20,30,40,50,60,70,80,90,100]

charts = [
    ("Bandwidth (MB/s) vs Finish Threshold", "Finish Threshold (%)", "Bandwidth (MB/s)",
     [("32 MiB", [24.4,25.1,25,24.6,23.5,22.7,23.4,20.3,20.4,19.1,22.6]),
      ("64 MiB", [37.8,37,36.8,32.6,34.3,30.7,26.8,29.3,27.1,29.6,24.5]),
      ("128 MiB", [57.5,58,56.7,54.9,44.5,44.4,46.6,36,30.9,20.8,20.4])], ft),

    ("Latency (ms) vs Finish Threshold", "Finish Threshold (%)", "Latency (ms)",
     [("32 MiB", [31.937,30.972,31.152,31.581,33.12,34.257,33.292,38.428,38.067,40.777,34.361]),
      ("64 MiB", [20.586,21.02,21.162,23.863,22.694,25.387,29.068,26.57,28.679,26.328,31.757]),
      ("128 MiB", [13.541,13.411,13.714,14.173,17.473,17.543,16.703,21.631,25.211,37.492,38.113])], ft),

    ("IOPS vs Finish Threshold", "Finish Threshold (%)", "IOPS",
     [("32 MiB", [31311,32287,32100,31664,30192,29190,30037,26022,26269,24523,29102]),
      ("64 MiB", [48576,47572,47254,41905,44063,39389,34402,37635,34868,37982,31488]),
      ("128 MiB", [73850,74566,72918,70555,57230,57003,59867,46228,39664,26672,26237])], ft),

    ("Bandwidth (MB/s) vs Finish Threshold (2 zones)", "Finish Threshold (%)", "Bandwidth (MB/s)",
     [("32 MiB", [19.4,20.7,19.5,17.5,17.1,19,17.4,17.7,11.9,13.1,13.4]),
      ("64 MiB", [29.5,31.5,29.1,25.8,24,22.3,21.5,20.5,16.3,12.1,13])], ft),

    ("Latency (ms) vs Finish Threshold (2 zones)", "Finish Threshold (%)", "Latency (ms)",
     [("32 MiB", [40.024,37.649,39.892,44.423,45.574,41.007,44.796,44.05,65.625,59.395,58.168]),
      ("64 MiB", [26.351,24.709,26.706,30.134,32.425,34.902,36.265,37.966,47.7,64.069,59.782])], ft),

    ("IOPS vs Finish Threshold (2 zones)", "Finish Threshold (%)", "IOPS",
     [("32 MiB", [24984,26560,25067,22510,21942,24385,22323,22701,15238,16836,17191]),
      ("64 MiB", [37949,40471,37444,33185,30840,28651,27574,26339,20964,15608,16727])], ft),

    ("Bandwidth (MB/s) vs Occupancy Level", "Occupancy Level (%)", "Bandwidth (MB/s)",
     [("32 MiB", [22.6,19.1,20.4,20.3,23.4,22.7,23.5,24.6,25,25.1,24.4]),
      ("16 MiB", [13.4,13.1,11.9,17.7,17.4,19,17.1,17.5,19.5,20.7,19.4])], occ),

    ("Bandwidth (MB/s) vs Occupancy Level (ascending)", "Occupancy Level (%)", "Bandwidth (MB/s)",
     [("32 MiB", [24.5,29.6,27.1,29.3,26.8,30.7,34.3,32.6,36.8,37,37.8]),
      ("16 MiB", [13,12.1,16.3,20.5,21.5,22.3,24,25.8,29.1,31.5,29.5])], occ),
]

fig, axes = plt.subplots(len(charts) + 1, 1, figsize=(10, 5 * (len(charts) + 1)))

colors = ['steelblue', 'red', 'black']

for ax, (title, xlabel, ylabel, series, x) in zip(axes, charts):
    for (label, data), color in zip(series, colors):
        ax.plot(x, data, marker='o', linewidth=2, markersize=5, label=label, color=color)
    ax.set_xlabel(xlabel, fontsize=11)
    ax.set_ylabel(ylabel, fontsize=11)
    ax.set_xticks(x)
    ax.set_title(title)
    ax.grid(True, linestyle='--', linewidth=0.6, alpha=0.6)
    ax.legend(loc="upper right")

# Garbage bytes bar chart
axes[-1].bar(ft, [252,179,117,448,188,258,160,257,153,188,153], color='steelblue', alpha=0.7)
axes[-1].set_title("Total Garbage Bytes vs Finish Threshold")
axes[-1].set_xlabel("Finish Threshold (%)", fontsize=11)
axes[-1].set_ylabel("Garbage Bytes", fontsize=11)
axes[-1].set_xticks(ft)
axes[-1].grid(True, linestyle='--', linewidth=0.6, alpha=0.6)

plt.tight_layout()
plt.savefig("zns_charts.png", dpi=150)
plt.show()





# KV bench

# FT values
ft = [100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 0]

# --- 32 MiB ---

latency_32 = [643.213993865667,778.043501947,780.885968619,400.812246417667,980.993684827333,614.95177048,527.032898050333,833.401226067667,661.990120013667,2002.886622325,2123.421701014]

bandwidth_32 = [
    0.09489090230015582,0.07844697127765189,0.07816142010841983,0.15227867111225508,0.062217685183919324,0.09925194003809286,0.1158090063747234,0.073236220851257,0.09219949725041205,0.02438590534049152,0.028743775304195964]


# --- 64 MiB ---

latency_64 = [209.875386157667,224.110288611667,216.341467302667,239.185537462667,240.826906442,231.088805522333,234.263370374333,247.421630035,279.359318691333,530.180841038667,1190.60790352333]

bandwidth_64 = [0.290816171288176,0.272344284718496,0.282124166998509,0.255179125366335,0.253439938052352,0.264119917501159,0.260540758687416,0.246684803755298,0.218482621363486,
                0.115121391656528,0.0512638594699232]


# --- 128 MiB ---

latency_128 = [151.449920024,162.215374943667,145.350847578667,152.053673508,191.000671860667,178.235220554667,179.510845786333,189.326844806333,216.685796753333,
               274.948674129333,1077.38481066033]

bandwidth_128 = [0.806011072707438,0.752519991045189,0.839832133995182,0.802810676544276,0.639109335641758,0.684883224090716,0.680016363163354,0.644759662185616,0.563351702460499,
                 0.443974908722707,0.113302425736987]


# Create subplots
fig, axs = plt.subplots(1, 2, figsize=(23, 7))

# --- Latency ---
axs[0].plot(ft, latency_32, marker='o', linewidth=2, markersize=5, label="32 MiB")
axs[0].plot(ft, latency_64, marker='o', linewidth=2, markersize=5, label="64 MiB", color='red')
axs[0].plot(ft, latency_128, marker='o', linewidth=2, markersize=5, label="128 MiB", color='black')
axs[0].set_xlabel("Occupancy Level (%)", fontsize=11)
axs[0].set_ylabel("Latency (us/op)", fontsize=11)
axs[0].set_xticks(ft)
axs[0].grid(True, linestyle='--', linewidth=0.6, alpha=0.6)
axs[0].legend(loc="upper right")

# --- Bandwidth ---
axs[1].plot(ft, bandwidth_32, marker='o', linewidth=2, markersize=5, label="32 MiB")
axs[1].plot(ft, bandwidth_64, marker='o', linewidth=2, markersize=5, label="64 MiB", color='red')
axs[1].plot(ft, bandwidth_128, marker='o', linewidth=2, markersize=5, label="128 MiB", color='black')
axs[1].set_xlabel("Occupancy Level (%)", fontsize=11)
axs[1].set_ylabel("Bandwidth (MB/s)", fontsize=11)
axs[1].set_xticks(ft)
axs[1].grid(True, linestyle='--', linewidth=0.6, alpha=0.6)
axs[1].legend(loc="upper right")

plt.tight_layout()
plt.show()