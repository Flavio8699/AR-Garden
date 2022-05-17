//
//  CustomButton.swift
//  AR-Garden
//
//  Created by Flavio Matias on 07/04/2022.
//

import SwiftUI

struct CustomButton: View {
    
    var icon: String
    var tab: Tab
    
    var body: some View {
        Button(action: {
            NotificationCenter.default.post(name: NSNotification.Name("Tab"), object: nil, userInfo: ["tab": tab])
        }, label: {
            Image(systemName: icon)
                .font(.system(size: 25))
                .frame(width: 55, height: 55)
                .foregroundColor(.white)
                .background(.black.opacity(0.4))
        })
        .clipShape(Circle())
    }
}
