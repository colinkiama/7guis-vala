public class FlightBookerApp : Gtk.Application {
    // Source: https://stackoverflow.com/a/15504877/7149232
    private Regex valid_date_regex = /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/; // vala-lint=space-before-paren, line-length, block-opening-brace-space-before

    const string[] FLIGHT_TYPES = { "one-way flight", "return flight" };
    string current_flight_type = "one-way flight";

    private Gtk.DropDown flight_type_drop_down;
    private Gtk.Entry start_date_entry;
    private Gtk.Entry end_date_entry;
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

        start_date_entry = new Gtk.Entry ();
        end_date_entry = new Gtk.Entry ();
        book_button = new Gtk.Button.with_label ("Book");

        var vertical_stack = new Gtk.Box (Gtk.Orientation.VERTICAL, 8) {
            valign = Gtk.Align.START
        };

        vertical_stack.append (flight_type_drop_down);
        vertical_stack.append (start_date_entry);
        vertical_stack.append (end_date_entry);
        vertical_stack.append (book_button);

        main_window.set_child (vertical_stack);
        main_window.present ();

        start_date_entry.changed.connect (update_form_state);
        end_date_entry.changed.connect (update_form_state);

        update_form_state ();
    }

    public void update_form_state () {
        bool is_start_date_valid = valid_date_regex.match (start_date_entry.text);
        bool is_end_date_valid = valid_date_regex.match (end_date_entry.text);
        bool is_start_date_empty = start_date_entry.text == "";
        bool is_end_date_empty = end_date_entry.text == "";

        if (current_flight_type == "one-way flight") {
            end_date_entry.sensitive = false;
            end_date_entry.remove_css_class ("invalid");
            book_button.sensitive = is_start_date_valid && !is_start_date_empty;
        } else {
            end_date_entry.sensitive = true;
            book_button.sensitive = is_start_date_valid && !is_start_date_empty && is_end_date_valid
                && !is_end_date_empty;
        }

        if (is_start_date_empty || is_start_date_valid) {
            start_date_entry.remove_css_class ("invalid");
        } else {
            start_date_entry.add_css_class ("invalid");
        }

        if (current_flight_type == "return flight" && !is_end_date_valid && !is_end_date_empty) {
            end_date_entry.add_css_class ("invalid");
        } else {
            end_date_entry.remove_css_class ("invalid");
        }

    }

    public static int main (string[] args) {
        return new FlightBookerApp ().run (args);
    }
}
