//
//  LedgerView.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 27/04/26.
//

import SwiftUI

struct LedgerView: View {
    @State private var searchText: String = ""
    var body: some View {
        VStack(spacing: 16) {
            Text("Ledger")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 32, weight: .semibold, design: .default))
                .foregroundColor(.onSurface)
                .padding(.top, 24)
            
            SearchBar(searchText: $searchText)
            
            EmptyState()
                .frame(maxHeight: .infinity)
            

        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 20)
        .modifier(BackgroundMesh())
    }
}

#Preview {
    LedgerView()
}
