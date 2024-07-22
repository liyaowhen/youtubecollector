int main (string[] args) {
    Gst.init(ref args);

    Song.Config.init("com.liyaowhen.Song");
    var config = Song.Config.get_instance ();

    Song.PlaylistObject playlist = new Song.PlaylistObject();
    playlist.name = "QQ";


    var app = new Song.Application ();
    
    return app.run (args);
}
