namespace Song {
    public class PlaylistButton : Gtk.Box {

        private Settings settings = new Settings ("com.liyaowhen.Song");
        
        private PlaylistObject playlist;
        private Gtk.Button remove_button;
        private Gtk.Revealer remove_button_revealer;

        public PlaylistButton (PlaylistObject _playlist) {
            this.playlist = _playlist;
            
        }

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
            add_css_class("toolbar");
            remove_button = new Gtk.Button.from_icon_name("app-remove-symbolic");

            remove_button_revealer = new Gtk.Revealer();
            remove_button_revealer.set_child(remove_button);
            remove_button_revealer.transition_type = Gtk.RevealerTransitionType.SWING_LEFT;
            remove_button_revealer.set_reveal_child(false);
            

            var main_button = new Gtk.Button();
            main_button.hexpand = true;
            append(main_button);
            append(remove_button_revealer);

            hexpand = true;

            main_button.clicked.connect(() => {
                //assumes that main_view is already instanciated
                SongController.main_view_content.change_page(playlist);
            });

            Timeout.add(1, () => {
                if (playlist.name != null) {
                    main_button.label = playlist.name;
                }
            });

            Config.get_instance().loaded.connect(() => {
                if (playlist.name != null) {
                    main_button.label = playlist.name;
                }
            });
            Config.get_instance().config_changed.connect(() => {
                if (playlist.name != null) {
                    main_button.label = playlist.name;
                }
            });
        }

        public void enter_removal_mode() {
            remove_button_revealer.set_reveal_child(true);
        }

        public void exit_removal_mode() {
            remove_button_revealer.set_reveal_child(false);
        }
    }
}