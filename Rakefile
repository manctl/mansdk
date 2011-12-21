BUILD='build'
STAGE='stage'
OUTPUT='output'

$stage_dir  = File.expand_path(STAGE)
$output_dir = File.expand_path(OUTPUT)
$build_dir  = File.expand_path(BUILD)

task :init do
    mkdir_p $stage_dir
    mkdir_p $output_dir
end

def build (t)
    source_dir = File.expand_path(t.name)
    build_dir = File.join($build_dir, t.name)   
    mkdir_p build_dir
    cd build_dir do
        sh 'cmake',
        "-DCMAKE_BUILD_TYPE:STRING=Release",
        "-DCMAKE_INSTALL_PREFIX:PATH=#{$stage_dir}",
        "-DCMAKE_PREFIX_PATH:PATH=#{$stage_dir}",
        "-DOUTPUT_DIRECTORY:PATH=#{$output_dir}",
        "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=#{$output_dir}/bin",
        "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=#{$output_dir}/lib",
        "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=#{$output_dir}/lib",
        "-DCMAKE_INSTALL_NAME_DIR:STRING=@loader_path/../lib",
        "-DCMAKE_INSTALL_RPATH:STRING=\$ORIGIN/../lib",
#        "-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON",
        source_dir
        sh 'make'
        sh 'make', 'install'
    end
end

task :jpeg         => [ :init              ] do | t | build t end
task :usb          => [ :init              ] do | t | build t end
task :openni       => [ :init, :jpeg, :usb ] do | t | build t end
task :primesensor  => [ :init, :openni     ] do | t | build t end
task :sensorkinect => [ :init, :openni     ] do | t | build t end
task :pcl          => [ :init, :openni     ] do | t | build t end

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
    :primesensor,
    :sensorkinect,
    :pcl,

    :pack,
]
