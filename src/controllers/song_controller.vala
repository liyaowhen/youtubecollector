using Gtk;

namespace Song {


    /* to ensure that doing things on the main_view_content or sidebar_content
    in this SongController allows for those objects to exist, instead of 
    doing functions related to this controller in the bare construct {},
    put it in a signal that will be released when the SongController is ready to use */
    public class SongController : Object {

        public static MainViewContent main_view_content; // main view content should avoid using this controller during instanciation
        public static SideBarContent sidebar_content;
        public static SideBar side_bar;
        public static Adw.OverlaySplitView split_view;
        public static MainView main_view;

        public static SongControls song_controls;

        public static Song.Window window;
        
        public static Adw.ToastOverlay toast_overlay = new Adw.ToastOverlay();
        
    }

    public class SignalHub : Object {
        private static SignalHub? instance = null;

        public signal void mouse_clicked();

        public static SignalHub get_instance () {
            if (instance == null) {
                instance = new SignalHub();
            }
            return instance;
        }
    }

    
}