namespace Song {
    public enum YtSearchBarStates {
        ENLARGING,
        SHRINKING,
        NONE,
    }

    public enum YtSearchViewStates {
        SEARCHING,
        IDLE,
    }

    public class YtSearchBar : Gtk.Box {

        public Gtk.SearchEntry search_entry = new Gtk.SearchEntry ();
        private MainViewActionBar container_parent;
        private Adw.Clamp search_clamp = new Adw.Clamp();

        private int min_width = 0;
        private int? max_width;

        private YtSearchBarStates state = YtSearchBarStates.NONE;
        private bool isEnlarged = false;

        public bool isMouseInside = false;
        private YtSearchBarStates? requesting_state = null;

        private Adw.TimedAnimation? enlarge_animation = null;
        private Adw.TimedAnimation? shrink_animation = null;
        private Adw.AnimationTarget size_animation_target;

        construct {
            var motion_sensor = new Gtk.EventControllerMotion();
            search_entry.add_controller(motion_sensor);

            motion_sensor.leave.connect(() => {
                isMouseInside = false;
            });

            motion_sensor.enter.connect(() => {
                isMouseInside = true;
            });

            var focus_event = new Gtk.EventControllerFocus();
            add_controller(focus_event);

            add_css_class ("toolbar");
            hexpand = true;

            search_entry.hexpand = true;

            search_clamp.set_child(search_entry);
            append(search_clamp);

            min_width = search_clamp.get_maximum_size ();
            max_width = min_width + 200;

            size_animation_target = new Adw.PropertyAnimationTarget(search_clamp, "maximum_size");

            instanciate_signals();

            var signal_hub = SignalHub.get_instance();
            signal_hub.yt_search_bar = this;
        }


        private void instanciate_signals() {
            var signal_hub = SignalHub.get_instance();

            search_entry.changed.connect((i) => {
                if (i.text != "") {
                    if (state != YtSearchBarStates.ENLARGING && isEnlarged != true && requesting_state != YtSearchBarStates.ENLARGING) {
                        enlarge();
                        signal_hub.enter_yt_search_mode();
                    }
                } else {
                    shrink();
                    signal_hub.exit_yt_search_mode();
                }
                signal_hub.request_search(i.get_text());
            });
        }

        private void enlarge() {
            if (enlarge_animation == null) {
                enlarge_animation = new Adw.TimedAnimation(search_clamp, min_width, max_width, 500, size_animation_target);
                enlarge_animation.done.connect(() => {
                    isEnlarged = true;
                    state = YtSearchBarStates.NONE;

                });
            }

            enlarge_animation.play();
            state = YtSearchBarStates.ENLARGING;
        }

        private void shrink() {
            if (shrink_animation == null) {
                shrink_animation = new Adw.TimedAnimation(search_clamp, max_width, min_width, 500, size_animation_target);
                shrink_animation.done.connect(() => {
                    isEnlarged = false;
                    state = YtSearchBarStates.NONE;
                });
            }

            shrink_animation.play();
            state = YtSearchBarStates.SHRINKING;
        }
    }

    public class YtSearchView : Gtk.Box {

        private YtSearchViewStates state = YtSearchViewStates.IDLE;

        private Cancellable active_search_query;
        private Gee.HashSet<YtSearchItem> results = new Gee.HashSet<YtSearchItem>();
        private Gee.HashSet<Gtk.Widget> result_widgets = new Gee.HashSet<Gtk.Widget>();
        private Gtk.FlowBox flow_box = new Gtk.FlowBox();

        private Subprocess? search_process = null;

