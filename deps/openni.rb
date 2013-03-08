cmake_dep :openni, [ :jpeg, :usb, ], {
    'OPENNI_BUILD_SAMPLES' => [ BOOL, ON ],
} if not WINDOWS
