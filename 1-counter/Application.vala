public class CounterApp : Gtk.Application {
    public CounterApp () {
        Object (
            application_id: "com.github.colinkiama.guis-vala",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this) {
            default_height = 300,
            default_width = 300,
            title = "Counter"
        };

        main_window.show_all ();
    }

    public static int main (string[] args) {
        return new CounterApp ().run (args);
    }
}
