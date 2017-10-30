import numpy as np
from scipy import io
from sklearn import mixture
import datetime
import os.path
import pickle


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


def represent_testset_using_trainset(subject_path, sub_num, hyperfold_num, train_folds, test_fold, num_of_clusters):
    train_folds_str = create_train_folds_str(train_folds)
    test_segments, test_trial_inds, y_test = load_testset(sub_num, hyperfold_num, test_fold)
    X_test = np.zeros((len(np.unique(test_trial_inds[0])) + len(np.unique(test_trial_inds[1])),
                       np.max(np.bincount(test_trial_inds[0].astype(int)))))

    for cur_cond in ['cond36', 'cond37']:
        gaussian_fname = '{}/hyperFoldNum{}/gaussian_obj_N{}_train{}_{}.pkl'.format(subject_path, hyperfold_num,
                                                                                    num_of_clusters, train_folds_str,
        with open(gaussian_fname, 'rb') as input:
            model = pickle.load(input)

        print('OK')
    return True


def create_train_folds_str(train_folds):
    train_folds_str = ''
    for ind, fold in enumerate(train_folds):
        train_folds_str += fold.__str__()
        if ind < len(train_folds) - 1:
            train_folds_str += '_'
    return train_folds_str


if __name__ == "__main__":
    conds_strs = ['cond36', 'cond37']
    sub_num = 102
    subject_path = '/cortex/data/MEG/Baus/CCdata/{}/matlabData/'.format(sub_num)
    hyperfold_num = 1
    train_folds = [1, 2, 3]
    test_fold = [4]
    # num_of_clusters = 100
    num_of_clusters_arr = [25, 50, 75, 100, 150, 200, 250, 300, 350, 400]


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
            if not os.path.isfile(gaussian_file_name):
                data = np.load('{}segments4clustering_{}.npz'.format(subject_path, cur_cond))
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
    # valid_segments_test, trial_inds_test = load_testset(sub_num, data['segments'], data['trial_inds'], hyperfold_num,
    #                                                     test_fold)

    # num_of_clusters = 50
    # data = np.load('{}segments4clustering_{}.npz'.format(subject_path, cur_cond))
    # represent_testset_using_trainset(subject_path, sub_num, hyperfold_num, train_folds, test_fold, num_of_clusters)
    print('so far so good')