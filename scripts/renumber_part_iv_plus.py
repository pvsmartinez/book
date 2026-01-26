import os
import re

base_dir = "03_Manuscript"
parts = ["Part_VI", "Part_V", "Part_IV"]

all_files = []
for part in parts:
    dir_path = os.path.join(base_dir, part)
    if not os.path.exists(dir_path): continue
    files = os.listdir(dir_path)
    for f in files:
        if f.endswith(".md"): 
            match = re.match(r"(\d+)(.*)", f)
            if match:
                num = int(match.group(1))
                all_files.append({
                    "path": os.path.join(dir_path, f),
                    "dir": dir_path,
                    "num": num,
                    "rest": match.group(2)
                })

# Sort descending
all_files.sort(key=lambda x: x["num"], reverse=True)

for f in all_files:
    if f["num"] >= 16:
        new_num = f["num"] + 1
        new_name = f"{new_num}{f['rest']}"
        new_path = os.path.join(f["dir"], new_name)
        print(f"Renaming {f['path']} -> {new_path}")
        os.rename(f['path'], new_path)
