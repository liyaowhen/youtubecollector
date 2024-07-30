namespace Song {
    public class MainView : Adw.NavigationPage {
        private Window window;

        public Settings settings = new Settings("com.liyaowhen.Song.playlists");
        public MainViewContent main_content;
        public PlaylistObject current_playlist;

        public MainView(Window _window) {
            this.window = _window;
        }

        construct {

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
                collapse_button_revealer.set_child(collapse_button);
                collapse_button_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
                var action_bar = new Adw.HeaderBar();
                action_bar.show_back_button = false;
                action_bar.title_widget = new YtSearchBar();
                action_bar.pack_start(collapse_button_revealer);
                collapse_button.clicked.connect(() => {
                    if(SongController.split_view.get_collapsed ()){
                        SongController.split_view.set_collapsed (false);
                        collapse_button_revealer.set_reveal_child(false);
                    } else {
                        SongController.split_view.set_collapsed(true);
                        action_bar.margin_start = -5;
                    }
                });

                Timeout.add(1, () => {
                    if (SongController.side_bar != null) {
                        SongController.side_bar.collapsing.connect(() => {
                            collapse_button_revealer.set_reveal_child(true);
                            action_bar.margin_start = 5;
                        });
                        return false;
                    }
                    return true;
                });

                
                var controls = new SongControls();

                toolbar_view.add_top_bar (action_bar);
                toolbar_view.set_content(scrollable);
                toolbar_view.add_bottom_bar (controls);

                this.child = toolbar_view;
                this.title = "main_view";

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


        }

        public void new_music_popover_show() {
            var popover = new NewMusicPopover();
            popover.present(this);
        }
    }

    public class MainViewContent : Gtk.Box {

        private Adw.NavigationView navigation_view;
        public PlaylistObject current_playlist;

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

        private void load_music(Adw.StatusPage page, PlaylistObject playlist) {
            Adw.Clamp clamp = new Adw.Clamp();
            Gtk.ListBox content = new Gtk.ListBox();
            /*foreach (string i in settings.get_strv(playlist_name)) {
                if (i != "") {
                    content.append(new MusicListRow(i));
                }
            }*/
            playlist.items.foreach((item) => {
                content.append(new MusicListRow(item));
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