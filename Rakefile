SDK_NAME    = 'ManSDK'
SDK_MAJOR   = 0
SDK_MINOR   = 1
SDK_VERSION = "#{ SDK_MAJOR }.#{ SDK_MINOR   }"
SDK_TITLE   = "#{ SDK_NAME  } #{ SDK_VERSION }"

#-------------------------------------------------------------------------------

require 'digest/sha1'
#require 'rubygems'
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
    File.open(path, "w") { | file | file << contents }
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

def mkdir_p_cd (path, &blk)
    mkdir_p path
    cd path, &blk
end

def cmd_bool (str)
    return str.upcase != 'OFF' && str.upcase != 'FALSE' && str != '0'
end

def on_off (bool)
    return bool ? 'ON' : 'OFF'
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
PARALLEL_TASKS   = false # FIXME: Make this work, eventually.

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

//------------------------------------------------------------------------------
// SYS

// See: http://poshlib.hookatooka.com/poshlib/trac.cgi.
const char sys [] =
#if   defined(_WINDOWS) || defined(_WIN64) || defined(__WINDOWS__)
#   define SYS_WINDOWS
              "windows"
#elif defined(__linux__) || defined(__linux) || defined(linux)
#   define SYS_LINUX
              "linux"
#elif defined(__APPLE__) && defined(__MACH__)
#   define SYS_MACOSX
              "macosx"
#else
#   define SYS_UNKNOWN
              "unknown"
#endif
;

//------------------------------------------------------------------------------
// OS

#if defined(SYS_WINDOWS)
const char* os ()
{
    return ""; // FIXME: Implement.
}
#elif defined(SYS_LINUX)
const char* os ()
{
    return ""; // FIXME: Implement.
}
#elif defined(SYS_MACOSX)
#   include <errno.h>
#   include <sys/sysctl.h>
#   include <vector>
#   include <cstring>

const char* os ()
{
    size_t size = 0;
    int ret = sysctlbyname("kern.osrelease", NULL, &size, NULL, 0);
    if (0 != ret)
        return "error";

    std::vector<char> buf(size);
    ret = sysctlbyname("kern.osrelease", &buf[0], &size, NULL, 0);
    if (0 != ret)
        return "error";

    if      (0 == std::strncmp(&buf[0], "12.", 3))
        return "10.8";
    else if (0 == std::strncmp(&buf[0], "11.", 3))
        return "10.7";
    else if (0 == std::strncmp(&buf[0], "10.", 3))
        return "10.6";

    return "";
}
#else
const char* os ()
{
    return "";
}
#endif

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
    return sysconf(_SC_NPROCESSORS_ONLN);
}
#endif

//------------------------------------------------------------------------------

int
usage (int argc, char* argv[], int ret)
{
    std::cout << argv[0] << "(sys|os|cpu|cores)" << std::endl;
    return ret;
}

int
main (int argc, char* argv[])
{
    if (argc < 2)
        return usage(argc, argv, 1);

    const std::string arg = argv[1];

    if      (arg == "cpu"  ) std::cout << cpu     << std::endl;
    else if (arg == "sys"  ) std::cout << sys     << std::endl;
    else if (arg == "os"   ) std::cout << os()    << std::endl;
    else if (arg == "cores") std::cout << cores() << std::endl;
    else
        return usage(argc, argv, 2);
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
            raise UNKNOWN_SYSTEM
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
    OS    = platform_val 'os'
    CPU   = platform_val 'cpu'
    CORES = platform_val 'cores'
end

#-------------------------------------------------------------------------------

# Post-Bootstrap

begin
    $core_cmds_dir = File.join HERE, 'core', 'cmds'

    case SYS
        when /#{SYS_MACOSX}|#{SYS_LINUX}/ then
            $cmake_gen  = 'Unix Makefiles'
            $make_cmd   = 'make'
            $make_flags = (PARALLEL_BUILDS ? [ '-j' + CORES.to_s ] : []) + MAKE_FLAGS
        when SYS_WINDOWS then
            $cmake_gen  = 'NMake Makefiles' # NMake Makefiles JOM makes it incompatible with QtCreator
            $jom_dir    =  File.join HERE, 'core', 'deps', 'jom'
            add_env_path $jom_dir
            $make_cmd   = PARALLEL_BUILDS ? 'jom' : 'nmake'
            $make_flags = [] + MAKE_FLAGS
        else
            raise UNKNOWN_SYSTEM
    end
end

#-------------------------------------------------------------------------------

# Platform-specific Keywords

WINDOWS = SYS == SYS_WINDOWS

MACOSX = SYS == SYS_MACOSX
MACOSX_MOUNTAIN_LION = MACOSX and OS == '10.8'
MACOSX_LION          = MACOSX and OS == '10.7'
MACOSX_SNOW_LEOPARD  = MACOSX and OS == '10.6'

LINUX = SYS == SYS_LINUX

UNIX = LINUX || MACOSX

AMD64  = CPU == CPU_AMD64
X86    = CPU == CPU_X86
CPU_64 = AMD64
CPU_32 = X86

# Cross-platform Helpers

def rpath ()
    if    LINUX  then return  LINUX_RPATH
    elsif MACOSX then return MACOSX_RPATH
    end
    return ""
end

def cmd (name)
    return File.join $core_cmds_dir, name + (UNIX ? '.sh' : '.cmd')
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

    #{ SYS }-#{ CPU }

Variables:

    PREFIX       = #{ PREFIX }
    CFG / CONFIG = #{ CFG } / #{ CONFIG }
    MAKE_FLAGS   = #{ MAKE_FLAGS }
    VERBOSE      = #{ VERBOSE }
    BUILD        = #{ BUILD }
    OUTPUT       = #{ OUTPUT }
    STAGE        = #{ STAGE }

#{DEPS_VARIABLES}

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

        parallel_task cfg_sym(name, cfg, '-deps') => dep_deps(deps, cfg)

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

require './deps.rb'
