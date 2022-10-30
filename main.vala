using Gtk;

public class CounterApp : Gtk.Application {
    public CounterApp () {
        Object (
            application_id: "com.github.colinkiama.counter",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var window = new Gtk.ApplicationWindow (this);

        var label = new Gtk.Label ("0");
        var count_button = new Gtk.Button () {
            label = "Count"
        };

        int count = 0;
        count_button.clicked.connect ((e) => {
            count++;
            label.label = count.to_string ();
        });

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10) {
            valign = Gtk.Align.START
        };

        box.append (label);
        box.append (count_button);
        
        window.set_child (box);
        window.present ();
    }
    
}

int main (string[] argv) {
    // Create a new application
    var app = new CounterApp ();
    return app.run (argv);
}