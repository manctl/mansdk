def write_file (path, contents)
    file = File.new(path, "w")
    file << contents
    file.close
end

def write_file_in (dir, path, contents)
    write_file File.join(dir, path), contents
end

def edit_file (path, pattern, replacement)
    text = File.read(path).gsub(pattern, replacement)
    File.open(path, "w") { |file| file << text }
end

#-------------------------------------------------------------------------------

 BUILD='build'
OUTPUT='output'
 STAGE='stage'

BOOL="BOOL"
STRING="STRING"
PATH="PATH"
FILEPATH="FILEPATH"
INTERNAL="INTERNAL"
ON="ON"
OFF="OFF"

 BUILD_DIR= "__BUILD_DIR__"
OUTPUT_DIR="__OUTPUT_DIR__"
 STAGE_DIR= "__STAGE_DIR__"

CONFIGS=[ "debug", "release", "relwithdebinfo", "minsizerel" ]

DEFAULT_CONFIG=ENV['CONFIG'] || "relwithdebinfo"

PREFIX=ENV['PREFIX'] || nil
VERBOSE=ENV['VERBOSE'] || "OFF"

def prefixed (path)
    return PREFIX ? File.join(PREFIX, path) : path
end

 $build_dir = File.expand_path(prefixed(ENV['BUILD_DIR' ] || BUILD))
$output_dir = File.expand_path(prefixed(ENV['OUTPUT_DIR'] || OUTPUT))
 $stage_dir = File.expand_path(prefixed(ENV['STAGE_DIR' ] || STAGE))

#-------------------------------------------------------------------------------

PLATFORM_OS_CPP = <<EOF
#include <iostream>

// See: http://poshlib.hookatooka.com/poshlib/trac.cgi.
static const char os [] =
#if   defined(_WIN32) || defined(_WIN64) || defined(__WINDOWS__)
    "windows"
#elif defined(__linux__) || defined(__linux) || defined(linux)
    "linux"
#elif defined(__APPLE__) && defined(__MACH__)
    "macosx"
#else
    "unknown"
#endif
;

int
main (int argc, char* argv[])
{
    std::cout << os << std::endl;
}
EOF

PLATFORM_ARCH_CPP = <<EOF
#include <iostream>

// See http://predef.sourceforge.net/prearch.html.
static const char arch [] =
#if   defined(_M_IX86) || defined(__i386__) || defined(__X86__) || defined(__I86__)
    "x86"
#elif defined(__amd64__) || defined(__amd64) || defined(__x86_64__) || defined(__x86_64) || defined(_M_X64)
    "x64"
#elif defined(_M_PPC) || defined(__ppc__) || defined(__powerpc__) || defined(__POWERPC__)
    "ppc"
#else
    "unknown"
#endif
;

int
main (int argc, char* argv[])
{
    std::cout << arch << std::endl;
}
EOF

PLATFORM_CMAKELISTS_TXT = <<EOF
cmake_minimum_required(VERSION 2.8)
project(platform)
add_executable(platform-os   platform-os.cpp)
add_executable(platform-arch platform-arch.cpp)
install(TARGETS platform-os platform-arch DESTINATION bin)
EOF

# FIXME: Move these inside the init task and let regular tasks depend on PLATFORM_OS & PLATFORM_ARCH.
case RUBY_PLATFORM
    when /win32|mingw32/ then
         WIN32=true
        MACOSX=false
         LINUX=false
          UNIX=false
    when /linux/ then
         WIN32=false
        MACOSX=false
         LINUX=true
          UNIX=true
    when /darwin/ then
         WIN32=false
        MACOSX=true
         LINUX=false
          UNIX=true
    else
        raise "Unknown Platform"
end

# FIXME: Likewise.
if WIN32
    $cmake_gen = 'NMake Makefiles'
    $make_cmd  = 'nmake'
    $make_options = []
    def path (str) return str.gsub('/', '\\') end
    USE_STATIC_LIBRARIES=false
