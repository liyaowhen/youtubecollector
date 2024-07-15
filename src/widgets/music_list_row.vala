namespace Song {
    public class MusicListRow : Gtk.Box {

        private Settings settings = new Settings("com.liyaowhen.Song.playlists");
        public string song_name;

        public MusicListRow (string _song_name) {
            this.song_name = _song_name;
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
            var label = new Gtk.Label (song_name);
            print(song_name + "making playlists song button");
            label.hexpand = true;
            append(label);

            var play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic");
            play_button.hexpand = false;
            play_button.add_css_class("flat");

            play_button.clicked.connect(() => {
                if (SongController.song_controls.current_song != song_name) {
                    SongController.song_controls.change_song(song_name);
                    play_button.icon_name = "media-playback-pause-symbolic";
                    Timeout.add(1, () => {
                        if (SongController.song_controls.current_song != song_name) {
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


            spacing = 5;
        }

    }

}