cmake_dep :cryptopp, [], MACOSX_MOUNTAIN_LION ? { 'CMAKE_CXX_COMPILER' => [ STRING, '/usr/bin/g++' ] } : {}
