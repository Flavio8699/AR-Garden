//
//  CatalogueView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 14/03/2022.
//

import SwiftUI

struct CatalogueView: View {
    
    @EnvironmentObject var session: Session
    @EnvironmentObject var modelsViewModel: ModelsViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack (alignment: .leading) {
                Divider()
                Text("Recents").font(.title2).bold()
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        let recents = modelsViewModel.getUniqueRecents()
                        ForEach(0..<recents.count, id: \.self) { index in
                            let model = recents[index]
                            
                            Button(action: {
                                model.loadModel(handler: { completed, error in
                                    if completed {
                                        modelsViewModel.selectedModelPlacement = model
                                    }
                                })
                                NotificationCenter.default.post(name: NSNotification.Name("Tab"), object: nil, userInfo: ["tab": nil])
                            }, label: {
                                Image(model.modelName).resizable().frame(width: 150, height: 150).cornerRadius(8)
                            })
                        }
                    }
                }
                Divider()
                Text("Items").font(.title2).bold()
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(0..<modelsViewModel.models.count, id: \.self) { index in
                            let model = modelsViewModel.models[index]
                            
                            Button(action: {
                                model.loadModel(handler: { completed, error in
                                    if completed {
                                        modelsViewModel.selectedModelPlacement = model
                                    }
                                })
                                NotificationCenter.default.post(name: NSNotification.Name("Tab"), object: nil, userInfo: ["tab": nil])
                            }, label: {
                                Image(model.modelName).resizable().frame(width: 150, height: 150).cornerRadius(8)
                            })
                        }
                    }
                }
            }.padding(.horizontal)
        }
        .navigationTitle("Catalogue")
        .navigationBarTitleDisplayMode(.inline)
    }
}
