//
//  Model.swift
//  AR-Garden
//
//  Created by Flavio Matias on 14/03/2022.
//

import Foundation
import RealityKit
import Combine
import ARKit
import SwiftUI

class Model: Identifiable {
    var id = UUID().uuidString
    var modelName: String
    var name: String
    var entity: ModelEntity?
    var category: ObjectCategory
    var scale: Float
    
    private var cancellable: AnyCancellable?
    
    init(modelName: String, name: String, category: ObjectCategory, scale: Float = 1.0) {
        self.modelName = modelName
        self.name = name
        self.category = category
        self.scale = scale
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    func loadModel(handler: @escaping (_ completed: Bool, _ error: Error?) -> Void) {
        if self.entity == nil {
            self.cancellable = ModelEntity.loadModelAsync(named: self.modelName)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        NSLog("Error for model \(self.modelName):", error.localizedDescription)
                        handler(false, error)
                    case .finished:
                        break
                    }
                }, receiveValue: { modelEntity in
                    self.entity = modelEntity
                    self.entity?.scale *= self.scale
                    handler(true, nil)
                })
        } else {
            handler(true, nil)
        }
    }
}
