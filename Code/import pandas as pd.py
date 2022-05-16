import pandas as pd 
import os
import numpy as np
os.chdir('C:/Users/rasha_um7aj52/OneDrive/Desktop/us_pollution')
os.getcwd()
df = pd.read_csv('final.csv')
print(df.head())
print(df.index.dtype)
df['T-1'] = df['Month'].shift(periods = 1, fill_value= 0)
df['D-1'] = df['Deaths'].shift(periods=1,fill_value=0)
df['YOY_Change'] = np.NAN
#create column that is YOY difference in deaths
for i,row in df.iterrows():
    while row['Month'] == row['T-1']:
        row['YOY_Change'] = row['Deaths']- row['D-1']
print(df.head())