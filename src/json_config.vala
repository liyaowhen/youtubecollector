/*
    example Config file structure :
    {
        "playlists": [
            "playlist1": {
                "properties": {
                    "type": 3, // use PlaylistType enum for video-only, audio-only, or an assortment
                    "playlist_picture": "amazing.png", // store all the playlist_pictures in a given directory
                }
                "items": [
                    "video1": {
                        "type": 1, // use enum to write in whether it is audio or video
                        "file": "video1.mp4",
                        "picture": "video1.png" // store the pictures of playlist items in a good directory
                    }
                    "audio2": {
                        "type": 2,
                        "file": "audio2.mp3",
                        "picture": "audio2.png"
                    }
                ]
            }
        ]
    }

*/

namespace Song {

    public enum PlaylistType {
        VIDEO_ONLY,
        AUDIO_ONLY,
        VIDEO_AND_AUDIO_COLLECTION,
    }

    public enum ItemType {
        VIDEO,
        AUDIO,
    }

    public class Config : GLib.Object {
        
        private static Config? instance = null;
        private static string config_file_path;
        private Json.Object? json_config;

        public List<PlaylistObject> playlists;
        public signal void config_changed();

        public static Config get_instance() {
            if (instance == null) {
                instance = new Config();
            }
            return instance;
        }

        private Config() {
            load();
        }
        
        private async void load() {
            playlists = new List<PlaylistObject>();
            print("load");
            File config_file = File.new_for_path(config_file_path);
            if (config_file.query_exists(null)) {
                try {
                    DataInputStream dis = new DataInputStream(config_file.read(null));
                    
                    size_t length;
                    string? content = dis.read_until("", out length, null);
                    if (content != null) {
                        Json.Parser parser = new Json.Parser();

                        try {
                            parser.load_from_file(config_file.get_path());
                        } catch (GLib.Error e) {
                            print(e.message);
                        }
                        print("\n" + config_file.get_path() + "\n");

                        Json.Node root = parser.get_root();
                        json_config = root.get_object();
                        
                        print(json_config.get_size().to_string());
    
                        // Parse settings from JSON
                        if (json_config.has_member("playlists")) {
                            Json.Object _playlists = json_config.get_object_member("playlists");
                            _playlists.foreach_member((object) => {
                                PlaylistObject _playList = new PlaylistObject();

                                _playList.name = object.get_string_member("name");
                                // TODO: ADD PROPERTIES _playList.properties = whatever
                                object.get_object_member("items").foreach_member((item) => {
                                    PlaylistItem _item = new PlaylistItem();
                                    _item.item_type = item.get_int_member("item_type");
                                    _item.name = item.get_string_member("name");
                                    _item.file = item.get_string_member("file");

                                    if (item.has_member("picture")) {
                                        _item.picture = item.get_string_member("picture");
                                    }
                                    if (item.has_member("source")) {
                                        _item.picture = item.get_string_member("source");
                                    }
                                    _playList.items.append(_item);
                                });
                                playlists.append(_playList);
                            });
                        }
                    }


                } catch (Error e) {
                    print("Error reading configuration file: %s\n", e.message);
                }
            }
        }
    
        /*public List<PlaylistObject> get_playlists() {
            
            return playlists.;
        }*/

        // Save configuration to file
        public async void save() {
            print("save");
            try {
                Json.Builder builder = new Json.Builder();

                // initialize the root "{}"
                builder.begin_object();

                // playlists
                    builder.set_member_name("playlists");
                    builder.begin_object();

                    foreach (PlaylistObject item in playlists) {
                        builder.set_member_name(item.name);
                        builder.begin_object();

                        // name
                        builder.set_member_name("name");
                        builder.add_string_value(item.name);

                        // properties
                        builder.set_member_name("properties");
                        builder.begin_object();
                        builder.end_object();

                        // items
                        builder.set_member_name("items");
                        builder.begin_object();

                        // foreach item
                        item.items.foreach((e) => {
                            builder.set_member_name(e.name);
                            builder.begin_object();

                            builder.set_member_name("name");
                            builder.add_string_value("name");

                            builder.set_member_name("item_type");
                            builder.add_int_value(e.item_type);

                            builder.set_member_name("file");
                            builder.add_string_value(e.file);

                            if (e.source != null) {
                                builder.set_member_name("source");
                                builder.add_string_value(e.source);
                            }

                            if (e.picture != null) {
                                builder.set_member_name("picture");
                                builder.add_string_value(e.picture);
                            }

                            builder.end_object();
                        });

                        // items end
                        builder.end_object();

                        builder.end_object();
                    }

                    
                    builder.end_object();

                builder.end_object();
    
                Json.Generator generator = new Json.Generator();
                generator.set_root(builder.get_root());
                generator.to_file(config_file_path);
                print("Configuration saved to %s\n", config_file_path);
            } catch (Error e) {
                print("Error saving configuration file: %s\n", e.message);
            }
            config_changed();
        }

        public static void init(string app_name) {
            string config_dir = Environment.get_user_config_dir();
            string app_config_dir = Path.build_filename(config_dir, app_name);
            config_file_path = Path.build_filename(app_config_dir, "config.json");

            File app_dir = File.new_for_path(app_config_dir);
            if (!app_dir.query_exists(null)) {
                print("directory never existed");
                try {
                    app_dir.make_directory_with_parents(null);
                    print("Created directory: %s\n", app_config_dir);
                } catch (Error e) {
                    print("Error creating directory: %s\n", e.message);
                }
            }

            File config_file = File.new_for_path(config_file_path);
            if (!config_file.query_exists(null)) {
                print("file never existed");
                Config.get_instance().save.begin(); // Create the file with default values
            }
        }
    }
} 