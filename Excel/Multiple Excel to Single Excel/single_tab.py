# install openpyxl

import pandas as pd

# List of Excel files to merge (update with your file paths)
excel_files = [
    "combined_data.xlsx"
]

# Output Excel file name where all tabs will be merged into a single tab
output_excel_file = "merged_data.xlsx"

# Initialize an empty DataFrame to store combined data
combined_data = pd.DataFrame()

# Loop through each Excel file and combine all tabs into a single DataFrame
for file in excel_files:
    # Read all sheets from the Excel file into a dictionary of DataFrames
    xls = pd.ExcelFile(file)
    sheet_names = xls.sheet_names
    
    # Loop through each sheet in the Excel file and append to combined_data
    for sheet_name in sheet_names:
        df = pd.read_excel(file, sheet_name=sheet_name)
        combined_data = pd.concat([combined_data, df], ignore_index=True)

# Write the combined_data DataFrame to a new Excel file with a single tab
combined_data.to_excel(output_excel_file, index=False)

print(f"Merged {len(excel_files)} Excel files into {output_excel_file} with {len(combined_data)} rows.")
