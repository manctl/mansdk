BUILD='build'
STAGE='stage'

$stage_dir = File.expand_path(STAGE)

task :prepare do
    mkdir_p $stage_dir
end

def build (t)
    source_dir = File.expand_path(t.name)
    build_dir = File.expand_path(File.join(BUILD, t.name))   
    mkdir_p build_dir
    cd build_dir do
        sh 'cmake',
        "-DCMAKE_BUILD_TYPE:STRING=Release",
        "-DCMAKE_INSTALL_PREFIX:STRING=#{$stage_dir}",
        "-DCMAKE_PREFIX_PATH:STRING=#{$stage_dir}",
        source_dir
        sh 'make'
        sh 'make', 'install'
    end
end

task :jpeg         do | t | build t end
task :usb          do | t | build t end
task :openni       do | t | build t end
task :primesensor  do | t | build t end
task :sensorkinect do | t | build t end
task :pcl          do | t | build t end

task :pack do
  cd $stage_dir do
    # FIXME: Package stage contents.
  end
end

task :default => [
    :prepare,

    :jpeg,
    :usb,
    :openni,
    :primesensor,
    :sensorkinect,
#   :pcl,

    :pack,
]
