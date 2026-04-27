//
//  GlassPanel.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 27/04/26.
//

import SwiftUI

struct GlassPanel: ViewModifier {
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(Color.white.opacity(0.05))
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    Text("Preview")
        .foregroundColor(.white)
        .padding()
        .modifier(GlassPanel(cornerRadius: 10))
        .modifier(BackgroundMesh())
}
