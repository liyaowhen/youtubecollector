namespace Song {
    public enum YtSearchBarStates {
        ENLARGING,
        SHRINKING,
        NONE,
    }

    public class YtSearchBar : Gtk.Box {

        private Gtk.SearchEntry search_entry = new Gtk.SearchEntry ();
        private MainViewActionBar container_parent;
        private Adw.Clamp search_clamp = new Adw.Clamp();

        private int min_width = 0;
        private int? max_width;

        private YtSearchBarStates state = YtSearchBarStates.NONE;
        private bool isEnlarged = false;

        private bool isMouseInside = false;
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

            /*focus_event.enter.connect(() => {
                enlarge();
                SongController.main_view.enter_yt_search_mode();
            });

            focus_event.leave.connect(() => {
                shrink();
                SongController.main_view.exit_yt_search_mode();
            });*/
        }


        private void instanciate_signals() {
            var signal_hub = SignalHub.get_instance();
            signal_hub.mouse_clicked.connect(() => {
                if (!isMouseInside && isEnlarged) {
                    shrink();
                    SongController.main_view.exit_yt_search_mode();
                } else if (!isEnlarged && isMouseInside) {
                    enlarge();
                    SongController.main_view.enter_yt_search_mode();
                } else if (!isEnlarged && !isMouseInside && state == YtSearchBarStates.ENLARGING) {
                    requesting_state = YtSearchBarStates.SHRINKING;
                    Timeout.add(1, () => {
                        if (requesting_state != YtSearchBarStates.SHRINKING) return false;
                        if (isEnlarged) {
                            shrink();
                            SongController.main_view.exit_yt_search_mode();
                            requesting_state = null;
                            return false;
                        }
                        return true;
                    });
                } else if (isEnlarged && isMouseInside && state == YtSearchBarStates.SHRINKING) {
                    requesting_state = YtSearchBarStates.ENLARGING;
                    Timeout.add(1, () => {
                        if (requesting_state != YtSearchBarStates.ENLARGING) return false;
                        if (!isEnlarged) {
                            enlarge();
                            SongController.main_view.enter_yt_search_mode();
                            requesting_state = null;
                            return false;
                        }
                        return true;
                    });
                }
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

}