public class CounterApp : Gtk.Application {
    public CounterApp () {
        Object (
            application_id: "com.github.colinkiama.seven-guis",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this) {
            default_height = 300,
            default_width = 300,
            title = "Counter"
        };

        var label = new Gtk.Label ("0");

        var count_button = new Gtk.Button () {
            label = "Count"
        };

        int count = 0;

        count_button.clicked.connect ((e) => {
            count++;
            label.label = count.to_string ();
        });

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        box.add (label);
        box.add (count_button);
        box.set_valign (Gtk.Align.START);

        main_window.add (box);
        main_window.show_all ();
    }

    public static int main (string[] args) {
        return new CounterApp ().run (args);
    }
}
