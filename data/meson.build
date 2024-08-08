desktop_file = i18n.merge_file(
        input: 'com.liyaowhen.YoutubeCollector.desktop.in',
       output: 'com.liyaowhen.YoutubeCollector.desktop',
         type: 'desktop',
       po_dir: '../po',
      install: true,
  install_dir: get_option('datadir') / 'applications'
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif

schemas_dir = get_option('prefix') / get_option('datadir') / 'glib-2.0' / 'schemas'
settings_schemas = [ 'com.liyaowhen.YoutubeCollector.gschema.xml', 'com.liyaowhen.YoutubeCollector.playlists.gschema.xml' ]

install_data(settings_schemas, install_dir: schemas_dir)

# Compile the schemas in the current directory; this is only
# useful for testing
gnome = import('gnome')
gnome.compile_schemas(depend_files: files(settings_schemas))

appstream_file = i18n.merge_file(
        input: 'com.liyaowhen.YoutubeCollector.metainfo.xml.in',
       output: 'com.liyaowhen.YoutubeCollector.metainfo.xml',
       po_dir: '../po',
      install: true,
  install_dir: get_option('datadir') / 'metainfo'
)

appstreamcli = find_program('appstreamcli', required: false, disabler: true)
test('Validate appstream file', appstreamcli,
     args: ['validate', '--no-net', '--explain', appstream_file])

install_data('com.liyaowhen.YoutubeCollector.gschema.xml',
  install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

compile_schemas = find_program('glib-compile-schemas', required: false, disabler: true)
test('Validate schema file',
     compile_schemas,
     args: ['--strict', '--dry-run', meson.current_source_dir()])

subdir('icons')
