import sys
import os
import pandas as pd
import numpy as np
import csv

file = sys.argv[1]

data = pd.read_csv(file)
offset_count = 0 
offset_total = 0

for offset in data["offset"]:
    if offset != 0:
        offset_count += 1
        offset_total += offset
    else:
        continue

avg_offset = offset_total / offset_count

filename = os.path.basename(file)
filename = filename[:-4] + "-SYNCED.csv"

print("Average offset calculated: ", avg_offset)
print("Writing file to: ", filename, "-SYNCED.csv")

data["timestamp"] -= avg_offset

print(data)

data.to_csv(filename, index=False)