elsif UNIX
    $cmake_gen = 'Unix Makefiles'
    $make_cmd  = 'make'
    $make_options = [] # ['-j', '4']
    def path (str) return str end
    USE_STATIC_LIBRARIES=true
else
    raise "Unknown System"
end

#-------------------------------------------------------------------------------

def config_path (path, config)
    return "#{path}/#{config}"
end

def config_symbol (sym, config)
    return "#{sym.to_s}:#{config}".intern
end

def config_deps (deps, config)
    ret = []
    [ :init, *deps ].each do | dep |
        ret << config_symbol(dep, config)
    end
    return ret
end

def config_val (val, config)
    return {
         BUILD_DIR => config_path( $build_dir, config),
        OUTPUT_DIR => config_path($output_dir, config),
         STAGE_DIR => config_path( $stage_dir, config),
    } [val] || val
end

#-------------------------------------------------------------------------------

def make_build_dir (name, config)
    build_dir = File.join(config_path($build_dir, config), name)
    mkdir_p build_dir
    return build_dir
end

def cmake_build_type (config)
    return {
        "debug"          => "Debug",
        "release"        => "Release",
        "relwithdebinfo" => "RelWithDebInfo",
        "minsizerel"     => "MinSizeRel",
    } [config]
end

def cmake_build (name, config, extra_defs = {}, extra_args = [])

    source_dir = File.expand_path(name)

    cd make_build_dir name, config do
        cmake_args = [
            "-DCMAKE_GENERATOR:STRING=#{$cmake_gen}",
            "-DCMAKE_BUILD_TYPE:STRING=#{cmake_build_type(config)}",
            "-DCMAKE_INSTALL_PREFIX:PATH=#{config_path($stage_dir,config)}",
            "-DCMAKE_PREFIX_PATH:PATH=#{config_path($stage_dir, config)}",
            "-DCMAKE_FIND_ROOT_PATH:PATH=#{config_path($stage_dir, config)}",
            "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE:STRING=BOTH",
            "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY:STRING=BOTH",
            "-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM:STRING=BOTH",
            "-DOUTPUT_DIRECTORY:PATH=#{config_path($output_dir, config)}",
            "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=#{config_path($output_dir,config)}/bin",
            "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=#{config_path($output_dir,config)}/lib",
            "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=#{config_path($output_dir,config)}/lib",
            "-DCMAKE_VERBOSE_MAKEFILE:BOOL=#{VERBOSE}"
        ]

        cmake_args << "-DCMAKE_INSTALL_NAME_DIR:STRING=@loader_path/../lib" if MACOSX
        cmake_args << "-DCMAKE_INSTALL_RPATH:STRING=\$ORIGIN/../lib" if LINUX

        extra_defs.each do | def_name, def_type_val |
            cmake_args << "-D#{def_name}:#{def_type_val[0]}=#{config_val(def_type_val[1], config)}"
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

#-------------------------------------------------------------------------------

task :init do
    mkdir_p $stage_dir
    mkdir_p $output_dir
    mkdir_p $build_dir
end

task :clean do
    rm_rf [ $build_dir, $output_dir, $stage_dir ]
end

task :pack do
  cd $stage_dir do
    # FIXME: Package stage contents.
  end
end

#-------------------------------------------------------------------------------

CONFIGS.each do | config |
    task config_symbol(:init, config) do
        mkdir_p config_path($stage_dir, config)
        mkdir_p config_path($output_dir, config)
        mkdir_p config_path($build_dir, config)

        source_dir = make_build_dir 'platform', config
        build_dir = File.join(source_dir, 'build')

        write_file_in source_dir, 'platform-os.cpp',   PLATFORM_OS_CPP
        write_file_in source_dir, 'platform-arch.cpp', PLATFORM_ARCH_CPP
        write_file_in source_dir, 'CMakeLists.txt',    PLATFORM_CMAKELISTS_TXT

        mkdir_p build_dir

        stage = config_path($stage_dir,config)
        cd build_dir do
            sh 'cmake',
                "-G#{$cmake_gen}",
                "-DCMAKE_BUILD_TYPE:STRING=#{cmake_build_type(config)}",
                "-DCMAKE_INSTALL_PREFIX:PATH=#{stage}",
                source_dir
            sh $make_cmd
            sh $make_cmd, 'install'
        end

        stage_bin = File.join(stage, 'bin')
        PLATFORM_OS=`#{File.join(stage_bin, 'platform-os')}`
        PLATFORM_ARCH=`#{File.join(stage_bin, 'platform-arch')}`
    end
