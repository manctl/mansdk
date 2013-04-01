# ManCTL's Software Development Kit

## What's this?

For now, this tree is just our growing bag of open-source dependencies and its master build system, exposed to the outer world.

Use at your own risk.

## Prerequisites

 * Windows | MacOSX | Linux
 * A functional C++ compilation toolchain.
 * Perl
  * Windows: (ActiveState)
  * Unix (system default)
 * [CMake](http://www.cmake.org) >= 2.8.10
 * [Ruby](http://www.ruby-lang.org) >= 1.9.3

## Installation

bundle

## Usage

### Examples

 * Build & install everything in MANSDK_DIR/{build,stage}:

        rake

 * More verbose version of the above:

        rake all

 * Builds & installs everything in /builds/mansdk/{build,stage}:

        rake PREFIX=/builds/mansdk

 * Build & install all the debug targets:

        rake CONFIG=debug

 * Shorthand for the above:

        rake debug

 * Shorthand for the above:

        rake D

 * Totally verbose version of the above:

        rake all:debug

 * Build pcl and its dependencies:

        rake pcl

 * Builds pcl alone:

        rake pcl-only

 * Build pcl in release mode:

        rake pcl:release

 * Build usb & jpeg in debug mode and pcl alone in release mode:

        rake CONFIG=debug usb jpeg pcl-only:release

 * Build using up to 8 cores (auto-detected by default):

        rake MAKE_FLAGS=-j8

 * Build absolutely everything:

        rake debug release relwithdebinfo minsizerel

    (Make sure your build directory storage is up to the task.)

 * Delete the entire default configuration (stage, output & build):

        rake clear

 * Delete the entire release and debug configurations (stages, outputs & builds):

        rake clear:{release,debug}

 * Delete the default pcl build directory and the builds directories of all its dependencies:

        rake pcl-clear

 * Delete the default pcl build directory:

        rake pcl-clear-only

 * Delete the debug pcl build directory:

    rake pcl-clear-only:debug

 * Remove absolutely everything:

        rake wipe

 * Display hopefully helpful information:

        rake help

 * Build everything using Qt5 instead of Qt4:

        rake QT5=ON

    WARNING: Do not mix Qt4 & Qt5 builds.

## About

### Why?

Because we found it incredibly hard to build stable cross-platform software on a massive, yet constantly evolving open-source software base.

### Authors

 * Nicolas Burrus
 * Nicolas Tisserand

More info: <http://manctl.com>
