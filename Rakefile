SDK_NAME    = 'ManSDK'
SDK_MAJOR   = 0
SDK_MINOR   = 1
SDK_VERSION = "#{ SDK_MAJOR }.#{ SDK_MINOR   }"
SDK_TITLE   = "#{ SDK_NAME  } #{ SDK_VERSION }"

#-------------------------------------------------------------------------------
# Library

HERE = File.dirname File.expand_path __FILE__

UNKNOWN_PLATFORM = "Unknown Platform"

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

def files_exist_in (dir, *files)
    ret = true
    files.each { | file | ret &&= File.exists? File.join(dir, file) }
    return ret
end

def add_env_path (path) ENV['PATH'] += File::PATH_SEPARATOR + native_path(path) end

def native_path (path)
    case RUBY_PLATFORM
        when /linux|darwin/  then return path
        when /win32|mingw32/ then return path.gsub('/', '\\')
        else raise UNKNOWN_PLATFORM
    end
end

case RUBY_PLATFORM
    when /linux|darwin/  then EXE_SUFFIX = ''
    when /win32|mingw32/ then EXE_SUFFIX = '.exe'
    else raise UNKNOWN_PLATFORM
end

def exe (path)
    return path + EXE_SUFFIX
end

# Ruby's cp_r is kinda broken on Unix when copying symbolic links on unix.
# Fall back to platform-specific replacements.
def mirror_dirs (source_dir, target_dir)
    # Skip hidden root source dir files by default.
    source_files = Dir.glob File.join(source_dir, '*')
    case RUBY_PLATFORM
        when /linux|darwin/  then
            source_files.each { | source_file | sh 'cp', '-a', source_file, target_dir }
        else
            cp_r source_files, target_dir, :preserve => true
    end
end

#-------------------------------------------------------------------------------
# Constants

CFG_D = 'D'    ; CFG_R   = 'R'      ; CFG_RD         = 'RD'            ; CFG_M      = 'M';
DEBUG = 'debug'; RELEASE = 'release'; RELWITHDEBINFO = 'relwithdebinfo'; MINSIZEREL = 'minsizerel';
CFGS = {
    DEBUG          => CFG_D,
    RELEASE        => CFG_R,
    RELWITHDEBINFO => CFG_RD,
    MINSIZEREL     => CFG_M,
}
CONFIGS = {
    CFG_D  => DEBUG,
    CFG_R  => RELEASE,
    CFG_RD => RELWITHDEBINFO,
    CFG_M  => MINSIZEREL,
}

STATIC_LIBRARIES = false

MACOSX_RPATH     = "@loader_path/../lib"
LINUX_RPATH      = "\$ORIGIN/../lib"

#-------------------------------------------------------------------------------
# Defaults

PREFIX     =  ENV['PREFIX'] || nil
CONFIG     =  ENV['CONFIG'] || CONFIGS[CFG_RD]
MAKE_FLAGS = (ENV['MAKE_FLAGS'] || '').split ' '
VERBOSE    =  ENV['VERBOSE'] || "OFF"
BUILD      =  ENV['BUILD' ] || 'build'
OUTPUT     =  ENV['OUTPUT'] || 'output'
STAGE      =  ENV['STAGE' ] || 'stage'

if ENV['CFG'] then
    CFG  = ENV['CFG']
    CONFIG = CONFIGS[CFG]
else
    CFG = CFGS[CONFIG]
end

#-------------------------------------------------------------------------------
# Directories

def prefixed (path) return File.join(PREFIX ? PREFIX : HERE, path) end

 $build_dir = File.expand_path prefixed BUILD
$output_dir = File.expand_path prefixed OUTPUT
 $stage_dir = File.expand_path prefixed STAGE

def  build_subdir (path) return File.join  $build_dir, path end
def output_subdir (path) return File.join $output_dir, path end
def  stage_subdir (path) return File.join  $stage_dir, path end

def  make_build_subdir (path) dir =  build_subdir(path); mkdir_p dir; return dir end
def make_output_subdir (path) dir = output_subdir(path); mkdir_p dir; return dir end
def  make_stage_subdir (path) dir =  stage_subdir(path); mkdir_p dir; return dir end

#-------------------------------------------------------------------------------
# Platform

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
# Bootstrap

