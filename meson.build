project('song', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.62.0',
  default_options: [ 'warning_level=2', 'werror=false', 'buildtype=debugoptimized',
                             'c_std=c17',
                             'adwaita:examples=false',
                             'adwaita:introspection=disabled',
                             'adwaita:tests=false',
                             'adwaita:vapi=false',
                             'gtk:build-examples=false',
                             'gtk:build-tests=false',
                             'gtk:build-testsuite=false',
                             'gtk:build-demos=false',
                             'gtk:introspection=disabled',
                             'libsass:werror=false',
                             'vte:c_std=gnu11',
                             'vte:cpp_std=gnu++17',
                             'vte:gir=false',
                             'vte:gtk3=false',
                             'vte:gtk4=true',
                             'vte:vapi=false',
                             'vte:werror=false',
],
)

i18n = import('i18n')
gnome = import('gnome')



subdir('data')
subdir('src')
subdir('po')

gnome.post_install(
     glib_compile_schemas: true,
    gtk_update_icon_cache: true,
  update_desktop_database: true,
)
