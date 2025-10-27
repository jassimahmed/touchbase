//
//  ProfileView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-10.
//

import SwiftUI
import FirebaseAuth
import os

struct ProfileView: View {
    let user: User
    private let currentUserId: String

    @State private var showLoginView = false
    @State private var showNotifications = false
    @State private var selectedTab: String?

    // Track connections reactively
    @State private var familyConnections: [User] = []
    @State private var friendConnections: [User] = []
    @State private var colleagueConnections: [User] = []

    @ObservedObject private var cache = ConnectionCache.shared

    private var isCurrentUser: Bool {
        currentUserId == user.id
    }

    init(user: User) {
        self.user = user
        self.currentUserId = Auth.auth().currentUser?.uid ?? "Show error page"
    }

    var body: some View {
        let availableTabs: [String] = {
            var tabs: [String] = []
            if !familyConnections.isEmpty { tabs.append("Family") }
            if !friendConnections.isEmpty { tabs.append("Friends") }
            if !colleagueConnections.isEmpty { tabs.append("Colleagues") }
            return tabs
        }()

        VStack(spacing: 20) {
            // MARK: - Profile Header
            Image("profile_pic")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .shadow(radius: 4)
                .background(.ultraThinMaterial, in: Circle())

            VStack(spacing: 4) {
                Text(user.name)
                    .font(.title2.bold())
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // MARK: - Conditional Buttons
            if isCurrentUser {
                Button(action: signOut) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                .padding(.horizontal)
            } else {
                AddRelationshipButton(user: user)
            }

            // MARK: - Tabs for connections
            if isCurrentUser && !availableTabs.isEmpty {
                VStack {
                    Picker("Select Tab", selection: $selectedTab) {
                        ForEach(availableTabs, id: \.self) { tab in
                            Text(tab).tag(tab as String?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    Group {
                        switch selectedTab {
                        case "Family":
                            ConnectionListView(users: familyConnections)
                        case "Friends":
                            ConnectionListView(users: friendConnections)
                        case "Colleagues":
                            ConnectionListView(users: colleagueConnections)
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.top, 8)
                    .transition(.opacity)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isCurrentUser {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNotifications = true }) {
                        Image(systemName: "envelope.badge")
                            .font(.title2)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showNotifications) {
            NotificationView()
        }
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
        }
        .onAppear {
            updateConnections()
            if selectedTab == nil {
                selectedTab = firstAvailableTab()
            }
        }
        .onChange(of: cache.connections) { _ in
          updateConnections()
            if selectedTab == nil || !firstAvailableTabsContains(selectedTab) {
                selectedTab = firstAvailableTab()
            }
        }
    }
  
    private func updateConnections() {
        familyConnections = cache.getFamily(for: currentUserId)
        friendConnections = cache.getFriend(for: currentUserId)
        colleagueConnections = cache.getColleague(for: currentUserId)
    }

    private func firstAvailableTab() -> String? {
        if !familyConnections.isEmpty { return "Family" }
        if !friendConnections.isEmpty { return "Friends" }
        if !colleagueConnections.isEmpty { return "Colleagues" }
        return nil
    }

    private func firstAvailableTabsContains(_ tab: String?) -> Bool {
        guard let tab else { return false }
        return (tab == "Family" && !familyConnections.isEmpty)
            || (tab == "Friends" && !friendConnections.isEmpty)
            || (tab == "Colleagues" && !colleagueConnections.isEmpty)
    }

    private func signOut() {
        do {
            try LoginService.shared.signOut()
            showLoginView = true
        } catch {
            LOGGER.error("Error signing out: \(error.localizedDescription)")
        }
    }
}
