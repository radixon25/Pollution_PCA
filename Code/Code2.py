import pandas as pd 
import os
import numpy as np
os.chdir('C:/Users/rasha_um7aj52/OneDrive/Desktop/us_pollution')
os.getcwd()
df = pd.read_csv('final.csv')
print(df.head())
print(df.index.dtype)
df['T-1'] = df['Month'] - df['Month'].shift(periods = 1)
df['D-1']= df['Deaths'].shift()
df['o3-1'] = df['O3 Mean'].shift()
df['SO2-1'] = df['SO2 Mean'].shift()
df['CO-1'] = df['CO Mean'].shift()
df['C_D'] =df.apply(lambda row: 0 if row['Year'] == 2000 else row['Deaths'] - row['D-1'], axis=1)
df['C_o3'] =df.apply(lambda row: 0 if row['Year'] == 2000 else row['O3 Mean'] - row['o3-1'], axis=1)
df['C_SO2'] =df.apply(lambda row: 0 if row['Year'] == 2000 else row['SO2 Mean'] - row['SO2-1'], axis=1)
df['C_CO'] =df.apply(lambda row: 0 if row['Year'] == 2000 else row['CO Mean'] - row['CO-1'], axis=1)
print(df)
df.to_csv('final_updated.csv')