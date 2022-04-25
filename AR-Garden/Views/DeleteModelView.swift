//
//  DeleteModelView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 04/04/2022.
//

import SwiftUI

struct DeleteModelView: View {
    
    @EnvironmentObject var viewModel: ARViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.selectedModelDeletion = nil
            }, label: {
                Image(systemName: "xmark.circle.fill").font(.system(size: 40, weight: .light, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 55, height: 55)
            })
            Spacer()
            Button(action: {
                viewModel.deleteSelectedModel()
            }, label: {
                Image(systemName: "trash.circle.fill").font(.system(size: 40, weight: .light, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 55, height: 55)
            })
            Spacer()
        }.padding(.vertical)
    }
}