begin
    case RUBY_PLATFORM
        when /linux|darwin/  then
            $cmake_gen  = 'Unix Makefiles'
            $make_cmd   = 'make'
            $make_flags = [] + MAKE_FLAGS
        when /win32|mingw32/ then
            $cmake_gen  = 'NMake Makefiles JOM'
            $jom_dir =  File.join HERE, 'core', 'deps', 'jom'
            add_env_path $jom_dir
            $make_cmd = 'jom'
            $make_flags = [] + MAKE_FLAGS
        else
            raise UNKOWN_PLATFORM
    end

    stage_bin = File.join stage_subdir 'platform/bin/'

    unless files_exist_in stage_bin, exe('platform-os'), exe('platform-arch')

        source_dir = make_build_subdir 'platform'
        build_dir  = make_build_subdir 'platform/build'
        stage_dir  = make_stage_subdir 'platform'

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
    end

    PLATFORM_OS_BIN   = File.join stage_bin, 'platform-os'
    PLATFORM_ARCH_BIN = File.join stage_bin, 'platform-arch'

    PLATFORM_OS   = `#{ PLATFORM_OS_BIN   }`.strip
    PLATFORM_ARCH = `#{ PLATFORM_ARCH_BIN }`.strip
end

#-------------------------------------------------------------------------------

# Platform-specific Keywords

WINDOWS = PLATFORM_OS == OS_WINDOWS
MACOSX  = PLATFORM_OS == OS_MACOSX
LINUX   = PLATFORM_OS == OS_LINUX
UNIX    = LINUX || MACOSX
AMD64   = PLATFORM_ARCH == ARCH_AMD64
X86     = PLATFORM_ARCH == ARCH_X86
ARCH_64 = AMD64
ARCH_32 = X86

# Cross-platform Helpers

def rpath ()
    if    LINUX  then return  LINUX_RPATH
    elsif MACOSX then return MACOSX_RPATH
    end
    return ""
end

#-------------------------------------------------------------------------------
# Configs

def sym_append (sym, *suffixes)
    name = sym.to_s
    suffixes.each { | suffix | name += suffix.to_s }
    return name.intern
end

def cfg_sym (sym, cfg, *suffixes)
    return sym_append(sym, ':', cfg, *suffixes)
end

def cfg_name (cfg)
    return CONFIGS[cfg]
end

def  cfg_build_dir (cfg) return  build_subdir cfg_name cfg end
def cfg_output_dir (cfg) return output_subdir cfg_name cfg end
def  cfg_stage_dir (cfg) return  stage_subdir cfg_name cfg end

def make_cfg_output_dir (cfg) ret = cfg_output_dir cfg; mkdir_p ret; return ret end
def  make_cfg_stage_dir (cfg) ret =  cfg_stage_dir cfg; mkdir_p ret; return ret end

#-------------------------------------------------------------------------------
# Tasks

$deps = []

task :default => :all

task :all => cfg_sym(:all, CFG)

task :pack => cfg_sym(:pack, CFG)

task :clear => cfg_sym(:clear, CFG)

CFGS.each_value do | cfg |

    task cfg_sym(:pack, cfg) => cfg_sym(:all, cfg) do
        cd stage_dir cfg do
            # FIXME: Package stage contents.
        end
    end

    task cfg_sym(:clear, cfg) do
        rm_rf [
              cfg_build_dir(cfg),
             cfg_output_dir(cfg),
              cfg_stage_dir(cfg),
        ]
    end

    # Aliases
    task cfg                            => cfg_sym(:all, cfg)
    task                 cfg_name(cfg)  => cfg
    task cfg_sym(:pack , cfg_name(cfg)) => cfg_sym(:pack , cfg)
    task cfg_sym(:clear, cfg_name(cfg)) => cfg_sym(:clear, cfg)
end

task :wipe do
    rm_rf [ $build_dir, $output_dir, $stage_dir ]
end

task :help do

    def half (x) return x / 2 end
    def centered (w, str) return ' ' * half(w - str.length) + str end

    puts <<EOF

#{ centered(80,       SDK_TITLE) }
#{ centered(80, '-' * SDK_TITLE.length) }

