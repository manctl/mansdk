custom_dep :qt5, [ :openssl, :jpeg, :png, :zlib ] do | name, cfg |

    dirs = dep_dirs name, cfg

    qt_version = {
        :major => 5,
        :minor => 0,
        :patch => 2,
    }

    qt5_cpus = {
        CPU_X86   => 'x86',
        CPU_AMD64 => 'x86_64',
    }

    msvc_cpus = {
        CPU_X86   => 'x86',
        CPU_AMD64 => 'x86_amd64',
    }

    qt5_cfgs = {
        CFG_D  => 'debug',
        CFG_R  => 'release',
        CFG_RD => 'release',
        CFG_M  => 'release',
    }

    mkdoc = true # FIXME: Make this configurable.

    bad_qt_libs = [
        { :name => 'WebKitWidgets', :dir => 'qtwebkit' }
    ]

    if MACOSX then
        # Webkit's WebProcess cannot be built on macosx, otherwise.
        bad_qt_libs.each do | lib |
            mkdir_p_cd File.join dirs[:build], lib[:dir] , 'lib' do
                [
                    ".#{qt_version[:major]}.#{qt_version[:minor]}.#{qt_version[:patch]}.dylib",
                    ".#{qt_version[:major]}.#{qt_version[:minor]}.dylib",
                    ".#{qt_version[:major]}.dylib",
                    '.dylib',
                    '.la',
                    '.prl',
                ].each do | suffix |
                    sh 'ln', '-sf', "libQt#{lib[:name]}#{suffix}", "libQt5#{lib[:name]}#{suffix}"
                end
            end
        end

        # QHelpGenerator cannot be run on macosx otherwise.
        mkdir_p_cd File.join dirs[:build], 'qtbase', 'lib' do
            sh 'ln', '-sf', File.join(dirs[:stage], 'lib', 'libpng.14.dylib')
        end
    end

    if WINDOWS then
        # FIXME: Implement.
    elsif UNIX then
        cd dirs[:build] do

            extra_args = []
            extra_args << '-no-framework' if MACOSX
            extra_args << '-webkit-debug' << '-declarative-debug' if cfg == 'debug'
            extra_args << '-nomake' << 'tools' unless mkdoc

            sh cmd('yes-run'), File.join(dirs[:source], 'configure'),
                '-opensource',
#                '-developer-build',
                '-prefix', dirs[:stage],
                '-arch', qt5_cpus[CPU],
                "-#{qt5_cfgs[cfg]}",
                '-system-zlib',
                '-system-libpng',
                '-nomake', 'examples',
                '-nomake', 'demos',
                '-I', File.join(dirs[:stage], 'include'),
                '-L', File.join(dirs[:stage], 'lib'),
                *extra_args

            sh $make_cmd, *$make_flags
            sh $make_cmd, *([ *$make_flags ] << 'install')

            if mkdoc then
                sh $make_cmd, 'docs'
                sh $make_cmd, 'install_htmldocs', 'install_qchdocs'
            end
        end
    end
end if QT5
