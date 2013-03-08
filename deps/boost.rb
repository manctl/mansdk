custom_dep :boost do | name, cfg |

    dirs = dep_dirs name, cfg

    if UNIX then
        bootstrap = './bootstrap.sh'
        b2 = './b2'
    else
        bootstrap = 'bootstrap.bat'
        b2 = 'b2.exe'
    end

    boost_build_variants = {
        CFG_D  => 'debug',
        CFG_R  => 'release',
        CFG_RD => 'release',
        CFG_M  => 'release',
    }

    boost_address_models = {
        CPU_X86   => 'address-model=32',
        CPU_AMD64 => 'address-model=64',
    }

    cd dirs[:source] do
        sh bootstrap
        ENV['NO_COMPRESSION'] = '1'
        # FIXME: b2 --dll-path=#{ rpath() } does not seem to work.
        b2_args = [
            "--prefix=#{    native_path dirs[:stage] }",
            "--build-dir=#{ native_path dirs[:build] }",
            '--without-python',
            boost_address_models[CPU],
            'threading=multi',
            "variant=#{ boost_build_variants[cfg] }",
        ]
        b2_args << 'link=static' if STATIC_LIBRARIES
        b2_args << 'cxxflags=-fPIC' if LINUX and CPU_64
        b2_args << 'install'
        sh b2, *b2_args
    end

    boost_libs = [
        'chrono',
        'date_time',
        'filesystem',
        'graph',
        'iostreams',
        'math_c99',
        'math_c99f',
        'math_c99l',
        'math_tr1',
        'math_tr1f',
        'math_tr1l',
        'prg_exec_monitor',
        'program_options',
        'random',
        'regex',
        'serialization',
        'signals',
        'system',
        'thread',
        'unit_test_framework',
        'wave',
        'wserialization',
    ]

    if MACOSX then
        boost_libs.each do | lib |
            sh 'install_name_tool', '-id',
                "#{ MACOSX_RPATH     }/libboost_#{ lib }.dylib",
                "#{ dirs[:stage] }/lib/libboost_#{ lib }.dylib"
            boost_libs.each do | lib_ |
                sh 'install_name_tool', '-change',
                                          "libboost_#{ lib }.dylib",
                    "#{ MACOSX_RPATH     }/libboost_#{ lib }.dylib",
                    "#{ dirs[:stage] }/lib/libboost_#{ lib_ }.dylib"
            end
        end
    end
end
