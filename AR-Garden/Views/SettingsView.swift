//
//  SettingsView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 22/03/2022.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var session: Session
    @EnvironmentObject var sceneManager: SceneManager
    
    var body: some View {
        Form {
            Section(header: Text("Augmented Reality")) {
                Toggle(isOn: $session.peopleOcclusion, label: {
                    Label(title: {
                        Text("People occlusion")
                    }, icon: {
                        Image(systemName: "person")
                    })
                })
                Toggle(isOn: $session.objectOcclusion, label: {
                    Label(title: {
                        Text("Object occlusion")
                    }, icon: {
                        Image(systemName: "cube.box")
                    })
                })
                Toggle(isOn: $session.lidar, label: {
                    Label(title: {
                        Text("Lidar")
                    }, icon: {
                        Image(systemName: "light.min")
                    })
                })
            }
            
            Section(header: Text("Multiuser experience")) {
                Button(action: {
                    
                }, label: {
                    Label(title: {
                        Text("Connect with peers")
                    }, icon: {
                        Image(systemName: "person.3")
                    })
                })
            }
            
            Section(header: Text("Scene")) {
                Button(action: {
                    sceneManager.persistenceAction = .save
                    NotificationCenter.default.post(name: NSNotification.Name("Tab"), object: nil, userInfo: ["tab": nil])
                }, label: {
                    Label(title: {
                        Text("Save scene")
                    }, icon: {
                        Image(systemName: "icloud.and.arrow.up")
                    })
                })
                
                Button(action: {
                    sceneManager.persistenceAction = .load
                    NotificationCenter.default.post(name: NSNotification.Name("Tab"), object: nil, userInfo: ["tab": nil])
                }, label: {
                    Label(title: {
                        Text("Load scene")
                    }, icon: {
                        Image(systemName: "icloud.and.arrow.down")
                    })
                })
            }

            Section {
                Button(action: {
                    for anchor in sceneManager.anchorEntities {
                        anchor.removeFromParent()
                    }
                    sceneManager.persistenceAction = .save
                    NotificationCenter.default.post(name: NSNotification.Name("Tab"), object: nil, userInfo: ["tab": nil])
                }, label: {
                    Label(title: {
                        Text("Delete objects")
                    }, icon: {
                        Image(systemName: "trash")
                    }).foregroundColor(Color(.systemRed))
                })
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
