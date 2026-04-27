//
//  SearchBar.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 27/04/26.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.onSurfaceVariant)
                .font(.system(size: 18))
            
            TextField("", text: $searchText, prompt: Text("Search transactions...")
                .foregroundColor(.white.opacity(0.2),))
                .font(.system(size: 16))
                .foregroundColor(.onSurface)
                .accentColor(.primaryTeal)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .modifier(GlassPanel(cornerRadius: 8))
    }
}

#Preview {
    @Previewable @State var searchText: String = ""
    
    SearchBar(searchText: $searchText).modifier(BackgroundMesh())
}
