using GLib;

namespace Song {
    public class NewMusicPopover : Adw.Dialog {

        private Settings settings = new Settings ("com.liyaowhen.Song");

        public signal void download();

        private Adw.NavigationView navigation_view_steps;
        private string steps_state = "";

        private Gtk.Button next_button;
        private bool isPlaylistFolder;

        public string song_title = "";
        public string song_url = "";

        construct {

            var header = new Adw.HeaderBar ();
            header.show_end_title_buttons = false;
            header.show_start_title_buttons = false;

            provide_ui();

            var cancel_button = new Gtk.Button();
            cancel_button.label = "Cancel";
            cancel_button.clicked.connect(() => {
                close();
            });

            next_button = new Gtk.Button();
            next_button.label = "Next";
            next_button.hide();
            next_button.clicked.connect(() => {
                if (steps_state == "online") {
                    var good = false;
                    string command = "ping " + song_url; // Replace with your desired Linux command
                    
                    string standard_output;
                    string standard_error;
                    int wait_status;

                    download();
                    /*try {
                        Process.spawn_command_line_sync(command,
                                                    out standard_output,
                                                    out standard_error,
                                                    out wait_status);
                        
                                                    print ("stdout:\n");
                                                    // Output: ````
                                                    print (standard_output);
                                                    print ("stderr:\n");
                                                    print (standard_error);
                                                    // Output: ``0``
                                                    print ("Status: %d\n", wait_status);

                            download();
                        
                    } catch (SpawnError e) {
                        print ("Error: %s\n", e.message);
                    } */
                }
            });

            header.pack_end(next_button);
            header.pack_start(cancel_button);

            var action_bar = new Gtk.ActionBar ();

            var content = new Adw.ToolbarView ();
            content.add_top_bar (header);

            content.set_content(navigation_view_steps);
            //content.add_bottom_bar (action_bar);

            set_child(content);

            set_title("create new song");
            follows_content_size = true;


            
        }

