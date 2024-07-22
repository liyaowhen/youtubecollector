namespace Song {
    public class PlaylistButton : Gtk.Button {

        private Settings settings = new Settings ("com.liyaowhen.Song");

        public signal void removal_mode();
        public signal void exit_removal_mode();
        
        private PlaylistObject playlist;

        public PlaylistButton (PlaylistObject _playlist) {
            this.playlist = _playlist;

            initialize();
        }

        construct {
            hexpand = true;

            clicked.connect(() => {
                //assumes that main_view is already instanciated
                SongController.main_view_content.change_page(playlist);
            });
        }

        public void initialize() {
            set_label(playlist.name);
            
        }
    }
}