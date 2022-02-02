class BoostPython38 < Formula
  desc "C++ library for C++/Python3 interoperability"
  homepage "https://www.boost.org/"
  url "https://boostorg.jfrog.io/artifactory/main/release/1.74.0/source/boost_1_74_0.tar.bz2"
  sha256 "83bfc1507731a0906e387fc28b7ef5417d591429e51e788417fe9ff025e116b1"
  license "BSL-1.0"
  head "https://github.com/boostorg/boost.git"

  bottle do
    cellar :any
    sha256 "eca007bea06791b5a65b4070e41f3502f9d057a9bccbfbbf9df19f196941cccb" => :catalina
    sha256 "59ba760e2c07838e121bf133c3a72870b7ca6364f465a5ea89af2d3ce9a094cb" => :mojave
    sha256 "7e6378396028787a96fc68610bca84e743e76fff8d1c20882b18c7fd96f7df10" => :high_sierra
  end

  depends_on "numpy" => :build
  depends_on "boost"
  depends_on "python@3.8"

  def install
    # "layout" should be synchronized with boost
    args = %W[
      -d2
      -j#{ENV.make_jobs}
      --layout=tagged-1.66
      --user-config=user-config.jam
      install
      threading=multi,single
      link=shared,static
    ]

    # Boost is using "clang++ -x c" to select C compiler which breaks C++14
    # handling using ENV.cxx14. Using "cxxflags" and "linkflags" still works.
    args << "cxxflags=-std=c++14"
    args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang

    # disable python detection in bootstrap.sh; it guesses the wrong include
    # directory for Python 3 headers, so we configure python manually in
    # user-config.jam below.
    inreplace "bootstrap.sh", "using python", "#using python"

    pyver = Language::Python.major_minor_version Formula["python@3.8"].opt_bin/"python3"
    py_prefix = Formula["python@3.8"].opt_frameworks/"Python.framework/Versions/#{pyver}"

    # Force boost to compile with the desired compiler
    (buildpath/"user-config.jam").write <<~EOS
      using darwin : : #{ENV.cxx} ;
      using python : #{pyver}
                   : python3
                   : #{py_prefix}/include/python#{pyver}
                   : #{py_prefix}/lib ;
    EOS

    system "./bootstrap.sh", "--prefix=#{prefix}", "--libdir=#{lib}",
                             "--with-libraries=python", "--with-python=python3",
                             "--with-python-root=#{py_prefix}"

    system "./b2", "--build-dir=build-python3",
                   "--stagedir=stage-python3",
                   "--libdir=install-python3/lib",
                   "--prefix=install-python3",
                   "python=#{pyver}",
                   *args

    lib.install Dir["install-python3/lib/*.*"]
    (lib/"cmake").install Dir["install-python3/lib/cmake/boost_python*"]
    (lib/"cmake").install Dir["install-python3/lib/cmake/boost_numpy*"]
    doc.install Dir["libs/python/doc/*"]
  end

  test do
    (testpath/"hello.cpp").write <<~EOS
      #include <boost/python.hpp>
      char const* greet() {
        return "Hello, world!";
      }
      BOOST_PYTHON_MODULE(hello)
      {
        boost::python::def("greet", greet);
      }
    EOS

    pyincludes = shell_output("#{Formula["python@3.8"].opt_bin}/python3-config --includes").chomp.split(" ")
    pylib = shell_output("#{Formula["python@3.8"].opt_bin}/python3-config --ldflags --embed").chomp.split(" ")
    pyver = Language::Python.major_minor_version(Formula["python@3.8"].opt_bin/"python3").to_s.delete(".")

    system ENV.cxx, "-shared", "hello.cpp", "-L#{lib}", "-lboost_python#{pyver}", "-o",
           "hello.so", *pyincludes, *pylib

    output = <<~EOS
      import hello
      print(hello.greet())
    EOS
    assert_match "Hello, world!", pipe_output(Formula["python@3.8"].opt_bin/"python3", output, 0)
  end
end
