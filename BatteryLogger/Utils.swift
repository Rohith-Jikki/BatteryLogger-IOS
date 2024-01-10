//
//  Utils.swift
//  BatteryLogger
//
//  Created by ALTRAI TECH on 09/01/24.
//

import Foundation
import UIKit

func writeToFile(
    batteryLevel:String,
    batteryState:String,
    deviceName: String,
    status:String,
    voltage:String,
    current:String,
    power:String,
    frequency:String
) -> URL?{
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in:  .userDomainMask).first else{
        print("Unable to access documents directory.")
        return nil
    }
    let fileName = "BatteryLogger.txt"
    
    let fileURL = documentsDirectory.appendingPathComponent(fileName)
    
    do{
        let data = "\(getTime()),\(batteryLevel),\(batteryState),\(deviceName),\(status),\(voltage),\(current),\(power),\(frequency)\n"

                // Open the file in append mode
                if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                    // Seek to the end of the file
                    fileHandle.seekToEndOfFile()

                    // Convert the string to data and write it to the file
                    fileHandle.write(data.data(using: .utf8)!)

                    // Close the file
                    fileHandle.closeFile()
                } else {
                    // If the file does not exist, create it and write the data
                    try data.write(to: fileURL, atomically: true, encoding: .utf8)
                }
        
        print("File successfully created and data written.")
        return fileURL
        
    } catch {
        print("Error writing to file: \(error.localizedDescription)")
        return nil
    }
}

func clearFile(fileURL:URL){
    do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)

            // Set the file handle to the beginning of the file
            fileHandle.seek(toFileOffset: 0)

            // Truncate the file content
            fileHandle.truncateFile(atOffset: 0)

            // Close the file handle
            fileHandle.closeFile()

            print("File content cleared.")
        } catch {
            print("Error clearing file content: \(error.localizedDescription)")
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
