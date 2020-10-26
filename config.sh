function pre_build {
    yum install -y boost-static
    cp -r boost-python-manylinux2010 boost
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    # python -c 'import sys; import yourpackage; sys.exit(yourpackage.test())'
}