        construct {

            orientation = Gtk.Orientation.VERTICAL;
            append(flow_box);
            flow_box.set_max_children_per_line(4);

            instanciate_signals();

            var yt_search_tmp = File.new_build_filename(Environment.get_tmp_dir(), "yt_search_tmp.json");
            if (!yt_search_tmp.query_exists(null)) {
                yt_search_tmp.create(FileCreateFlags.NONE, null);
                print(yt_search_tmp.get_path());
            }
            print(yt_search_tmp.get_path());
            print(Environment.get_tmp_dir());

            var motion_sensor = new Gtk.EventControllerMotion();
            get_parent().add_controller(motion_sensor);

            var signal_hub = SignalHub.get_instance();
            motion_sensor.leave.connect(() => {
                signal_hub.yt_search_bar.isMouseInside = false;
            });

            motion_sensor.enter.connect(() => {
                signal_hub.yt_search_bar.isMouseInside = true;
            });

            hexpand = true;
            hexpand_set = true;
            vexpand = true;
            vexpand_set = true;
        }

        private void instanciate_signals() {
            var signal_hub = SignalHub.get_instance();
            signal_hub.request_search.connect((query) => {
                search.begin(query);
                state = YtSearchViewStates.SEARCHING;
            });

            //label.label = signal_hub.yt_search_bar.search_entry.text;
        }

        private async void search(string query) {
            //label.label = query;
            string temp_file = Path.build_path("/", Environment.get_tmp_dir(), "yt_search_tmp.json");

            string[] command = {
                "sh", 
                "-c", 
                "./song-search " +
                query,
                null
            };
            print("\n");
            foreach(string s in command) {
                print(s + " ");
            }

            MainLoop loop = new MainLoop ();
            try {

                //TODO: remove ghost processes

                /*Process.spawn_async_with_pipes(
                    Environment.get_tmp_dir(), 
                    command, 
                    null, 
                    GLib.SpawnFlags.SEARCH_PATH | GLib.SpawnFlags.DO_NOT_REAP_CHILD, 
                    null, 
                    out child_pid, 
                    out std_input, 
                    out std_out, 
                    out std_error
                );*/

                /*Process.spawn_async_with_pipes(
                    Environment.get_user_config_dir() + "/com.liyaowhen.Song", 
                    command, 
                    null, 
                    GLib.SpawnFlags.SEARCH_PATH | GLib.SpawnFlags.DO_NOT_REAP_CHILD, 
                    null, 
                    out child_pid, 
                    out std_input, 
                    out std_out, 
                    out std_error
                );*/

                if (search_process != null && search_process.get_identifier() != null) {
                    search_process.force_exit();
                }
                try {
                    search_process = new Subprocess(GLib.SubprocessFlags.STDIN_PIPE | GLib.SubprocessFlags.STDOUT_PIPE | GLib.SubprocessFlags.STDERR_PIPE, 
                        Environment.get_user_config_dir() + "/com.liyaowhen.Song/search-utility", query);
                } catch (GLib.Error e) {
                    print(e.message);
                }

                try {
                    search_process.communicate_utf8_async.begin(null, null, (obj, res) => {
                        try {
                            string? stdout_buff;
                            string? stderr_buff;
                            search_process.communicate_utf8_async.end (res, out stdout_buff, out stderr_buff);

                            if (stdout_buff != null) {
                                print ("STDOUT: %s\n", stdout_buff);
                                read_json(stdout_buff);
                            }

                            if (stderr_buff != null) {
                                print ("STDERR: %s\n", stderr_buff);
                            }
                        } catch (Error e) {
                            print ("Error: %s\n", e.message);
                        }
                    });
                } catch (GLib.Error e) {
                    print(e.message);
                }


                //GLib.IOChannel stdout_channel = new IOChannel.unix_new(std_out);
                StringBuilder output_buffer = new StringBuilder();

                /*stdout_channel.add_watch(IOCondition.IN | IOCondition.HUP, (i, c) => {
                    if (c == IOCondition.HUP) {
                        if (cancellable.is_cancelled()) {
                            //Process.close_pid(child_pid);
                            loop.quit();
                            return false;
                        }
                        read_json(cancellable, output_buffer.str);
                        return false;
                    }

                    try {
                        string line;
                        i.read_line(out line, null, null);
                        output_buffer.append(line);
                    } catch (GLib.ConvertError e) {
                        print("IOChannelError: %s\n", e.message);
                    }

                    return true;
                });*/
                
                //IOChannel error = new IOChannel.unix_new (std_error);


                /*error.add_watch(IOCondition.IN | IOCondition.HUP, (i, c) => {
                    if (c == IOCondition.HUP) {
                        return false;
                    }
                    try {
                        string line;
                        i.read_line(out line, null, null);

                    } catch (GLib.ConvertError e) {
                        print("IOChannelError: %s\n", e.message);
                    }
                    return true;
                }); */

                /*ChildWatch.add(child_pid, (pid, status) => {
                    Process.close_pid (pid);
                    loop.quit ();
                    print("process ended");
                    
                }); */

                loop.run();
            } catch (GLib.SpawnError e) {
                print(e.message);
            }
        }

