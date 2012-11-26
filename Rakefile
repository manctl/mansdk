SDK_NAME    = 'ManSDK'
SDK_MAJOR   = 0
SDK_MINOR   = 1
SDK_VERSION = "#{ SDK_MAJOR }.#{ SDK_MINOR   }"
SDK_TITLE   = "#{ SDK_NAME  } #{ SDK_VERSION }"

#-------------------------------------------------------------------------------

require 'digest/sha1'
require 'rubygems'
require 'git'

#-------------------------------------------------------------------------------
# Library

HERE = File.dirname File.expand_path __FILE__

UNKNOWN_SYSTEM = "Unknown System"

def read_file (path)
    return '' unless File.exists? path
    return File.read path
end

def read_file_in (dir, name)
    return read_file File.join(dir, name)
end

def write_file (path, contents)
    file = File.new(path, "w")
    file << contents
    file.close
end

def write_file_in (dir, name, contents)
    write_file File.join(dir, name), contents
end

def edit_file (path, pattern, replacement)
    text = File.read(path).gsub(pattern, replacement)
    File.open(path, "w") { | file | file << text }
end

def files_exist_in (dir, *names)
    names.each { | name | if not File.exists? File.join(dir, name) then return false end }
    return true
end

def add_env_path (path) ENV['PATH'] += File::PATH_SEPARATOR + native_path(path) end

def native_path (path)
    case RUBY_PLATFORM
        when /linux|darwin/  then return path
        when /win32|mingw32/ then return path.gsub('/', '\\')
        else raise UNKNOWN_SYSTEM
    end
end

case RUBY_PLATFORM
    when /linux|darwin/  then EXE_SUFFIX = ''
    when /win32|mingw32/ then EXE_SUFFIX = '.exe'
    else raise UNKNOWN_SYSTEM
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

PARALLEL_BUILDS  = true
PARALLEL_TASKS   = true

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

PLATFORM_CPP = <<EOF
#include <iostream>
#include <string>

namespace {

//------------------------------------------------------------------------------
// SYS

// See: http://poshlib.hookatooka.com/poshlib/trac.cgi.
const char sys [] =
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


//------------------------------------------------------------------------------
// CPU

// See http://predef.sourceforge.net/prearch.html.
const char cpu [] =
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

//------------------------------------------------------------------------------
// CORES

// See: http://stackoverflow.com/questions/150355/programmatically-find-the-number-of-cores-on-a-machine
#if _WIN32
#   define WIN32_LEAN_AND_MEAN
#   define WIN32_EXTRA_LEAN
#   include <windows.h>
int
cores ()
{
    SYSTEM_INFO info;
    GetSystemInfo(&info);
    return info.dwNumberOfProcessors;
}
#else
#include <unistd.h>
int
cores ()
{
    return sysconf( _SC_NPROCESSORS_ONLN );
}
#endif

//------------------------------------------------------------------------------

void
usage (int argc, char* argv[], int ret)
{
    std::cout << argv[0] << "(sys|cpu|cores)" << std::endl;
}

}

int
main (int argc, char* argv[])
{
    if (argc < 1)
        usage(argc, argv, 1);

    const std::string arg = argv[1];

    if      (arg == "cpu"  ) std::cout << cpu     << std::endl;
    else if (arg == "sys"  ) std::cout << sys     << std::endl;
    else if (arg == "cores") std::cout << cores() << std::endl;
    else
        usage(argc, argv, 2);
}
EOF

PLATFORM_CPP_HASH = Digest::SHA1.hexdigest PLATFORM_CPP

SYS_WINDOWS = 'windows'
SYS_LINUX   = 'linux'
SYS_MACOSX  = 'macosx'

CPU_X86   = 'x86'
CPU_AMD64 = 'amd64'
CPU_PPC   = 'ppc'

PLATFORM_CMAKELISTS_TXT = <<EOF
cmake_minimum_required(VERSION 2.8)
project(platform)
add_executable( platform platform.cpp)
install(TARGETS platform DESTINATION bin)
EOF

#===============================================================================
# Bootstrap

begin
    case RUBY_PLATFORM
        when /linux|darwin/  then
            cmake_gen  = 'Unix Makefiles'
            make_cmd   = 'make'
        when /win32|mingw32/ then
            cmake_gen  = 'NMake Makefiles'
            make_cmd   = 'nmake'
        else
            raise UNKOWN_SYSTEM
    end

    source_dir = make_build_subdir 'platform'
    build_dir  = make_build_subdir 'platform/build'
    stage_dir  = make_stage_subdir 'platform'
    bin_dir    = make_stage_subdir 'platform/bin/'
    share_dir  = make_stage_subdir 'platform/share/'

    PLATFORM_CPP_HASH_FILE = 'platform.cpp.hash'

    cpp_hash = read_file_in(share_dir, PLATFORM_CPP_HASH_FILE)

    unless cpp_hash == PLATFORM_CPP_HASH

        write_file_in share_dir , PLATFORM_CPP_HASH_FILE, PLATFORM_CPP_HASH
        write_file_in source_dir, 'platform.cpp', PLATFORM_CPP
        write_file_in source_dir, 'CMakeLists.txt',   PLATFORM_CMAKELISTS_TXT

        cd build_dir do
            sh 'cmake',
                "-G#{cmake_gen}",
                "-DCMAKE_BUILD_TYPE:STRING=Release",
                "-DCMAKE_INSTALL_PREFIX:PATH=#{ stage_dir }",
                source_dir
            sh make_cmd
            sh make_cmd, 'install'
        end
    end

    PLATFORM_BIN = File.join bin_dir, 'platform'
    def platform_val (arg) return `#{ PLATFORM_BIN } #{ arg }`.strip end

    SYS   = platform_val 'sys'
    CPU   = platform_val 'cpu'
    CORES = platform_val 'cores'