end

CONFIGS.each do | config |
    task config_symbol(:pack, config) do
        cd config_path($stage_dir, config) do
            # FIXME: Package stage contents.
        end
    end
end

def custom_task (sym, deps = [], &blk)
    name = sym.to_s
    CONFIGS.each do | config |
        t = task config_symbol(name, config) => config_deps(deps, config) do | task, args | blk.call(name, config) end
    end
    task sym => [ config_symbol(name, DEFAULT_CONFIG) ]
end

def cmake_task (sym, deps = [], extra_defs = {}, extra_args = [])
    custom_task sym, deps do | name, config | cmake_build name, config, extra_defs, extra_args end
end

def all_tasks (syms)
    CONFIGS.each do | config |
        task config.intern => config_symbol(:init, config)
        syms.each do | sym |
            task config.intern => config_symbol(sym, config)
        end
        task config.intern => config_symbol(:pack, config)
    end
    task :init => config_symbol(:init, DEFAULT_CONFIG)
    task :pack => config_symbol(:pack, DEFAULT_CONFIG)
    task :default => DEFAULT_CONFIG.intern
end

#===============================================================================

cmake_task :zlib

cmake_task :portaudio, [], {
    'PA_DLL_LINK_WITH_STATIC_RUNTIME' => [ BOOL, OFF ],
}

cmake_task :vectorial

cmake_task :jpeg

cmake_task :png, [ :zlib ], {
    'PNG_NO_CONSOLE_IO'   => [ BOOL, OFF ],
    'PNG_NO_STDIO'        => [ BOOL, OFF ],
    'NO_VERSION_SUFFIXES' => [ BOOL, ON ],
}

cmake_task :usb

cmake_task :openni, [ :jpeg, :usb, ], {
    'OPENNI_BUILD_SAMPLES' => [ BOOL, ON ],
}

cmake_task :primesensor,   [ :openni ]

cmake_task :sensorkinect,  [ :openni ]

cmake_task :sensorkin4win, [ :openni ]

cmake_task :nite,          [ :openni ]

cmake_task :eigen

cmake_task :flann, [], {
    'BUILD_CUDA_LIB'        => [ BOOL, OFF ],
    'BUILD_PYTHON_BINDINGS' => [ BOOL, OFF ],
    'BUILD_MATLAB_BINDINGS' => [ BOOL, OFF ],
    'BUILD_C_BINDINGS'      => [ BOOL, OFF ],
    'BUILD_C_BINDINGS'      => [ BOOL, OFF ],
}.tap { | flags |
    flags['CMAKE_CXX_FLAGS'] = [ STRING, "/bigobj" ] if WIN32
}

cmake_task :qhull, [], {}.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
}

custom_task :boost do | name, config |
    source_dir = File.expand_path(name)
    build_dir = make_build_dir name, config

    if UNIX then
        bootstrap = './bootstrap.sh'
        b2 = './b2'
        def path (str) return str end
    else
        bootstrap = 'bootstrap.bat'
        b2 = 'b2.exe'
        def path (str) return str.gsub('/', '\\') end
    end

    def boost_build_variant (config)
        return {
            "debug"          => "debug",
            "release"        => "release",
            "relwithdebinfo" => "release",
            "minsizerel"     => "release",
        } [config]
    end

    cd source_dir do
        sh bootstrap
        ENV['NO_COMPRESSION'] = '1'
        b2_args = [
            "--prefix=#{path(config_path($stage_dir, config))}",
            "--build-dir=#{path(build_dir)}",
            '--without-python',
            'address-model=64', # FIXME: Address model should not be hard-coded.
            'threading=multi',
            "variant=#{boost_build_variant(config)}",
        ]
        b2_args << 'link=static' if USE_STATIC_LIBRARIES
        b2_args << 'cxxflags=-fPIC' if LINUX # FIXME: x86_64 only.
        b2_args << 'install'
        sh b2, *b2_args
    end
