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

        private Adw.TimedAnimation? enlarge_animation = null;
        private Adw.TimedAnimation? shrink_animation = null;
        private Adw.AnimationTarget size_animation_target;

        construct {
            var gesture = new Gtk.GestureClick();
            add_controller(gesture);

            add_css_class ("toolbar");
            hexpand = true;

            search_entry.hexpand = true;

            search_clamp.set_child(search_entry);
            append(search_clamp);

            min_width = search_clamp.get_maximum_size ();
            max_width = min_width + 200;

            size_animation_target = new Adw.PropertyAnimationTarget(search_clamp, "maximum_size");

            instanciate_signals();

            
        }

        private void instanciate_signals() {
            search_entry.changed.connect((e) => {
                if (e.get_text() != null && state == YtSearchBarStates.NONE) {
                    if (e.get_text() != "" && !isEnlarged) {
                        enlarge();
                    } else if (e.get_text() == "" && isEnlarged) {
                        shrink();
                    }
                }
            });
            
        }

        private void enlarge() {
            if (enlarge_animation == null) {
                enlarge_animation = new Adw.TimedAnimation(search_clamp, min_width, max_width, 500, size_animation_target);
                enlarge_animation.done.connect(() => {
                    isEnlarged = true;
                    state = YtSearchBarStates.NONE;
                    print(state.to_string() + "\n");
                    print(isEnlarged.to_string() + "\n");
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
                    print(state.to_string() + "\n");
                    print(isEnlarged.to_string() + "\n");
                });
            }

            shrink_animation.play();
            state = YtSearchBarStates.SHRINKING;
        }
    }
}