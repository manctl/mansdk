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
    File.open(path, "w") { | file | file << text }
end

def expand_flags(str)
    return str.split(' ')
end

#-------------------------------------------------------------------------------

 BUILD='build'
OUTPUT='output'
 STAGE='stage'

 BUILD_DIR= "__BUILD_DIR__"
OUTPUT_DIR="__OUTPUT_DIR__"
 STAGE_DIR= "__STAGE_DIR__"

CONFIGS=[ "debug", "release", "relwithdebinfo", "minsizerel" ]

# FIXME: I do not understand how to change the build type
# when a target is present otherwise.
DEFAULT_CONFIG=ENV['CONFIG'] || "relwithdebinfo"

PREFIX=ENV['PREFIX'] || nil
VERBOSE=ENV['VERBOSE'] || "OFF"
MAKE_FLAGS=expand_flags(ENV['MAKE_FLAGS'] || '')

def prefixed (path)
    return PREFIX ? File.join(PREFIX, path) : path
end

 $build_dir = File.expand_path prefixed ENV['BUILD_DIR' ] || BUILD
$output_dir = File.expand_path prefixed ENV['OUTPUT_DIR'] || OUTPUT
 $stage_dir = File.expand_path prefixed ENV['STAGE_DIR' ] || STAGE

 MACOSX_RPATH="@loader_path/../lib"
 LINUX_RPATH="\$ORIGIN/../lib"

def make_build_dir  (path)  build_dir = File.join  $build_dir, path; mkdir_p  build_dir; return  build_dir end
def make_output_dir (path) output_dir = File.join $output_dir, path; mkdir_p output_dir; return output_dir end
def make_stage_dir  (path)  stage_dir = File.join  $stage_dir, path; mkdir_p  stage_dir; return  stage_dir end

#-------------------------------------------------------------------------------

PLATFORM_OS_CPP = <<EOF
#include <iostream>

// See: http://poshlib.hookatooka.com/poshlib/trac.cgi.
static const char os [] =
#if   defined(_WINDOWS) || defined(_WIN64) || defined(__WINDOWS__)
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

OS_WINDOWS='windows'
OS_LINUX='linux'
OS_MACOSX='macosx'

PLATFORM_ARCH_CPP = <<EOF
#include <iostream>

// See http://predef.sourceforge.net/prearch.html.
static const char arch [] =
#if   defined(_M_IX86) || defined(__i386__) || defined(__X86__) || defined(__I86__)
    "x86"
#elif defined(__amd64__) || defined(__amd64) || defined(__x86_64__) || defined(__x86_64) || defined(_M_X64)
    "amd64"
#elif defined(_M_PPC) || defined(__ppc__) || defined(__powerpc__) || defined(__POWERPC__)
    "ppc"
#else
    "unknown"
#endif
;

int
main (int argc, char* argv[])
{
    std::cout << arch;
}
EOF

ARCH_X86='x86'
ARCH_AMD64='amd64'
ARCH_PPC='ppc'

PLATFORM_CMAKELISTS_TXT = <<EOF
cmake_minimum_required(VERSION 2.8)
project(platform)
add_executable(platform-os   platform-os.cpp)
add_executable(platform-arch platform-arch.cpp)
install(TARGETS platform-os platform-arch DESTINATION bin)
EOF

#===============================================================================

