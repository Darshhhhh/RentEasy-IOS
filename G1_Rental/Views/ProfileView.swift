import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var isEditing    = false
    @State private var name         = ""
    @State private var contact      = ""
    @State private var cardNumber   = ""     
    @State private var errorMessage: String?

    private let service = FirestoreService()

    var body: some View {
        VStack(spacing: 16) {
            Text("Profile").font(.title)

            if let user = authVM.user {
                Form {
                    Section("Account") {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                        if isEditing {
                            TextField("Name", text: $name)
                        } else {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text(user.name)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Section("Details") {
                        if isEditing {
                            TextField("Contact", text: $contact)
                            TextField("Credit/Debit Card Number", text: $cardNumber)
                                .keyboardType(.numberPad)
                        } else {
                            HStack {
                                Text("Contact")
                                Spacer()
                                Text(user.contact)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("Card Number")
                                Spacer()
                                Text(user.cardNumber)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    if let msg = errorMessage {
                        Section {
                            Text(msg)
                                .foregroundColor(.red)
                        }
                    }
                }

                if isEditing {
                    HStack {
                        Button("Cancel") {
                            cancelEdit()
                        }
                        Spacer()
                        Button("Save") {
                            saveProfile()
                        }
                        .disabled(name.isEmpty || cardNumber.isEmpty)
                    }
                    .padding([.leading, .trailing])
                } else {
                    Button("Edit Profile") {
                        startEdit()
                    }
                    .padding()
                }

                if !isEditing {
                    Button("Logout", role: .destructive) {
                        authVM.signOut()
                    }
                    .padding(.top)
                }

            } else {
                ProgressView()
            }
        }
        .onAppear { loadFields() }
    }

    private func loadFields() {
        guard let u = authVM.user else { return }
        name       = u.name
        contact    = u.contact
        cardNumber = u.cardNumber
    }

    private func startEdit() {
        loadFields()
        errorMessage = nil
        isEditing = true
    }

    private func cancelEdit() {
        loadFields()
        isEditing = false
    }

    private func saveProfile() {
        guard var u = authVM.user else { return }
        u.name       = name
        u.contact    = contact
        u.cardNumber = cardNumber

        service.updateUserProfile(u) { err in
            DispatchQueue.main.async {
                if let err = err {
                    errorMessage = "Update failed: \(err.localizedDescription)"
                } else {
                    authVM.listenAuthState()  // refresh user
                    isEditing = false
                }
            }
        }
    }
}
