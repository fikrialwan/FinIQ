//
//  BackgroudMesh.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 26/04/26.
//

import SwiftUI

struct BackgroundMesh: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                Circle()
                    .fill(.secondaryContainer.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -150, y: -300)
                
                Circle()
                    .fill(.primaryTealContainer.opacity(0.1))
                    .frame(width: 350, height: 350)
                    .blur(radius: 100)
                    .offset(x: 150, y: 300)
                
            }
            
            content
        }
        
    }
}

#Preview {
    Text("Preview").foregroundStyle(.white).modifier(BackgroundMesh())
}
