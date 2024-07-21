song_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'music/new_music_popover.vala',
  'widgets/side_bar.vala',
  'json_config.vala',
  'widgets/main_view.vala',
  'widgets/playlist.vala',
  'controllers/song_controller.vala',
  'widgets/music_list_row.vala',
  'widgets/song_controls.vala',
  'playlist_object.vala'
]

song_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
  dependency('vte-2.91-gtk4'),
  dependency('json-glib-1.0'),
  dependency('gstreamer-1.0'),
]

song_sources += gnome.compile_resources('song-resources',
  'song.gresource.xml',
  c_name: 'song'
)


executable('song', song_sources,
  dependencies: song_deps,
       install: true,
)
