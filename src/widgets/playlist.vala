namespace Song {
    public class PlaylistButton : Gtk.Box {

        
        public PlaylistObject playlist;
        private Gtk.Button remove_button;
        private Gtk.Revealer remove_button_revealer;

        public PlaylistButton (PlaylistObject _playlist) {
            this.playlist = _playlist;
            
        }

        construct {

            orientation = Gtk.Orientation.HORIZONTAL;
            add_css_class("toolbar");
            remove_button = new Gtk.Button.from_icon_name("entry-clear-outline-symbolic");

            remove_button.clicked.connect(() => {
                print("clicked");
                confirm_delete_popup();
            });

            remove_button_revealer = new Gtk.Revealer();
            remove_button_revealer.set_child(remove_button);
            remove_button_revealer.transition_type = Gtk.RevealerTransitionType.SWING_LEFT;
            remove_button_revealer.set_reveal_child(false);
            

            var main_button = new Gtk.Button();
            main_button.hexpand = true;
            append(main_button);
            append(remove_button_revealer);
            main_button.can_shrink = true;

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

        private void confirm_delete_popup() {
            
            
            var alert_dialog = new Adw.AlertDialog("Remove Playlist?",
            "Deleting a playlist is a non-reversable action,
                however the playlist's items will remain intact in the configuration folder");
            
            alert_dialog.add_response("Cancel", "Cancel");
            alert_dialog.add_response("Confirm", "Confirm");
            alert_dialog.set_response_appearance("Confirm", Adw.ResponseAppearance.DESTRUCTIVE);

            alert_dialog.present(this);

            
            alert_dialog.response.connect((i, e) => {
                if (e == "Confirm") {
                    Config.get_instance().playlists.remove(playlist);
                    Config.get_instance().save.begin();
                }
            });
            
            
        }
    }
}