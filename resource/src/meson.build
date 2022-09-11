
shower_sources = [
  'sushi-font-loader.h',
  'sushi-font-loader.c',
  'font-model.h',
  'font-model.c',
  'sushi-font-widget.h',
  'sushi-font-widget.c',
  'shower.c'
]

executable('showmytext', shower_sources,
  include_directories: [ root_inc, include_directories('.') ],
  dependencies: [ mathlib_dep, glib_dep, gtk_dep, libhandy_dep, harfbuzz_dep, fontconfig_dep, freetype2_dep ],
  install: true)

