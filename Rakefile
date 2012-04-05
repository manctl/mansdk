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
    $cmake_gen = 'NMake Makefiles'
    $make_cmd  = 'nmake'
else
    $cmake_gen = 'Unix Makefiles'
    $make_cmd  = 'make'
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
#           "-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON",
        ]

        extra_defs.each do | name, type_val |
            cmake_args << "-D#{name}:#{type_val[0]}=#{type_val[1]}"
        end

        extra_args.each do | arg |
            cmake_args << arg
        end

        cmake_args << source_dir

        sh 'cmake', *cmake_args
        sh $make_cmd
        sh $make_cmd, 'install'
    end
end

task :jpeg         => [ :init,                    ] do | t | cmake_build t end

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
    cd source_dir do
        sh './bootstrap.sh', "--prefix=#{$stage_dir}"
        ENV['NO_COMPRESSION'] = '1'
        sh './b2', "--prefix=#{$stage_dir}", "--build-dir=#{build_dir}", 'link=static', 'threading=multi', 'install'
    end
end

task :vtk => [ :init, ] do | t | cmake_build t, {
    'CMAKE_VERBOSE_MAKEFILE' => [ BOOL, ON ],
    'CMAKE_C_FLAGS'   => [ STRING, '-fPIC' ],
    'CMAKE_CXX_FLAGS' => [ STRING, '-fPIC' ],
    'BUILD_TESTING' => [ BOOL, OFF ],
}
end

task :pcl          => [ :init, :boost, :eigen, :flann, :openni, :qhull, :vtk ] do | t | cmake_build t, {
    'BUILD_simulation'             => [ BOOL, OFF ],
    'BOOST_ROOT'                   => [ PATH, $stage_dir ],
    'Boost_NO_SYSTEM_PATHS'        => [ BOOL, ON ],
    'FLANN_ROOT'                   => [ PATH, $stage_dir ],
}
#, [ '--trace' ]
end

task :opencv       => [ :init,                    ] do | t | cmake_build t, {
    'WITH_CUDA'             => [ BOOL, OFF ],
}
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

    :pack,
]
