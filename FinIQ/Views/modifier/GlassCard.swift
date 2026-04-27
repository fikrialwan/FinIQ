//
//  GlassCard.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 26/04/26.
//

import SwiftUI

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(24)
            .background(.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}

#Preview {
    Text("Preview").foregroundColor(.white).modifier(GlassCard()).modifier(BackgroundMesh())
}
