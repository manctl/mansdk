# For now, use Qt5 by default on Mac OS X 10.8 and Qt4 anywhere else.
QT5 = ENV['QT5'] ? cmd_bool(ENV['QT5']) : MACOSX_MOUNTAIN_LION

Dir.glob('./deps/*.rb').each { | dep | require dep }

DEPS_VARIABLES = <<EOF
    QT5          = #{ on_off QT5 }
EOF
