public class ViewModel : Object {
    public Gtk.ListStore flight_types { get; set; }
    public FlightType current_flight_type { get; set; }
    public bool is_start_date_valid { get; set; }
    public bool is_end_date_valid { get; set; }

    construct {
        flight_types = new Gtk.ListStore (1, typeof (FlightType));
        Gtk.TreeIter iter;
        flight_types.append (out iter);
        flight_types.set (iter, 0, FlightType.ONE_WAY, -1);
        flight_types.append (out iter);
        flight_types.set (iter, 0, FlightType.RETURN, -1);
    }
}
