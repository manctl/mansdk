custom_dep :openssl do | name, cfg |

    dirs = dep_dirs name, cfg

    # Remove this if you find out how to perform out-of-source openssl builds.
    mirror_dirs dirs[:source], dirs[:build]

    if WINDOWS then

        configure_cpus = {
            CPU_X86   => 'VC-WIN32',
            CPU_AMD64 => 'VC-WIN64A',
        }

        configure_post_cmds = {
            CPU_X86   => "ms/do_ms",
            CPU_AMD64 => "ms/do_win64a",
        }

        cd dirs[:build] do
            sh 'perl', "./Configure", configure_cpus[CPU], 'no-asm', "--prefix=#{ dirs[:stage] }"
            sh configure_post_cmds[CPU]
            sh 'nmake', '-f', 'ms/ntdll.mak'
            sh 'nmake', '-f', 'ms/ntdll.mak', 'install'
        end
    else
        cd dirs[:build] do
             sh "./config", "--prefix=#{ dirs[:stage] }"
             sh 'make'
             sh 'make', 'install'
        end
    end
end
