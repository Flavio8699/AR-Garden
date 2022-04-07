//
//  DeleteModelView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 04/04/2022.
//

import SwiftUI

struct DeleteModelView: View {
    
    @EnvironmentObject var modelsViewModel: ModelsViewModel
    @EnvironmentObject var sceneManager: SceneManager
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                modelsViewModel.selectedModelDeletion = nil
            }, label: {
                Image(systemName: "xmark.circle.fill").font(.system(size: 40, weight: .light, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 55, height: 55)
            })
            Spacer()
            Button(action: {
                guard let anchor = modelsViewModel.selectedModelDeletion?.anchor else { return }
                
                let identifier = anchor.anchorIdentifier
                if let index = sceneManager.anchorEntities.firstIndex(where: { $0.anchorIdentifier == identifier }) {
                    sceneManager.anchorEntities.remove(at: index)
                }
                anchor.removeFromParent()
                modelsViewModel.selectedModelDeletion = nil
                sceneManager.persistenceAction = .save
            }, label: {
                Image(systemName: "trash.circle.fill").font(.system(size: 40, weight: .light, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 55, height: 55)
            })
            Spacer()
        }.padding(.vertical)
    }
}
