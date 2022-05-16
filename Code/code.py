import os
from numpy import int64
import pandas as pd
os.chdir('C:/Users/rasha_um7aj52/OneDrive/Desktop/TS_Pollution/Data')
df_death = pd.read_csv('deaths_raw.csv')
df_death[['Year1','Month1']] = df_death['Month Code'].str.split('/',expand = True)
df_death = df_death.fillna(0)
print(df_death['Year Code'])
df_death_la = df_death[df_death['State'] == 'Louisiana']
df_death_la = df_death_la[df_death_la.Year != 1999]
df_death_la = df_death_la[['Month1','Year1','Deaths']]
df_death_la = df_death_la.rename({'Month1':'Month','Year1':'Year'}, axis = 1)
print(df_death_la.head())
df_death_la['Month'] = df_death_la['Month'].astype(str).astype(int)
df_death_la['Year'] = df_death_la['Year'].astype(str).astype(int)
df_death_la['Deaths'] = df_death_la['Deaths'].astype(str).astype(int)

print(list(df_death_la.columns.values))
print(df_death_la.dtypes)


df_pol = pd.read_csv('pollution_rawdata.csv')
df_pol[['Day','Month','Year']] = df_pol['Date Local'].str.split(',', expand = True)
df_pol[['Delete','Month','Date']] = df_pol['Month'].str.split(' ', expand = True)
d = {'January':1,'February':2,'March':3,'April':4,'May':5,'June':6,'July':7,'August':8,'September':9,'October':10,'November':11,'December':12}
df_pol.Month = df_pol.Month.map(d)
df_monpol = df_pol.groupby(by = ['Month','Year','State']).mean().reset_index()
df_monpol = df_monpol[['State','Month','Year','NO2 Mean','O3 Mean','SO2 Mean','CO Mean']]
df_pol_la = df_monpol[df_monpol['State'] == 'Louisiana']
df_pol_la['Year'] = df_pol_la['Year'].astype(str).astype(int)
print(df_pol_la.head())
print(list(df_pol_la.dtypes))
death_pol_df = pd.merge(df_pol_la, df_death_la,  left_on = ['Month','Year'], right_on = ['Month','Year'])
print(death_pol_df.head()) 