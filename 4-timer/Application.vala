public class CounterApp : Gtk.Application {
    public bool is_timer_running { get; private set; }
    public TimeSpan duration;
    public TimeSpan time_elapsed { get; private set; }

    private DateTime last_stored_time;
    private Gtk.ProgressBar timer_bar;
    private Gtk.Label elapsed_time_label;

    // In milliseconds (ms)
    const int TIMER_UPDATE_INTERVAL = 100;

    public CounterApp () {
        Object (
            application_id: "com.github.colinkiama.timer",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var window = new Gtk.ApplicationWindow (this) {
            default_width = 300,
            title = "Timer"
        };

        var timer_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        var timer_bar_label = new Gtk.Label ("Elapsed Time:");
        var timer_bar = new Gtk.ProgressBar () {
            hexpand = true,
            halign = Gtk.Align.FILL,
            valign = Gtk.Align.CENTER
        };

        timer_box.append (timer_bar_label);
        timer_box.append (timer_bar);

        elapsed_time_label = new Gtk.Label ("0.0s") {
            halign = Gtk.Align.START
        };

        var duration_label = new Gtk.Label ("Duration:");
        var duration_slider = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 30, 1) {
            hexpand = true,
            halign = Gtk.Align.FILL,
            valign = Gtk.Align.CENTER
        };

        duration_slider.value_changed.connect (() => {
           duration = (TimeSpan) (duration_slider.get_value () * TimeSpan.SECOND);
           start_timer ();
        });

        var duration_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10) {
            valign = Gtk.Align.CENTER
        };

        duration_box.append (duration_label);
        duration_box.append (duration_slider);

        var reset_button = new Gtk.Button.with_label ("Reset");

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
        bool should_continue = time_elapsed <= duration;

        last_stored_time = current_time;
        print ("Time elapsed in seconds: %llu.%03llu\n", seconds, milliseconds);

        if (should_continue) {
            elapsed_time_label.label = "%llu.%llus".printf (seconds, milliseconds / 100);
        } else {
            is_timer_running = false;
            elapsed_time_label.label = "%llus".printf (seconds);
        }

        return should_continue;
    }
}

int main (string[] argv) {
    // Create a new application
    var app = new CounterApp ();
    return app.run (argv);
}
