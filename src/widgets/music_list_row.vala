namespace Song {
    public class MusicListRow : Gtk.Box {

        private Settings settings = new Settings("com.liyaowhen.Song.playlists");
        public PlaylistItem item;
        private PlaylistObject playlist;

        private Gee.HashSet<Gtk.Widget> playlist_widgets = new Gee.HashSet<Gtk.Widget>();

        public MusicListRow (PlaylistItem _item, PlaylistObject playlist) {
            this.item = _item;
            this.playlist = playlist;
            build_ui();
        }

        construct {

            margin_bottom = 5;
            margin_top = 5;
            margin_start = 5;
            margin_end = 5;
            vexpand = true;
            hexpand = true;
            vexpand_set = true;
            hexpand_set = true;
            orientation = Gtk.Orientation.HORIZONTAL;
        }

        private void build_ui() {
            var label = new Gtk.Label (item.name);
            print(item.name + "making playlists song button");
            label.hexpand = true;
            append(label);

            var play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic");
            play_button.hexpand = false;
            play_button.add_css_class("flat");

            play_button.clicked.connect(() => {
                if (SongController.song_controls.current_item != item) {
                    SongController.song_controls.change_item(item);
                    play_button.icon_name = "media-playback-pause-symbolic";
                    Timeout.add(1, () => {
                        if (SongController.song_controls.current_item != item) {
                            // when another song is called to play, reset the button state
                            play_button.icon_name = "media-playback-start-symbolic";
                            return false;
                        }
                        return true;
                    });
                } else if (SongController.song_controls.isPlaying) {
                    SongController.song_controls.pause();
                    play_button.icon_name = "media-playback-start-symbolic";
                } else if (!SongController.song_controls.isPlaying) {
                    SongController.song_controls.play();
                    play_button.icon_name = "media-playback-pause-symbolic";
                }
            });

            append(play_button);
            
            var options_button = new Gtk.MenuButton();
            options_button.set_icon_name("view-more-symbolic");
            options_button.add_css_class("flat");

                
                    var add_playlists_menu = new Menu();
                    fill_playlists(add_playlists_menu);

                    var menu = new Menu();
                    menu.append_section("Add To Other Playlists", add_playlists_menu);

                    //popover.set_child(nav_view);

            

            options_button.set_menu_model(menu);
            prepend(options_button);

            spacing = 5;
        }

        private async void fill_playlists(Menu menu) {
            var config = Config.get_instance();

            menu.remove_all();

            config.playlists.foreach((i) => {
                if (i != playlist) {
                    var playlist = new MenuItem(i.name, null);
                    string[] target_array = {this.playlist.name, i.name, item.name};
                    playlist.set_action_and_target_value("app.add_item_to_playlist", target_array);
                    menu.append_item(playlist);
                }
            });
        }

    }

    public class AddItemToPlaylistRequest : GLib.Object {
        public PlaylistObject? target = null;
        public PlaylistItem? item = null;

        public AddItemToPlaylistRequest(PlaylistObject playlist, PlaylistItem item) {
            this.target = playlist;
            this.item = item;
        }
    }

}