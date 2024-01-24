#!/bin/bash

zig build
time zig-out/bin/mandelbrot 1024 2>mand.pgm
