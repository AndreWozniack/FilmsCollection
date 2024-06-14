import SwiftUI

struct MainView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {

            FilmListView()
                .tabItem {
                    Label("Recomendações", systemImage: "magnifyingglass.circle.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.circle.fill")
                }
                .tag(2)
        }
        .accentColor(Color.orange)
    }
}

#Preview {
    ContentView()
}
