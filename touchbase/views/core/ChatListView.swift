import SwiftUI

struct ChatListView: View {
    var body: some View {
        List(0..<10, id: \.self) { i in
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(Text("\(i)").foregroundColor(.white))
                VStack(alignment: .leading) {
                    Text("Chat \(i)")
                    Text("Last message preview")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .listStyle(.plain)
        .navigationTitle("Chats")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView()
            .previewDisplayName("TabView with ChatListView")
    }
}
