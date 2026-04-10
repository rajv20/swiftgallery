import SwiftUI
import Combine

struct PhotoItem: Identifiable {
    let id = UUID()
    let imageName: String
    let author: String
}

class Gallery: ObservableObject {
    @Published var photos = [
        PhotoItem(imageName: "nature.o", author: "Nature Shots"),
        PhotoItem(imageName: "digital.art", author: "Digital Art"),
        PhotoItem(imageName: "historical", author: "Historical"),
        PhotoItem(imageName: "concerts", author: "Concerts"),
        PhotoItem(imageName: "family", author: "family"),
        PhotoItem(imageName: "gaming", author: "Gaming Life"),
    ]
    
    @Published var isDark = false
}

struct PhotoGallery: View {
    @StateObject var vm = Gallery()
    
    var body: some View {
        TabView {
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .environmentObject(vm)
        .preferredColorScheme(vm.isDark ? .dark : .light)
    }
}

struct GalleryView: View {
    @EnvironmentObject var vm: Gallery
    @Namespace var animation
    @State var selectedPhoto: PhotoItem?
    @State var searchText = ""
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 50) {
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search photos...", text: $searchText)
                        }
                        .padding(21)
                        .background(Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: 26))
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(vm.photos) { photo in
                                PhotoCard(p: photo, animation: animation)
                                    .onTapGesture {
                                        withAnimation(.bouncy) {
                                            selectedPhoto = photo
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu("Sort") {
                        Button("By Name", action: {})
                        Button("By Date", action: {})
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            vm.isDark.toggle()
                        }
                    } label: {
                        Image(systemName: vm.isDark ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundColor(.primary)
                            .font(.title3)
                    }
                }
            }
            .navigationTitle("Gallery")
        }
    }
}

struct PhotoCard: View {
    let p: PhotoItem
    var animation: Namespace.ID
    @State private var scale = 1.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(p.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: 160)
                    .clipped()
                    .cornerRadius(20)
            }
        }
        .frame(height: 160)
        .overlay(alignment: .bottomLeading) {
            Text(p.author)
                .foregroundColor(.white)
                .bold()
                .padding()
        }
        .scaleEffect(scale)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation {
                        scale = 0.5
                    }
                }
                .onEnded { _ in
                    withAnimation {
                        scale = 1.0
                    }
                }
        )
    }
}

struct DetailView: View {
    let photo: PhotoItem
    @Binding var selectedPhoto: PhotoItem?
    var animation: Namespace.ID
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 350)
                    
                    Image(photo.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Spacer()
            }
        }
    }
}

struct ProfileView: View {
    @State private var isSheetOpen = false
    @State private var viewStyle = 1
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                Picker("Style", selection: $viewStyle) {
                    Text("List Mode").tag(0)
                    Text("Grid Mode").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(19)
                
                List {
                    Group {
                        Text("Profile Actions")
                            .font(.title2)
                            .bold()
                        
                        NavigationLink("My Favorites") {
                            Text("Favorited Items Here")
                        }
                        
                        NavigationLink("Private Photos") {
                            Text("No private photos")
                        }
                    }
                    
                    Divider()
                    
                    Grid(horizontalSpacing: 60, verticalSpacing: 10) {
                        GridRow {
                            Text("Photos").bold()
                            Text("Videos").bold()
                        }
                        GridRow {
                            Text("101K")
                            Text("30")
                        }
                        .foregroundColor(.brown)
                    }
                    .padding(.vertical, 28)
                }
                .font(.headline)
                
                Button {
                    isSheetOpen = true
                } label: {
                    Text("Add New Aesthetic Shot")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(120)
                        .padding()
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $isSheetOpen) {
                VStack(spacing: 15) {
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 60))
                        .foregroundColor(.indigo)
                    
                    Text("Upload Photo Window")
                        .font(.title2)
                        .bold()
                }
            }
        }
    }
}

#Preview {
    PhotoGallery()
}
