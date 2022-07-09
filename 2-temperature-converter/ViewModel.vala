public class ViewModel : Object {
    private double _celsius_temp = 0;
    private double _fahrenheit_temp = 32;

    public double celsius_temp {
        set {
            if (_celsius_temp != value) {
                _celsius_temp = value;
                fahrenheit_temp = (value * 9 / 5) + 32;
            }
        }
        get {
            return _celsius_temp;
        }
    }

    public double fahrenheit_temp {
        set {
            if (_fahrenheit_temp != value) {
                _fahrenheit_temp = value;
                celsius_temp = (value - 32) / 9 * 5;
            }
        }
        get {
            return _fahrenheit_temp;
        }
    }
}
