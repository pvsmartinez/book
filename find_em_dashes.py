import os

ms_dir = "03_Manuscript"
em_dash = "\u2014"

for root, dirs, files in os.walk(ms_dir):
    for file in files:
        if file.endswith(".md"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8") as f:
                lines = f.readlines()
                for i, line in enumerate(lines):
                    if em_dash in line:
                        print(f"{path}:{i+1}:{line.strip()}")
