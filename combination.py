# install pandas
import pandas as pd

# List of CSV filenames separated by comma (change these to match your file names)
csv_files = [
    'example1.csv',
    'example2.csv'
    # Add all your CSV filenames here
]

# Excel file name where CSVs will be combined
excel_file_name = 'combined_data.xlsx'

# Create Excel writer object with xlsxwriter engine
writer = pd.ExcelWriter(excel_file_name, engine='xlsxwriter')

for csv_file in csv_files:
    # Extract tab (worksheet) name from CSV file name
    tab_name = csv_file.replace('.csv', '')[:31]  # Truncate to Excel sheet name limit (31 characters)

    # Read CSV file into DataFrame
    df = pd.read_csv(csv_file)

    # Write DataFrame to Excel as a new worksheet
    df.to_excel(writer, sheet_name=tab_name, index=False)

# Save the Excel file by closing the writer
writer.close()

print(f'Combined {len(csv_files)} CSV files into {excel_file_name} with {len(csv_files)} tabs.')
