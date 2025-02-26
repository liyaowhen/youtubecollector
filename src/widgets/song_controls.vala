using Gst;


namespace Song {
    public class SongControls : Gtk.Box {

        private Settings songs_list = new Settings("com.liyaowhen.Song.playlists");
        private Settings settings = new Settings("com.liyaowhen.Song");

        public Gtk.Scale progress_bar;
        public Gtk.Adjustment progress_bar_adjustment;
        private bool isDragging;
        private Gtk.Button progress_bar_controller;
        private uint? seekTimeout = null;

        private string item_directory = Path.build_path("/", Environment.get_user_config_dir(), "com.liyaowhen.Song");

        public bool isPlaying;
        public PlaylistItem current_item;

        public Gst.Element playbin;

        public SongControls() {
            
        }

        construct {

            playbin = Gst.ElementFactory.make("playbin", "player");
        // Gstreamer stuff
            isPlaying = false;
        // UI
            orientation = Gtk.Orientation.VERTICAL;
            vexpand = false;
            hexpand = true;
            hexpand_set = true;

            progress_bar_adjustment = new Gtk.Adjustment(0, 0, 1, 1, 1, 0);
            progress_bar = new Gtk.Scale(Gtk.Orientation.HORIZONTAL, progress_bar_adjustment);
            progress_bar.set_draw_value(false);


            
            var signal_hub = SignalHub.get_instance();
            Timeout.add(500, () => {

                if (playbin != null && isPlaying) {
                    var position = (int64) 0;
                    var duration = (int64) 0;
                    
                    //playbin.set_state(Gst.State.PLAYING);
                    

                    // Query the current position and duration
                    if (playbin.query_position(Format.TIME, out position) && 
                        playbin.query_duration(Format.TIME, out duration)) {
                        progress_bar.set_range(0, (double) duration / Gst.SECOND);
                        progress_bar.set_value((double) position / Gst.SECOND);
                        print("working");
                    }

                } else {

                }


                return true;
            });
            
            
            progress_bar.adjust_bounds.connect((range) => {
                if (playbin != null) {
                    //var seek_time = (int64)(progress_bar.get_value() * Gst.SECOND);
                    //playbin.seek_simple(Format.TIME, SeekFlags.FLUSH | SeekFlags.TRICKMODE_FORWARD_PREDICTED, seek_time);
                    isPlaying = false;
                    print("seeking");
                    if (seekTimeout != null) {
                        if (seekTimeout > 0) {
                            GLib.Source.remove(seekTimeout);
                        }
                    }
    
                    seekTimeout = Timeout.add(200, () => {
                        if (playbin != null) {
                            int64 seek_time = (int64)(progress_bar.get_value() * Gst.SECOND);
                            playbin.seek_simple(Format.TIME, SeekFlags.FLUSH | SeekFlags.KEY_UNIT, seek_time);
                        }
                        return false; // Remove the timeout
                    });
                } 

            });
             // emitted when user (not program) changes the scale

            signal_hub.end_drag.connect(() => {
                isPlaying = true;
            });

        
            append(progress_bar);

            // add controls to control the music
            music_controls();

            SongController.song_controls = this;
        }
        


        private void music_controls() {
            var clamp = new Adw.Clamp();

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            box.hexpand = true;
            box.halign = Gtk.Align.CENTER;
            box.margin_bottom = 10;
            
            var play_button = new Gtk.Button.from_icon_name("media-playback-start-symbolic");
            play_button.halign = Gtk.Align.CENTER;

            Timeout.add(1, () => {
                if (isPlaying == true) {
                    play_button.set_icon_name("media-playback-pause-symbolic");
                } else {
                    play_button.set_icon_name("media-playback-start-symbolic");
                }
                return true;
                
            });

            play_button.clicked.connect(() => {
                if (isPlaying) pause();
                else play();
            });

            box.append(play_button);

            play_button.clicked.connect(() => {
                play_music();
            });

            clamp.child = box;
              
            append(clamp);
        }

        private void play_music() {
            if (current_item != null) {
                
            }
        }

        public void play() {
            playbin.set_state(Gst.State.PLAYING);
            isPlaying = true;
        }

        public void pause() {
            playbin.set_state(Gst.State.PAUSED);
            isPlaying = false;
        }

        public void change_item(PlaylistItem item) {
            print("song is now " + item.name + "\n");
            current_item = item;
            string file_path = item.file;
            print("song full path is " + file_path);
            playbin.set_state(Gst.State.NULL);
            playbin.set_property("uri", File.new_for_path(file_path).get_uri());
            playbin.set_start_time(0);
            playbin.set_state(Gst.State.PLAYING);
            isPlaying = true;

        }

    }
}