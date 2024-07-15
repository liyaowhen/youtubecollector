#!/bin/bash

# Clean previous build (if needed)
# ninja -C builddir clean

# Set up Meson build directory
meson setup builddir --buildtype=debug

# Build the project
ninja -C builddir

# Run the executable
song
