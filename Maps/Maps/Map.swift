//
//  Map.swift
//
//  Created by Jakub Jelinek on 21/02/2023.
//

import SwiftUI
import MapKit
/// So i can communicate between views, i have to use Representable-Controller/Coordinator
struct Map: UIViewRepresentable {
    @Binding var errorMessage: String
    @Binding var searchedResults: Array<MKMapItem>
    @Binding var selectedResult: MKMapItem
    @Binding var regionDefault : MKCoordinateRegion
//    @Binding var sourceLocation: CLLocationCoordinate2D
//    @Binding var destinationLocation: CLLocationCoordinate2D
    @Binding var directionsOn: Bool
    @Binding var direction: Direction
    
    /// Creates the view object and configures its initial state.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    /// Updates the state of the specified view with new information from SwiftUI.
    func updateUIView(_ mapView: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        mapView.removeAnnotations(mapView.annotations)
        if !searchedResults.isEmpty{
            if selectedResult !== MKMapItem(){
                let region = MKCoordinateRegion(center: selectedResult.placemark.coordinate, span: span)
                let customAnnotation = CustomAnnotation(
                    title: selectedResult.placemark.name,
                    locationName: selectedResult.placemark.title,
                    coordinate: selectedResult.placemark.coordinate)
                mapView.addAnnotation(customAnnotation)
                mapView.setRegion(region, animated: true)
            }else{
                searchedResults.forEach{
                    result in
                    let region = MKCoordinateRegion(center: result.placemark.coordinate, span: span)
                    let customAnnotation = CustomAnnotation(
                        title: result.placemark.name,
                        locationName: result.placemark.title,
                        coordinate: result.placemark.coordinate)
                    mapView.addAnnotation(customAnnotation)
                    mapView.setRegion(region, animated: true)
                }
            }
        }else{
            let customAnnotation = CustomAnnotation(
                title: "",
                locationName: "",
                coordinate: regionDefault.center)
            mapView.addAnnotation(customAnnotation)
            mapView.setRegion(regionDefault, animated: true)
        }
        if directionsOn{
            mapView.removeOverlays(mapView.overlays)
            let sourceMapItem = MKMapItem(placemark: MKPlacemark(coordinate: direction.sourceLocation!))
            let destinationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: direction.finalDestination!))
            
            let customAnnotation = CustomAnnotation(
                title: "",
                locationName: "",
                coordinate: regionDefault.center)
            mapView.addAnnotation(customAnnotation)
            let directionRequest = MKDirections.Request()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate { response, error in
                guard let response = response else { return }
                let route = response.routes[0]
                mapView.addOverlay(route.polyline, level: .aboveRoads)
            }
            
            let region = MKCoordinateRegion(center: direction.sourceLocation!, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            mapView.setRegion(region, animated: true)
        }
        else{
            mapView.removeOverlays(mapView.overlays)
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "location")
            annotationView.markerTintColor = .green
            annotationView.glyphImage = UIImage(systemName: "flag.checkered.circle")
            return annotationView
        }
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5.0
            return renderer
        }
    }
}

class Direction{
    var sourceLocation: CLLocationCoordinate2D?
    var finalDestination: CLLocationCoordinate2D?
    
    init(){
            // Empty implementation
        }
    
    init(sourceLocation: CLLocationCoordinate2D, finalDestination: CLLocationCoordinate2D) {
        self.sourceLocation = sourceLocation
        self.finalDestination = finalDestination
    }
}


