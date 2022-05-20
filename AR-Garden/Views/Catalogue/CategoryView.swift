//
//  CategoryView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 17/05/2022.
//

import SwiftUI

struct CategoryView: View {
    
    var category: ObjectCategory
    @EnvironmentObject var viewModel: ARViewModel
    var items: [GridItem] {
        Array(repeating: .init(.flexible(minimum: 120)), count: 2)
    }
    @State var previewItem: Model? = nil
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid (columns: items) {
                let models = viewModel.getModels(for: category)
                ForEach(0..<models.count, id: \.self) { index in
                    let model = models[index]
                    
                    Menu(content: {
                        Group {
                            Button("Place object", action: {
                                viewModel.selectedModelPlacement = model
                                NotificationCenter.default.post(name: NSNotification.Name("Tab"), object: nil, userInfo: ["tab": nil])
                            })
                            Button("Preview", action: {
                                previewItem = model
                            })
                        }
                    }) {
                        ItemView(model: model)
                    }
                }
            }
        }
        .sheet(item: $previewItem, content: { model in
            NavigationView {
                ARQuickLookView(name: model.modelName).edgesIgnoringSafeArea(.all)
                .navigationBarTitle(model.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            previewItem = nil
                        }
                    }
                }
            }
        })
        .padding(.horizontal)
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.large)
    }
}
