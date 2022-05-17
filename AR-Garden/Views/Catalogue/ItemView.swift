//
//  ItemView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 05/05/2022.
//

import SwiftUI

struct ItemView: View {
    
    var model: Model
    
    var body: some View {
        ZStack (alignment: .center) {
            Color(.white)
            Image(model.modelName).resizable().scaledToFit().frame(height: 150)
            VStack (spacing: 0) {
                Spacer()
                ZStack (alignment: .center) {
                    Color(.systemGray).opacity(0.4)
                    Text(model.name).foregroundColor(.black)
                }.frame(height: 35)
            }
        }.overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [15.0])).foregroundColor(Color(.systemGray))
        ).frame(height: 170).cornerRadius(8)
    }
}
