cmake_dep :zlib, [], {
    'BUILD_SHARED_LIBS' => [ BOOL, (not STATIC_LIBRARIES) ],
 }.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and CPU_64
} # if not LINUX
