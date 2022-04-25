//
//  PlaceModelView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 14/03/2022.
//

import SwiftUI

struct PlaceModelView: View {
    
    @EnvironmentObject var viewModel: ARViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.selectedModelPlacement = nil
            }, label: {
                Image(systemName: "xmark.circle.fill").font(.system(size: 40, weight: .light, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 55, height: 55)
            })
            Spacer()
            Button(action: {
                if let model = viewModel.selectedModelPlacement {
                    viewModel.placeModels.append(model)
                    viewModel.selectedModelPlacement = nil
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }, label: {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 40, weight: .light, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 55, height: 55)
            })
            Spacer()
        }.padding(.vertical)
    }
}
