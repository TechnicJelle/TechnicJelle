#!/usr/bin/env bash

# Refresh program lists
sudo apt-get update

# Install Python3 & PIP
sudo apt-get -y install python3-pip

# Make sure it's installed and working
pip3 --version

# Install dependencies
pip install markdown ghapi

# Actually generate the website
python3 generate.py -v -g "$1"