        private void read_json(string json) {
            
            results.clear();
            try {
                /*
                    Json.Parser parser = new Json.Parser();
                    parser.load_from_data(json, -1);
                    Json.Node root = parser.get_root();
                    Json.Object root_object = root.get_object();

                    if (root_object.has_member("entries")) {
                        var entries = root_object.get_array_member("entries");
                        var entries_members = entries.get_elements();
                        entries_members.foreach((i) => {
                            var entry = i.get_object();
                            YtSearchItem search_item = new YtSearchItem();
                            if (entry.has_member("requested_downloads")) {
                                //requested formats has 2 parts, the video and audio parts
                                var requested_downloads = entry.get_array_member("requested_downloads");
                                var requested_downloads_iterable = requested_downloads.get_elements();
                                
                                //has only one array item
                                requested_downloads_iterable.foreach((e) => {
                                    var requested_downloads_object = e.get_object();
                                    if (requested_downloads_object.has_member("requested_formats")) {
                                        var requested_formats = requested_downloads_object.get_array_member("requested_formats");
                                        var requested_formats_iterable = requested_formats.get_elements();
                                        //requested formats iterable hosts 2 objects, a video stream and audio stream object
                                        
                                        requested_formats_iterable.foreach((j) => {
                                            var video_or_audio_object = j.get_object();
                                            if (video_or_audio_object.has_member("audio_ext")) {
                                                var audio_ext = video_or_audio_object.get_string_member("audio_ext");
                                                if (audio_ext != "none") {
                                                    // if object is audio
                                                    search_item.audio_url = video_or_audio_object.get_string_member("url");
                                                } else {
                                                    // if object is video
                                                    search_item.url = video_or_audio_object.get_string_member("url");
                                                }
                                            }
                                        });
                                    }
                                });

                            }
                            if (entry.has_member("fulltitle")) {
                                search_item.title = entry.get_string_member("fulltitle");
                            }
                            results.add(search_item);
                            print("\n " + search_item.title);
                        });
                    }
                    print("idle");
                    state = YtSearchViewStates.IDLE;

                    load_contents();
                */
                Json.Parser parser = new Json.Parser();
                parser.load_from_data(json, -1);
                Json.Node root = parser.get_root();
                Json.Array root_object = root.get_array();
                var root_object_iterable = root_object.get_elements();
                results.clear();

                root_object_iterable.foreach((i) => {
                    var item = i.get_object();
                    YtSearchItem search_item = new YtSearchItem();
                    if (item.has_member("title")) {
                        search_item.title = item.get_string_member("title");
                    }
                    if (item.has_member("url")) {
                        search_item.url = item.get_string_member("url");
                    }
                    if (item.has_member("image")) {
                        search_item.thumbnail_url = item.get_string_member("image");
                    }
                    results.add(search_item);
                });
                

                /* 
                if (root_object.has_member("entries")) {
                    var entries = root_object.get_array_member("entries");
                    var entries_members = entries.get_elements();
                    entries_members.foreach((i) => {
                        var entry = i.get_object();
                        YtSearchItem search_item = new YtSearchItem();
                        if (entry.has_member("requested_downloads")) {
                            //requested formats has 2 parts, the video and audio parts
                            var requested_downloads = entry.get_array_member("requested_downloads");
                            var requested_downloads_iterable = requested_downloads.get_elements();
                            
                            //has only one array item
                            requested_downloads_iterable.foreach((e) => {
                                var requested_downloads_object = e.get_object();
                                if (requested_downloads_object.has_member("requested_formats")) {
                                    var requested_formats = requested_downloads_object.get_array_member("requested_formats");
                                    var requested_formats_iterable = requested_formats.get_elements();
                                    //requested formats iterable hosts 2 objects, a video stream and audio stream object
                                    
                                    requested_formats_iterable.foreach((j) => {
                                        var video_or_audio_object = j.get_object();
                                        if (video_or_audio_object.has_member("audio_ext")) {
                                            var audio_ext = video_or_audio_object.get_string_member("audio_ext");
                                            if (audio_ext != "none") {
                                                // if object is audio
                                                search_item.audio_url = video_or_audio_object.get_string_member("url");
                                            } else {
                                                // if object is video
                                                search_item.url = video_or_audio_object.get_string_member("url");
                                            }
                                        }
                                    });
                                }
                            });

                        }
                        if (entry.has_member("fulltitle")) {
                            search_item.title = entry.get_string_member("fulltitle");
                        }
                        results.add(search_item);
                        print("\n " + search_item.title);
                    });
                } */
                print("idle");
                state = YtSearchViewStates.IDLE;

                load_contents();
            } catch (Error e) {
                print("Failed to parse JSON: %s\n", e.message);
            }
        }

