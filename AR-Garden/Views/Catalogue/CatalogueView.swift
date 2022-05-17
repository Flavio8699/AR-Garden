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
        VStack (spacing: 0) {
            if !viewModel.recentModels.isEmpty {
                VStack (alignment: .leading, spacing: 0) {
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
                                    ItemView(model: model)
                                })
                            }
                        }
                    }
                }.padding([.top, .horizontal]).frame(maxHeight: 250)
                Divider()
            }
            List {
                Section(header: Text("Item categories")) {
                    ForEach(ObjectCategory.allCases, id: \.rawValue) { category in
                        NavigationLink(destination: CategoryView(category: category)) {
                            Text(category.rawValue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Catalogue")
        .navigationBarTitleDisplayMode(.inline)
    }
}
