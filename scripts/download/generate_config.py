import os
import sys
import pandas as pd
import yaml

# Define input/output paths
input_csv = "config/SraRunTable.csv"
output_yaml = "config/config.yaml"

def main():
    # Step 1: Check if the input CSV exists
    if not os.path.exists(input_csv):
        print(f"Error: Metadata file not found at {input_csv}")
        sys.exit(1)

    try:
        # Step 2: Load the CSV file
        df = pd.read_csv(input_csv)
    except Exception as e:
        print(f"Error reading {input_csv}: {e}")
        sys.exit(1)

    # Step 3: Check if 'Run' column exists
    if "Run" not in df.columns:
        print("Error: 'Run' column not found in the SRA metadata.")
        sys.exit(1)

    # Step 4: Extract and validate SRA IDs
    sra_ids = df["Run"].dropna().unique().tolist()
    if not sra_ids:
        print("Error: No SRA IDs found in the 'Run' column.")
        sys.exit(1)

    # Step 5: Write to config.yaml
    try:
        with open(output_yaml, "w") as f:
            yaml.dump({"sra_ids": sra_ids}, f, sort_keys=False)
        print(f"config.yaml created with {len(sra_ids)} SRA run IDs at {output_yaml}")
    except Exception as e:
        print(f"Error writing config file: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

