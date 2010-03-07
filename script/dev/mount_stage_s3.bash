#!/bin/bash

s3fs \
    yournextmp-stage \
    -o use_cache=~/yournextmp_s3_cache \
    ~/yournextmp