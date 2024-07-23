namespace Song {

    public class SideBar : Adw.NavigationPage {

        private Settings settings = new Settings("com.liyaowhen.Song");
        private Window window;

        public SideBarContent side_bar_content;
        public SideBarControls side_bar_controls;



        public SideBar(Window _window) {
            this.window = _window;
        }

        construct {

            var toolbar_view = new Adw.ToolbarView();

            var scroll_box = new Gtk.ScrolledWindow();
            side_bar_content = new SideBarContent ();
            side_bar_content.set_vexpand (true);
            side_bar_content.set_hexpand (true);
            scroll_box.child = side_bar_content;

            side_bar_controls = new SideBarControls (side_bar_content);
            side_bar_controls.set_hexpand (true);

            toolbar_view.set_content(scroll_box);
            toolbar_view.add_bottom_bar(side_bar_controls);

            title = "Songs:";
            this.child = toolbar_view;
        }
    }

    public class SideBarContent : Gtk.Box {

        private Settings settings = new Settings("com.liyaowhen.Song.playlists");
        public Gee.HashSet<PlaylistButton> playlist_buttons = new Gee.HashSet<PlaylistButton>();
        private MainView main_view;

        public SideBarContent() {
        }

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            valign = Gtk.Align.START;

            
            spacing = 5;
            margin_bottom = 5;
            margin_top = 5;
            margin_start = 5;
            margin_end = 5;

            vexpand = true;
            hexpand = true;
            vexpand_set = true;
            hexpand_set = true;

            PlaylistObject initial_playlist;

            /*var playlist_names = settings.get_strv("playlists");
            foreach (string _name in playlist_names) {
                var playlist = new PlaylistButton(_name);
                if (_name == playlist_names[0]) {
                    initial_playlist = playlist;
                }
                playlists.append(playlist);
                append(playlist);
            }*/

            Config config = Config.get_instance();
            
            bool firstDeclared = false;
            config.playlists.foreach((_playlist) => {
                var button = new PlaylistButton(_playlist);
                if (!firstDeclared) {initial_playlist = _playlist; firstDeclared = true;}

                playlist_buttons.add(button);
                append(button);
            });

            config.config_changed.connect(() => {
                playlist_buttons.clear();
                config.playlists.foreach((_playlist) => {
                    var button = new PlaylistButton(_playlist);
    
                    playlist_buttons.add(button);
                    append(button);
                });
            });

            Timeout.add(1000, () => {
                if (playlist_buttons == null) {
                    print("\n playlist buttons empty");
                } else {
                    print("\n playlist not empty");
                }

            });

            //print("sidbar requesting main_view_content switch to playlist of name:\n" + playlists.nth_data(0).name);
            Timeout.add(1, () => {
                if (SongController.main_view_content != null) {
                    SongController.main_view_content.change_page(initial_playlist);
                    return false;

                }
                return true;
            }, 1);
            SongController.sidebar_content = this;
            
            //reconfigure_playlist_button_group(); DOES NOT WORK FOR SOME REASON

        }

        
    }

    public class SideBarControls : Gtk.Box {

        private SideBarContent sidebar_content;
        private Gtk.ActionBar action_bar;


        public SideBarControls(SideBarContent _sidebar_content) {
            this.sidebar_content = _sidebar_content;
            
        }

        construct {
            action_bar = new Gtk.ActionBar();
            action_bar.vexpand = true;
            action_bar.hexpand = true;
            append(action_bar);

            this.orientation = Gtk.Orientation.HORIZONTAL;
            this.add_css_class ("toolbar");

            // make ui
                var select_button = new Gtk.ToggleButton();
                select_button.set_icon_name ("checkbox-symbolic");
                    var delete_button = new Gtk.Button();
                    delete_button.set_icon_name ("user-trash-symbolic");
                    var export_button = new Gtk.Button();
                    export_button.set_icon_name("document-save-symbolic");

                var options_button = new Gtk.Button(); // TODO: change to Gtk.MenuButton
                options_button.set_icon_name("open-menu-symbolic");
                options_button.sensitive = true;

                action_bar.pack_start(select_button);
                //action_bar.set_center_widget(empty_spacer());
                action_bar.pack_end(options_button);

                select_button.toggled.connect((i) => {
                    if (sidebar_content == null) {
                        print("\n sidebar is null");
                    } else if (sidebar_content.playlist_buttons == null) {
                        print("\n sidebar buttons are null");
                    }
                    if (i.get_active()) {
                        sidebar_content.playlist_buttons.foreach((e) => {
                            e.enter_removal_mode();
                            print(e.name);
                        });
                    } else {
                        sidebar_content.playlist_buttons.foreach((e) => {
                            e.exit_removal_mode();
                            print(e.name);
                        });
                    }
                });
                

            // signals

        }

        private Gtk.Separator empty_spacer() {
            var empty_spacer = new Gtk.Separator(Gtk.Orientation.VERTICAL);
            empty_spacer.hexpand = true;
            empty_spacer.add_css_class("spacer");
            return empty_spacer;
        }

    }

}