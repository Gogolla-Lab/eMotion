import numpy as np
import pandas as pd

df_1 = pd.read_csv(r"C:\Users\serce\Desktop\20210525_IPFPro_Plate1-4_Report.csv")
df_2 = pd.read_excel(r"C:\Users\serce\Desktop\IPFPro_sample_list_20210318 - Copy.xlsx", engine='openpyxl', sheet_name=0)

temp_df = pd.DataFrame(index=df_2['Filename'].values, columns=df_1['PG.UniProtIds'].values)

for col in df_1.columns[4:]:
    start_idx = col.find(' ') + 1
    end_idx = col.find('.raw.')
    filename = col[start_idx:end_idx]
    temp_df.loc[filename, :] = df_1.loc[:, col].values

temp_df = temp_df.reset_index()
temp_df = temp_df.rename(columns={'index': 'Filename'})

merged_df = pd.merge(df_2, temp_df, on='Filename')
merged_df.to_csv('merged.csv', index=False)
