public class FlightBookerApp : Gtk.Application {
    private Regex valid_date_regex = /^(\d{2})\.(\d{2})\.(\d{4})$/; // vala-lint=space-before-paren, line-length, block-opening-brace-space-before

    const string[] FLIGHT_TYPES = { "one-way flight", "return flight" };
    string current_flight_type = "one-way flight";

    private Gtk.DropDown flight_type_drop_down;
    private Gtk.Entry departure_date_entry;
    private Gtk.Entry return_date_entry;
    private Gtk.Button book_button;

    public FlightBookerApp () {
        Object (
            application_id: "com.github.colinkiama.flight-booker",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this) {
            default_height = 300,
            default_width = 300,
            title = "Book Flight"
        };

         Gtk.CssProvider css_provider = new Gtk.CssProvider ();
         css_provider.load_from_resource ("com/github/colinkiama/flight-booker/app.css");

         Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        flight_type_drop_down = new Gtk.DropDown.from_strings (FLIGHT_TYPES);

        flight_type_drop_down.notify["selected-item"].connect ((param_spec, item) => {
            current_flight_type = (string) FLIGHT_TYPES[flight_type_drop_down.selected];
            update_form_state ();
        });

        departure_date_entry = new Gtk.Entry ();
        return_date_entry = new Gtk.Entry ();
        book_button = new Gtk.Button.with_label ("Book");

        var vertical_stack = new Gtk.Box (Gtk.Orientation.VERTICAL, 8) {
            valign = Gtk.Align.START
        };

        vertical_stack.append (flight_type_drop_down);
        vertical_stack.append (departure_date_entry);
        vertical_stack.append (return_date_entry);
        vertical_stack.append (book_button);

        main_window.set_child (vertical_stack);
        main_window.present ();

        departure_date_entry.changed.connect (update_form_state);
        return_date_entry.changed.connect (update_form_state);

        update_form_state ();
    }

    public void update_form_state () {
        bool is_departure_regex_valid = valid_date_regex.match (departure_date_entry.text);
        bool is_return_regex_valid = valid_date_regex.match (return_date_entry.text);

        DateTime departure_date = is_departure_regex_valid ? parse_date (departure_date_entry.text) : null;
        DateTime return_date = is_return_regex_valid ? parse_date (return_date_entry.text) : null;

        bool is_departure_date_valid = departure_date != null;
        bool is_return_date_valid = return_date != null;


        if (departure_date_entry.text == "" || is_departure_date_valid) {
            departure_date_entry.remove_css_class ("invalid");
        } else {
            departure_date_entry.add_css_class ("invalid");
        }

        if (current_flight_type == "one-way flight") {
            return_date_entry.sensitive = false;
            return_date_entry.remove_css_class ("invalid");
        } else {
            if (return_date_entry.text == "" || is_return_date_valid) {
                return_date_entry.remove_css_class ("invalid");
            } else {
                return_date_entry.add_css_class ("invalid");
            }

            return_date_entry.sensitive = true;
        }

        if (current_flight_type == "return flight") {
            if (is_departure_date_valid && is_return_date_valid) {
                TimeSpan difference = return_date.difference (departure_date);
                book_button.sensitive = difference >= 0;
            } else {
                book_button.sensitive = false;
            }
        } else {
            book_button.sensitive = is_departure_date_valid;
        }
    }

    public static int main (string[] args) {
        return new FlightBookerApp ().run (args);
    }

    public DateTime parse_date (string str) {
        string[] date_vals = str.split (".");
        int day = int.parse (date_vals[0]);
        int month = int.parse (date_vals[1]);
        int year = int.parse (date_vals[2]);

        return new DateTime.local (year, month, day, 0, 0, 0);
    }
}
