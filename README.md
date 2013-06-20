utility-support
===============

Support repo for M-Lab utility slice.

To start:

    git clone --recursive https://github.com/m-lab-tools/utility-support.git
    cd utility-support
    ./package/slicebuild.sh mlab_utility_test

We recommend building in a dedicated environment.  The build scripts
create /home/mlab_utility_test and require root privileges to execute.

There is a dependency on 'git' and the yumgroup 'Development tools'.
