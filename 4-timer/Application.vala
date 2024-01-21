public class CounterApp : Gtk.Application {
    bool is_timer_running;
    TimeSpan duration;
    TimeSpan time_elapsed;
    DateTime last_stored_time;
    Gtk.ProgressBar timer_bar;
    Gtk.Label elapsed_time_label;

    const int TIMER_UPDATE_INTERVAL = 100; // In milliseconds (ms)
    const int MAX_DURATION = 20; // In seconds

    public CounterApp () {
        Object (
            application_id: "com.github.colinkiama.timer",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var window = new Gtk.ApplicationWindow (this) {
            default_width = 400,
            title = "Timer"
        };

        var timer_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        var timer_bar_label = new Gtk.Label ("Elapsed Time:");
        timer_bar = new Gtk.ProgressBar () {
            hexpand = true,
            halign = Gtk.Align.FILL,
            valign = Gtk.Align.CENTER
        };

        timer_box.append (timer_bar_label);
        timer_box.append (timer_bar);

        elapsed_time_label = new Gtk.Label ("0.0s") {
            halign = Gtk.Align.START
        };

        var duration_label = new Gtk.Label ("Duration:") {
            valign = Gtk.Align.START
        };

        var duration_slider = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, MAX_DURATION, 1) {
            hexpand = true,
            halign = Gtk.Align.FILL,
        };

        duration_slider.set_tooltip_text ("0.0s");
        duration_slider.value_changed.connect (() => {
            duration = (TimeSpan) (duration_slider.get_value () * TimeSpan.SECOND);
            int64 seconds = duration / TimeSpan.SECOND;
            string tooltip_text = "%lld.0s".printf (seconds);
            duration_slider.set_tooltip_text (tooltip_text);
            start_timer ();
        });

        for (int i = 0; i <= MAX_DURATION; i++) {
            duration_slider.add_mark (i, Gtk.PositionType.BOTTOM, null);
        }

        var duration_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10) {
            valign = Gtk.Align.CENTER
        };

        duration_box.append (duration_label);
        duration_box.append (duration_slider);

        var reset_button = new Gtk.Button.with_label ("Reset");
        reset_button.clicked.connect (() => {
            start_timer ();
        });

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 10) {
            margin_top = 20,
            margin_bottom = 20,
            margin_start = 12,
            margin_end = 12
        };

        box.append (timer_box);
        box.append (elapsed_time_label);
        box.append (duration_box);
        box.append (reset_button);

        window.set_child (box);
        window.present ();
    }

    private void start_timer () {
        time_elapsed = 0;
        last_stored_time = new DateTime.now_utc ();
        timer_bar.fraction = 1;
        if (!is_timer_running) {
            is_timer_running = true;
            Timeout.add (TIMER_UPDATE_INTERVAL, tick);
        }
    }

    private bool tick () {
        var current_time = new DateTime.now_utc ();
        time_elapsed += current_time.difference (last_stored_time);
        int64 seconds = time_elapsed / TimeSpan.SECOND;
        int64 milliseconds = (time_elapsed - (seconds * TimeSpan.SECOND)) / TimeSpan.MILLISECOND;
        bool should_continue = time_elapsed < duration;
        last_stored_time = current_time;

        if (should_continue) {
            timer_bar.fraction = 1 - ((double) time_elapsed / (double) duration);
        } else {
            is_timer_running = false;
            seconds = duration / TimeSpan.SECOND;
            milliseconds = (duration - (seconds * TimeSpan.SECOND)) / TimeSpan.MILLISECOND;
            timer_bar.fraction = 0;
        }

        elapsed_time_label.label = "%lld.%llds".printf (seconds, milliseconds / 100);
        return should_continue;
    }
}

int main (string[] argv) {
    // Create a new application
    var app = new CounterApp ();
    return app.run (argv);
}
