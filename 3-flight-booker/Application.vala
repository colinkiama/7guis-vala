public class FlightBookerApp : Gtk.Application {
    const string[] FLIGHT_TYPES = { "one-way flight", "return flight" };

    string current_flight_type = "one-way flight";
    Regex valid_date_regex = /^(\d{2})\.(\d{2})\.(\d{4})$/;
    DateTime? departure_date = null;
    DateTime? return_date = null;

    Gtk.DropDown flight_type_drop_down;
    Gtk.Entry departure_date_entry;
    Gtk.Entry return_date_entry;
    Gtk.Button book_button;

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
        book_button.clicked.connect (() => {
            string message;
            if (current_flight_type == "one-way flight") {
                message = @"You have booked a one-way flight on $(departure_date_entry.text).";
            } else {
                message = @"You have booked a round-trip flight departing on $(departure_date_entry.text) "
                          + @"and returning on $(return_date_entry.text).";
            }

            var dialog = new Gtk.MessageDialog (
                main_window,
                Gtk.DialogFlags.DESTROY_WITH_PARENT | Gtk.DialogFlags.MODAL,
                Gtk.MessageType.INFO,
                Gtk.ButtonsType.OK,
                message
            );

            dialog.response.connect ((response_id) => dialog.close ());
            dialog.show ();
        });

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

    private void update_form_state () {
        bool is_departure_regex_valid = valid_date_regex.match (departure_date_entry.text);
        bool is_return_regex_valid = valid_date_regex.match (return_date_entry.text);

        departure_date = is_departure_regex_valid ? parse_date (departure_date_entry.text) : null;
        return_date = is_return_regex_valid ? parse_date (return_date_entry.text) : null;

        update_departure_field (departure_date != null);
        update_return_field (return_date != null);
        update_book_button ();
    }

    private void update_book_button () {
         if (current_flight_type == "one-way flight") {
            book_button.sensitive = departure_date != null;
        } else {
            if (departure_date != null && return_date != null) {
                TimeSpan difference = return_date.difference (departure_date);
                book_button.sensitive = difference >= 0;
            } else {
                book_button.sensitive = false;
            }
        }
    }

    private void update_departure_field (bool is_departure_date_valid) {
        if (departure_date_entry.text == "" || is_departure_date_valid) {
            departure_date_entry.remove_css_class ("invalid");
        } else {
            departure_date_entry.add_css_class ("invalid");
        }
    }

    private void update_return_field (bool is_return_date_valid) {
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
    }

    private DateTime parse_date (string str) {
        string[] date_vals = str.split (".");
        int day = int.parse (date_vals[0]);
        int month = int.parse (date_vals[1]);
        int year = int.parse (date_vals[2]);

        return new DateTime.local (year, month, day, 0, 0, 0);
    }

    public static int main (string[] args) {
        return new FlightBookerApp ().run (args);
    }

}
