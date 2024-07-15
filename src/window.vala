namespace Song {
    public class Window : Adw.ApplicationWindow {


        private Settings settings = new Settings ("com.liyaowhen.Song");
        public SideBar sidebar;
        public MainView main_view;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {

            var gesture = new Gtk.GestureDrag();

            var provider = new Gtk.CssProvider();
            provider.load_from_path("style.css");

            this.get_style_context().add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // GSettings
            this.settings.bind ("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
            this.settings.bind ("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
            this.settings.bind ("window-maximized", this, "maximized", SettingsBindFlags.DEFAULT);

        // UI
            var title_bar = new Adw.HeaderBar ();
            //title_bar.set_decoration_layout("icon:close");
            title_bar.show_title = false;

            var add_button = new Gtk.Button();
            var add_button_content = new Adw.ButtonContent ();
            add_button_content.set_icon_name("tab-new-symbolic");
            add_button_content.set_label("new song");
            add_button_content.set_parent(add_button);

            add_button.clicked.connect(() => {
                new_music_popover_show();
            });

            var collapse_button = new Gtk.Button.from_icon_name ("folder-open-symbolic");
            title_bar.pack_start (collapse_button);
            title_bar.pack_start(add_button);
           

            
            main_view = new MainView(this);
            sidebar = new SideBar(this);

            var split_view = new Adw.NavigationSplitView ();
            split_view.set_sidebar (sidebar);
            split_view.set_content(main_view);
            split_view.show_content = true;
            

            var _content = new Adw.ToolbarView ();
            _content.add_top_bar (title_bar);
            _content.set_content (split_view);

            _content.add_controller(gesture);
            SongController.gesture = gesture;            
            
            collapse_button.clicked.connect(() => {
                if(split_view.get_collapsed ()){
                    split_view.set_collapsed (false);
                    collapse_button.set_icon_name("folder-open-symbolic");
                } else {
                    split_view.set_collapsed(true);
                    collapse_button.set_icon_name("folder-symbolic");
                }
            });

            
            set_content(_content);

            
        }

        public void new_music_popover_show() {
            var popover = new NewMusicPopover();
            popover.present(this);
        }
    }
}
