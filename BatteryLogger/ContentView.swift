//
//  ContentView.swift
//  BatteryLogger
//
//  Created by ALTRAI TECH on 09/01/24.
//

import SwiftUI
class BatteryViewModel: ObservableObject{
    @Published var batteryLevel: Int = 0
    @Published var batteryStateDescription: String = ""
    
    init(){
        UIDevice.current.isBatteryMonitoringEnabled = true
        self.batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        setBatteryState()
    }
    
    private func setBatteryState(){
        let batteryState = UIDevice.current.batteryState
        self.batteryStateDescription = getBatteryState(for: batteryState)
    }
    
    private func getBatteryState(for state: UIDevice.BatteryState)->String{
        switch state{
        case .charging:
            return "True"
        case .unknown:
            return "False"
        case .unplugged:
            return "False"
        case .full:
            return "False"
        @unknown default:
            return "False"
        }
    }
}


struct ContentView: View {
    
    @ObservedObject private var batteryViewModel = BatteryViewModel()
    
    @State private var ipInput:String = ""
    @State private var device:Device?
    @State private var success:Bool = false
    @State private var response:String = "response"
    @State private var time:String = ""
    @State private var batteryValue:String = ""
    @State private var batteryState:String = ""
    
    var body: some View {
        VStack {
            Text(response)
            Text(time)
            Text(batteryState)
            Text(batteryValue)
            TextField("Enter Ip Address", text: $ipInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Start", action: {
                startFetchingData()
                batteryValue = String( batteryViewModel.batteryLevel)
                batteryState = String(batteryViewModel.batteryStateDescription)
            }).padding()
            Button("Stop", action:{})
        }.padding()
    }
    
    func startFetchingData(){
        Task{
            do{
                device = try await getUser(ipAddress: ipInput)
                response = device?.DEVN ?? "no response"
                time = getTime()
                success = true
                writeToFile(
                    deviceName: device?.DEVN ?? "nil",
                    status: device?.STATUS ?? "nil",
                    voltage: device?.VOLTAGE ?? "nil",
                    current: device?.CURRENT ?? "nil",
                    power: device?.POWER ?? "nil",
                    frequency: device?.FREQUENCY ?? "nil"
                )
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

