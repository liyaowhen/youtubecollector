#!/bin/bash

# Clean previous build (if needed)
# ninja -C builddir clean

# Set up Meson build directory
meson setup build --buildtype=debug

# Build the project
meson compile -C build

# Install project
meson install -C build

# Run the executable
song
