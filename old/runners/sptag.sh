#!/bin/bash

PYTHONPATH=/scratch/musa/app_dir/sptag/Release
python3 -c '''
import sys
sys.path.append("/scratch/musa/app_dir/sptag/Release")
import SPTAG
'''