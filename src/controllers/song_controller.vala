using Gtk;

namespace Song {


    public delegate void EventQueue();
    /* to ensure that doing things on the main_view_content or sidebar_content
    in this SongController allows for those objects to exist, instead of 
    doing functions related to this controller in the bare construct {},
    put it in a signal that will be released when the SongController is ready to use */
    public class SongController : Object {

        public static MainViewContent main_view_content; // main view content should avoid using this controller during instanciation
        public static SideBarContent sidebar_content;

        public static SongControls song_controls;

        public static Adw.ApplicationWindow window;
        
    }

    
}