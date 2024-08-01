namespace Song {
    public class Window : Adw.ApplicationWindow {


        private Settings settings = new Settings ("com.liyaowhen.Song");
        public SideBar sidebar;
        public MainView main_view;
        public Gtk.ShortcutAction ctrl_z = new Gtk.SignalAction("ctrl_z");

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {

            SongController.window = this;

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

            var add_playlist = new Gtk.Button();
            var add_playlist_content = new Adw.ButtonContent();
            add_playlist_content.set_icon_name("tab-new-symbolic");
            add_playlist_content.set_label("New Playlist");
            add_playlist.set_child(add_playlist_content);

            add_playlist.clicked.connect(() => {
                var popover = new NewPlaylistPopover();
                popover.present(this);
            });

            var add_button = new Gtk.Button();
            var add_button_content = new Adw.ButtonContent ();
            add_button_content.set_icon_name("tab-new-symbolic");
            add_button_content.set_label("new song");
            add_button.set_child(add_button_content);

            add_button.clicked.connect(() => {
                new_music_popover_show();
            });

            var yt_search_bar = new YtSearchBar();
            var collapse_button = new Gtk.Button.from_icon_name ("folder-open-symbolic");
            title_bar.pack_start (collapse_button);
            title_bar.pack_start(add_playlist);
            title_bar.pack_start(add_button);
            title_bar.title_widget = yt_search_bar;
           

            
            main_view = new MainView(this);
            sidebar = new SideBar(this);

            var split_view = new Adw.OverlaySplitView ();
            split_view.set_sidebar (sidebar);
            split_view.set_content(main_view);
            split_view.collapsed = false;
            SongController.split_view = split_view;
            
            

            var _content = new Adw.ToolbarView ();
            //_content.add_top_bar (title_bar);
            //TODO: reimplement top bar
            _content.set_content (split_view);
            
            var controller = new Gtk.ShortcutController();
            Gtk.ShortcutTrigger trigger = Gtk.ShortcutTrigger.parse_string("<Control>Z");
            controller.add_shortcut(new Gtk.Shortcut(trigger, ctrl_z));
            add_controller(new Gtk.ShortcutController());

            
            collapse_button.clicked.connect(() => {
                if(split_view.get_show_sidebar ()){
                    split_view.set_collapsed (false);
                    collapse_button.set_icon_name("folder-open-symbolic");
                } else {
                    split_view.set_collapsed(true);
                    collapse_button.set_icon_name("folder-symbolic");
                }
            });

            set_content(_content);

            var click_monitor = new Gtk.GestureClick ();
            _content.add_controller(click_monitor);
            click_monitor.set_propagation_phase(Gtk.PropagationPhase.CAPTURE);

            var signal_hub = SignalHub.get_instance();
            click_monitor.begin.connect(() => {
                signal_hub.mouse_clicked();
            });
        }

        public void new_music_popover_show() {
            var popover = new NewMusicPopover();
            popover.present(this);
        }
    }
}
