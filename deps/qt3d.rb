custom_dep :qt3d, [ :qt ] do | name, cfg |

    dirs = dep_dirs name, cfg

    if WINDOWS then
        # FIXME: Have qt properly stage itself on windows.
        qmake_path  = File.join dep_build_dir('qt', cfg), 'bin', 'qmake.exe'
    else
        qmake_path  = File.join dirs[:stage], 'bin', 'qmake'
    end

    project_path = File.join dirs[:source], 'qt3d.pro'

    cd dirs[:build] do
        # FIXME: Honor build configuration.
        sh qmake_path, '-d', "PREFIX=#{ dirs[:stage] }", project_path
        sh $make_cmd, *$make_flags
        sh $make_cmd, "INSTALL_ROOT=#{ dirs[:stage] }", 'install'
    end
end if not WINDOWS and not MACOSX_MOUNTAIN_LION # Fails at install on Windows, fails at build on MacOSX 10.8.
