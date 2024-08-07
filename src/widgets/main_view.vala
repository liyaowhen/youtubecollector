namespace Song {
    public class MainView : Adw.NavigationPage {
        private Window window;

        public Settings settings = new Settings("com.liyaowhen.Song.playlists");
        public MainViewContent main_content;
        public PlaylistObject current_playlist;
        private Gtk.Revealer add_button_revealer = new Gtk.Revealer();
        private Gtk.Revealer controls_revealer = new Gtk.Revealer();
        private Gtk.Revealer exit_yt_search_mode_revealer = new Gtk.Revealer();
        private Adw.HeaderBar action_bar;

        

        public MainView(Window _window) {
            this.window = _window;
        }

        construct {
            SongController.main_view = this;

            // make ui
                var toolbar_view = new Adw.ToolbarView ();

                var scrollable = new Gtk.ScrolledWindow();
                main_content = new MainViewContent();
                scrollable.set_child(main_content);
                scrollable.hexpand = true;
                scrollable.hexpand_set = true;

                var collapse_button_revealer = new Gtk.Revealer();
                var collapse_button = new Gtk.Button.from_icon_name ("folder-symbolic");
                
                collapse_button.valign = Gtk.Align.CENTER;

                var add_button = new Gtk.Button();
                var add_button_content = new Adw.ButtonContent ();
                add_button_content.set_icon_name("applications-multimedia-symbolic");
                add_button_content.set_label("Add Item");
                add_button.set_child(add_button_content);
                add_button.valign = Gtk.Align.CENTER;
                add_button_revealer.set_child(add_button);
                add_button_revealer.set_reveal_child(true);
                add_button_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;

                add_button.clicked.connect(() => {
                    var popover = new NewMusicPopover();
                    popover.present(this);
                });

                var exit_yt_search_mode = new Gtk.Button.from_icon_name("go-previous-symbolic");
                exit_yt_search_mode.valign = Gtk.Align.CENTER;
                exit_yt_search_mode_revealer.set_child(exit_yt_search_mode);
                exit_yt_search_mode_revealer.set_reveal_child(false);
                exit_yt_search_mode_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;

                exit_yt_search_mode.clicked.connect(() => {
                    SignalHub.get_instance().exit_yt_search_mode();
                });

                action_bar = new Adw.HeaderBar();
                action_bar.show_back_button = false;
                action_bar.title_widget = new YtSearchBar();
                action_bar.pack_start(collapse_button);
                action_bar.pack_start(add_button_revealer);
                action_bar.pack_start(exit_yt_search_mode_revealer);
                action_bar.margin_start = 5;

                collapse_button.clicked.connect(() => {
                    if(SongController.split_view.get_collapsed ()){
                        SongController.split_view.show_sidebar = false;
                        collapse_button.visible = true;
                    } else {
                        SongController.split_view.show_sidebar = true;
                        collapse_button.visible = false;

                    }
                });

                Timeout.add(1, () => {
                    if (SongController.side_bar != null && SongController.split_view != null) {
                        if (SongController.split_view.get_show_sidebar()) {
                            collapse_button.visible = false;
                        } else collapse_button.visible = true;
                        SongController.side_bar.collapsing.connect(() => {
                            collapse_button.visible = true;

                        });
                        return false;
                    }
                    return true;
                });

                
                var controls = new SongControls();
                controls_revealer.set_child(controls);
                controls_revealer.set_reveal_child(true);
                controls_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;

                toolbar_view.add_top_bar (action_bar);
                toolbar_view.set_content(scrollable);
                toolbar_view.add_bottom_bar (controls_revealer);

                this.child = toolbar_view;
                this.title = "main_view";

                instanciate_signals();
                
        }

        private void instanciate_signals() {
            var signal_hub = SignalHub.get_instance();
            signal_hub.enter_yt_search_mode.connect(() => {
                add_button_revealer.set_reveal_child(false);
                controls_revealer.set_reveal_child(false);
                exit_yt_search_mode_revealer.set_reveal_child(true);
                action_bar.set_margin_start(-5);
                
            });

            signal_hub.exit_yt_search_mode.connect(() => {
                add_button_revealer.set_reveal_child(true);
                controls_revealer.set_reveal_child(true);
                exit_yt_search_mode_revealer.set_reveal_child(false);
                action_bar.set_margin_start(0);
            });
        }


    }

    public class MainViewActionBar : Gtk.Box {
        private MainViewContent main_view;
        private YtSearchBar yt_search_bar;

        public MainViewActionBar (MainViewContent _main_view) {
            this.main_view = _main_view;
        }

        construct {


            orientation = Gtk.Orientation.HORIZONTAL;
            hexpand = true;
            halign = Gtk.Align.FILL;
            yt_search_bar.hexpand = true;

            can_focus = true;
            focusable = true;
            focus_on_click = true;
        }

        public void new_music_popover_show() {
            var popover = new NewMusicPopover();
            popover.present(this);
        }
    }

    public class MainViewContent : Gtk.Box {

        private Adw.NavigationView navigation_view;
        public PlaylistObject current_playlist;

        private Adw.NavigationPage? yt_search_page = null;

        public MainViewContent() {
            vexpand = true;
            hexpand = true;
            print("loading empty ui");
            navigation_view = new Adw.NavigationView();
            append(navigation_view);
            navigation_view.vexpand = true;
            navigation_view.hexpand = true;

        }

        construct {
            SongController.main_view_content = this;

            var config = Config.get_instance();
            config.config_changed.connect(() => {
                if (config.playlists != null) {
                    if (config.playlists.length() == 1) {
                        config.playlists.foreach((i) => {
                            change_page(i);
                            return;
                        });
                    }
                }
            });

            var signal_hub = SignalHub.get_instance();
            signal_hub.enter_yt_search_mode.connect(() => {
                search_ui();
            });
            signal_hub.exit_yt_search_mode.connect(() => {
                if (yt_search_page != null) {
                    print("removing page");
                    navigation_view.pop();
                }
            });

        }

        public void change_page(PlaylistObject playlist) {
            print("change page called");

            if (current_playlist == playlist) return;

            current_playlist = playlist;

            if (playlist.items.is_empty()) {
                empty_playlist_ui(playlist);
                return;
            } else {
                playlist_ui(playlist);
            }


        }

        private void empty_playlist_ui(PlaylistObject playlist) {
            var empty_page = new Adw.StatusPage();
            var parent_page = new Adw.NavigationPage(empty_page,"no songs added");
            empty_page.set_title("Empty Playlist " + playlist.name);
            empty_page.set_icon_name("edit-find-symbolic");
            empty_page.set_description("Click the button on the top left to add songs in this playlist.");

            navigation_view.push(parent_page);      
        }

        private void playlist_ui(PlaylistObject playlist) {
            var playlist_page = new Adw.StatusPage();
            playlist_page.set_title(playlist.name);
            playlist_page.set_icon_name("emblem-music-symbolic");

            load_music(playlist_page, playlist);
            
            var parent_page = new Adw.NavigationPage(playlist_page, playlist.name);

            navigation_view.push(parent_page);
        }

        private void search_ui() {
            if (yt_search_page == null) {
                var yt_search_list = YtSearchView.get_instance();
                var yt_search_list_container = new Gtk.ScrolledWindow();
                yt_search_list_container.vexpand = true;
                yt_search_list_container.set_child(yt_search_list);
                yt_search_page = new Adw.NavigationPage(yt_search_list_container, "Searching...");
            }
            navigation_view.push(yt_search_page);
        }

        private void load_music(Adw.StatusPage page, PlaylistObject playlist) {
            Adw.Clamp clamp = new Adw.Clamp();
            Gtk.ListBox content = new Gtk.ListBox();
            /*foreach (string i in settings.get_strv(playlist_name)) {
                if (i != "") {
                    content.append(new MusicListRow(i));
                }
            }*/
            playlist.items.foreach((item) => {
                MusicListRow i = new MusicListRow(item, playlist);
                content.append(i);

            });
            var config = Config.get_instance();
            config.config_changed.connect(() => {
                content.remove_all();
                playlist.items.foreach((item) => {
                    MusicListRow i = new MusicListRow(item, playlist);
                    content.append(i);
        
                });
            });
            clamp.child = content;
            page.child = clamp;
            content.hexpand = true;
        }

        /*private Gtk.WidgetPaintable playlist_cover(string playlist_name) {
            Gtk.WidgetPaintable paintable = new Gtk.WidgetPaintable();
            return paintable;
        } */
    }
    


}