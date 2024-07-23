namespace Song {
    public class NewPlaylistPopover : Adw.Dialog {

        private bool valid_entry = false;
        private bool _isBoth_ = true;

        construct {

            valid_entry = false;

            Gtk.Button cancel = new Gtk.Button.with_label ("Cancel");
            cancel.clicked.connect(() => {
                close();
            });

            Gtk.Button confirm = new Gtk.Button.with_label ("Confirm");
            confirm.sensitive = false;

            var header = new Adw.HeaderBar ();
            header.show_end_title_buttons = false;
            header.show_start_title_buttons = false;
            header.pack_end (confirm);
            header.pack_start (cancel);

            Gtk.Entry entry = new Gtk.Entry();
            set_focus(entry);

            List<weak PlaylistObject> already_existing_playlists = Config.get_instance().playlists.copy();
            Gee.HashSet<string> already_existing_playlists_string;
            already_existing_playlists.foreach ((i) => {
                already_existing_playlists_string.add(i.name);
            });

            entry.changed.connect(() => {
                if (entry.get_buffer ().length == 0) {
                    valid_entry = false;
                    confirm.sensitive = false;
                } else {
                    if (!already_existing_playlists_string.contains(entry.text)) {
                        valid_entry = true;
                        confirm.sensitive = true;
                    } else {
                        valid_entry = false;
                        confirm.sensitive = false;
                    }
                }
            });

            confirm.clicked.connect(() => {
                if (valid_entry) {
                    var config = Config.get_instance ();
                    var playlist = new PlaylistObject();
                    playlist.name = entry.text;
                    config.playlists.append(playlist);
                    config.save();
                }
            });

            var is_song = new Gtk.CheckButton.with_label ("song");
            var is_video = new Gtk.CheckButton.with_label("video");
            var is_both = new Gtk.CheckButton.with_label ("both");

            is_both.activate.connect(() => {
                _isBoth_ = true;
                is_song.sensitive = false;
                is_video.sensitive = false;
            });

            var check_box_row = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            check_box_row.vexpand = true;
            check_box_row.hexpand = true;
            check_box_row.halign = Gtk.Align.CENTER;
            check_box_row.append(is_song);
            check_box_row.append(is_video);
            check_box_row.append(is_both);

            // use settings to determine this later
            is_both.set_active(true);

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
            box.append(entry);
            box.append(check_box_row);

            var content = new Adw.ToolbarView ();
            content.add_top_bar (header);
            content.set_content(box);

            set_child(content);
            set_title("Playlist Name");

        }
    }
}