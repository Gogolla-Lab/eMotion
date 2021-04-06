import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, confusion_matrix

# Path to aggregated.h5 file
data_path = r"C:\Users\serce\Desktop\aggregated.h5"

data = pd.read_hdf(data_path)  # Read in the data
data = data.dropna(axis='columns')  # Drop columns containing na

# Subset the DataFrame
subset_labels = ['animal', 'day', 'ts', 'zscore', 'Eating Zone', 'Eating']
subset = data.loc[:, subset_labels]

# Classify behavior
choices = ['in', 'eating', 'out']
conditions = [
    subset['Eating Zone'].eq(True) & subset['Eating'].eq(False),
    subset['Eating Zone'].eq(True) & subset['Eating'].eq(True),
    subset['Eating Zone'].eq(False) & subset['Eating'].eq(False)
]
subset['behavior'] = np.select(conditions, choices, default='error')

# print(subset.loc[subset['behavior'] == 'error'])  # ask Alja why this is happening?

subset = subset[subset['behavior'] != 'error']
subset = subset[subset['ts'] <= 1980]

X = subset['zscore'].to_numpy().reshape(-1, 1)
X = StandardScaler().fit_transform(X)
y = subset['Eating'].to_numpy()

x_train, x_test, y_train, y_test = train_test_split(X, y, train_size=0.75, random_state=10061991)

lr = LogisticRegression(verbose=1, random_state=10061991, max_iter=10000, penalty='none', tol=1e-6)
lr.fit(x_train, y_train)

cm = confusion_matrix(y_test, lr.predict(x_test))
cr = classification_report(y_test, lr.predict(x_test))
print(cm)
print(cr)
print(lr.score(x_test, y_test))
