# FIXME: Properly dispatch on actual config.
# FIXME: Ruby does not compile on 64 bit target architectures.

custom_dep :ruby do | name, cfg |

    dirs = dep_dirs name, cfg

    # FIXME: This will also modify the environment of subsequent unrelated targets.
    add_env_path File.join dirs[:source] , 'win32', 'bin'

    if WINDOWS then
        cd dirs[:build] do
            sh File.join(dirs[:source], 'win32', 'configure.bat')
            edit_file(File.join(dirs[:build], 'Makefile'), /^RT = msvcr\d+/, 'RT = msvcrt')
            sh 'nmake'
            sh 'nmake', "DESTDIR=#{ dirs[:stage] }", 'install', 'install-lib'
        end
    else
        cd dirs[:source] do
             sh 'autoconf'
        end
        cd dirs[:build] do
             sh File.join(dirs[:source], 'configure'), "--prefix=#{ dirs[:stage] }"
             sh 'make'
             sh 'make', 'install', 'install-lib'
        end
    end
end if CPU_32
