import SwiftUI
import FirebaseAuth

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()

    var body: some View {
        List(viewModel.chats) { chat in
            let currentUserID = Auth.auth().currentUser?.uid ?? ""
            let otherParticipantID = chat.participants.first { $0 != currentUserID } ?? ""
            let displayName = viewModel.participantNames[otherParticipantID] ?? otherParticipantID.prefix(1).uppercased()

            NavigationLink(destination: ChatView(chatID: chat.id)) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(displayName.prefix(1)))
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading) {
                        Text(viewModel.participantNames[otherParticipantID] ?? "Unknown")
                            .font(.headline)
                        Text(chat.lastMessage ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Chats")
    }
}
