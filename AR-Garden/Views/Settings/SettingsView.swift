//
//  SettingsView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 22/03/2022.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var viewModel: ARViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Augmented Reality")) {
                Toggle(isOn: $viewModel.settings.peopleOcclusion, label: {
                    Label("People occlusion", systemImage: "person")
                })
                Toggle(isOn: $viewModel.settings.objectOcclusion, label: {
                    Label("Object occlusion", systemImage: "cube.box")
                })
                Toggle(isOn: $viewModel.settings.lidar, label: {
                    Label("Lidar", systemImage: "light.min")
                })
            }
            
            Section(header: Text("Multiuser experience")) {
                Toggle(isOn: $viewModel.settings.multiuser, label: {
                    Label("Connect with peers", systemImage: "person.3")
                })
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
