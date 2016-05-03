clear all; close all;

global ANYQUIST;
global FS;

ANYQUIST = 1;

FS = 10e6;

h = rrcosfilter(0.3, 1e6, 20);