Platform:

    #{ PLATFORM_OS }-#{ PLATFORM_ARCH }

Variables:

    PREFIX       = #{ PREFIX }
    CFG / CONFIG = #{ CFG } / #{ CONFIG }
    MAKE_FLAGS   = #{ MAKE_FLAGS }
    VERBOSE      = #{ VERBOSE }
    BUILD        = #{ BUILD }
    OUTPUT       = #{ OUTPUT }
    STAGE        = #{ STAGE }

Targets:

                                all[:#{ CFGS.values().join '|:' }]
    <dep>[-only|-clear|-clear-only][:#{ CFGS.values().join '|:' }]
                              clear[:#{ CFGS.values().join '|:' }]
                               help
                               wipe

Aliases:

    <dep> => <dep>:#{ CFG }

    all   =>   all:#{ CFG }
    clear => clear:#{ CFG }

    D     =>   all:#{ CFG_D  }
    R     =>   all:#{ CFG_R  }
    RD    =>   all:#{ CFG_RD }
    M     =>   all:#{ CFG_M  }

    #{ DEBUG }          => #{ CFG_D  }
    #{ RELEASE }        => #{ CFG_R  }
    #{ RELWITHDEBINFO } => #{ CFG_RD }
    #{ MINSIZEREL }     => #{ CFG_M  }

    <dep>*:#{ DEBUG }          => <dep>:#{ CFG_D  }
    <dep>*:#{ RELEASE }        => <dep>:#{ CFG_R  }
    <dep>*:#{ RELWITHDEBINFO } => <dep>:#{ CFG_RD }
    <dep>*:#{ MINSIZEREL }     => <dep>:#{ CFG_M  }

Deps:

    #{ $deps.sort.join "\n    " }
EOF
end

#-------------------------------------------------------------------------------
# Deps

def custom_dep (sym, deps = [], &blk)
    name       = sym.to_s
    only       = (name + '-only').intern
    clear      = (name + '-clear').intern
    clear_only = (name + '-clear-only').intern

    CFGS.each_value do | cfg |

        task cfg_sym(:all, cfg) => cfg_sym(name, cfg)

        task cfg_sym(name, cfg) => dep_deps(deps, cfg) do | task, args | blk.call(name, cfg) end

        task cfg_sym(only, cfg) => dep_deps([]  , cfg) do | task, args | blk.call(name, cfg) end

        task cfg_sym(:clear, cfg) => cfg_sym(clear, cfg)

        task cfg_sym(clear, cfg) => dep_deps(deps, cfg, '-clear')
        task cfg_sym(clear, cfg) => cfg_sym(clear_only, cfg)

        task cfg_sym(clear_only, cfg) do
            rm_rf dep_build_dir(name, cfg)
        end

        # Aliases
        task cfg_sym(name      , cfg_name(cfg)) => cfg_sym(name      , cfg)
        task cfg_sym(only      , cfg_name(cfg)) => cfg_sym(only      , cfg)
        task cfg_sym(clear     , cfg_name(cfg)) => cfg_sym(clear     , cfg)
        task cfg_sym(clear_only, cfg_name(cfg)) => cfg_sym(clear_only, cfg)
    end

    task sym        => [ cfg_sym(name      , CFG) ]
    task only       => [ cfg_sym(only      , CFG) ]
    task clear      => [ cfg_sym(clear     , CFG) ]
    task clear_only => [ cfg_sym(clear_only, CFG) ]

    $deps << name
end

def dep_deps (deps, cfg, suffix = '')
    ret = [ ]
    deps.each do | dep_ |
        ret << cfg_sym(sym_append(dep_, suffix), cfg)
    end
    return ret
end

def dep_source_dir (name)
    return File.expand_path File.join 'deps', name
end

def dep_build_dir (name, cfg)
    return File.join(cfg_build_dir(cfg), name)
end

def make_dep_build_dir (name, cfg)
    build_dir = dep_build_dir(name, cfg)
    mkdir_p build_dir
    return build_dir
end

def dep_dirs (name, cfg)
    return {
        :source => dep_source_dir(name),
        :build  => make_dep_build_dir(name, cfg),
        :output => make_cfg_output_dir(cfg),
        :stage  => make_cfg_stage_dir(cfg),
    }
end

#-------------------------------------------------------------------------------
# CMake Deps

# CMake Definitions Keywords

BOOL     = "BOOL"
STRING   = "STRING"
PATH     ="PATH"
FILEPATH ="FILEPATH"
INTERNAL ="INTERNAL"

ON = "ON"
OFF = "OFF"

 DEP_BUILD_DIR="__BUILD_DIR__"
DEP_OUTPUT_DIR="__OUTPUT_DIR__"
 DEP_STAGE_DIR="__STAGE_DIR__"

# CMake Definitions Expansions

def cmake_def_val (val, name, cfg)
    return {
         DEP_BUILD_DIR =>  dep_build_dir(name, cfg),
        DEP_OUTPUT_DIR => cfg_output_dir(      cfg),
         DEP_STAGE_DIR =>  cfg_stage_dir(      cfg),
    } [val] || val
end

def cmake_build_type (cfg)
    return {
        CFG_D  => "Debug",
        CFG_R  => "Release",
        CFG_RD => "RelWithDebInfo",
        CFG_M  => "MinSizeRel",
    } [cfg]
end

def cmake_build (name, cfg, extra_defs = {}, extra_args = [])

    dirs = dep_dirs name, cfg

    cd dirs[:build] do
        cmake_args = [
            "-DCMAKE_GENERATOR:STRING=#{ $cmake_gen }",
            "-DCMAKE_BUILD_TYPE:STRING=#{ cmake_build_type cfg }",
            "-DCMAKE_INSTALL_PREFIX:PATH=#{ dirs[:stage] }",
            "-DCMAKE_PREFIX_PATH:PATH=#{ dirs[:stage] }",
            "-DCMAKE_FIND_ROOT_PATH:PATH=#{ dirs[:stage] }",
            "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE:STRING=BOTH",
            "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY:STRING=BOTH",
            "-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM:STRING=BOTH",
            "-DOUTPUT_DIRECTORY:PATH=#{ dirs[:output] }",
            "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=#{ dirs[:output] }/bin",
            "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=#{ dirs[:output] }/lib",
            "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=#{ dirs[:output] }/lib",
            "-DCMAKE_VERBOSE_MAKEFILE:BOOL=#{ VERBOSE }"
        ]

        cmake_args << "-DCMAKE_INSTALL_NAME_DIR:STRING=#{ MACOSX_RPATH }" if MACOSX
        cmake_args << "-DCMAKE_INSTALL_RPATH:STRING=#{     LINUX_RPATH }" if LINUX

        extra_defs.each do | def_name, def_type_val |
            cmake_args << "-D#{ def_name }:#{ def_type_val[0] }=#{ cmake_def_val(def_type_val[1], name, cfg) }"
        end

        extra_args.each do | arg |
            cmake_args << arg
        end

        cmake_args << dirs[:source]

        sh 'cmake', *cmake_args
        sh $make_cmd, *$make_flags
        sh $make_cmd, 'install'
    end
end

def cmake_dep (sym, deps = [], extra_defs = {}, extra_args = [])
    custom_dep sym, deps do | name, cfg | cmake_build name, cfg, extra_defs, extra_args end
end

#===============================================================================
# ManSDK Deps

cmake_dep :zlib, [], {
    'BUILD_SHARED_LIBS' => [ BOOL, (not STATIC_LIBRARIES) ],
 }.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
} if not LINUX

cmake_dep :portaudio, [], {
    'PA_DLL_LINK_WITH_STATIC_RUNTIME' => [ BOOL, OFF ],
}

cmake_dep :stk if not LINUX

cmake_dep :vectorial

cmake_dep :jpeg

cmake_dep :cryptopp

cmake_dep :png, WINDOWS ? [ :zlib ] : [], {
    'PNG_NO_CONSOLE_IO'   => [ BOOL, OFF ],
    'PNG_NO_STDIO'        => [ BOOL, OFF ],
    'NO_VERSION_SUFFIXES' => [ BOOL, ON ],
}

cmake_dep :opengm, [ :boost ], {
    'BOOST_ROOT'      => [ PATH, DEP_STAGE_DIR ],
    'WITH_BOOST'      => [ BOOL, ON ],
    'BUILD_EXAMPLES'  => [ BOOL, OFF ],
    'BUILD_TESTING'   => [ BOOL, OFF ],
}

cmake_dep :quazip, [ :qt ] + (LINUX ? [] : [:zlib ])

cmake_dep :g2o, [ :eigen ] if not WINDOWS

cmake_dep :usb

cmake_dep :openni, [ :jpeg, :usb, ], {
    'OPENNI_BUILD_SAMPLES' => [ BOOL, ON ],
} if not WINDOWS

cmake_dep :primesensor,   [ :openni ] if not WINDOWS

cmake_dep :sensorkinect,  [ :openni ] if not WINDOWS

cmake_dep :nite,          [ :openni ] if not WINDOWS

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

cmake_dep :qhull, [], {}.tap { | flags |
    flags[ 'CMAKE_C_FLAGS'   ] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
    flags[ 'CMAKE_CXX_FLAGS' ] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
}

custom_dep :boost do | name, cfg |

    dirs = dep_dirs name, cfg

    if UNIX then
        bootstrap = './bootstrap.sh'
        b2 = './b2'
    else
        bootstrap = 'bootstrap.bat'
        b2 = 'b2.exe'
    end

    def boost_build_variant (cfg)
        return {
            CFG_D  => 'debug',
            CFG_R  => 'release',
            CFG_RD => 'release',
            CFG_M  => 'release',
        } [cfg]
    end

    cd dirs[:source] do
        sh bootstrap
        ENV['NO_COMPRESSION'] = '1'

        # FIXME: b2 --dll-path=#{ rpath() } does not seem to work.

        b2_args = [
            "--prefix=#{    native_path dirs[:stage] }",
            "--build-dir=#{ native_path dirs[:build] }",
            '--without-python',
            'address-model=64', # FIXME: Address model should not be hard-coded.
            'threading=multi',
            "variant=#{ boost_build_variant(cfg) }",
        ]
        b2_args << 'link=static' if STATIC_LIBRARIES
        b2_args << 'cxxflags=-fPIC' if LINUX and ARCH_64
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
                "#{ MACOSX_RPATH     }/libboost_#{ lib }.dylib",
                "#{ dirs[:stage] }/lib/libboost_#{ lib }.dylib"
            boost_libs.each do | lib_ |
                sh 'install_name_tool', '-change',
                                          "libboost_#{ lib }.dylib",
                    "#{ MACOSX_RPATH     }/libboost_#{ lib }.dylib",
                    "#{ dirs[:stage] }/lib/libboost_#{ lib_ }.dylib"
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

cmake_dep :pcl, [ :boost, :eigen, :flann, :qhull, :qt, :vtk ] + (WINDOWS ? [ :png ] : [ :openni ]), {
    'BUILD_apps'                  => [ BOOL, OFF ],
    'BUILD_simulation'            => [ BOOL, OFF ],
    'BUILD_outofcore'             => [ BOOL, OFF ],
    'BUILD_gpu_kinfu'             => [ BOOL, ON  ],
    'BUILD_gpu_kinfu_large_scale' => [ BOOL, OFF ],
    'BUILD_GPU'                   => [ BOOL, ON  ],
    'BUILD_CUDA'                  => [ BOOL, ON  ],
    'BUILD_cuda_features'         => [ BOOL, OFF ],
    'BUILD_cuda_io'               => [ BOOL, OFF ], # Broken on Windows with PCL trunk.
    'BUILD_cuda_sample_consensus' => [ BOOL, OFF ],
    'BUILD_cuda_segmentation'     => [ BOOL, OFF ],
    'BUILD_gpu_features'          => [ BOOL, OFF ],
    'BUILD_gpu_octree'            => [ BOOL, ON ],
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
    'BUILD_visualization'         => [ BOOL, ON  ], # kinfu
    'BUILD_TESTS'                 => [ BOOL, OFF ],
    'BUILD_OPENNI'                => [ BOOL, OFF ],
    'BOOST_ROOT'                  => [ PATH, DEP_STAGE_DIR ],
    'Boost_NO_SYSTEM_PATHS'       => [ BOOL, ON  ],
    'FLANN_ROOT'                  => [ PATH, DEP_STAGE_DIR ],
    'PCL_SHARED_LIBS'             => [ BOOL, (not STATIC_LIBRARIES) ],
    'PCL_ONLY_CORE_POINT_TYPES'   => [ BOOL, ON  ],
}.tap { | flags |
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and ARCH_64
}

#, [ '--trace' ]

cmake_dep :opencv, [] + (WINDOWS ? [ :png ] : []), {
    'CMAKE_BUILD_TYPE'               => [ STRING, "Release" ], # relwithdeinfo is not supported
    'BUILD_SHARED_LIBS'              => [ BOOL  , (not STATIC_LIBRARIES) ],
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

custom_dep :openssl do | name, cfg |

    dirs = dep_dirs name, cfg

    # Remove this if you find out how to perform out-of-source openssl builds.
    mirror_dirs dirs[:source], dirs[:build]

    if WINDOWS then
        cd dirs[:build] do
            if ARCH_32 then
                sh 'perl', "./Configure", 'VC-WINDOWS', 'no-asm', "--prefix=#{ dirs[:stage] }"
                sh "ms/do_ms"
            elsif ARCH_64 then
                sh 'perl', "./Configure", 'VC-WIN64A', 'no-asm', "--prefix=#{ dirs[:stage] }"
                sh "ms/do_win64a"
            end
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

# FIXME: Properly dispatch on actual config.
custom_dep :qt, [ :openssl ] do | name, cfg |

    dirs = dep_dirs name, cfg

    def qt_config (cfg)
        return {
            CFG_D  => 'debug',
            CFG_R  => 'release',
            CFG_RD => 'release',
            CFG_M  => 'release',
        } [cfg]
    end

    # FIXME: Ugly hack to avoid building qt every time.
    if File.exists? "#{ dirs[:build] }/.qmake.cache" then
        next
    end

    if WINDOWS then
        cd dirs[:build] do
            # FIXME: Do 32/64 bit dispatch.
            # FIXME: Properly install products in stage.
            sh "#{ dirs[:source] }/build-qt-windows-msvc10.cmd", 'amd64', (qt_config cfg), dirs[:stage]
            cp_r "#{ dirs[:build] }/bin/qmake.exe", "#{ dirs[:stage] }/bin/qmake.exe"
        end
    elsif UNIX then
        cd dirs[:build] do
            # FIXME: Do 32/64 bit dispatch.
            sh "#{ dirs[:source] }/build-qt-unix-make.sh", 'amd64', (qt_config cfg), dirs[:stage]
        end
    end
end

# FIXME: Properly dispatch on actual config.
# FIXME: Ruby does not compile on 64 bit target architectures.

custom_dep :ruby do | name, cfg |

    dirs = dep_dirs name, cfg

    add_env_path source_dir + '/win32/bin'

    if WINDOWS then
        cd dirs[:build] do
            sh "#{ dirs[:source] }/win32/configure.bat"
            edit_file("#{ dirs[:build] }/Makefile", /^RT = msvcr\d+/, 'RT = msvcrt')
            sh 'nmake'
            sh 'nmake', "DESTDIR=#{ dirs[:stage] }", 'install', 'install-lib'
        end
    else
        cd dirs[:source] do
             sh 'autoconf'
        end
        cd dirs[:build] do
             sh "#{ dirs[:source] }/configure", "--prefix=#{ dirs[:stage] }"
             sh 'make'
             sh 'make', 'install', 'install-lib'
        end
    end
end if ARCH_32

custom_dep :qt3d, [ :qt ] do | name, cfg |

    dirs = dep_dirs name, cfg

    if WINDOWS then
        # FIXME: Have qt properly stage itself on windows.
        qmake_path  = "#{ dep_build_dir('qt', cfg) }/bin/qmake.exe"
    else
        qmake_path  = "#{ dirs[:stage] }/bin/qmake"
    end

    project_path = "#{ dirs[:source] }/qt3d.pro"

    cd dirs[:build] do
        # FIXME: Honor build configuration.
        sh qmake_path, '-d', "PREFIX=#{ dirs[:stage] }", project_path
        sh $make_cmd, *$make_flags
        sh $make_cmd, "INSTALL_ROOT=#{ dirs[:stage] }", 'install'
    end
end if not WINDOWS # Fails at install on Windows.
