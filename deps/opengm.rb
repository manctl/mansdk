cmake_dep :opengm, [ :boost ], {
    'BOOST_ROOT'      => [ PATH, DEP_STAGE_DIR ],
    'WITH_BOOST'      => [ BOOL, ON ],
    'BUILD_EXAMPLES'  => [ BOOL, OFF ],
    'BUILD_TESTING'   => [ BOOL, OFF ],
}