begin
    mkdir_p $stage_dir
    mkdir_p $output_dir
    mkdir_p $build_dir

    case RUBY_PLATFORM
        when /linux|darwin/  then
            $cmake_gen = 'Unix Makefiles'
            $make_cmd  = 'make'
            $make_flags = [] + MAKE_FLAGS
            def path (str) return str end
            USE_STATIC_LIBRARIES=false
        when /win32|mingw32/ then
            $cmake_gen = 'NMake Makefiles'
            $make_cmd  = 'nmake'
            $make_flags = [] + MAKE_FLAGS
            def path (str) return str.gsub('/', '\\') end
            USE_STATIC_LIBRARIES=false
        else
            raise "Unknown Platform"
    end

    source_dir = make_build_dir 'platform'
    build_dir  = make_build_dir 'platform/build'
    stage_dir  = make_stage_dir 'platform'

    write_file_in source_dir, 'platform-os.cpp',   PLATFORM_OS_CPP
    write_file_in source_dir, 'platform-arch.cpp', PLATFORM_ARCH_CPP
    write_file_in source_dir, 'CMakeLists.txt',    PLATFORM_CMAKELISTS_TXT

    cd build_dir do
        sh 'cmake',
            "-G#{$cmake_gen}",
            "-DCMAKE_BUILD_TYPE:STRING=Release",
            "-DCMAKE_INSTALL_PREFIX:PATH=#{ stage_dir }",
            source_dir
        sh $make_cmd
        sh $make_cmd, 'install'
    end

    stage_bin = File.join stage_dir, 'bin'

    PLATFORM_OS_BIN   = File.join stage_bin, 'platform-os'
    PLATFORM_ARCH_BIN = File.join stage_bin, 'platform-arch'
end

PLATFORM_OS   = `#{ PLATFORM_OS_BIN   }`.strip
PLATFORM_ARCH = `#{ PLATFORM_ARCH_BIN }`.strip

puts "Platform: #{ PLATFORM_OS }-#{ PLATFORM_ARCH }"

WINDOWS = PLATFORM_OS == OS_WINDOWS
MACOSX  = PLATFORM_OS == OS_MACOSX
LINUX   = PLATFORM_OS == OS_LINUX
UNIX    = LINUX || MACOSX

ARCH_64 = PLATFORM_ARCH == ARCH_AMD64
ARCH_32 = PLATFORM_ARCH == ARCH_X86

#===============================================================================

BOOL="BOOL"
STRING="STRING"
PATH="PATH"
FILEPATH="FILEPATH"
INTERNAL="INTERNAL"
ON="ON"
OFF="OFF"

def cmake_build_type (cfg)
    return {
        "debug"          => "Debug",
        "release"        => "Release",
        "relwithdebinfo" => "RelWithDebInfo",
        "minsizerel"     => "MinSizeRel",
    } [cfg]
end

def cmake_build (name, cfg, extra_defs = {}, extra_args = [])

    source_dir = dep_source_dir name
    output_dir = output_dir cfg
    stage_dir  = stage_dir cfg

    cd make_dep_build_dir name, cfg do
        cmake_args = [
            "-DCMAKE_GENERATOR:STRING=#{ $cmake_gen }",
            "-DCMAKE_BUILD_TYPE:STRING=#{ cmake_build_type cfg }",
            "-DCMAKE_INSTALL_PREFIX:PATH=#{ stage_dir }",
            "-DCMAKE_PREFIX_PATH:PATH=#{ stage_dir }",
            "-DCMAKE_FIND_ROOT_PATH:PATH=#{ stage_dir }",
            "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE:STRING=BOTH",
            "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY:STRING=BOTH",
            "-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM:STRING=BOTH",
            "-DOUTPUT_DIRECTORY:PATH=#{ output_dir }",
            "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=#{ output_dir }/bin",
            "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=#{ output_dir }/lib",
            "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=#{ output_dir }/lib",
            "-DCMAKE_VERBOSE_MAKEFILE:BOOL=#{ VERBOSE }"
        ]

        cmake_args << "-DCMAKE_INSTALL_NAME_DIR:STRING=#{ MACOSX_RPATH }" if MACOSX
        cmake_args << "-DCMAKE_INSTALL_RPATH:STRING=#{     LINUX_RPATH }" if LINUX

        extra_defs.each do | def_name, def_type_val |
            cmake_args << "-D#{ def_name }:#{ def_type_val[0] }=#{ dep_val(def_type_val[1], cfg) }"
        end

        extra_args.each do | arg |
            cmake_args << arg
        end

        cmake_args << source_dir

        sh 'cmake', *cmake_args
        sh $make_cmd, *$make_flags
        sh $make_cmd, 'install'
    end
end

#-------------------------------------------------------------------------------

task :setup do
    # Nothing, now.
end

#-------------------------------------------------------------------------------

def cfg_dir (path, cfg)
    return "#{path}/#{cfg}"
end