end

#-------------------------------------------------------------------------------

# Post-Bootstrap

begin
    case SYS
        when /#{SYS_MACOSX}|#{SYS_LINUX}/ then
            $cmake_gen  = 'Unix Makefiles'
            $make_cmd   = 'make'
            $make_flags = PARALLEL_BUILDS ? [ '-j' + CORES.to_s ] : [] + MAKE_FLAGS
        when SYS_WINDOWS then
            $cmake_gen  = 'NMake Makefiles' # NMake Makefiles JOM makes it incompatible with QtCreator
            $jom_dir    =  File.join HERE, 'core', 'deps', 'jom'
            add_env_path $jom_dir
            $make_cmd   = PARALLEL_BUILDS ? 'jom' : 'nmake'
            $make_flags = [] + MAKE_FLAGS
        else
            raise UNKOWN_SYSTEM
    end
end

#-------------------------------------------------------------------------------

# Platform-specific Keywords

WINDOWS = SYS == SYS_WINDOWS
MACOSX  = SYS == SYS_MACOSX
LINUX   = SYS == SYS_LINUX
UNIX    = LINUX || MACOSX
AMD64   = CPU == CPU_AMD64
X86     = CPU == CPU_X86
CPU_64  = AMD64
CPU_32  = X86

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

def parallel_task (hsh, &blk) return PARALLEL_TASKS ? multitask(hsh, &blk) : task(hsh, &blk) end

multitask :default => :all

multitask :all => cfg_sym(:all, CFG)

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

    #{ SYS }-#{ CPU }

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

