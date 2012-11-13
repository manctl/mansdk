ManSDK
======

ManCTL's Development Dependencies Bundle.

Prerequisites
-------------

 * /usr/bin/env ruby --version >= 1.8-ish

Examples
--------

 * rake

Builds & installs everything in MANSDK_DIR/{build,stage}.

* rake PREFIX=/builds/mansdk

Builds & installs everything in /builds/mansdk/{build,stage}.

 * rake CONFIG=debug

Builds & installs all the debug targets.

 * rake debug

Shorthand for the above.

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
