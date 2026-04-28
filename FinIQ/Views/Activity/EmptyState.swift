//
//  EmptyState.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 27/04/26.
//

import SwiftUI

struct EmptyState: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "receipt.fill")
                .font(.system(size: 40))
                .foregroundColor(.primaryTeal)
                .frame(width: 96, height: 96)
                .background(
                    Circle()
                        .fill(.primaryTeal.opacity(0.1))
                        .blur(radius: 10)
                )
                .modifier(GlassPanel(cornerRadius: 48))
            
            Text("Your activity is empty.")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.onSurface)
            
            Text("Tap the + button to log your first expense or income.")
                .font(.system(size: 16))
                .foregroundColor(.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
    }
}

#Preview {
    EmptyState(icon: "receipt.fill", title: "Your activity is empty.", description: "Tap the + button to log your first expense or income.")
        .modifier(BackgroundMesh())
    
    EmptyState(icon: "magnifyingglass", title: "No results found", description: "We couldn't find any activities matching your search. Try a different keyword")
        .modifier(BackgroundMesh())
}
