cmake_dep :png, WINDOWS ? [ :zlib ] : [], {
    'PNG_NO_CONSOLE_IO'   => [ BOOL, OFF ],
    'PNG_NO_STDIO'        => [ BOOL, OFF ],
    'NO_VERSION_SUFFIXES' => [ BOOL, ON ],
    'NO_DEBUG_SUFFIXES'   => [ BOOL, ON ],
}
