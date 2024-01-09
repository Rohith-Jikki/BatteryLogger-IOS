//
//  Utils.swift
//  BatteryLogger
//
//  Created by ALTRAI TECH on 09/01/24.
//

import Foundation
import UIKit

func writeToFile(
    deviceName: String,
    status:String,
    voltage:String,
    current:String,
    power:String,
    frequency:String
){
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in:  .userDomainMask).first else{
        print("Unable to access documents directory.")
        return
    }
    let fileName = "BatteryLogger.txt"
    
    let fileURL = documentsDirectory.appendingPathComponent(fileName)
    
    do{
        try "\(deviceName),\(status),\(voltage),\(current),\(power),\(frequency)"
            .write(
                to: fileURL,
                atomically:true,
                encoding: .utf8
            )
        
        print("File successfully created and data written.")
   
        
    } catch {
        print("Error writing to file: \(error.localizedDescription)")

    }
}

func getTime() -> String{
    let now = Date()

        let formatter = DateFormatter()

        formatter.timeZone = TimeZone.current

        formatter.dateFormat = "HH:mm:ss"

        let dateString = formatter.string(from: now)
    return dateString
}
