namespace Song {
    public class MainView : Adw.NavigationPage {
        private Window window;

        public Settings settings = new Settings("com.liyaowhen.Song.playlists");
        public MainViewContent main_content;
        public string current_playlist;

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

                var action_bar = new MainViewActionBar (main_content);
                
                var controls = new SongControls();

                toolbar_view.add_top_bar (action_bar);
                toolbar_view.set_content(scrollable);
                toolbar_view.add_bottom_bar (controls);

                this.child = toolbar_view;
                this.title = "main_view";

        }


    }

    public class MainViewActionBar : Gtk.Box {
        private Gtk.ActionBar action_bar;
        private MainViewContent main_view;

        public MainViewActionBar (MainViewContent _main_view) {
            this.main_view = _main_view;
        }

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
            action_bar = new Gtk.ActionBar();




            action_bar.vexpand = true;
            action_bar.hexpand = true;
            append(action_bar);


        }

        public void new_music_popover_show() {
            var popover = new NewMusicPopover();
            popover.present(this);
        }
    }

    public class MainViewContent : Gtk.Box {

        private Settings settings = new Settings("com.liyaowhen.Song.playlists");
        private Adw.NavigationView navigation_view;
        public string current_playlist;

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
        }

        public void change_page(string playlist_name) {
            print("change page called");

            bool isKeyValid = false;
            foreach (string key in settings.list_keys()){
                if (key == playlist_name) {
                    print("valid playlist");
                    isKeyValid = true;
                }
            }
            if (!isKeyValid) {
                print("invalid playlist_name");
                return;
            }

            current_playlist = playlist_name;

            string[] songs = settings.get_strv(playlist_name);
            print("\n playlist contains: \n" + songs[1]);
            if (songs.length == 1) {
                if (songs[0] == "") {empty_playlist_ui(playlist_name); return;}
                else {
                    //
                }
            } else if (songs.length > 1) {
                if (songs[1] != null) {
                    print("making a page with actual content");
                    playlist_ui(playlist_name);
                }
            }


        }

        private void empty_playlist_ui(string playlist_name) {
            var empty_page = new Adw.StatusPage();
            var parent_page = new Adw.NavigationPage(empty_page,"no songs added");
            empty_page.set_title("Empty Playlist " + playlist_name);
            empty_page.set_icon_name("edit-find-symbolic");
            empty_page.set_description("Click the button on the top left to add songs in this playlist.");
            navigation_view.push(parent_page);      
        }

        private void playlist_ui(string playlist_name) {
            var playlist_page = new Adw.StatusPage();
            playlist_page.set_title(playlist_name);
            playlist_page.set_icon_name("emblem-music-symbolic");

            load_music(playlist_page, playlist_name);
            
            var parent_page = new Adw.NavigationPage(playlist_page, playlist_name);
            navigation_view.push(parent_page);
        }

        private void load_music(Adw.StatusPage page, string playlist_name) {
            Adw.Clamp clamp = new Adw.Clamp();
            Gtk.ListBox content = new Gtk.ListBox();
            foreach (string i in settings.get_strv(playlist_name)) {
                if (i != "") {
                    content.append(new MusicListRow(i));
                }
            }
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