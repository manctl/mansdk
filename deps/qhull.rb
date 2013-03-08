cmake_dep :qhull, [], {}.tap { | flags |
    flags[ 'CMAKE_C_FLAGS'   ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
    flags[ 'CMAKE_CXX_FLAGS' ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
}
