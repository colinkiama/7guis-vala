public class FlightBookerApp : Gtk.Application {
    private ViewModel _view_model = new ViewModel ();

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

        var flight_type_combo_box = new Gtk.ComboBox ();
        flight_type_combo_box.set_model (_view_model.flight_types);

        Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
        flight_type_combo_box.pack_start (renderer, true);
        // flight_type_combo_box.add_attribute (renderer, "text", 0);
        flight_type_combo_box.set_cell_data_func (renderer, update_cell_layout_data);
        flight_type_combo_box.changed.connect (combo_box_changed);

        var vertical_stack = new Gtk.Box (Gtk.Orientation.VERTICAL, 4) {
            valign = Gtk.Align.START
        };

        vertical_stack.add (flight_type_combo_box);

        main_window.add (vertical_stack);
        main_window.show_all ();
    }

    public void update_cell_layout_data (
        Gtk.CellLayout cell_layout,
        Gtk.CellRenderer cell,
        Gtk.TreeModel tree_model,
        Gtk.TreeIter iter) {
        Value val;
        tree_model.get_value (iter, 0, out val);

        FlightType selected_flight_type = (FlightType) val;
        string flight_text = "";
        switch (selected_flight_type) {
            case FlightType.ONE_WAY:
                flight_text = "one-way flight";
                break;
            case FlightType.RETURN:
                flight_text = "return flight";
                break;
        }

        var text_cell = (Gtk.CellRendererText)cell;
        text_cell.text = flight_text;
    }

    public void combo_box_changed (Gtk.ComboBox combo_box) {
        Gtk.TreeIter iter;
        Value val;

        combo_box.get_active_iter (out iter);
        _view_model.flight_types.get_value (iter, 0, out val);

        var selected_flight_type = (FlightType) val;

        print ("Selection is: %s", selected_flight_type.to_string ());

    }

    public static int main (string[] args) {
        return new FlightBookerApp ().run (args);
    }
}
