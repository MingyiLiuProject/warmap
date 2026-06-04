import CoreLocation

enum LocationPrivacy {
    static func blurredCoordinate(
        latitude: Double,
        longitude: Double,
        precision: Double = 0.01
    ) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: (latitude / precision).rounded() * precision,
            longitude: (longitude / precision).rounded() * precision
        )
    }
}

