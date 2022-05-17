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
    @State var confirmDeletionShowing: Bool = false
    @EnvironmentObject var viewModel: ARViewModel
    
    var body: some View {
        ZStack (alignment: .bottom) {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            if viewModel.selectedModelPlacement != nil {
                PlaceModelView()
            } else if viewModel.selectedModelDeletion != nil {
                DeleteModelView()
            } else {
                VStack {
                    HStack {
                        Spacer()
                        RecentsButton()
                        Spacer()
                        CustomButton(icon: "square.grid.2x2", tab: .catalogue)
                        Spacer()
                        Menu(content: {
                            Section(header: Text("Settings")) {
                                Button(action: {
                                    NotificationCenter.default.post(name: NSNotification.Name("Tab"), object: nil, userInfo: ["tab": Tab.settings])
                                }, label: {
                                    Label("Settings", systemImage: "gear")
                                })
                            }
                            Section(header: Text("Delete")) {
                                Button(role: .destructive, action: {
                                    confirmDeletionShowing.self = true
                                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                }, label: {
                                    Label("Delete objects", systemImage: "trash")
                                })
                            }
                            Section(header: Text("Scene")) {
                                Button(action: {
                                    viewModel.persistenceAction = .save
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                }, label: {
                                    Label("Save scene", systemImage: "icloud.and.arrow.up")
                                }).disabled(!viewModel.persistenceAvailable)
                                
                                Button(action: {
                                    viewModel.persistenceAction = .load
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                }, label: {
                                    Label("Load scene", systemImage: "icloud.and.arrow.down")
                                })
                            }
                        }, label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 25))
                                .frame(width: 55, height: 55)
                                .foregroundColor(.white)
                                .background(.black.opacity(0.4))
                        })
                        .clipShape(Circle())
                        Spacer()
                    }
                    .confirmationDialog("Are you sure you want to delete all the objects?", isPresented: $confirmDeletionShowing, titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            for anchor in viewModel.anchorEntities {
                                anchor.removeFromParent()
                            }
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            viewModel.resetModels()
                        }
                        Button("Cancel", role: .cancel) { }
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
            viewModel.loadModels()
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("Tab"), object: nil, queue: .main) { data in
                guard let userInfo = data.userInfo else { return }
                
                if let tab = userInfo["tab"] {
                    self.currentTab = tab as? Tab
                }
            }
        }
    }
}
