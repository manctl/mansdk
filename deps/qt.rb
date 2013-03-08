custom_dep :qt, [ :openssl, :jpeg, :png, :zlib ] do | name, cfg |

    dirs = dep_dirs name, cfg

    qt_cpus = {
        CPU_X86   => 'x86',
        CPU_AMD64 => 'x86_64',
    }

    msvc_cpus = {
        CPU_X86   => 'x86',
        CPU_AMD64 => 'x86_amd64',
    }

    qt_cfgs = {
        CFG_D  => 'debug',
        CFG_R  => 'release',
        CFG_RD => 'release',
        CFG_M  => 'release',
    }

#    # FIXME: Ugly hack to avoid building qt every time.
#    if File.exists? File.join(dirs[:build], '.qmake.cache') then
#        next
#    end

    if WINDOWS then
        cd dirs[:build] do

            # FIXME: Someone explain me how to perform reliable, deterministic parallel builds on windows.
            make_flags = [ *$make_flags ] + ($make_cmd == 'jom' ? [ '-j1' ] : [])

            sh File.join(dirs[:source], 'build-qt-windows-msvc10.cmd'), msvc_cpus[CPU], qt_cfgs[cfg], dirs[:stage], $make_cmd, *make_flags

            # FIXME: Properly install ALL products in stage.
            cp_r File.join(dirs[:build], 'bin', 'qmake.exe'), File.join(dirs[:stage], 'bin', 'qmake.exe')
        end
    elsif UNIX then
        cd dirs[:build] do
            mkdoc = '1' # FIXME: Make this configurable.
            sh File.join(dirs[:source], 'build-qt-unix-make.sh'), qt_cpus[CPU], qt_cfgs[cfg], dirs[:stage], SYS, mkdoc, $make_cmd, *$make_flags
        end
    end
end
