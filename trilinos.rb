require 'formula'

class Trilinos < Formula
  homepage 'http://trilinos.sandia.gov'
  url 'http://trilinos.sandia.gov/download/files/trilinos-11.2.3-Source.tar.gz'
  sha1 '91ed5de34d9cf80cb03afe761e8e1bf07398221a'

  option "with-boost",    "Enable Boost support"
  # We have build failures with scotch. Help us on this, if you can!
  # option "with-scotch",   "Enable Scotch partitioner"
  option "with-netcdf",   "Enable Netcdf support"
  option "with-teko",     "Enable 'Teko' secondary-stable package"
  option "with-shylu",    "Enable 'ShyLU' experimental package"
  option "with-python",   "Enable 'PyTrilinos' package"

  depends_on MPIDependency.new(:cc, :cxx)
  depends_on 'cmake' => :build
  depends_on 'boost'      if build.include? 'with-boost'
  depends_on 'scotch'     if build.include? 'with-scotch'
  depends_on 'netcdf'     if build.include? 'with-netcdf'
  depends_on 'swig'       if build.include? 'with-python'

  def patches
    # fix bug where PyTrilinos won't link when using Clang compiler
    # reported to Trilinos-Users Mon, 17 Jun 2013 08:50:50 -0400
    DATA
  end

  def install

    args = std_cmake_args
    args << "-DBUILD_SHARED_LIBS=ON"
    args << "-DTPL_ENABLE_MPI:BOOL=ON"
    args << "-DTPL_ENABLE_BLAS=ON"
    args << "-DTPL_ENABLE_LAPACK=ON"
    args << "-DTPL_ENABLE_Zlib:BOOL=ON"
    args << "-DTrilinos_ENABLE_ALL_PACKAGES=ON"
    args << "-DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=ON"
    args << "-DTrilinos_ENABLE_Fortran:BOOL=OFF"
    args << "-DTrilinos_ENABLE_EXAMPLES:BOOL=OFF"
    args << "-DTrilinos_VERBOSE_CONFIGURE:BOOL=OFF"
    args << "-DZoltan_ENABLE_ULLONG_IDS:Bool=ON"

    # Extra non-default packages
    args << "-DTrilinos_ENABLE_ShyLU:BOOL=ON"  if build.include? 'with-shylu'
    args << "-DTrilinos_ENABLE_Teko:BOOL=ON"   if build.include? 'with-teko'

    # Third-party libraries
    args << "-DTPL_ENABLE_Boost:BOOL=ON"    if build.include? 'with-boost'
    args << "-DTPL_ENABLE_Scotch:BOOL=ON"   if build.include? 'with-scotch'
    args << "-DTPL_ENABLE_Netcdf:BOOL=ON"   if build.include? 'with-netcdf'
    args << "-DTrilinos_ENABLE_PyTrilinos:BOOL=ON"    if build.include? 'with-python'
    args << "-DPyTrilinos_INSTALL_PREFIX:PATH=#{prefix}"    if build.include? 'with-python'
                                               #
    mkdir 'build' do
      system "cmake", "..", *args
      system "make install"
    end

  end

end

__END__
diff -u -r a/packages/PyTrilinos/src/CMakeLists.txt b/packages/PyTrilinos/src/CMakeLists.txt
--- a/packages/PyTrilinos/src/CMakeLists.txt	2013-04-25 13:15:58.000000000 -0400
+++ b/packages/PyTrilinos/src/CMakeLists.txt	2013-06-16 08:18:49.000000000 -0400
@@ -62,7 +62,7 @@
 # to the pytrilinos library and PyTrilinos extension modules
 SET(EXTRA_LINK_ARGS "${CMAKE_SHARED_LINKER_FLAGS}")
 IF(APPLE)
-  IF(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
+  IF((CMAKE_CXX_COMPILER_ID MATCHES "GNU") OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
     SET(EXTRA_LINK_ARGS "${EXTRA_LINK_ARGS} -undefined dynamic_lookup")
   ENDIF()
 ENDIF(APPLE)
diff -u -r a/packages/Sundance/python/src/CMakeLists.txt b/packages/Sundance/python/src/CMakeLists.txt
--- a/packages/Sundance/python/src/CMakeLists.txt	2013-04-25 13:16:10.000000000 -0400
+++ b/packages/Sundance/python/src/CMakeLists.txt	2013-06-16 08:59:04.000000000 -0400
@@ -4,7 +4,7 @@
 # to the pytrilinos library and PyTrilinos extension modules
 SET(EXTRA_LINK_ARGS "")
 IF(APPLE)
-  IF(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
+  IF((CMAKE_CXX_COMPILER_ID MATCHES "GNU") OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
     APPEND_SET(EXTRA_LINK_ARGS "-undefined dynamic_lookup")
   ENDIF()
 ENDIF(APPLE)
