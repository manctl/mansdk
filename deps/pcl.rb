cmake_dep :pcl, [ :boost, :eigen, :flann, :qhull, :qt, :vtk ] + (WINDOWS ? [ :png ] : [ :openni ]), {
    'BUILD_apps'                  => [ BOOL, OFF ],
    'BUILD_simulation'            => [ BOOL, OFF ],
    'BUILD_outofcore'             => [ BOOL, OFF ],
    'BUILD_gpu_kinfu'             => [ BOOL, ON  ],
    'BUILD_gpu_kinfu_large_scale' => [ BOOL, OFF ],
    'BUILD_GPU'                   => [ BOOL, ON  ],
    'BUILD_CUDA'                  => [ BOOL, ON  ],
    'BUILD_cuda_features'         => [ BOOL, OFF ],
    'BUILD_cuda_io'               => [ BOOL, OFF ], # Broken on Windows with PCL trunk.
    'BUILD_cuda_sample_consensus' => [ BOOL, OFF ],
    'BUILD_cuda_segmentation'     => [ BOOL, OFF ],
    'BUILD_gpu_features'          => [ BOOL, OFF ],
    'BUILD_gpu_octree'            => [ BOOL, ON  ],
    'BUILD_gpu_people'            => [ BOOL, OFF ],
    'BUILD_gpu_segmentation'      => [ BOOL, OFF ],
    'BUILD_gpu_surface'           => [ BOOL, OFF ],
    'BUILD_gpu_tracking'          => [ BOOL, OFF ],
    'BUILD_keypoints'             => [ BOOL, OFF ],
    'BUILD_ml'                    => [ BOOL, ON  ],
    'BUILD_recognition'           => [ BOOL, OFF ],
    'BUILD_segmentation'          => [ BOOL, ON  ], # registration
    'BUILD_stereo'                => [ BOOL, OFF ],
    'BUILD_tracking'              => [ BOOL, OFF ],
    'BUILD_visualization'         => [ BOOL, ON  ], # kinfu
    'BUILD_TESTS'                 => [ BOOL, OFF ],
    'BUILD_OPENNI'                => [ BOOL, OFF ],
    'BOOST_ROOT'                  => [ PATH, DEP_STAGE_DIR ],
    'Boost_NO_SYSTEM_PATHS'       => [ BOOL, ON  ],
    'FLANN_ROOT'                  => [ PATH, DEP_STAGE_DIR ],
    'PCL_SHARED_LIBS'             => [ BOOL, (not STATIC_LIBRARIES) ],
    'PCL_ONLY_CORE_POINT_TYPES'   => [ BOOL, ON  ],
}.tap { | flags |
    flags[ 'CMAKE_C_FLAGS'     ] = [ STRING, '-fPIC'        ] if LINUX and CPU_64
    flags[ 'CMAKE_CXX_FLAGS'   ] = [ STRING, '-fPIC'        ] if LINUX and CPU_64
    flags[ 'CMAKE_CXX_COMPILER'] = [ STRING, '/usr/bin/g++' ] if MACOSX_MOUNTAIN_LION
    flags[ 'CUDA_HOST_COMPILER'] = [ STRING, '/usr/bin/gcc' ] if MACOSX_MOUNTAIN_LION
}
#, [ '--trace' ]
