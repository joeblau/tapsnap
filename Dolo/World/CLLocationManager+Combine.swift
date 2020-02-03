import Combine
import CoreLocation

final class CombineLocationManager: CLLocationManager, CLLocationManagerDelegate {
    static let shared = CombineLocationManager()
    
    override init() {
        super.init()
        delegate = self
    }
    
    var _didChangeAuthorization = PassthroughSubject<CLAuthorizationStatus, Never>()
    var _didUpdateLocations = PassthroughSubject<[CLLocation], Error>()
    var _didEnterRegion = PassthroughSubject<CLRegion, Error>()
    var _didExitRegion = PassthroughSubject<CLRegion, Error>()
    var _didStartMonitoringFor = PassthroughSubject<CLRegion, Never>()
    var _didVisit =  PassthroughSubject<CLVisit, Error>()
    var _didUpdateHeading =  PassthroughSubject<CLHeading, Error>()

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        _didChangeAuthorization.send(status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _didUpdateLocations.send(locations)
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        _didEnterRegion.send(region)
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        _didExitRegion.send(region)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _didUpdateLocations.send(completion: .failure(error))
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
         _didStartMonitoringFor.send(region)
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        _didEnterRegion.send(completion: .failure(error))
        _didExitRegion.send(completion: .failure(error))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        _didVisit.send(visit)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        _didUpdateHeading.send(newHeading)
    }
}

extension CLLocationManager {
    
    var didChangeAuthorization: AnyPublisher<CLAuthorizationStatus, Never> {
        CombineLocationManager.shared._didChangeAuthorization.eraseToAnyPublisher()
    }

    var didUpdateLocations: AnyPublisher<[CLLocation], Error> {
        CombineLocationManager.shared._didUpdateLocations.eraseToAnyPublisher()
    }
    
    var didEnterRegion: AnyPublisher<CLRegion, Error> {
        CombineLocationManager.shared._didEnterRegion.eraseToAnyPublisher()
    }

    var didExitRegion: AnyPublisher<CLRegion, Error> {
        CombineLocationManager.shared._didExitRegion.eraseToAnyPublisher()
    }

}
