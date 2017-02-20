#!/bin/bash
codes_download pykern
pip install -r requirements.txt
python setup.py install
pyenv rehash
hash pykern
