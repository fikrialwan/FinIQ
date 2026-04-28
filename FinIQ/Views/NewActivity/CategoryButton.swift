//
//  CategoryButton.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 27/04/26.
//

import SwiftUI

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Background Circle
                    Circle()
                        .fill(isSelected ? .primaryTeal.opacity(0.15) : Color.white.opacity(0.05))
                        .frame(width: 60, height: 60)
                    
                    // Border Outline
                    Circle()
                        .stroke(isSelected ? .primaryTeal : Color.clear, lineWidth: 1.5)
                        .frame(width: 60, height: 60)
                    
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .primaryTeal : Color.white.opacity(0.8))
                }
                
                // Title
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .primaryTeal : Color.white.opacity(0.8))
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        CategoryButton(
            title: "Food", icon: "fork.knife", isSelected: true) {
                
            }
        
        CategoryButton(
            title: "Food", icon: "fork.knife", isSelected: false) {
                
            }
    }.modifier(BackgroundMesh())
}