def  build_dir (cfg) return cfg_dir $build_dir , cfg end
def output_dir (cfg) return cfg_dir $output_dir, cfg end
def  stage_dir (cfg) return cfg_dir $stage_dir , cfg end

def cfg_dirs (cfg)
    return build_dir(cfg), output_dir(cfg), stage_dir(cfg)
end

def dep (sym, cfg)
    return "#{sym.to_s}:#{cfg}".intern
end

#-------------------------------------------------------------------------------

def dep_deps (deps, cfg)
    ret = []
    [ :init, *deps ].each do | dep_ |
        ret << dep(dep_, cfg)
    end
    return ret
end

def dep_val (val, cfg)
    return {
         BUILD_DIR =>  build_dir(cfg),
        OUTPUT_DIR => output_dir(cfg),
         STAGE_DIR =>  stage_dir(cfg),
    } [val] || val
end

def dep_source_dir (name)
    return File.expand_path name
#   FIXME: return File.expand_path File.join 'deps', name
end

def make_dep_build_dir (name, cfg)
    build_dir = File.join(build_dir(cfg), name)
    mkdir_p build_dir
    return build_dir
end

#-------------------------------------------------------------------------------

CONFIGS.each do | cfg |
    task dep(:init, cfg) => :setup
end

task :init => dep(:init, DEFAULT_CONFIG)

#-------------------------------------------------------------------------------

CONFIGS.each do | cfg |
    task dep(:pack, cfg) do
        cd stage_dir cfg do
            # FIXME: Package stage contents.
        end
    end
end

task :pack => dep(:pack, DEFAULT_CONFIG)

#-------------------------------------------------------------------------------

CONFIGS.each do | cfg |
    task dep(:clean, cfg) do
        rm_rf [
             build_dir(cfg),
            output_dir(cfg),
             stage_dir(cfg),
        ]
    end
end

task :clean => dep(:clean, DEFAULT_CONFIG )

#-------------------------------------------------------------------------------

task :clear do
    rm_rf [ $build_dir, $output_dir, $stage_dir ]
end

#-------------------------------------------------------------------------------

task :default => DEFAULT_CONFIG.intern

#-------------------------------------------------------------------------------

def custom_dep (sym, deps = [], &blk)
    name      = sym.to_s
    name_only = name + '-only'
    sym_only  = name_only.intern

    CONFIGS.each do | cfg |
        task dep(name     , cfg) => dep_deps(deps, cfg) do | task, args | blk.call(name, cfg) end
        task dep(name_only, cfg) => dep_deps([]  , cfg) do | task, args | blk.call(name, cfg) end
    end

    task sym      => [ dep(name     , DEFAULT_CONFIG) ]
    task sym_only => [ dep(name_only, DEFAULT_CONFIG) ]
end
#-------------------------------------------------------------------------------

def cmake_dep (sym, deps = [], extra_defs = {}, extra_args = [])
    custom_dep sym, deps do | name, cfg | cmake_build name, cfg, extra_defs, extra_args end
end

#-------------------------------------------------------------------------------

def deps (syms)
    CONFIGS.each do | cfg |
        syms.each do | sym |
            task cfg.intern => dep(sym, cfg)
            task dep(:pack, cfg) => cfg.intern
        end
    end
end

#===============================================================================

cmake_dep :zlib, [], {
    'BUILD_SHARED_LIBS' => [ BOOL, (not USE_STATIC_LIBRARIES) ],
 }.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
}

cmake_dep :portaudio, [], {
    'PA_DLL_LINK_WITH_STATIC_RUNTIME' => [ BOOL, OFF ],
}

cmake_dep :stk

cmake_dep :vectorial

cmake_dep :jpeg

cmake_dep :cryptopp

cmake_dep :png, WINDOWS ? [ :zlib ] : [], {
    'PNG_NO_CONSOLE_IO'   => [ BOOL, OFF ],
    'PNG_NO_STDIO'        => [ BOOL, OFF ],
    'NO_VERSION_SUFFIXES' => [ BOOL, ON ],
}

cmake_dep :opengm, [ :boost ], {
    'WITH_BOOST'      => [ BOOL, ON ],
    'BUILD_EXAMPLES'  => [ BOOL, OFF ],
    'BUILD_TESTING'   => [ BOOL, OFF ],
}

