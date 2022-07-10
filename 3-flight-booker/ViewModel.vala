public class ViewModel : Object {
    private bool _is_start_date_valid = true;
    private bool _is_end_date_valid = true;
    private string _start_date = "";
    private string _end_date = "";

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
                print ("New Start Date value: %s\n", value);
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
}
