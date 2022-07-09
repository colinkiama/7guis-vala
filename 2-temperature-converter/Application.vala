public class TempConverterApp : Gtk.Application {
    public TempConverterApp () {
        Object (
            application_id: "com.github.colinkiama.temp-conv",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this) {
            default_height = 300,
            default_width = 300,
            title = "TempConv"
        };


        var celsius_entry = new Gtk.Entry () {
            text = "0"
        };

        var celsius_label = new Gtk.Label ("Celsius");

        var celsius_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4) {
            valign = Gtk.Align.START
        };

        celsius_box.add (celsius_entry);
        celsius_box.add (celsius_label);

        var farenheit_entry = new Gtk.Entry () {
            text = "32"
        };

        var farenheit_label = new Gtk.Label ("Fahrenheit");

        var fahrenheit_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4) {
            valign = Gtk.Align.START
        };

        fahrenheit_box.add (farenheit_entry);
        fahrenheit_box.add (farenheit_label);

        var outer_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
        outer_box.set_valign (Gtk.Align.START);
        outer_box.add (celsius_box);
        outer_box.add (new Gtk.Label ("="));
        outer_box.add (fahrenheit_box);

        main_window.add (outer_box);
        main_window.show_all ();
    }

    public static int main (string[] args) {
        return new TempConverterApp ().run (args);
    }
}