cmake_dep :quazip, [ :qt ]

cmake_dep :g2o, [ :eigen ]

cmake_dep :usb

cmake_dep :openni, [ :jpeg, :usb, ], {
    'OPENNI_BUILD_SAMPLES' => [ BOOL, ON ],
}

cmake_dep :primesensor,   [ :openni ]

cmake_dep :sensorkinect,  [ :openni ]

cmake_dep :sensorkin4win, [ :openni ]

cmake_dep :nite,          [ :openni ]

cmake_dep :eigen

cmake_dep :flann, [], {
    'BUILD_CUDA_LIB'        => [ BOOL, OFF ],
    'BUILD_PYTHON_BINDINGS' => [ BOOL, OFF ],
    'BUILD_MATLAB_BINDINGS' => [ BOOL, OFF ],
    'BUILD_C_BINDINGS'      => [ BOOL, OFF ],
    'BUILD_C_BINDINGS'      => [ BOOL, OFF ],
}.tap { | flags |
    flags[ 'CMAKE_CXX_FLAGS' ] = [ STRING, "/bigobj" ] if WINDOWS
}

cmake_dep :qhull, [],
    {}.tap { | flags |
        flags[ 'CMAKE_C_FLAGS'   ] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
        flags[ 'CMAKE_CXX_FLAGS' ] = [ STRING, '-fPIC' ] if LINUX # FIXME: x86_64 only.
}

def rpath ()
    if    LINUX  then return  LINUX_RPATH
    elsif MACOSX then return MACOSX_RPATH
    end
    return ""
end

custom_dep :boost do | name, cfg |

    source_dir = dep_source_dir name
    build_dir  = make_dep_build_dir name, cfg
    stage_dir  = stage_dir cfg

    if UNIX then
        bootstrap = './bootstrap.sh'
        b2 = './b2'
        def path (str) return str end
    else
        bootstrap = 'bootstrap.bat'
        b2 = 'b2.exe'
        def path (str) return str.gsub '/', '\\' end
    end

    def boost_build_variant (cfg)
        return {
            "debug"          => "debug",
            "release"        => "release",
            "relwithdebinfo" => "release",
            "minsizerel"     => "release",
        } [cfg]
    end

    cd source_dir do
        sh bootstrap
        ENV['NO_COMPRESSION'] = '1'

        # FIXME: b2 --dll-path=#{ rpath() } does not seem to work.

        b2_args = [
            "--prefix=#{ path stage_dir }",
            "--build-dir=#{ path build_dir }",
            '--without-python',
            'address-model=64', # FIXME: Address model should not be hard-coded.
            'threading=multi',
            "variant=#{boost_build_variant(cfg)}",
        ]
        b2_args << 'link=static' if USE_STATIC_LIBRARIES
        b2_args << 'cxxflags=-fPIC' if LINUX # FIXME: x86_64 only.
        b2_args << 'install'
        sh b2, *b2_args
    end

    boost_libs = [
        'chrono',
        'date_time',
        'filesystem',
        'graph',
        'iostreams',
        'math_c99',
        'math_c99f',
        'math_c99l',
        'math_tr1',
        'math_tr1f',
        'math_tr1l',
        'prg_exec_monitor',
        'program_options',
        'random',
        'regex',
        'serialization',
        'signals',
        'system',
        'thread',
        'unit_test_framework',
        'wave',
        'wserialization',
    ]

    if MACOSX then
        boost_libs.each do | lib |
            sh 'install_name_tool', '-id',
                "#{ MACOSX_RPATH }/libboost_#{ lib }.dylib",
                "#{ stage_dir }/lib/libboost_#{ lib }.dylib"
            boost_libs.each do | lib_ |
                sh 'install_name_tool', '-change',
                    "libboost_#{ lib }.dylib",
                    "#{ MACOSX_RPATH }/libboost_#{ lib }.dylib",
                    "#{ stage_dir }/lib/libboost_#{ lib_ }.dylib"
            end
        end
    end
end

