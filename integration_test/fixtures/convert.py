import csv
import json
import os

# Define the input and output file paths
csv_file_path = 'integration_test/fixtures/addresses.csv'
json_file_path = 'integration_test/fixtures/s.json'

# Ensure the output directory exists
os.makedirs(os.path.dirname(json_file_path), exist_ok=True)

# Read the CSV file and convert each row to a dictionary
with open(csv_file_path, mode='r', newline='') as csv_file:
    reader = csv.DictReader(csv_file)
    data = [row for row in reader]

# Write the list of dictionaries to a JSON file
with open(json_file_path, mode='w') as json_file:
    json.dump(data, json_file, indent=4)