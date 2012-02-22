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

def cmake_build (t, args = {})
    source_dir = File.expand_path(t.name)
    build_dir = File.join($build_dir, t.name)   
    mkdir_p build_dir
    
    extra_defs = []
    args.each do | name, type_val |
        extra_defs << "-D#{name}:#{type_val[0]}=#{type_val[1]}"
    end

    extra_defs.each do | item |
        puts "#{item}"
    end

    cd build_dir do
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
            *extra_defs
        ]
        cmake_args << source_dir

        sh 'cmake', *cmake_args
        sh $make_cmd
        sh $make_cmd, 'install'
    end
end

task :jpeg         => [ :init              ] do | t | cmake_build t end
task :usb          => [ :init              ] do | t | cmake_build t end
task :openni       => [ :init, :jpeg, :usb ] do | t | cmake_build t, {
    'OPENNI_BUILD_SAMPLES' => [ BOOL, ON ]
} end
task :primesensor  => [ :init, :openni     ] do | t | cmake_build t end
task :sensorkinect => [ :init, :openni     ] do | t | cmake_build t end
task :nite         => [ :init, :openni     ] do | t | cmake_build t end
task :pcl          => [ :init, :openni     ] do | t | cmake_build t, {
    'BUILD_simulation' => [ BOOL, OFF ]
} end

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

    :pack,
]
