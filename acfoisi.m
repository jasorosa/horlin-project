clear all; close all;

global ACFOISI;
global FS;

ACFOISI = 1;

FS = 10e6;

h = rrcosfilter(0.3, 1e6, 20);