# Makefile for MSc Diss
# usage: make [target]
# targets: all, rf, xgboost, lstm
# author:  Archie Benn sj19031@bristol.ac.uk

all: rf xgboost lstm rnn

rf:
	python src/python/train.py --model rf

xgboost:
	python src/python/train.py --model xgboost

lstm:
	python src/python/train.py --model lstm

rnn:
	python  src/python/train.py --model rnn
