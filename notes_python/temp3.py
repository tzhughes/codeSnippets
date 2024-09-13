import pandas as pd


# Create a DataFrame with the required data
data = {
    'name': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'age': [25, 30, 35, 40, 45],
    'city': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix']
}
print(data)
df = pd.DataFrame(data)
print(df)