        private void provide_ui() {

            navigation_view_steps = new Adw.NavigationView();

        // starting page (choose what kind of app should be)

            var song_folder_button = new Gtk.Button();
            var song_folder_button_content = new Adw.ButtonContent();
            song_folder_button_content.set_icon_name("folder-symbolic");
            song_folder_button_content.set_parent(song_folder_button);
            song_folder_button.set_hexpand(false);


            song_folder_button.clicked.connect(() => {
                var file_chooser = new Gtk.FileChooserDialog("Choose Folder",
                                                            null,
                                                            Gtk.FileChooserAction.SELECT_FOLDER,
                                                            "_Open",
                                                            Gtk.ResponseType.ACCEPT,
                                                            "_Cancel",
                                                            Gtk.ResponseType.CANCEL);

                
                file_chooser.response.connect((dialouge, response) => {
                    if (response == Gtk.ResponseType.ACCEPT) {
                        // ... retrieve the location from the dialog and open it
                        settings.set_string("song-folder", file_chooser.get_file().get_path());
                        print(settings.get_string("song-folder"));
                        file_chooser.destroy();
                        isPlaylistFolder = true;
                    }
                    if (response == Gtk.ResponseType.CANCEL) {
                        file_chooser.destroy();
                    }
                });
                
                file_chooser.show();
            });

            if (settings.get_string("song-folder") == null) {
                isPlaylistFolder = false;
            } else isPlaylistFolder = true;

            song_folder_button.destroy.connect(() => {
                // for safety
                song_folder_button_content.destroy();
            });

            var online_button = new Gtk.Button();
            var online_button_content = new Adw.ButtonContent();
            online_button_content.set_icon_name("globe-alt2-symbolic");
            online_button_content.set_label("from the internet (spotify and youtube supported)");
            online_button_content.set_parent(online_button);
            online_button.set_hexpand(false);
            online_button.sensitive = isPlaylistFolder;

            online_button.destroy.connect(() => {
                // for safety
                online_button_content.destroy();
            });

            var import_button = new Gtk.Button();
            var import_button_content = new Adw.ButtonContent();
            import_button_content.set_icon_name("arrow-into-box-symbolic");
            import_button_content.set_label("use your own music");
            import_button_content.set_parent(import_button);
            import_button.set_hexpand(false);
    import_button.sensitive = isPlaylistFolder;

            import_button.destroy.connect(() => {
                // for safety
                import_button_content.destroy();
            });



            var starting_page_content = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
            starting_page_content.append(song_folder_button);
            starting_page_content.append(online_button);
            starting_page_content.append(import_button);

            var starting_page = new Adw.NavigationPage(starting_page_content, "main");

        //add from online
            var title_entry = new Adw.EntryRow();
            title_entry.title = "Title";

            var url_entry = new Adw.EntryRow();
            url_entry.title = "link to song (youtube, spotify supported)";

            title_entry.changed.connect(() => {
                song_title = title_entry.text;
                if (song_url.length != 0 && song_title.length != 0) {
                    next_button.sensitive = true;
                } else {
                    next_button.sensitive = false;
                }
            });

            url_entry.changed.connect(() => {
                song_url = url_entry.text;
                if (song_url.length != 0 && song_title.length != 0) {
                    next_button.sensitive = true;
                } else {
                    next_button.sensitive = false;
                }
            });

            var online_page_content = new Gtk.ListBox();
            online_page_content.append(title_entry);
            online_page_content.append(url_entry);

            var online_page = new Adw.NavigationPage(online_page_content, "beginning");


        //downloading page
            var terminal = new Vte.Terminal();
            var downloading_page = new Adw.NavigationPage(terminal, "Downloading...");
        
        // complete page
            var complete_page_widget = new Adw.StatusPage();
            complete_page_widget.set_icon_name("emoji-body-symbolic");
            complete_page_widget.set_title("Done importing song");
            complete_page_widget.set_description("go back to listening to songs");
            complete_page_widget.add_css_class("compact");
            var complete_page = new Adw.NavigationPage(complete_page_widget, "Done");
        
        //show the views
            navigation_view_steps.add(starting_page);
            navigation_view_steps.add(online_page);
            navigation_view_steps.add(downloading_page);
            navigation_view_steps.add(complete_page);
            navigation_view_steps.margin_bottom = 5;
            navigation_view_steps.margin_top = 5;
            navigation_view_steps.margin_start = 5;
            navigation_view_steps.margin_end = 5;


            // handle moving around the navigation view
            online_button.clicked.connect(() => {
                navigation_view_steps.push(online_page);
                next_button.show();
                next_button.sensitive = false;
                steps_state = "online";
                terminal.spawn_async(Vte.PtyFlags.DEFAULT,
                    settings.get_string("song-folder"),
                    {"bash"}, 
                    null, 
                    GLib.SpawnFlags.DO_NOT_REAP_CHILD,
                    () => {
    
                    }, 
                    30, 
                    GLib.Cancellable.get_current(),
                    (vterm, gid) => {
                });
                
            });

            // check if there is a folder for the songs to be stored
            if (this.settings.get_string("song-folder").length == 0) {
                song_folder_button_content.set_label("Set download directory");
                song_folder_button.add_css_class("suggested-action");
                online_button.set_sensitive(false);
                import_button.set_sensitive(false);
            } else {
                song_folder_button_content.set_label(settings.get_string("song-folder"));
                settings.changed.connect(() => {
                    song_folder_button_content.set_label(settings.get_string("song-folder"));
                });
            }

            download.connect(() => {
                navigation_view_steps.push(downloading_page);

                string command = "yt-dlp " + "-x -o " + song_title + " --audio-format mp3 " + "'" + song_url + "' \nexit \n";  // \n makes sure that the terminal presses enter after receiving the command
                print(command);

                
                terminal.feed_child(command.data);
                terminal.set_input_enabled(false);
                terminal.child_exited.connect(() => {

                    Settings _list = new Settings("com.liyaowhen.Song.playlists");
                    //Check if the song created had no errors
                    bool file_valid = true;
                    try {
                        var file = File.new_for_path(settings.get_string("song-folder") + "/" + song_title + ".mp3");
                        print("file is \n" + settings.get_string("song-folder") + "/" + song_title + ".mp3");
                        file.read();
                    } catch (GLib.Error e) {
                        print(e.message);
                        file_valid = false;
                    }

                    if (file_valid) {
                        /*if (SongController.main_view_content == null) return;
                        var main_content = SongController.main_view_content;
                        string[] _string_array = _list.get_strv(main_content.current_playlist.name);
                        _string_array += song_title;
                        _list.set_strv(main_content.current_playlist, _string_array);
                        foreach(string str in _list.get_strv(main_content.current_playlist)) {
                            print("this playlist has \n" + str);
                        }*/
                    }

                    //TODO implement error page
                    navigation_view_steps.push(complete_page);

                    size_t length;
                    
                    print(settings.get_value("songs").dup_string(out length));


                });
                

            });

        }
    }


}