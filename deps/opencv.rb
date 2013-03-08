custom_dep :opencv, [] + (WINDOWS ? [ :png ] : []) do | name, cfg |
    # Release and debug are the only supported opencv builds.
    opencv_cfgs = {
        CFG_D  => CFG_D,
        CFG_RD => CFG_R,
        CFG_R  => CFG_R,
        CFG_M  => CFG_R,
    }

    cmake_build name, cfg, {
        'BUILD_SHARED_LIBS'              => [ BOOL  , (not STATIC_LIBRARIES) ],
        'CMAKE_BUILD_TYPE'               => [ STRING, "#{ cmake_build_type(opencv_cfgs[cfg]) }" ],
        'BUILD_WITH_STATIC_CRT'          => [ BOOL  , OFF ],
        'BUILD_TIFF'                     => [ BOOL  , ON  ],
        'BUILD_TESTS'                    => [ BOOL  , OFF ],
        'WITH_CUDA'                      => [ BOOL  , OFF ],
        'WITH_FFMPEG'                    => [ BOOL  , OFF ],
        'WITH_EIGEN'                     => [ BOOL  , OFF ],
        'CMAKE_LINK_INTERFACE_LIBRARIES' => [ STRING, "" ],
    }.tap { | flags |
        flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
        flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and CPU_64
    }
end
