//
//  HeroCard.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 26/04/26.
//

import SwiftUI

struct HeroCard: View {
    var totalWealth: Int
    var iqScore: Int
    var hasActivity: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TOTAL WEALTH")
                    .font(.system(size: 12, weight: .medium))
                    .tracking(1)
                    .foregroundColor(.onSurfaceVariant)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("Rp")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.onSurfaceVariant)
                    Text(totalWealth.formatted())
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.onSurface)
                }
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("IQ SCORE")
                    .font(.system(size: 12, weight: .medium))
                    .tracking(1)
                    .foregroundColor(.onSurfaceVariant)
                Text("\(hasActivity ? String(iqScore) : "--")")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.primaryTeal)
            }
            
            if (!hasActivity) {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.primaryTeal)
                        .frame(width: 32, height: 32)
                        .background(.primaryTeal.opacity(0.2))
                        .clipShape(Circle())
                    
                    Text("Start your journey. Add your first transaction to calculate your IQ score and unlock financial insights.")
                        .font(.system(size: 14))
                        .foregroundColor(.onSurfaceVariant)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.05), lineWidth: 1))
            }
        }.modifier(GlassCard())
    }
}

#Preview {
    HeroCard(totalWealth: 0, iqScore: 0, hasActivity: false).modifier(BackgroundMesh())
}
