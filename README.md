# US Average Food Prices Over Time
![Grocery Store Sample Image](https://github.com/NickElias01/Capstone_CodeLouisville/assets/134450333/4f5cfe51-fb87-44f8-8354-64023ab68294)

Welcome to my Code:You Capstone project! This analysis utilizes SQL executed through Pandas within a Jupyter notebook, accompanied by a Tableau Public dashboard for visualization.

## Project Overview

The objective of this project is to analyze trends in the price fluctuations of common grocery products, such as milk, eggs, and coffee, from 1980 to 2023. Additionally, the dataset includes information on electricity costs per kilowatt-hour (KWH) and gasoline prices, providing a comprehensive view of consumer trends over time.

### Data Source

The data used in this analysis is sourced from the U.S. Bureau of Labor Statistics. For more details, visit: [Bureau of Labor Statistics - CPI Data](https://www.bls.gov/cpi/data.htm)

## Instructions

1. Ensure you have the latest version of Python installed on your device.
2. Clone this repository to access the necessary CSV files and database file.
3. Open the Jupyter notebook (.ipynb file) to explore the SQL queries and resulting tables.
4. View the Tableau visualization through the following link: [Tableau Visualization](https://public.tableau.com/app/profile/nick.elias/viz/USGroceryData1980-2023/Dashboard1)

### Setting Up the Environment

To ensure all dependencies are correctly installed, follow these steps:

1. **Create a Virtual Environment**:
   - Navigate to the project directory.
   - Run the following command to create a virtual environment (if you haven't done so already):
     ```bash
     python -m venv .venv
     ```

2. **Activate the Virtual Environment**:
   - On Windows:
     ```bash
     .venv\Scripts\activate
     ```
   - On macOS/Linux:
     ```bash
     source .venv/bin/activate
     ```

3. **Install Required Packages**:
   - Make sure your `requirements.txt` file is up to date. To install the required packages, run:
     ```bash
     pip install -r requirements.txt
     ```

### Raw Data Files

- `grocery_data.csv`
- `product_mapping.csv`

## Key Findings

- The average price of tomatoes surged by **118%** in 1990.
- Bacon prices increased from **$1.64 per lb** in October 1980 to **$7.22 per lb** in October 2023.
- Unleaded gasoline was, on average, **$0.61 per gallon** in 1976, rising to **$3.71 per gallon** in 2023.