class State : Object {
    private bool _is_start_date_valid = true;
    private bool _is_end_date_valid = true;
    private string _start_date = "";
    private string _end_date = "";

    // Source: https://stackoverflow.com/a/15504877/7149232
    private Regex _valid_date_regex = /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/; // vala-lint=space-before-paren, line-length, block-opening-brace-space-before

    private FlightType _current_flight_type;
    public FlightType current_flight_type {
        get {
            return _current_flight_type;
        }
        set {
            if (_current_flight_type != value) {
                _current_flight_type = value;
                flight_type_changed (value);
            }
        }
    }

    public GLib.ListStore flight_types { get; set; }
    public bool is_start_date_valid {
        get {
            return _is_start_date_valid;
        }

        set {
            if (_is_start_date_valid != value) {
                _is_start_date_valid = value;
                start_date_validity_changed (value);
            }
        }
    }

    public bool is_end_date_valid {
        get {
            return _is_end_date_valid;
        }

        set {
            if (_is_end_date_valid != value) {
                _is_end_date_valid = value;
                end_date_validity_changed (value);
            }
        }
    }

    public string start_date {
        set {
            if (_start_date != value) {
                _start_date = value;
                is_start_date_valid = check_valid_date_constraints (value);
            }
        }
        get {
            return _start_date;
        }
    }

    public string end_date {
        set {
            if (_end_date != value) {
                _end_date = value;
                is_end_date_valid = check_valid_date_constraints (value);
            }
        }
        get {
            return _end_date;
        }
    }

    public signal void start_date_validity_changed (bool is_valid);
    public signal void end_date_validity_changed (bool is_valid);
    public signal void flight_type_changed (FlightType next_flight_type);

    construct {
        flight_types = new GLib.ListStore (typeof (FlightTypeInfo));
        flight_types.append (new FlightTypeInfo (FlightType.ONE_WAY));
        flight_types.append (new FlightTypeInfo (FlightType.RETURN));
    }

    public bool check_valid_date_constraints (string str) {
        return _valid_date_regex.match (str);
    }
}

public class FlightTypeInfo : Object {
    public FlightType flight_type { get; set; }

    public FlightTypeInfo (FlightType flight_type) {
        Object (
            flight_type: flight_type
        );
    }
}

public enum FlightType {
    ONE_WAY,
    RETURN;
}

public class FlightBookerApp : Gtk.Application {
    public static string get_flight_label (FlightTypeInfo info) {
        FlightType flight_type = info.flight_type;
        switch (flight_type) {
            case FlightType.ONE_WAY:
                return "one-way flight";
            case FlightType.RETURN:
                return "return flight";
            default:
                return "";
        }
    }

    private State state = new State ();
    private Gtk.DropDown flight_type_drop_down;
    private Gtk.Entry start_date_entry;
    private Gtk.Entry end_date_entry;
    private Gtk.Button book_button;
    private Binding current_end_date_sensitivity_binding;

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

        flight_type_drop_down = new Gtk.DropDown (
            state.flight_types,
            new Gtk.CClosureExpression (typeof (string), null, {}, (Callback) FlightBookerApp.get_flight_label, null, null)
        );

        flight_type_drop_down.notify["selected-item"].connect ((param_spec, item) => {
            FlightTypeInfo info = (FlightTypeInfo) state.flight_types.get_item (flight_type_drop_down.selected);
            state.current_flight_type = info.flight_type;
        });

        start_date_entry = new Gtk.Entry ();
        end_date_entry = new Gtk.Entry ();
        book_button = new Gtk.Button.with_label ("Book");

        setup_bindings ();

        var vertical_stack = new Gtk.Box (Gtk.Orientation.VERTICAL, 8) {
            valign = Gtk.Align.START
        };

        vertical_stack.append (flight_type_drop_down);
        vertical_stack.append (start_date_entry);
        vertical_stack.append (end_date_entry);
        vertical_stack.append (book_button);

        main_window.set_child (vertical_stack);
        main_window.present ();
    }

    public void setup_bindings () {
        state.start_date_validity_changed.connect (handle_start_date_validity_change);
        state.end_date_validity_changed.connect (handle_end_date_validity_change);
        state.flight_type_changed.connect (handle_flight_type_change);

        state.bind_property ("start-date", start_date_entry, "text", GLib.BindingFlags.BIDIRECTIONAL);
        state.bind_property ("end-date", end_date_entry, "text", GLib.BindingFlags.BIDIRECTIONAL);

        handle_flight_type_change (state.current_flight_type);
    }

    public void handle_flight_type_change (FlightType next_flight_type) {
        if (current_end_date_sensitivity_binding != null) {
            current_end_date_sensitivity_binding.unbind ();
        }

        switch (next_flight_type) {
            case FlightType.ONE_WAY:
                current_end_date_sensitivity_binding = state.bind_property ("current-flight-type", end_date_entry,
                    "sensitive", GLib.BindingFlags.SYNC_CREATE, flight_type_to_sensitivity_bool);
                break;
            default:
                current_end_date_sensitivity_binding = state.bind_property ("is-start-date-valid", end_date_entry,
                    "sensitive", GLib.BindingFlags.SYNC_CREATE);
                break;
        }
    }

    public bool flight_type_to_sensitivity_bool (GLib.Binding binding, GLib.Value src_val, ref Value target_val) {
        var flight_type = (FlightType)src_val;

        switch (flight_type) {
                case FlightType.ONE_WAY:
                    target_val = false;
                    break;
                default:
                    target_val = true;
                    break;
        }

        return true;
    }

    public void handle_start_date_validity_change (bool is_valid) {
        if (is_valid) {
            start_date_entry.get_style_context ().remove_class ("invalid");
            return;
        }

        start_date_entry.get_style_context ().add_class ("invalid");
    }

    public void handle_end_date_validity_change (bool is_valid) {
        if (is_valid) {
            end_date_entry.get_style_context ().remove_class ("invalid");
            return;
        }

        end_date_entry.get_style_context ().add_class ("invalid");
    }

    public static int main (string[] args) {
        return new FlightBookerApp ().run (args);
    }
}
