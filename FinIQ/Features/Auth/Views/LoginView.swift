import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        headerSection

                        inputSection

                        if viewModel.isBiometricAvailable {
                            biometricButton
                        }

                        loginButton

                        registerLink
                    }
                    .padding(24)
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(viewModel: viewModel)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.teal)

            Text("Finiq")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Track your wealth")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 48)
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
                .textContentType(.password)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var biometricButton: some View {
        Button {
            Task {
                await viewModel.authenticateWithBiometric()
            }
        } label: {
            HStack {
                Image(systemName: viewModel.biometricType == .faceID ? "faceid" : "touchid")
                Text("Sign in with \(viewModel.biometricType == .faceID ? "Face ID" : "Touch ID")")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)
    }

    private var loginButton: some View {
        Button {
            Task {
                await viewModel.login()
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Sign In")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.teal)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.isLoginValid || viewModel.isLoading)
    }

    private var registerLink: some View {
        Button {
            showRegister = true
        } label: {
            HStack {
                Text("Don't have an account? ")
                    .foregroundStyle(.secondary)
                Text("Sign Up")
                    .foregroundStyle(.teal)
            }
        }
    }
}