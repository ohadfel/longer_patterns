import numpy as np
from scipy import io
from sklearn import mixture
import datetime
import os.path
import pickle
import scipy
import matplotlib.pyplot as plt

def split_segments(sub_num, segments, trial_inds, hyperfold_num, valid_folds, cond_ind):
    conds = ['cond36', 'cond37']
    cur_cond =conds[cond_ind]
    sub_data_path = '/cortex/users/ohad/pairs_analysis/{}'.format(sub_num - (100 * (sub_num > 100)))
    sub_path = '{}/hyperFoldNum{}'.format(sub_data_path, hyperfold_num)

    folds_splits = io.loadmat('{}/folds_splits.mat'.format(sub_path))
    mask = np.zeros((folds_splits[cur_cond].shape[0]), dtype=bool)
    for fold in valid_folds:
        mask += (folds_splits[cur_cond][:, 1] == fold)
    valid_trials = folds_splits[cur_cond][mask, 0]

    mask_segments = np.zeros((trial_inds.shape[0], 1), dtype=bool)
    for trial in valid_trials:
        mask_segments += (trial_inds == trial)
    final_mask = np.array([seg_ind[0] for seg_ind in mask_segments])
    valid_segments = segments[final_mask, :]
    return valid_segments, trial_inds[mask_segments]


# def split_segments2train_test(sub_num, segments, trial_inds, hyperfold_num, train_folds, test_fold, cond_ind):
#     valid_segments_train, trial_inds_train = split_segments(sub_num, segments, trial_inds, hyperfold_num, train_folds,
#                                                             cond_ind)
#     valid_segments_test, trial_inds_test = split_segments(sub_num, segments, trial_inds, hyperfold_num, test_fold,
#                                                           cond_ind)
#     return valid_segments_train, trial_inds_train, valid_segments_test, trial_inds_test

def load_testset(sub_num, hyperfold_num, test_fold):
    valid_segments_test = np.zeros(0)
    trial_inds_test = np.zeros(0)
    y_test = np.zeros(0)
    for cur_cond_ind, cur_cond in enumerate(['cond36', 'cond37']):
        data = np.load('{}segments4clustering_{}.npz'.format(subject_path, cur_cond))

        valid_segments_test_tmp, trial_inds_test_tmp = split_segments(sub_num, data['segments'], data['trial_inds'],
                                                                      hyperfold_num, test_fold, cur_cond_ind)
        if cur_cond_ind == 0:
            valid_segments_test = valid_segments_test_tmp
            trial_inds_test = trial_inds_test_tmp
            y_test = cur_cond_ind * np.ones(trial_inds_test_tmp.shape)

        else:
            valid_segments_test = np.vstack((valid_segments_test, valid_segments_test_tmp))
            trial_inds_test = np.vstack((trial_inds_test, trial_inds_test_tmp))
            y_test = np.hstack((y_test, cur_cond_ind * np.ones(trial_inds_test_tmp.shape)))
    return valid_segments_test, trial_inds_test, y_test


def find_clusters(num_of_clusters, segments_train):
    gaussian = mixture.GaussianMixture(n_components=num_of_clusters, covariance_type='spherical', max_iter=200,
                                       random_state=0, verbose=100)
    gaussian.fit(segments_train)
    return gaussian

def transform_point_back_to_space_time_mat(vec):
    return vec.reshape((512,10))

def represent_testset_using_trainset(subject_path, sub_num, hyperfold_num, train_folds, test_fold, num_of_clusters):
    train_folds_str = create_train_folds_str(train_folds)
    test_segments, test_trial_inds, y_test = load_testset(sub_num, hyperfold_num, test_fold)
    X_test_llr = np.zeros((len(np.unique(test_trial_inds[0])) + len(np.unique(test_trial_inds[1])),
                       np.max(np.bincount(test_trial_inds[0].astype(int)))))
    X_test_log_prob_cond0 = np.zeros((len(np.unique(test_trial_inds[0])) + len(np.unique(test_trial_inds[1])),
                           np.max(np.bincount(test_trial_inds[0].astype(int)))))
    gaussian_base_file_name ='{}/hyperFoldNum{}/gaussian_obj_N{}_train{}_'.format(subject_path, hyperfold_num,
                                                                                    num_of_clusters, train_folds_str)
    gaussian_fname = '{}cond36.pkl'.format(gaussian_base_file_name)
    with open(gaussian_fname, 'rb') as input:
        model0 = pickle.load(input)
    X_test_log_prob_cond0 = -model0._estimate_log_prob(test_segments)
    X_test_log_prob_cond0.sort(axis=1)
    # plot_cluster_as_space_time(model0.means_[10])


    gaussian_fname = '{}cond37.pkl'.format(gaussian_base_file_name)
    with open(gaussian_fname, 'rb') as input:
        model1 = pickle.load(input)
    X_test_log_prob_cond1 = -model1._estimate_log_prob(test_segments)
    X_test_log_prob_cond1.sort(axis=1)
    # X_test_llr = np.multiply(np.exp(X_test_log_prob_cond0),1/(np.exp(model._estimate_log_prob(test_segments))))

    X_test_llr = -X_test_log_prob_cond0 - (-X_test_log_prob_cond1)

    # for cur_cond in ['cond36', 'cond37']:
    #     gaussian_fname = '{}/hyperFoldNum{}/gaussian_obj_N{}_train{}_{}.pkl'.format(subject_path, hyperfold_num,
    #                                                                                 num_of_clusters, train_folds_str,
    #                                                                                 cur_cond)
    #     with open(gaussian_fname, 'rb') as input:
    #         model = pickle.load(input)b_cond0 = -model._estimate_log_prob(test_segments)
    # q2 = coumpute_probabilty(model, test_segments[:5])
    # plt.figure(1)
    # plt.plot(range(num_of_clusters), -q[2], 'b', range(num_of_clusters), -q2[2], 'r')
    # plt.yscale('log')
    # plt.show()
    return True


