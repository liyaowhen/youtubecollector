/* application.vala
 *
 * Copyright 2024 Leo Wen
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Song {
    public class Application : Adw.Application {
        public Application () {
            Object (application_id: "com.liyaowhen.Song", flags: ApplicationFlags.DEFAULT_FLAGS);
        }

        construct {
            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
                { "preferences", this.on_preferences_action },
                { "quit", this.quit }
            };
            var add_song_to_playlist_action = new SimpleAction("add_item_to_playlist", VariantType.STRING_ARRAY);
            add_song_to_playlist_action.activate.connect(add_song_to_playlist);
            this.add_action_entries (action_entries, this);
            this.add_action(add_song_to_playlist_action);
            this.set_accels_for_action ("app.quit", {"<primary>q"});
        }

        public override void activate () {
            base.activate ();
            var win = this.active_window;
            if (win == null) {
                win = new Song.Window (this);
            }
            win.present ();

        }

        private void on_about_action () {
            string[] developers = { "Leo Wen" };
            var about = new Adw.AboutWindow () {
                transient_for = this.active_window,
                application_name = "song",
                application_icon = "com.liyaowhen.Song",
                developer_name = "Leo Wen",
                version = "0.1.0",
                developers = developers,
                copyright = "© 2024 Leo Wen",
            };

            about.present ();
        }

        private void on_preferences_action () {
            message ("app.preferences action activated");
        }

        private void add_song_to_playlist(Action a, GLib.Variant? data) {
            // [current_playlist.name, target_playlist.name, item.name]
            print("action used");
            string[] request = data.get_strv ();
            if (request.length != 3) return;

            var config = Config.get_instance ();
            print("request is valid");

            PlaylistObject? target_playlist = null;
            PlaylistObject? current_playlist = null;
            config.playlists.foreach((i) => {
                if (i.name == request[1]) {
                    target_playlist = i;
                }
                if (i.name == request[0]) {
                    current_playlist = i;
                }
            });
            if (target_playlist == null | current_playlist == null) return;
            print("was able to find playlist reference");

            PlaylistItem? item = null;
            current_playlist.items.foreach ((i) => {
                if (i.name == request[2]) {
                    item = i;
                }
            });
            if (item == null) return;
            print("item was not null");
            
            target_playlist.add_item (item);
            print("added to other playlist");
            config.save.begin();
        }
    }
}