cmake_dep :vtk, [], {
    'CMAKE_VERBOSE_MAKEFILE' => [ BOOL, ON ],
    'BUILD_TESTING' => [ BOOL, OFF ],
}.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
}

cmake_dep :pcl, [ :boost, :eigen, :flann, :qhull, :vtk ] + (WINDOWS ? [:png] : [:openni]), {
	'BUILD_apps'                  => [ BOOL, OFF ],
    'BUILD_simulation'            => [ BOOL, OFF ],
    'BUILD_outofcore'             => [ BOOL, OFF ],
    'BUILD_gpu_kinfu_large_scale' => [ BOOL, OFF ],
    'BUILD_GPU'                   => [ BOOL, ON  ],
    'BUILD_CUDA'                  => [ BOOL, ON  ],
    'BUILD_cuda_features'         => [ BOOL, OFF ],
    'BUILD_cuda_io'               => [ BOOL, OFF ], # Broken on Windows with PCL trunk.
	'BUILD_cuda_sample_consensus' => [ BOOL, OFF ],
	'BUILD_cuda_segmentation'     => [ BOOL, OFF ],
	'BUILD_gpu_features'          => [ BOOL, OFF ],
	'BUILD_gpu_octree'            => [ BOOL, OFF ],
	'BUILD_gpu_people'            => [ BOOL, OFF ],
	'BUILD_gpu_segmentation'      => [ BOOL, OFF ],
	'BUILD_gpu_surface'           => [ BOOL, OFF ],
	'BUILD_gpu_tracking'          => [ BOOL, OFF ],
	'BUILD_keypoints'             => [ BOOL, OFF ],
    'BUILD_ml'                    => [ BOOL, ON  ],
	'BUILD_recognition'           => [ BOOL, OFF ],
    'BUILD_segmentation'          => [ BOOL, ON  ], # registration
	'BUILD_stereo'                => [ BOOL, OFF ],
	'BUILD_tracking'              => [ BOOL, OFF ],	
    'BUILD_visualization'         => [ BOOL, ON  ],	# kinfu
	'BUILD_TESTS'                 => [ BOOL, OFF ],
    'BUILD_OPENNI'                => [ BOOL, OFF ],
	'BOOST_ROOT'                  => [ PATH, STAGE_DIR ],
    'Boost_NO_SYSTEM_PATHS'       => [ BOOL, ON  ],
    'FLANN_ROOT'                  => [ PATH, STAGE_DIR ],
    'PCL_SHARED_LIBS'             => [ BOOL, (not USE_STATIC_LIBRARIES) ],
    'PCL_ONLY_CORE_POINT_TYPES'   => [ BOOL, ON  ],
}.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
}

#, [ '--trace' ]

cmake_dep :opencv, [] + (WINDOWS ? [:png] : []), {
    'CMAKE_BUILD_TYPE'               => [ STRING, "Release" ], # relwithdeinfo is not supported
    'BUILD_SHARED_LIBS'              => [ BOOL  , (not USE_STATIC_LIBRARIES) ],
    'BUILD_WITH_STATIC_CRT'          => [ BOOL  , OFF ],
    'BUILD_TIFF'                     => [ BOOL  , ON  ],
    'BUILD_TESTS'                    => [ BOOL  , OFF ],
    'WITH_CUDA'                      => [ BOOL  , OFF ],
    'WITH_FFMPEG'                    => [ BOOL  , OFF ],
    'WITH_EIGEN'                     => [ BOOL  , OFF ],
    'CMAKE_LINK_INTERFACE_LIBRARIES' => [ STRING, "" ],
}.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
}

# FIXME: Properly dispatch on actual config.
custom_dep :qt do | name, cfg |
    source_dir = dep_source_dir name
     build_dir = make_dep_build_dir name, cfg
     stage_dir = stage_dir cfg

    def qt_config (cfg)
        return {
            "debug"          => "debug",
            "release"        => "release",
            "relwithdebinfo" => "release",
            "minsizerel"     => "release",
        } [cfg]
    end

    # FIXME: Ugly hack to avoid building qt every time.
    if File.exists? "#{ build_dir }/.qmake.cache" then
        next
    end

    if WINDOWS then
        cd build_dir do
            # FIXME: Do 32/64 bit dispatch.
            # FIXME: Properly install products in stage.
            sh "#{ source_dir }/build-qt-windows-msvc10.cmd", 'amd64', (qt_config cfg)
        end
    elsif UNIX then
        cd build_dir do
            # FIXME: Do 32/64 bit dispatch.
            sh "#{ source_dir }/build-qt-unix-make.sh", 'amd64', (qt_config cfg), stage_dir
        end
    end
