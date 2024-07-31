namespace Song {

    public class SideBar : Adw.NavigationPage {

        private Settings settings = new Settings("com.liyaowhen.Song");
        private Window window;

        public SideBarContent side_bar_content;
        public SideBarControls side_bar_controls;

        public signal void collapsing();
        // unify the signals for sidebar and maincontent collapsing in a singleton song controller


        public SideBar(Window _window) {
            this.window = _window;
        }

        construct {
            SongController.side_bar = this;

            var toolbar_view = new Adw.ToolbarView();

            var collapse_button = new Gtk.Button.from_icon_name ("folder-open-symbolic");
            collapse_button.clicked.connect(() => {
                if(SongController.split_view.get_show_sidebar()){
                    SongController.split_view.show_sidebar = false;
                    collapse_button.set_icon_name("folder-open-symbolic");
                } else {
                    SongController.split_view.show_sidebar = true;
                    collapse_button.set_icon_name("folder-symbolic");
                }        
                collapsing();
            });    

            var add_button = new Gtk.Button.from_icon_name("bookmark-new-symbolic");

            add_button.clicked.connect(() => {
                var popover = new NewPlaylistPopover();
                popover.present(this);
            });

            var header_bar = new Adw.HeaderBar();
            header_bar.margin_top = 5;
            header_bar.margin_start = 5;
            header_bar.show_title = false;
            header_bar.show_start_title_buttons = false;
            header_bar.show_end_title_buttons = false;
            header_bar.pack_start(collapse_button);
            header_bar.pack_start(add_button);

            var scroll_box = new Gtk.ScrolledWindow();
            scroll_box.hscrollbar_policy = Gtk.PolicyType.NEVER;
            side_bar_content = new SideBarContent ();
            side_bar_content.set_vexpand (true);
            side_bar_content.set_hexpand (true);
            scroll_box.child = side_bar_content;

            side_bar_controls = new SideBarControls (side_bar_content);
            side_bar_controls.set_hexpand (true);

            toolbar_view.add_top_bar(header_bar);
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

            PlaylistObject? initial_playlist = null;

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
            if (config.playlists != null) {
                foreach (PlaylistObject _playlist in config.playlists) {
                    var button = new PlaylistButton(_playlist);
                    if (!firstDeclared) {initial_playlist = _playlist; firstDeclared = true;}
    
                    playlist_buttons.add(button);
                    append(button);
                }
            }


            print("\n aaaaaa" + playlist_buttons.size.to_string() + "\n");

            config.config_changed.connect(() => {
                foreach (PlaylistButton e in playlist_buttons) {
                    print("\n" + e.playlist.name + "eee");
                    e.destroy();
                }
                if (config.playlists != null) {
                    config.playlists.foreach((_playlist) => {
                        var button = new PlaylistButton(_playlist);
        
                        playlist_buttons.add(button);
                        append(button);
                    }); 
                }
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
                    if (initial_playlist != null) {
                        SongController.main_view_content.change_page(initial_playlist);
                        return false;
                    }
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
                        foreach (PlaylistButton e in sidebar_content.playlist_buttons) {
                            e.enter_removal_mode();
                            print(e.playlist.name);
                        }
                    } else {
                        foreach (PlaylistButton e in sidebar_content.playlist_buttons) {
                            e.exit_removal_mode();
                            print(e.playlist.name);
                        }
                    }
                    print("\n" + sidebar_content.playlist_buttons.size.to_string() + "\n");
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