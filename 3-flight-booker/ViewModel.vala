public class ViewModel : Object {
    private bool _is_start_date_valid = true;
    private bool _is_end_date_valid = true;
    private string _start_date = "";
    private string _end_date = "";

    // Source: https://stackoverflow.com/a/15504877/7149232
    private Regex _valid_date_regex = /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/; // vala-lint=space-before-paren, line-length, block-opening-brace-space-before

    public Gtk.ListStore flight_types { get; set; }
    public FlightType current_flight_type { get; set; }
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

    construct {
        flight_types = new Gtk.ListStore (1, typeof (FlightType));
        Gtk.TreeIter iter;
        flight_types.append (out iter);
        flight_types.set (iter, 0, FlightType.ONE_WAY, -1);
        flight_types.append (out iter);
        flight_types.set (iter, 0, FlightType.RETURN, -1);
    }

    public bool check_valid_date_constraints (string str) {
        return _valid_date_regex.match (str);
    }
}