end

def add_env_path (path)
    ENV['PATH'] = "#{ ENV['PATH'] };#{ path }"
end

# FIXME: Properly dispatch on actual config.
# FIXME: Ruby does not compile on 64 bit target architectures.

custom_dep :ruby do | name, cfg |
    if ARCH_32
        source_dir = File.expand_path name
         build_dir = make_dep_build_dir name, cfg
         stage_dir = stage_dir cfg

        add_env_path "#{ path(source_dir) }\\win32\\bin"
        if WINDOWS then
            cd build_dir do
                sh "#{source_dir}/win32/configure.bat"
                edit_file("#{ build_dir }/Makefile", /^RT = msvcr\d+/, 'RT = msvcrt')
                sh 'nmake'
                sh 'nmake', "DESTDIR=#{ stage_dir }", 'install', 'install-lib'
            end
        else
            cd source_dir do
                 sh 'autoconf'
            end
            cd build_dir do
                 sh "#{ source_dir }/configure", "--prefix=#{ stage_dir }"
                 sh 'make'
                 sh 'make', 'install', 'install-lib'
            end
        end
    end
end

custom_dep :qt3d, [ :qt ] do | name, cfg |
    source_dir = dep_source_dir name
     build_dir = make_dep_build_dir name, cfg
     stage_dir = stage_dir cfg

    if WINDOWS then
        # FIXME: Have qt properly stage itself on windows.
        qmake_path  = "#{ make_dep_build_dir('qt', cfg) }/bin/qmake.exe"
    else
        qmake_path  = "#{ stage_dir }/bin/qmake"
    end
    project_path = "#{ source_dir }/qt3d.pro"
    cd build_dir do
        # FIXME: Honor build configuration.
        sh qmake_path, '-d', "PREFIX=#{ stage_dir }", project_path
        sh $make_cmd, *$make_flags
        sh $make_cmd, "INSTALL_ROOT=#{ stage_dir }", 'install'
    end
end

custom_dep :openssl do | name, cfg |
    source_dir = dep_source_dir name
     build_dir = make_dep_build_dir name, cfg
     stage_dir = stage_dir cfg

    # Remove this if you find out how to perform out-of-source openssl builds.
    cp_r source_dir, build_dir(cfg)

    if WINDOWS then
        cd build_dir do
            if ARCH_32 then
                sh 'perl', "./Configure", 'VC-WINDOWS', 'no-asm', "--prefix=#{ stage_dir }"
                sh "ms/do_ms"
            elsif ARCH_64 then
                sh 'perl', "./Configure", 'VC-WIN64A', 'no-asm', "--prefix=#{ stage_dir }"
                sh "ms/do_win64a"
            end
            sh 'nmake', '-f', 'ms/ntdll.mak'
            sh 'nmake', '-f', 'ms/ntdll.mak', 'install'
        end
    else
        cp_r source_dir, build_dir
        cd build_dir do
             sh "./config", "--prefix=#{ stage_dir }"
             sh 'make'
             sh 'make', 'install'
        end
    end
end

#-------------------------------------------------------------------------------

deps [
    :portaudio,
    :vectorial,
    :jpeg,
    :usb,
    :pcl,
    :opencv,
    :boost,
    :ruby,
    :qt,
    :qt3d,
    :quazip,
    :cryptopp,
    :openssl
#   :opengm
].tap { | list |
    list << :png          if WINDOWS
    list << :zlib         if WINDOWS
    list << :openni       if not WINDOWS
    list << :primesensor  if not WINDOWS
    list << :sensorkinect if not WINDOWS
    list << :nite         if not WINDOWS
    list << :stk          if not LINUX
}

#-------------------------------------------------------------------------------

# FIXME: NB does neither implicitly want boost, nor qt.

