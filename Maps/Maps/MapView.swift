//
//  MapView.swift
//
//  Created by Jakub Jelinek on 21/02/2023.
//
import MapKit
import SwiftUI
import CoreLocationUI

struct MapView: View {
    @StateObject var locationManager = LocationManager()
    @State var errorMessage: String = ""
    @State private var searchQuery: String = ""
    @State private var isSearching: Bool = false
    @State private var isEditing = false
    @State var searchedResults: Array<MKMapItem> = []
    @State var selectedResult: MKMapItem = MKMapItem()
    @State var regionDefault : MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.83834587046632, longitude: 14.254053016537693), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State var direction: Direction = Direction()
    @State var directionsOn : Bool = false
    
    var body: some View {
        ZStack(alignment: .topLeading){
            Map(errorMessage: $errorMessage, searchedResults: $searchedResults, selectedResult: $selectedResult, regionDefault: $regionDefault, directionsOn: $directionsOn, direction: $direction)
                .onAppear(perform: locationManager.requestLocation)
                .edgesIgnoringSafeArea(.all)
            if !directionsOn{
                HStack{
                    TextField("Search...", text: $searchQuery, onEditingChanged: {_ in})
                        .padding(7)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(7)
                        .shadow(radius: 3, x: 0, y: 2)
                    Button(action: searchButtonTapped) {
                        Image(systemName: "magnifyingglass")
                            .padding(.trailing, isEditing ? 2 : 10)
                    }.disabled(searchQuery == "" ? true : false)
                        .foregroundColor(.blue)
                }
                .cornerRadius(8)
                .padding(4)
                LocationButton {
                    locationButtonTapped()
                }
                .labelStyle(.iconOnly)
                .foregroundColor(.white)
                .cornerRadius(50)
                .padding(.top, 70)
                .padding(.trailing, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            ScrollView(.horizontal){
                HStack {
                    if !searchedResults.isEmpty {
                        ForEach(searchedResults, id: \.self) { result in
                            VStack(alignment: .leading){
                                Text(result.placemark.name ?? "Unknown location")
                                    .font(.headline)
                                    .padding()
                                Text(result.placemark.title ?? "Unknown location")
                                    .font(.footnote)
                                    .padding(.horizontal)
                                HStack{
                                    Button("Select") {
                                        selectLocation(result: result)
                                    }
                                    .fixedSize(horizontal: true, vertical: false)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                        .disabled(directionsOn ? true : false)
                                    Spacer()
                                    Button(action: {
                                        directions(result: result)
                                    }){
                                        Image(systemName: directionsOn ? "eraser.line.dashed" : "road.lanes")
                                    }.frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                }.padding()
                            }.frame(maxWidth: 300, minHeight: 200)
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                                .padding()
                        }
                    }
                }.padding()
                    .shadow(radius: 10, x: 0, y: 5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            if isSearching {
                ProgressView()
            }
            
        }
        .alert(isPresented: $isSearching) {
            Alert(
                title: Text("Loading..."),
                message: nil,
                dismissButton: .cancel(Text("Cancel")
                )
            )
        }
    }
    func removeResults(){
        searchedResults.removeAll()
    }
    
    func directions(result: MKMapItem){
        directionsOn = !directionsOn
        if directionsOn{
            isSearching = true
            direction.sourceLocation = regionDefault.center
            direction.finalDestination = selectedResult.placemark.coordinate
        }
        isSearching = false
    }
    
    func locationButtonTapped(){
        selectedResult = MKMapItem()
        searchedResults.removeAll()
        if let location = locationManager.location {
            regionDefault = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            let usersLocation = MKMapItem(placemark: MKPlacemark(coordinate: location))
            selectedResult =  usersLocation
        }
    }
    
    func selectLocation(result : MKMapItem){
        selectedResult = result
    }
    func searchButtonTapped() {
        isSearching = true
        
        searchedResults.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            self.isSearching = false
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let response = response else {
                print("No response")
                return
            }
            
            for mapItem in response.mapItems {
                searchedResults.append(mapItem)
            }
            print(searchedResults)
            
            if searchedResults.count > 0{
                selectedResult = searchedResults[0]
            }
        }
    }
    
}
