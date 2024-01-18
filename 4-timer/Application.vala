using Gtk;

public class CounterApp : Gtk.Application {
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

        var elapsed_time_label = new Gtk.Label ("0.0s") {
            halign = Gtk.Align.START
        };

        var duration_label = new Gtk.Label ("Duration:");
        var duration_slider = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 30, 0.1) {
            hexpand = true,
            halign = Gtk.Align.FILL,
            valign = Gtk.Align.CENTER
        };

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

}

int main (string[] argv) {
    // Create a new application
    var app = new CounterApp ();
    return app.run (argv);
}
