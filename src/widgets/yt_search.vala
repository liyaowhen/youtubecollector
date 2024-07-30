namespace Song {
    public class YtSearchBar : Gtk.Box {

        private Gtk.SearchEntry search_entry = new Gtk.SearchEntry ();
        private MainViewActionBar container_parent;
        private Adw.Clamp search_clamp = new Adw.Clamp();



        construct {
            var gesture = new Gtk.GestureClick();
            add_controller(gesture);

            add_css_class ("toolbar");
            hexpand = true;

            search_entry.hexpand = true;

            search_clamp.set_child(search_entry);
            append(search_clamp);
        }
    }
}