//
//  FloatingButton.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 27/04/26.
//

import SwiftUI
import SwiftData

struct FloatingNewActivityButton: View {
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showSheet.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.background)
                        .frame(width: 56, height: 56)
                        .background(.primaryTeal)
                        .clipShape(Circle())
                        .shadow(color: .primaryTeal.opacity(0.4), radius: 8, x: 0, y: 0)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 16)
                .sheet(isPresented: $showSheet) {
                    ActivityEntrySheet()
                        .presentationBackground {
                            Color.onSurfaceContainer
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .presentationCornerRadius(32)
                        .presentationDragIndicator(.hidden,)
                        .presentationDetents([.fraction(0.95)])
                }
            }
        }
    }
}

#Preview {
    FloatingNewActivityButton()
        .modelContainer(for: [Activity.self, HomeSummary.self])
        .modifier(BackgroundMesh())
}

