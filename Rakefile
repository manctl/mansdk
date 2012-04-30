BUILD='build'
STAGE='stage'
OUTPUT='output'

BOOL="BOOL"
STRING="STRING"
PATH="PATH"
FILEPATH="FILEPATH"
INTERNAL="INTERNAL"
ON="ON"
OFF="OFF"

$stage_dir  = File.expand_path(STAGE)
$output_dir = File.expand_path(OUTPUT)
$build_dir  = File.expand_path(BUILD)

if RUBY_PLATFORM =~ /win32|mingw32/
    WIN32=true
    UNIX=false
    $cmake_gen = 'NMake Makefiles'
    $make_cmd  = 'nmake'
    $make_options = []
    def path (str) return str.gsub('/', '\\') end
else
    WIN32=false
    UNIX=true
    $cmake_gen = 'Unix Makefiles'
    $make_cmd  = 'make'
    $make_options = ['-j', '4']
    def path (str) return str end
end

task :init do
    mkdir_p $stage_dir
    mkdir_p $output_dir
    mkdir_p $build_dir
end

def make_build_dir (name)
    build_dir = File.join($build_dir, name)   
    mkdir_p build_dir
    return build_dir
end

def cmake_build (t, extra_defs = {}, extra_args = [])

    source_dir = File.expand_path(t.name)

    cd make_build_dir t.name do
        cmake_args = [    
            "-DCMAKE_GENERATOR:STRING=#{$cmake_gen}",
            "-DCMAKE_BUILD_TYPE:STRING=Release",
            "-DCMAKE_INSTALL_PREFIX:PATH=#{$stage_dir}",
            "-DCMAKE_PREFIX_PATH:PATH=#{$stage_dir}",
            "-DOUTPUT_DIRECTORY:PATH=#{$output_dir}",
            "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=#{$output_dir}/bin",
            "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=#{$output_dir}/lib",
            "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=#{$output_dir}/lib",
            "-DCMAKE_INSTALL_NAME_DIR:STRING=@loader_path/../lib",
            "-DCMAKE_INSTALL_RPATH:STRING=\$ORIGIN/../lib",
            "-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
        ]

        extra_defs.each do | name, type_val |
            cmake_args << "-D#{name}:#{type_val[0]}=#{type_val[1]}"
        end

        extra_args.each do | arg |
            cmake_args << arg
        end

        cmake_args << source_dir

        sh 'cmake', *cmake_args
        sh $make_cmd, *$make_options
        sh $make_cmd, 'install'
    end
end

task :jpeg         => [ :init,                    ] do | t | cmake_build t end

task :png          => [ :init,                    ] do | t | cmake_build t end

task :usb          => [ :init,                    ] do | t | cmake_build t end

task :openni       => [ :init, :jpeg, :usb,       ] do | t | cmake_build t, {
    'OPENNI_BUILD_SAMPLES' => [ BOOL, ON ],
} end

task :primesensor  => [ :init, :openni,           ] do | t | cmake_build t end

task :sensorkinect => [ :init, :openni,           ] do | t | cmake_build t end

task :nite         => [ :init, :openni,           ] do | t | cmake_build t end

task :eigen        => [ :init,                    ] do | t | cmake_build t end

task :flann        => [ :init,                    ] do | t | cmake_build t, {
    'BUILD_CUDA_LIB'        => [ BOOL, OFF ],
    'BUILD_PYTHON_BINDINGS' => [ BOOL, OFF ],
    'BUILD_MATLAB_BINDINGS' => [ BOOL, OFF ],
}
end

task :qhull        => [ :init,                    ] do | t | cmake_build t end

task :boost => [ :init, ] do | t |
    source_dir = File.expand_path(t.name)
    build_dir = make_build_dir t.name

    if UNIX then
        bootstrap = './bootstrap.sh'
        b2 = './b2'
    else
        bootstrap = 'bootstrap.bat'
        b2 = 'b2.exe'
    end

    cd source_dir do
        sh bootstrap
        ENV['NO_COMPRESSION'] = '1'
        # FIXME: -fPIC is for linux-x86_64 only.
        # FIXME: Address model should not be hard-coded.
        sh b2, "--prefix=#{path($stage_dir)}", "--build-dir=#{path(build_dir)}", '--without-python', 'cxxflags=-fPIC', 'architecture=x86', 'address-model=64', 'link=static', 'threading=multi', 'install'
    end
