from __future__ import division
import os
import sys
import argparse
import nibabel as nib
from nibabel.streamlines import load
import numpy as np
import dipy
from dipy.tracking.vox2track import streamline_mapping
from dipy.tracking.streamline import length, set_number_of_points
from dipy.tracking import metrics as tm


def compute_volume(bundle):
	"""Compute voxel volume of a bundle.
	"""
	aff=np.array([[-1.25, 0, 0, 90],[0, 1.25, 0, -126],[0, 0, 1.25, -72],[0, 0, 0, 1]])
    voxel_list = streamline_mapping(bundle, affine=aff).keys()
    vol_bundle = len(set(voxel_list))

    return vol_bundle


def compute_mean_bundle_curvature(bundle):
    """Compute the mean scalar curvature of a bundle.
	"""
	mean_st_curvature = np.zeros(len(bundle))
    for i, sa in enumerate(bundle):
		m=tm.mean_curvature(sa)
		mean_st_curvature[i] = m	
	mean_bundle_curvature = np.mean(mean_st_curvature)   

	return mean_bundle_curvature


def compute_volume_and_curvature(bundle_filename):
	bundle = nib.streamlines.load(bundle_filename)
	bundle = bundle.streamlines
	vol_bundle = compute_volume(bundle)
	mean_bundle_curvature = compute_mean_bundle_curvature(bundle)

	return vol_bundle, mean_bundle_curvature



if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('-bundle', nargs='?', const=1, default='',
	                    help='The bundle filename')
	parser.add_argument('-list', nargs='?',  const=1, default='',
	                    help='The tract name list file .txt')                                                  
	args = parser.parse_args()

	result = np.zeros((8,2))

	with open(args.list) as f:
		content = f.read().splitlines()
	
	for t, tract_name in enumerate(content):
		tract_filename = '%s_tract.trk' %(tract_name)
	    vol_bundle, mean_bundle_curvature = compute_volume_and_curvature(tract_filename)
	    result[t,0] = vol_bundle
	    result[t,1] = mean_bundle_curvature
		np.save('result.npy', result)

	sys.exit() 