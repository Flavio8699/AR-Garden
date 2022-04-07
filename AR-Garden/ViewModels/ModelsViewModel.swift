//
//  ModelsViewModel.swift
//  AR-Garden
//
//  Created by Flavio Matias on 01/04/2022.
//

import Foundation
import RealityKit

class ModelsViewModel: ObservableObject {
    
    // All the models
    @Published var models = [Model]()
    
    // Selected model for placement
    @Published var selectedModelPlacement: Model?
    
    // Temporary storage for the models to be placed
    var placeModels = [ModelAnchor]()
    
    // Recently placed models
    @Published var recentModels = [Model]()
    
    // Selected model for deletion
    @Published var selectedModelDeletion: ModelEntity? = nil {
        willSet (model) {
            if selectedModelDeletion == nil, let modelForDeletion = model {
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                modelForDeletion.modelDebugOptions = component
            } else if let previousModel = selectedModelDeletion, let modelForDeletion = model {
                previousModel.modelDebugOptions = nil
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                modelForDeletion.modelDebugOptions = component
            } else if model == nil {
                selectedModelDeletion?.modelDebugOptions = nil
            }
        }
    }
    
    func loadModels() {
        let teapot = Model(modelName: "teapot", name: "Teapot", scale: 0.1)
        let cupandsaucer = Model(modelName: "cupandsaucer", name: "Cup and saucer", scale: 0.01)
        let tree = Model(modelName: "tree", name: "Tree", scale: 0.1)
        
        self.models += [teapot, cupandsaucer, tree]
    }
    
    func clearModels() {
        for model in models {
            model.entity = nil
        }
    }
    
    func getUniqueRecents() -> [Model] {
        var result = [Model]()
        
        for model in self.recentModels.reversed() {
            if !result.contains(where: { $0.modelName == model.modelName }) {
                result.append(model)
            }
        }
        
        return result
    }
}
