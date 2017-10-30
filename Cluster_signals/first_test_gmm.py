from scipy import io
from scipy.signal.windows import gaussian
from sklearn import mixture
import numpy as np
import datetime
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt


cond2 = io.loadmat('/cortex/data/MEG/Baus/CCdata/102/matlabData/segments4clustering_cond2.mat')
print(datetime.datetime.now())
gaussian2 = mixture.GaussianMixture(n_components=500, covariance_type='spherical', max_iter=500, random_state=0,verbose=100)
gaussian2.fit(cond2['segments'])
y_train_pred2 = gaussian2.predict(cond2['segments'])
plt.hist(y_train_pred2, 100)


cond1 = io.loadmat('/cortex/data/MEG/Baus/CCdata/102/matlabData/segments4clustering_cond1.mat')
gaussian1 = mixture.GaussianMixture(n_components=100, covariance_type='spherical', max_iter=500, random_state=0,verbose=100)
print(datetime.datetime.now())
gaussian1.fit(cond1['segments'])
y_train_pred1 = gaussian1.predict(cond1['segments'])
plt.hist(y_train_pred1, 100)

last_class = y_train_pred1[0]
repetitions_1 = 0
repetitions_2 = 0
last_repeat = False

for ii in range(1, len(y_train_pred1)):
    if y_train_pred1[ii] == last_class:
        repetitions_1 += 1
        if last_repeat:
            repetitions_2 += 1
        last_repeat = True
    else:
        last_class = y_train_pred1[ii]
        last_repeat = False



print(datetime.datetime.now())