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
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid (columns: items) {
                let models = viewModel.getModels(for: category)
                ForEach(0..<models.count, id: \.self) { index in
                    let model = models[index]
                    
                    Button(action: {
                        viewModel.selectedModelPlacement = model
                        NotificationCenter.default.post(name: NSNotification.Name("Tab"), object: nil, userInfo: ["tab": nil])
                    }, label: {
                        ItemView(model: model)
                    })
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.large)
    }
}