#{
        lines = []
        w = 0
        $deps.each do | dep | w = w < dep.length ? dep.length : w end

        count = 0
        $deps.each do | dep |
            g = Git.open(File.join(HERE, 'deps', dep))
            head = g.object('HEAD').sha
            align = w - dep.length
        if count == 0 then
            lines << "    #{ ' ' * w             }   #{ ' ' * 7    }" # FIXME: D   R   RD  M"
        end
            lines << "    #{ ' ' * align }#{ dep } @ #{ head[0..6] }" # FIXME: *   OK  OK  ."
            count += 1
        end
        lines.sort.join "\n"
}
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

        # Hooks
        task cfg_sym(:all, cfg) => cfg_sym(name, cfg)
        task cfg_sym(:clear, cfg) => cfg_sym(clear, cfg)

        multitask cfg_sym(name, cfg, '-deps') => dep_deps(deps, cfg)

        task cfg_sym(only, cfg) do | task, args | blk.call(name, cfg) end

        task cfg_sym(name, cfg) => [ cfg_sym(name, cfg, '-deps'), cfg_sym(only, cfg) ]

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
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and CPU_64
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
    flags[ 'CMAKE_C_FLAGS'   ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
    flags[ 'CMAKE_CXX_FLAGS' ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
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

    boost_build_variants = {
        CFG_D  => 'debug',
        CFG_R  => 'release',
        CFG_RD => 'release',
        CFG_M  => 'release',
    }

    boost_address_models = {
        CPU_X86   => 'address-model=32',
        CPU_AMD64 => 'address-model=64',
    }

    cd dirs[:source] do
        sh bootstrap
        ENV['NO_COMPRESSION'] = '1'
        # FIXME: b2 --dll-path=#{ rpath() } does not seem to work.
        b2_args = [
            "--prefix=#{    native_path dirs[:stage] }",
            "--build-dir=#{ native_path dirs[:build] }",
            '--without-python',
            boost_address_models[CPU],
            'threading=multi',
            "variant=#{ boost_build_variants[cfg] }",
        ]
        b2_args << 'link=static' if STATIC_LIBRARIES
        b2_args << 'cxxflags=-fPIC' if LINUX and CPU_64
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
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and CPU_64
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
    'BUILD_gpu_octree'            => [ BOOL, ON  ],
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
    flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
    flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and CPU_64
}

#, [ '--trace' ]

custom_dep :opencv, [] + (WINDOWS ? [ :png ] : []) do | name, cfg |
    # Release and debug are the only supported opencv builds.
    opencv_cfgs = {
        CFG_D  => CFG_D,
        CFG_RD => CFG_R,
        CFG_R  => CFG_R,
        CFG_M  => CFG_R,
    }

    cmake_build name, opencv_cfgs[cfg], {
        'BUILD_SHARED_LIBS'              => [ BOOL  , (not STATIC_LIBRARIES) ],
        'BUILD_WITH_STATIC_CRT'          => [ BOOL  , OFF ],
        'BUILD_TIFF'                     => [ BOOL  , ON  ],
        'BUILD_TESTS'                    => [ BOOL  , OFF ],
        'WITH_CUDA'                      => [ BOOL  , OFF ],
        'WITH_FFMPEG'                    => [ BOOL  , OFF ],
        'WITH_EIGEN'                     => [ BOOL  , OFF ],
        'CMAKE_LINK_INTERFACE_LIBRARIES' => [ STRING, "" ],
    }.tap { | flags |
        flags['CMAKE_C_FLAGS'  ] = [ STRING, '-fPIC' ] if LINUX and CPU_64
        flags['CMAKE_CXX_FLAGS'] = [ STRING, '-fPIC' ] if LINUX and CPU_64
    }
end

custom_dep :openssl do | name, cfg |

    dirs = dep_dirs name, cfg

    # Remove this if you find out how to perform out-of-source openssl builds.
    mirror_dirs dirs[:source], dirs[:build]

    if WINDOWS then

        configure_cpus = {
            CPU_X86   => 'VC-WIN32',
            CPU_AMD64 => 'VC-WIN64A',
        }

        configure_post_cmds = {
            CPU_X86   => "ms/do_ms",
            CPU_AMD64 => "ms/do_win64a",
        }

        cd dirs[:build] do
            sh 'perl', "./Configure", configure_cpus[CPU], 'no-asm', "--prefix=#{ dirs[:stage] }"
            sh configure_post_cmds[CPU]
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

custom_dep :qt, [ :openssl ] do | name, cfg |

    dirs = dep_dirs name, cfg

    qt_cpus = {
        CPU_X86   => 'x86',
        CPU_AMD64 => 'amd64',
    }

    qt_cfgs = {
        CFG_D  => 'debug',
        CFG_R  => 'release',
        CFG_RD => 'release',
        CFG_M  => 'release',
    }

    # FIXME: Ugly hack to avoid building qt every time.
    if File.exists? File.join(dirs[:build], '.qmake.cache') then
        next
    end

    if WINDOWS then
        cd dirs[:build] do
            sh File.join(dirs[:source], 'build-qt-windows-msvc10.cmd'), qt_cpus[CPU], qt_cfgs[cfg], dirs[:stage], $make_cmd

            # FIXME: Properly install ALL products in stage.
            cp_r File.join(dirs[:build], 'bin', 'qmake.exe'), File.join(dirs[:stage], 'bin', 'qmake.exe')
        end
    elsif UNIX then
        cd dirs[:build] do
            sh File.join(dirs[:source], 'build-qt-unix-make.sh'), qt_cpus[CPU], qt_cfgs[cfg], dirs[:stage], $make_cmd, *$make_flags
        end
    end
end

# FIXME: Properly dispatch on actual config.
# FIXME: Ruby does not compile on 64 bit target architectures.

custom_dep :ruby do | name, cfg |

    dirs = dep_dirs name, cfg

    add_env_path File.join dirs[:source] , 'win32', 'bin'

    if WINDOWS then
        cd dirs[:build] do
            sh File.join(dirs[:source], 'win32', 'configure.bat')
            edit_file(File.join(dirs[:build], 'Makefile'), /^RT = msvcr\d+/, 'RT = msvcrt')
            sh 'nmake'
            sh 'nmake', "DESTDIR=#{ dirs[:stage] }", 'install', 'install-lib'
        end
    else
        cd dirs[:source] do
             sh 'autoconf'
        end
        cd dirs[:build] do
             sh File.join(dirs[:source], 'configure'), "--prefix=#{ dirs[:stage] }"
             sh 'make'
             sh 'make', 'install', 'install-lib'
        end
    end
end if CPU_32

custom_dep :qt3d, [ :qt ] do | name, cfg |

    dirs = dep_dirs name, cfg

    if WINDOWS then
        # FIXME: Have qt properly stage itself on windows.
        qmake_path  = File.join dep_build_dir('qt', cfg), 'bin', 'qmake.exe'
    else
        qmake_path  = File.join dirs[:stage], 'bin', 'qmake'
    end

    project_path = File.join dirs[:source], 'qt3d.pro'

    cd dirs[:build] do
        # FIXME: Honor build configuration.
        sh qmake_path, '-d', "PREFIX=#{ dirs[:stage] }", project_path
        sh $make_cmd, *$make_flags
        sh $make_cmd, "INSTALL_ROOT=#{ dirs[:stage] }", 'install'
    end
end if not WINDOWS # Fails at install on Windows.
