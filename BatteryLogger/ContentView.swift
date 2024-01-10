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
    @State private var url:URL?
    @State private var timer: Timer?
    
    
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
                if self.timer == nil {
                                   // Start the continuous task
                                   self.startContinuousTask()
                               } else {
                                   // Stop the continuous task
                                   self.stopContinuousTask()
                               }
                
                batteryValue = String( batteryViewModel.batteryLevel)
                batteryState = String(batteryViewModel.batteryStateDescription)
                
            }).padding()
            
            Button("Stop", action:{
                self.stopContinuousTask()
            }).padding()
            
            Button("Clear File", action: {
                clearFile(fileURL: (url!))
            }).padding()
            
            ShareLink(item: ((url) ?? URL(string: "www.google.com"))!)
        }.padding()
        // Disable the idle timer when the view appears
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        // Re-enable the idle timer when the view disappears
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        
    }
    // Function to start the continuous task
        private func startContinuousTask() {
            self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                startFetchingData(
                    batteryLevel: String(batteryViewModel.batteryLevel),
                    batteryState: batteryViewModel.batteryStateDescription
                )
                print("Continuous task is running every 5 seconds...")
            }
        }

        // Function to stop the continuous task
        private func stopContinuousTask() {
            // Stop the timer
            self.timer?.invalidate()
            self.timer = nil
            print("Continuous task stopped.")
        }
    
    
    func startFetchingData(batteryLevel:String, batteryState:String){
        Task{
            do{
                device = try await getUser(ipAddress: ipInput)
                response = device?.DEVN ?? "no response"
                time = getTime()
                success = true
                url = writeToFile(
                    batteryLevel: batteryLevel,
                    batteryState: batteryState,
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


