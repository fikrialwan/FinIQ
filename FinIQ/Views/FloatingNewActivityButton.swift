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
                    TransactionEntrySheet()
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

struct TransactionEntrySheet: View {
    enum FocusedField {
        case amount, note
    }
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query private var activities: [Activity]
    @Query private var homeSummaries: [HomeSummary]
    @Namespace private var animation

    @State private var selectedType: TransactionType = .expense
    @State private var rawAmount: Int = 0
    @State private var displayAmount: String = ""
    @State private var note: String = ""
    @State private var selectedCategory: String = "Food"
    @FocusState private var focusedField: FocusedField?

    private var currentBalance: Int {
        homeSummaries.first?.balance ?? 0
    }

    private var isAmountBiggerThanBalance: Bool {
        selectedType == .expense && rawAmount > currentBalance
    }

    private var isSubmitDisabled: Bool {
        rawAmount == 0 || isAmountBiggerThanBalance
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.1))
                .frame(width: 40, height: 5)
                .padding(.bottom, 24)
            
            HStack {
                Text("New Activity")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.onSurface)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.onSurfaceVariant)
                        .frame(width: 32, height: 32)
                        .background(.onSurfaceContainer)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
            }
            
            Spacer()
            
            VStack{
                HStack(alignment: .center, spacing: 8) {
                    Text("Rp")
                        .font(.system(size: 40, weight: .bold))
                    
                    TextField("", text: $displayAmount, prompt: Text("0")
                        .foregroundColor(.primaryTeal))
                    .font(.system(size: 40, weight: .bold))
                    .keyboardType(.numberPad)
                    .fixedSize(horizontal: true, vertical: false)
                    .focused($focusedField, equals: .amount)
                    .onChange(of: displayAmount) { oldValue, newValue in
                        let justNumbers = newValue.filter { $0.isNumber }
                        
                        rawAmount = Int(justNumbers) ?? 0
                        
                        if let value = Int(justNumbers) {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            formatter.groupingSeparator = "."
                            
                            if let formatted = formatter.string(from: NSNumber(value: value)) {
                                if displayAmount != formatted {
                                    displayAmount = formatted
                                }
                            }
                        } else {
                            // If they delete everything, clear the field
                            displayAmount = ""
                        }
                    }
                    .onAppear {
                        focusedField = .amount
                    }
                }
                .foregroundColor(.primaryTeal)
                .tracking(-1)
                
                Text("Current Balance: Rp \(currentBalance.formatted())")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isAmountBiggerThanBalance ? .error : .onSurfaceVariant)
            }
            
            Spacer()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 0) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    selectedType = type
                                    selectedCategory = type.categories[0].0
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: type.icon)
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    Text(type.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(selectedType == type ? .primaryTeal : .onSurfaceVariant)
                                .background(
                                    ZStack {
                                        if selectedType == type {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.primaryTeal.opacity(0.15))
                                                .matchedGeometryEffect(id: "ActiveTab", in: animation)
                                        }
                                    }
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(6)
                    .background(.white.opacity(0.1))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    
                    Text("SELECT CATEGORY")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.onSurfaceVariant)
                    
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(selectedType.categories, id: \.0) { category in
                            CategoryButton(
                                title: category.0,
                                icon: category.1,
                                isSelected: selectedCategory == category.0,
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCategory = category.0
                                    }
                                }
                            )
                        }
                    }
                    .padding(.bottom, 24)
                    
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 18))
                            .foregroundColor(note.isEmpty ? .onSurfaceVariant : .primaryTeal)
                        
                        TextField("", text: $note, prompt: Text("Add a note...")
                            .foregroundColor(Color.white.opacity(0.1)), axis: .vertical)
                        .lineLimit(1...4)
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                        .accentColor(.primaryTeal)
                        .focused($focusedField, equals: .note)
                    }
                    .padding(16)
                    .background(.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .padding(.bottom, 32)
                }
            }
            
            Button(action: {
                let newActivity = Activity(
                    amount: rawAmount, type: selectedType, category: selectedCategory, note: note
                )
                let homeSummary = homeSummaries.first ?? HomeSummary()

                if homeSummaries.isEmpty {
                    context.insert(homeSummary)
                }

                context.insert(newActivity)
                homeSummary.recalculate(from: activities)
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                    Text("Add Activity")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isSubmitDisabled ? .onSurfaceVariant : .primaryTeal)
                .cornerRadius(12)
            }
            .disabled(isSubmitDisabled)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
}

#Preview {
    FloatingNewActivityButton()
        .modelContainer(for: [Activity.self, HomeSummary.self])
        .modifier(BackgroundMesh())
}