end

cmake_task :vtk, [], {
    'CMAKE_VERBOSE_MAKEFILE' => [ BOOL, ON ],
    'BUILD_TESTING' => [ BOOL, OFF ],
}.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
}

cmake_task :pcl, [ :boost, :eigen, :flann, :png, :openni, :qhull, :vtk ], {
    'BUILD_apps'              => [ BOOL, OFF ],
    'BUILD_simulation'        => [ BOOL, OFF ],
    'BUILD_GPU'               => [ BOOL, ON ],
    'BUILD_CUDA'              => [ BOOL, ON ],
    'BOOST_ROOT'              => [ PATH, STAGE_DIR ],
    'Boost_NO_SYSTEM_PATHS'   => [ BOOL, ON ],
    'FLANN_ROOT'              => [ PATH, STAGE_DIR ],
    'PCL_SHARED_LIBS'         => [ BOOL, (not USE_STATIC_LIBRARIES) ],
    'BUILD_TESTS'             => [ BOOL, OFF ],
}.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
}

#, [ '--trace' ]

cmake_task :opencv, [ :png ], {
    'BUILD_SHARED_LIBS'     => [ BOOL, (not USE_STATIC_LIBRARIES) ],
    'BUILD_WITH_STATIC_CRT' => [ BOOL, OFF ],
    'WITH_CUDA'             => [ BOOL, OFF ],
    'BUILD_TESTS'           => [ BOOL, ON  ],
    'WITH_FFMPEG'           => [ BOOL, OFF ],
    'WITH_EIGEN'            => [ BOOL, OFF ],
}.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
},
# FIXME: How can this work in a fully automated build?
["-DCMAKE_GENERATOR:STRING='Visual Studio 10 Win64'"]

# FIXME: Properly dispatch on actual config.
custom_task :qt do | name, config |
    source_dir = File.expand_path(name)
    build_dir = make_build_dir name, config

    def qt_config (config)
        return {
            "debug"          => "debug",
            "release"        => "release",
            "relwithdebinfo" => "release",
            "minsizerel"     => "release",
        } [config]
    end

    if WIN32 then
        cd build_dir do
            # FIXME: Do 32/64 bit dispatch.
            # FIXME: Properly install products in stage.
            sh "#{source_dir}/build-qt-windows-msvc10.cmd", 'amd64', qt_config(config)
        end
    else
        cd build_dir do
            # FIXME: Do 32/64 bit dispatch.
            sh "#{source_dir}/build-qt-unix-make.sh", 'amd64', qt_config(config), config_path($stage_dir, config)
        end
    end
end

# FIXME: Properly dispatch on actual config.
# FIXME: Ruby does not compile on 64 bit target architectures.

custom_task :ruby do | name, config |
    if PLATFORM_ARCH == 'x86'
        source_dir = File.expand_path(name)
        build_dir = make_build_dir name, config
        ENV['PATH'] = "#{ENV['PATH']};#{path(source_dir)}\\win32\\bin"
        if WIN32 then
            cd build_dir do
                sh "#{source_dir}/win32/configure.bat"
                edit_file("#{build_dir}/Makefile", /^RT = msvcr\d+/, 'RT = msvcrt')
                sh 'nmake'
                sh 'nmake', "DESTDIR=#{config_path($stage_dir, config)}", 'install', 'install-lib'
            end
        else
            cd source_dir do
                 sh 'autoconf'
            end
            cd build_dir do
                 sh "#{source_dir}/configure", "--prefix=#{config_path($stage_dir, config)}"
                 sh 'make'
                 sh 'make', 'install', 'install-lib'
            end
        end
    end
end

#-------------------------------------------------------------------------------

all_tasks [
    :zlib,
    :portaudio,
    :png,
    :vectorial,
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
]
