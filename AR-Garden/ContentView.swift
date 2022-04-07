//
//  ContentView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 22/02/2022.
//

import SwiftUI
import RealityKit

enum Tab {
    case catalogue
    case settings
}

struct ContentView: View {
    
    @State var currentTab: Tab?
    @EnvironmentObject var session: Session
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelsViewModel: ModelsViewModel
    
    var body: some View {
        ZStack (alignment: .bottom) {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            if modelsViewModel.selectedModelPlacement != nil {
                PlaceModelView()
            } else if modelsViewModel.selectedModelDeletion != nil {
                DeleteModelView()
            } else {
                VStack {
                    HStack {
                        Spacer()
                        RecentsButton()
                        Spacer()
                        CustomButton(icon: "square.grid.2x2", tab: .catalogue)
                        Spacer()
                        CustomButton(icon: "slider.horizontal.3", tab: .settings)
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: .constant(currentTab != nil), onDismiss: {
            currentTab = nil
        }) {
            NavigationView {
                VStack {
                    switch currentTab {
                    case .catalogue:
                        CatalogueView()
                    case .settings:
                        SettingsView()
                    default:
                        EmptyView()
                    }
                }.toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            currentTab = nil
                        }
                    }
                }
            }
        }
        .onAppear {
            modelsViewModel.loadModels()
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("Tab"), object: nil, queue: .main) { data in
                guard let userInfo = data.userInfo else { return }
                
                if let tab = userInfo["tab"] {
                    self.currentTab = tab as? Tab
                }
            }
        }
    }
}
