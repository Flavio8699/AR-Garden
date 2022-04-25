//
//  CatalogueView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 14/03/2022.
//

import SwiftUI

struct CatalogueView: View {
    
    @EnvironmentObject var viewModel: ARViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack (alignment: .leading) {
                Divider()
                Text("Recents").font(.title2).bold()
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        let recents = viewModel.getUniqueRecents()
                        ForEach(0..<recents.count, id: \.self) { index in
                            let model = recents[index]
                            
                            Button(action: {
                                viewModel.selectedModelPlacement = model
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
                        ForEach(0..<viewModel.models.count, id: \.self) { index in
                            let model = viewModel.models[index]
                            
                            Button(action: {
                                viewModel.selectedModelPlacement = model
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
