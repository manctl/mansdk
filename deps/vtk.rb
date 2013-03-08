cmake_dep :vtk, [], {
    'CMAKE_VERBOSE_MAKEFILE' => [ BOOL, ON ],
    'BUILD_TESTING' => [ BOOL, OFF ],
}.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and CPU_64
}
