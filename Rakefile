# task :primesensor do
#   puts "primesensor"
# end
# 
# task :sensorkinect do | name |
#   puts name
#   sh "echo foo"
# end

# task :openni do
#     puts "openni"
# end

BUILD='build'
STAGE='stage'

stage_dir = File.expand_path(STAGE)

task :pcl do | t |

  source_dir = File.expand_path(t.name)
   build_dir = File.expand_path(File.join(BUILD, t.name))

  mkdir_p build_dir

  cd build_dir do
      sh 'cmake',
	"-DCMAKE_BUILD_TYPE:STRING=Release",
	"-DCMAKE_INSTALL_PREFIX:STRING=#{stage_dir}",
	source_dir
      sh 'make', '-j'
      sh 'make', 'install'
  end

  mkdir_p stage_dir

  cd stage_dir do
    # FIXME: Package stage contents.
  end
end

task :default => [
    :openni,
    :pcl,
    :primesensor,
    :sensorkinect,
]
