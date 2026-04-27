//
//  SwiftUIView.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 26/04/26.
//

import SwiftUI

struct RecentActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.onSurface)
                .padding(.horizontal, 8)
            
            VStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.system(size: 24))
                    .foregroundColor(.onSurfaceVariant)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
                    .padding(.bottom, 8)
                
                Text("It's quiet here")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.onSurface)
                
                Text("Transactions will appear once you add them.")
                    .font(.system(size: 14))
                    .foregroundColor(.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 48)
            .modifier(GlassCard())
        }
    }
}

#Preview {
    RecentActivityCard().modifier(BackgroundMesh())
}
