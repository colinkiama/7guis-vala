public class FlightBookerApp : Gtk.Application {
    private ViewModel _view_model = new ViewModel ();
    private Gtk.ComboBox flight_type_combo_box;
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

        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        flight_type_combo_box = new Gtk.ComboBox ();
        start_date_entry = new Gtk.Entry ();
        end_date_entry = new Gtk.Entry ();
        book_button = new Gtk.Button.with_label ("Book");
        flight_type_combo_box.set_model (_view_model.flight_types);
        flight_type_combo_box.changed.connect ((combo_box) => {
            Gtk.TreeIter current_item;
            combo_box.get_active_iter (out current_item);

            Value val;
            combo_box.get_model ().get_value (current_item, 0, out val);

            _view_model.current_flight_type = (FlightType) val;
        });

        Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
        flight_type_combo_box.pack_start (renderer, true);
        flight_type_combo_box.set_cell_data_func (renderer, update_cell_layout_data);
        flight_type_combo_box.set_active (0);


        setup_bindings ();

        var vertical_stack = new Gtk.Box (Gtk.Orientation.VERTICAL, 8) {
            valign = Gtk.Align.START
        };

        vertical_stack.add (flight_type_combo_box);
        vertical_stack.add (start_date_entry);
        vertical_stack.add (end_date_entry);
        vertical_stack.add (book_button);

        main_window.add (vertical_stack);
        main_window.show_all ();
    }

    public void setup_bindings () {
        _view_model.start_date_validity_changed.connect (handle_start_date_validity_change);
        _view_model.end_date_validity_changed.connect (handle_end_date_validity_change);
        _view_model.flight_type_changed.connect (handle_flight_type_change);

        _view_model.bind_property ("start-date", start_date_entry, "text", GLib.BindingFlags.BIDIRECTIONAL);
        _view_model.bind_property ("end-date", end_date_entry, "text", GLib.BindingFlags.BIDIRECTIONAL);

        handle_flight_type_change (_view_model.current_flight_type);
    }

    public void handle_flight_type_change (FlightType next_flight_type) {
        if (current_end_date_sensitivity_binding != null) {
            current_end_date_sensitivity_binding.unbind ();
        }

        switch (next_flight_type) {
            case FlightType.ONE_WAY:
                current_end_date_sensitivity_binding = _view_model.bind_property ("current-flight-type", end_date_entry,
                    "sensitive", GLib.BindingFlags.SYNC_CREATE, flight_type_to_sensitivity_bool);
                break;
            default:
                current_end_date_sensitivity_binding = _view_model.bind_property ("is-start-date-valid", end_date_entry,
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

    public static int main (string[] args) {
        return new FlightBookerApp ().run (args);
    }
}
