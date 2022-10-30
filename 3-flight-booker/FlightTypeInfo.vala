public class FlightTypeInfo : Object {
    public FlightType flight_type { get; set; }

    public FlightTypeInfo (FlightType flight_type) {
        Object (
            flight_type: flight_type
        );
    }
}
