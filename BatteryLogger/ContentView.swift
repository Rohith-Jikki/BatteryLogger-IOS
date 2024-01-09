//
//  ContentView.swift
//  BatteryLogger
//
//  Created by ALTRAI TECH on 09/01/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var ipInput:String = ""
    @State private var device:Device?
    @State private var success:Bool = false
    
    var body: some View {
        VStack {
            TextField("Enter Ip Address", text: $ipInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Start", action: {
                startFetchingData()
            }).padding()
            Button("Stop", action: {})
        }
        .padding()
        }
    
    func startFetchingData(){
        Task{
            do{
                device = try await getUser(ipAddress: ipInput)
                success = true
            }
            catch{
                device = nil
                success = false
                print("Error fetching data")
            }
        }
    }
    
    func getUser(ipAddress:String) async throws -> Device{
        let endpoint = "http://\(ipAddress)/P"
        
        guard let url = URL(string: endpoint) else{
            throw DError.invalidURL
        }
        
        let(data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw DError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Device.self, from: data)
        }catch{
            throw DError.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
