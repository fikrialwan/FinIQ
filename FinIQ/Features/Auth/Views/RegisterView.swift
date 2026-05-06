import SwiftUI

struct RegisterView: View {
    @Bindable var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    headerSection

                    inputSection

                    registerButton

                    loginLink
                }
                .padding(24)
            }
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus.fill")
                .font(.system(size: 64))
                .foregroundStyle(.teal)

            Text("Join Finiq")
                .font(.title)
                .fontWeight(.bold)

            Text("Start tracking your wealth today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)

            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)

            Picker("Currency", selection: $viewModel.currencyPref) {
                Text("IDR - Indonesian Rupiah").tag("IDR")
                Text("USD - US Dollar").tag("USD")
                Text("EUR - Euro").tag("EUR")
                Text("GBP - British Pound").tag("GBP")
            }
            .pickerStyle(.menu)
            .padding(.vertical, 8)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var registerButton: some View {
        Button {
            Task {
                await viewModel.register()
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create Account")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.teal)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.isRegisterValid || viewModel.isLoading)
    }

    private var loginLink: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Text("Already have an account? ")
                    .foregroundStyle(.secondary)
                Text("Sign In")
                    .foregroundStyle(.teal)
            }
        }
    }
}