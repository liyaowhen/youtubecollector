namespace Song {
    public class Playlist : Gtk.Button {

        private Settings settings = new Settings ("com.liyaowhen.Song");

        public signal void removal_mode();
        public signal void exit_removal_mode();
        
        private string playlist_name;

        public Playlist (string _playlist_name) {
            this.playlist_name = _playlist_name;

            initialize();
        }

        construct {
            hexpand = true;

            clicked.connect(() => {
                //assumes that main_view is already instanciated
                SongController.main_view_content.change_page(playlist_name);
            });
        }

        public void initialize() {
            set_label(playlist_name);
            
        }
    }
}