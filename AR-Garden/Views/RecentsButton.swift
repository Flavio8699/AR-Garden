//
//  RecentsButton.swift
//  BSP6
//
//  Created by Flavio Matias on 07/04/2022.
//

import SwiftUI

struct RecentsButton: View {
    
    @EnvironmentObject var modelsViewModel: ModelsViewModel
    
    var body: some View {
        if let recent = modelsViewModel.recentModels.last {
            Button(action: {
                modelsViewModel.selectedModelPlacement = recent
            }, label: {
                Image(recent.modelName)
                    .resizable()
                    .frame(width: 55, height: 55)
                    .aspectRatio(1/1, contentMode: .fit)
                    .background(.white)
            })
            .clipShape(Circle())
        } else {
            Image(systemName: "clock.fill")
                .font(.system(size: 25))
                .frame(width: 55, height: 55)
                .foregroundColor(.white)
                .background(.black.opacity(0.4))
                .clipShape(Circle())
        }
    }
}
