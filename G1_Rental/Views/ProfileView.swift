//
//  ProfileView.swift
//  G1_Rental
//
//  Updated by Darsh on 2025-07-10.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var isEditing    = false
    @State private var name         = ""
    @State private var contact      = ""
    @State private var cardNumber   = ""
    @State private var errorMessage = ""
    @State private var showSuccess  = false

    private let service = FirestoreService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Profile Header (flush left)
                HStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authVM.user?.name ?? "")
                            .font(.title2).bold()
                        Text(authVM.user?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // Detail fields (flush left)
                VStack(alignment: .leading, spacing: 16) {
                    fieldRow(icon: "person.fill",
                             label: "Name",
                             text: $name,
                             editable: isEditing)
                    fieldRow(icon: "phone.fill",
                             label: "Contact",
                             text: $contact,
                             editable: isEditing)
                    fieldRow(icon: "creditcard.fill",
                             label: "Card Number",
                             text: $cardNumber,
                             editable: isEditing)
                }

                // Validation error
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                // Action Buttons
                VStack(spacing: 16) {
                    if isEditing {
                        Button {
                            saveProfile()
                        } label: {
                            Label("Save Profile", systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)

                        Button {
                            cancelEdit()
                        } label: {
                            Label("Cancel", systemImage: "xmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.gray)
                    } else {
                        Button {
                            startEdit()
                        } label: {
                            Label("Edit Profile", systemImage: "square.and.pencil")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }

                    Button(role: .destructive) {
                        authVM.signOut()
                    } label: {
                        Label("Logout", systemImage: "power")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding()
            }
            .padding(.leading)    // only leading inset for header & fields
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadFields() }
        .alert("Profile updated successfully", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {}
        }
    }

    // MARK: - Helpers

    private func fieldRow(icon: String,
                          label: String,
                          text: Binding<String>,
                          editable: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.blue)
            if editable {
                TextField(label, text: text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.headline)
                    Text(text.wrappedValue)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func loadFields() {
        guard let u = authVM.user else { return }
        name       = u.name
        contact    = u.contact
        cardNumber = u.cardNumber
    }

    private func startEdit() {
        errorMessage = ""
        loadFields()
        isEditing = true
    }

    private func cancelEdit() {
        errorMessage = ""
        loadFields()
        isEditing = false
    }

    private func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Name cannot be empty."
            return
        }
        guard var u = authVM.user else { return }
        u.name       = name
        u.contact    = contact
        u.cardNumber = cardNumber

        service.updateUserProfile(u) { err in
            DispatchQueue.main.async {
                if let err = err {
                    errorMessage = "Update failed: \(err.localizedDescription)"
                } else {
                    authVM.listenAuthState()
                    isEditing  = false
                    showSuccess = true
                }
            }
        }
    }
}
