from lib2to3.pgen2.pgen import DFAState
import pandas as pd 
import os
import numpy as np
print(os.getcwd())
IN_PATH = os.path.join('OneDrive','Desktop','us_pollution','pollution_rawdata.csv')
df = pd.read_csv(IN_PATH)
df = df[df['State Code']==22]
print(df.head())
""" Note to group: Delete Max hour columns, code columns, and add population column. Find county populations, and weight the measurements by population"""