//
//  Settings.swift
//  AR-Garden
//
//  Created by Flavio Matias on 22/02/2022.
//

import SwiftUI
import Combine

class Settings: ObservableObject {
        
    // Settings
    @Published var peopleOcclusion: Bool = false
    @Published var objectOcclusion: Bool = true
    @Published var lidar: Bool = true
    @Published var multiuser: Bool = true
}