end

# FIXME: -fPIC is for linux-x86_64 only.
task :vtk => [ :init, ] do | t | cmake_build t, {
    'CMAKE_VERBOSE_MAKEFILE' => [ BOOL, ON ],
    'CMAKE_C_FLAGS'   => [ STRING, '-fPIC' ], # FIXME: Linux-x86_64 only.
    'CMAKE_CXX_FLAGS' => [ STRING, '-fPIC' ], # FIXME: Likewise.
    'BUILD_TESTING' => [ BOOL, OFF ],
}
end

task :pcl          => [ :init, :boost, :eigen, :flann, :openni, :qhull, :vtk ] do | t | cmake_build t, {
    'BUILD_simulation'        => [ BOOL, OFF ],
    'BOOST_ROOT'              => [ PATH, $stage_dir ],
    'Boost_NO_SYSTEM_PATHS'   => [ BOOL, ON ],
    'FLANN_ROOT'              => [ PATH, $stage_dir ],
    'PCL_SHARED_LIBS'         => [ BOOL, OFF ],
    'BUILD_TESTS'             => [ BOOL, OFF ],
    'CMAKE_C_FLAGS'           => [ STRING, '-fPIC' ], # FIXME: Linux-x86_64 only.
    'CMAKE_CXX_FLAGS'         => [ STRING, '-fPIC' ], # FIXME: Likewise.
}
#, [ '--trace' ]
end

task :opencv       => [ :init, :png                ] do | t | cmake_build t, {
    'BUILD_SHARED_LIBS'     => [ BOOL, OFF ],
    'WITH_CUDA'             => [ BOOL, OFF ],
    'BUILD_TESTS'           => [ BOOL, ON  ],
    'WITH_FFMPEG'           => [ BOOL, OFF ],
    'WITH_EIGEN'            => [ BOOL, OFF ],
    'CMAKE_C_FLAGS'         => [ STRING, '-fPIC' ], # FIXME: Linux-x86_64 only.
    'CMAKE_CXX_FLAGS'       => [ STRING, '-fPIC' ], # FIXME: Likewise.
}
end

task :qt => [ :init, ] do | t |  
    if WIN32 then
        source_dir = File.expand_path(t.name)
        build_dir = make_build_dir t.name
        cd build_dir do
            # FIXME: Do 32/64 bit dispatch.
            sh "#{source_dir}/build-qt-win64-msvc10.cmd"
        end    
    end
end

def edit_file (path, pattern, replacement)
    text = File.read(path).gsub(pattern, replacement)
    File.open(path, "w") { |file| file << text }
end

task :ruby => [ :init, ] do | t |
    source_dir = File.expand_path(t.name)
    build_dir = make_build_dir t.name
    ENV['PATH'] = "#{ENV['PATH']};#{path(source_dir)}\\win32\\bin"
    if WIN32 then
        cd build_dir do
            sh "#{source_dir}/win32/configure.bat"
            edit_file("#{build_dir}/Makefile", /^RT = msvcr\d+/, 'RT = msvcrt')
            sh 'nmake'
            sh 'nmake', "DESTDIR=#{$stage_dir}", 'install', 'install-lib'
        end
    else
        cd source_dir do
             sh 'autoconf'
        end
        cd build_dir do
             sh "#{source_dir}/configure", "--prefix=#{$stage_dir}"
             sh 'make'
             sh 'make', 'install', 'install-lib'
        end
    end
end

task :pack do
  cd $stage_dir do
    # FIXME: Package stage contents.
  end
end

task :clean do
    rm_rf [ $build_dir, $output_dir, $stage_dir ]
end

task :default => [
    :init,

    :jpeg,
    :usb,
    :openni,
    :nite,
    :primesensor,
    :sensorkinect,
    :pcl,
    :opencv,
    :boost,
    :qt,
    :ruby,

    :pack,
]
