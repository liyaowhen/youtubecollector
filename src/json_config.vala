using Json;

namespace Song {

    public class JsonConfig : GLib.Object {
        
        private Settings settings = new Settings("com.liyaowhen.Song");

        public class JsonConfig () {
            var json_text = settings.get_string("songs");

            var parser = new Json.Parser();
            try {
                parser.load_from_data (json_text, json_text.length);
            } catch (GLib.Error e) {
                print(e.message);
            }
            

        }
    }
} 