#!/bin/bash
codes_yum install boost-devel
codes_download radiasoft/rslinac integration
python setup.py install
