class State : Object {
    private double _celsius_temp = 0;
    private double _fahrenheit_temp = 32;

    public double celsius_temp {
        set {
            if (_celsius_temp != value) {
                _celsius_temp = value;
                fahrenheit_temp = (value * 9 / 5) + 32;
            }
        }
        get {
            return _celsius_temp;
        }
    }

    public double fahrenheit_temp {
        set {
            if (_fahrenheit_temp != value) {
                _fahrenheit_temp = value;
                celsius_temp = (value - 32) / 9 * 5;
            }
        }
        get {
            return _fahrenheit_temp;
        }
    }
}

public class TempConverterApp : Gtk.Application {
    private State state = new State ();

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
            text = state.celsius_temp.to_string ()
        };

        state.bind_property ("celsius-temp", celsius_entry, "text", GLib.BindingFlags.BIDIRECTIONAL,
            double_to_string,
            string_to_double
        );

        var celsius_label = new Gtk.Label ("Celsius");

        var celsius_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4) {
            valign = Gtk.Align.START
        };

        celsius_box.append (celsius_entry);
        celsius_box.append (celsius_label);

        var farenheit_entry = new Gtk.Entry () {
            text = state.fahrenheit_temp.to_string ()
        };

        state.bind_property ("fahrenheit-temp", farenheit_entry, "text", GLib.BindingFlags.BIDIRECTIONAL,
            double_to_string,
            string_to_double
        );

        var farenheit_label = new Gtk.Label ("Fahrenheit");

        var fahrenheit_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4) {
            valign = Gtk.Align.START
        };

        fahrenheit_box.append (farenheit_entry);
        fahrenheit_box.append (farenheit_label);

        var outer_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
        outer_box.set_valign (Gtk.Align.START);
        outer_box.append (celsius_box);
        outer_box.append (new Gtk.Label ("="));
        outer_box.append (fahrenheit_box);

        main_window.child = outer_box;
        main_window.present ();
    }

    public static bool double_to_string (Binding binding, Value src_val, ref Value target_val) {
        double starting_val = (double) src_val;
        target_val = starting_val.to_string ();
        return true;
    }

    public static bool string_to_double (Binding binding, Value src_val, ref Value target_val) {
        string starting_val = (string) src_val;
        return double.try_parse (starting_val, out target_val);
    }

    public static int main (string[] args) {
        return new TempConverterApp ().run (args);
    }
}
