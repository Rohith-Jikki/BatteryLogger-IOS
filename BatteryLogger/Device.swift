//
//  Device.swift
//  BatteryLogger
//
//  Created by ALTRAI TECH on 09/01/24.
//

import Foundation

struct Device: Codable{
    let DEVN: String
    let STATUS: String
    let VOLTAGE: String
    let CURRENT: String
    let POWER: String
    let FREQUENCY: String
}
