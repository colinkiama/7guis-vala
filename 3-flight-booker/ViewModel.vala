public class ViewModel : Object {
    public Gtk.ListStore flight_types { get; set; }

    construct {
        flight_types = new Gtk.ListStore (1, typeof (FlightType));
        Gtk.TreeIter iter;
        flight_types.append (out iter);
        flight_types.set (iter, 0, FlightType.ONE_WAY, -1);
        flight_types.append (out iter);
        flight_types.set (iter, 0, FlightType.RETURN, -1);
    }
}
