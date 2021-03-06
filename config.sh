function pre_build {
    yum install -y wget
    yum install -y ca-certificates
    wget https://boostorg.jfrog.io/artifactory/main/release/1.74.0/source/boost_1_74_0.tar.bz2
    tar --bzip2 -xf boost_1_74_0.tar.bz2
    cp -r "boost-python-manylinux2010-$PLAT/" boost
    mkdir boost/include
    mv boost_1_74_0/boost boost/include
    ls boost
    pwd
    export BOOST_DIR="`pwd`/boost"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:`pwd`/boost/lib"
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    # python -c 'import sys; import yourpackage; sys.exit(yourpackage.test())'
}
