import numpy as np
from scipy import io
import h5py
from misc.analytic_wfm import peakdetect
import os.path

# trials_matrix(cond_ind,trial_ind,time_ind,source_ind)


def sample_segments4clustering(trials_matrix, segments_length, segments_overlap, sub_num, cond_ind):
    sub_data_path = '/cortex/users/ohad/pairs_analysis/{}'.format(sub_num-(100*(sub_num > 100)))
    # sub_path = '{}/hyperFoldNum{}'.format(sub_data_path, hyperfold_num)

    if segments_overlap == 0:
        segments_overlap = segments_length
    starts_times = np.arange(0, trials_matrix.shape[2]-(segments_length+16), segments_overlap)

    # valid_trials = trials_matrix.shape[0]
    flat_single_segment = segments_length * trials_matrix.shape[3]
    num_of_trials = trials_matrix.shape[1]-np.isnan(trials_matrix[cond_ind, :, 0, 0]).sum()
    num_segments = len(starts_times) * num_of_trials
    segments = np.zeros((num_segments, flat_single_segment))

    trial_inds = np.zeros((num_segments, 1))
    start_inds = np.zeros((num_segments, 1))
    stop_inds = np.zeros((num_segments, 1))

    last_ind = 0
    end_trial_flag = False
    for trial_ind in range(num_of_trials):
        print('working on trial {}'.format(trial_ind))
        if end_trial_flag:
            break
        for start_time in starts_times:
            cur_range = np.arange(start_time, start_time + segments_length)
            trial_inds[last_ind] = trial_ind+1
            start_inds[last_ind] = start_time
            stop_inds[last_ind] = start_time + segments_length
            tmp_mat = trials_matrix[cond_ind, trial_ind, cur_range, :]
            # final_mat = tmp_mat - tmp_mat.mean(axis=1, keepdims=True)
            if np.isnan(tmp_mat).all():
                end_trial_flag = True
                break
            segments[last_ind, :] = tmp_mat.flatten()
            last_ind += 1

    return segments, trial_inds, start_inds, stop_inds


def find_segments_starts(trials_matrix, cond_ind):
    print('Good')
    import matplotlib.pyplot as plt

    peaks_inds_per_trial = np.zeros((trials_matrix.shape[1], 0))
    for trial_ind in range(trials_matrix.shape[1]):
        temp_set = set()
        for source_ind in range(trials_matrix.shape[3]):
            q = trials_matrix[cond_ind, trial_ind, :, source_ind]
            all_peaks = peakdetect.peakdetect(q, lookahead=5)
            peaks = np.array(all_peaks[0])
            temp_set |= set(peaks[:, 0])
            # xx = np.arange(0, len(q))
            # plt.plot(xx, q, 'k', peaks[:, 0], peaks[:, 1], 'ro')
            # plt.show()
        print('1')
    return True


if __name__ == "__main__":
    conds_strs = ['cond36', 'cond37']
    arrays = {}
    subject_path = '/cortex/data/MEG/Baus/CCdata/102/matlabData/'
    data_file = 'all_trials_matrix_SNR_CCD_8to60.mat'
    f = h5py.File(subject_path+data_file)
    for k, v in f.items():
        arrays[k] = np.array(v)

    # find_segments_starts(arrays['trials_matrix'], 0)
    # sample_segments4clustering(trials_matrix, segments_length, segments_overlap, sub_num, cond_ind)
    cur_cond = 0
    trials_matrix = arrays['trials_matrix']
    for cur_cond in range(2):
        output_file_candidate = '{}segments4clustering_{}.npz'.format(subject_path, conds_strs[cur_cond])
        if not os.path.isfile(output_file_candidate):
            segments, trial_inds, start_inds, stop_inds = sample_segments4clustering(trials_matrix, 10, 1, 102, cur_cond)
            with open(output_file_candidate, 'w') as f:  # Python 3: open(..., 'wb')
                # pickle.dump([segments, trial_inds, start_inds, stop_inds], f)
                np.savez(f, segments=segments, trial_inds=trial_inds, start_inds=start_inds, stop_inds=stop_inds)
                print('file saved at {}'.format(output_file_candidate))
        else:
            continue
    # split_segments(102, segments, trial_inds, 1, [1, 2, 3], 1)
    print(segments.shape)
    print('Finish')