def coumpute_probabilty(gaussian,X):
    prob = np.zeros((X.shape[0], gaussian.means_.shape[0]))
    cov_matrix = np.diag(gaussian.covariances_)
    # cluster_inds = 14:21]
    for cluster_ind in range(gaussian.means_.shape[0]):
        print(cluster_ind)
        scipy_gaussian = scipy.stats.multivariate_normal(mean=gaussian.means_[cluster_ind], cov=gaussian.covariances_[cluster_ind])
        prob[:, cluster_ind] = scipy_gaussian.logpdf(X)
        # prob[line_ind,cluster_ind] = scipy_gaussian
    return prob


def plot_cluster_as_space_time(cluster_coords):
    spacing = 2.5
    pattern_mat = cluster_coords.reshape((512, 10)).transpose()
    colors = plt.cm.jet(np.linspace(0, 1, 512))

    for source_ind in range(pattern_mat.shape[1]):
        plt.plot(range(10), pattern_mat[:, source_ind]+spacing*source_ind, color=(colors[source_ind, :3]), linewidth=pattern_mat[:, source_ind].std()/10)
    plt.show()


def create_train_folds_str(train_folds):
    train_folds_str = ''
    for ind, fold in enumerate(train_folds):
        train_folds_str += fold.__str__()
        if ind < len(train_folds) - 1:
            train_folds_str += '_'
    return train_folds_str


def count_supports(model_str, segments):
    with open(model_str, 'rb') as input:
        model = pickle.load(input)
    y = model.predict(segments)
    binconts = np.bincount(y)
    ii = np.nonzero(binconts)[0]
    t = zip(ii, binconts[ii])
    print('ok')




if __name__ == "__main__":
    conds_strs = ['cond36', 'cond37']
    sub_num = 102
    subject_path = '/cortex/data/MEG/Baus/CCdata/{}/matlabData/'.format(sub_num)
    hyperfold_num = 1
    train_folds = [1, 2, 3]
    test_fold = [4]
    # num_of_clusters = 100
    num_of_clusters_arr = [25, 50, 75, 100, 150, 200, 250, 300, 350, 400]
    num_of_clusters_arr = [25, 50, 75, 100, 150, 200, 250, 300]
    # num_of_clusters_arr = [500, 1000, 1500, 2000, 2500, 3000]
    num_of_clusters_arr = [200]


    train_folds_str = create_train_folds_str(train_folds)

    gaussians = []
    for num_of_clusters in num_of_clusters_arr:
        print('*** Working on num_of_clusters={} ***'.format(num_of_clusters))
        for cond_ind, cur_cond in enumerate(conds_strs):
            gaussian_file_name = '{}/hyperFoldNum{}/gaussian_obj_N{}_train{}_{}.pkl'.format(subject_path,
                                                                                                hyperfold_num,
                                                                                                num_of_clusters,
                                                                                                train_folds_str,
                                                                                                cur_cond)
            data = np.load('{}segments4clustering_{}.npz'.format(subject_path, cur_cond))
            if not os.path.isfile(gaussian_file_name):
                # valid_segments, trial_inds = split_segments(102, data['segments'], data['trial_inds'],
                #  1, [1, 2, 3], cond_ind)
                valid_segments_train, trial_inds_train = split_segments(sub_num, data['segments'], data['trial_inds'],
                                                                        hyperfold_num, train_folds, cond_ind)
                # valid_segments_train, trial_inds_train, valid_segments_test, trial_inds_test =
                # split_segments2train_test(sub_num, data['segments'], data['trial_inds'], hyperfold_num, train_folds,
                # test_fold, cond_ind)
                print(datetime.datetime.now())
                # gaussians.append(find_clusters(num_of_clusters, valid_segments_train))
                gaussian = find_clusters(num_of_clusters, valid_segments_train)

                with open(gaussian_file_name, 'wb') as output:
                    pickle.dump(gaussian, output, pickle.HIGHEST_PROTOCOL)
                # np.savez(gaussian_file_name, gaussian=gaussian, num_of_clusters=num_of_clusters)
                print('File saved at {}'.format(gaussian_file_name))
                print(datetime.datetime.now())
            else:
                pass
                # count_supports(gaussian_file_name, data['segments'])
    # valid_segments_test, trial_inds_test = load_testset(sub_num, data['segments'], data['trial_inds'], hyperfold_num,
    #                                                     test_fold)

    num_of_clusters = 400
    data = np.load('{}segments4clustering_{}.npz'.format(subject_path, cur_cond))
    represent_testset_using_trainset(subject_path, sub_num, hyperfold_num, train_folds, test_fold, num_of_clusters)
    print('so far so good')