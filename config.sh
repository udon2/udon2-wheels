function pre_build {
    if [ -z "$IS_OSX" ]; then
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
    else
        python3 --version
        ls

        if [ "$MB_PYTHON_VERSION" = "3.9" ]; then
            brew install boost-python3
            brew list | grep 'boost'
            brew info boost-python3
            echo "ls"
            ls /usr/local/Cellar/boost-python3/1.76.0/lib
            export BOOST_DIR="/usr/local/Cellar/boost-python3/1.76.0"
        elif [ "$MB_PYTHON_VERSION" = "3.8" ]; then
            brew install ./formulas/boost-python38.rb
            echo "ls2"
            ls /usr/local/Cellar/boost-python38/1.74.0/lib
            export BOOST_DIR="/usr/local/Cellar/boost-python38/1.74.0"
        elif [ "$MB_PYTHON_VERSION" = "3.7" ]; then
            brew install ./formulas/boost-python37.rb
            echo "ls2"
            ls /usr/local/Cellar/boost-python37/1.74.0/lib
            export BOOST_DIR="/usr/local/Cellar/boost-python37/1.72.0"
        fi
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$BOOST_DIR/lib"
    fi
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    # python -c 'import sys; import yourpackage; sys.exit(yourpackage.test())'
}
