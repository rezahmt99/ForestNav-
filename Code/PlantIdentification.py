import requests
import json
import pandas as pd
import os

API_KEY = " "
API_ENDPOINT = "https://my-api.plantnet.org/v2/identify/all"
image_path_1 = "images/IMG_20240424_161323.jpg"
image_path_2 = "images/IMG_20240424_161720.jpg"

# Open image files
with open(image_path_1, 'rb') as image_file_1, open(image_path_2, 'rb') as image_file_2:
    # Create a list of tuples for files
    files = [
        ('images', ('IMG_20240424_161323.jpg', image_file_1)),
        ('images', ('IMG_20240424_161720.jpg', image_file_2))
    ]

    data = {
        'organs': ['flower', 'leaf']
    }

    response = requests.post(API_ENDPOINT, files=files, data=data, params={'api-key': API_KEY})

    if response.status_code == 200:
        result = response.json()
        print("Identification results:")
        print(json.dumps(result, indent=4))  # Print the result with indentation

        # Extract the results
        results = result.get('results', [])

        # Prepare data for the Excel file
        excel_data = {}
        for item in results:
            species = item.get('species', {}).get('scientificNameWithoutAuthor', 'N/A')
            score = item.get('score', 'N/A')

            # Extract the list of probable species and scores
            probable_names = item.get('species', {}).get('commonNames', [])
            if not probable_names:
                probable_names = ['N/A']  # In case there are no common names, ensure we have at least one entry

            # Create or update the entry for the species
            if species not in excel_data:
                excel_data[species] = {
                    'Species': species,
                    'Common Names': set(probable_names),
                    'Score': score
                }
            else:
                excel_data[species]['Common Names'].update(probable_names)

        # Convert common names set to a comma-separated string
        for species, data in excel_data.items():
            data['Common Names'] = ', '.join(data['Common Names'])

        # Create a DataFrame
        df = pd.DataFrame(excel_data.values())

        # Define the output file path
        output_file = os.path.join(os.path.expanduser("~"), "Desktop", "identification_results.xlsx")

        # Save the DataFrame to an Excel file
        df.to_excel(output_file, index=False)
        print(f"Results saved to {output_file}")

    else:
        print("Error:", response.status_code)