        private void load_contents() {
            foreach (Gtk.Widget i in result_widgets) {
                remove(i);
                print("destroying widgets");
            }
            result_widgets.clear();
            results.foreach((result) => {
                var label = new Gtk.Label(result.title);
                var link = new Gtk.LinkButton(result.url);
                var thumbnail = new Gtk.Picture();
                thumbnail.vexpand = true;
                thumbnail.vexpand_set = true;
                thumbnail.can_shrink = false;
                load_url_to_image.begin(thumbnail, result.thumbnail_url);
                var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
                var options_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
                options_box.append(label);
                var overlay = new Gtk.Overlay();
                overlay.set_child(thumbnail);
                overlay.add_overlay(options_box);
                append(overlay);
                result_widgets.add(overlay);
                return true;
            });
        }

        private async void load_url_to_image (Gtk.Picture? image, string url) {
            Soup.Session session = new Soup.Session ();
            Soup.Message message = new Soup.Message ("GET", url);

            session.send_and_read_async.begin(message, 1, null, (o, object) => {
                var bytes = session.send_and_read_async.end(object);
                var stream = new GLib.MemoryInputStream();
                stream.add_bytes(bytes);
                var pixbuf = new Gdk.Pixbuf.from_stream(stream, null);
                if (image != null) {
                    image.set_pixbuf(pixbuf);
                }
            });

        }
    }

    public class YtSearchItem : GLib.Object {
        public string title = "";
        public string url = "";
        public string thumbnail_url = "";
    }

    public class ExpandableImage : Gtk.DrawingArea {
        public Gdk.Pixbuf? pixbuf = null;

        public ExpandableImage () {
            var frame = new Gtk.Frame(null);

            this.set_draw_func((drawing_area, cairo_context, i) => {
                if (pixbuf != null) {
                    Gdk.cairo_set_source_pixbuf(cairo_context, pixbuf, 0, 0);
                } else {
                    cairo_context.set_source_rgb(200, 200, 200);
                }
                cairo_context.paint();
            });

            queue_draw();
        }


    }
}