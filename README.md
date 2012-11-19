# ManCTL's Software Development Kit

## What's this?

For now, this tree is just our growing bag of open-source dependencies and its master build system, exposed to the outer world.

Use at your own risk.

## Prerequisites

 * /usr/bin/env ruby --version >= 1.8-ish
 * CMake 2.8.10
 * Perl
 * A functional C++ compilation toolchain.
 * Windows | MacOSX | Linux

## Usage

### Examples

 * rake

Builds & installs everything in MANSDK_DIR/{build,stage}.

 * rake all

More verbose version of the above.

 * rake PREFIX=/builds/mansdk

Builds & installs everything in /builds/mansdk/{build,stage}.

 * rake CONFIG=debug

Builds & installs all the debug targets.

 * rake debug

Shorthand for the above.

 * rake all:debug

More verbose version of the above.

 * rake pcl

Builds pcl and its dependencies.

 * rake pcl-only

Builds pcl alone.

 * rake pcl:release

Builds pcl in release mode.

 * rake CONFIG=debug usb jpeg pcl-only:release

Builds usb & jpeg in debug mode and pcl alone in release mode.

 * rake MAKE_FLAGS=-j8

Builds (using up to 8 cores).

 * rake debug release relwithdebinfo minsizerel

Builds absolutely everything. Make sure your build directory storage is up to the task.

 * rake clear

Deletes the entire default configuration (stage, output & build).

 * rake clear:{release,debug}

Deletes the entire release and debug configurations (stages, outputs & builds).

 * rake pcl-clear

Deletes the default pcl build directory and the builds directories of all its dependencies.

 * rake pcl-clear-only

Deletes the default pcl build directory.

 * rake pcl-clear-only:debug

Deletes the debug pcl build directory.

 * rake wipe

Removes absolutely everything.

 * rake help

Displays hopefully helpful information.

## About

### Why?

Because we found it incredibly hard to build stable cross-platform software on a massive, yet constantly evolving open-source software base.

### Authors

 * Nicolas Burrus
 * Nicolas Tisserand

More info: http://manctl.com
