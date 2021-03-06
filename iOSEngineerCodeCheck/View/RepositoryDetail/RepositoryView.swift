import SwiftUI
import Combine
import struct Kingfisher.KFImage

struct RepositoryView<ViewModel: RepositoryViewModelProtocol>: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        if viewModel.repository == nil {
            loadingView
                .onAppear {
                    viewModel.loadRepository()
                }
        } else {
            List {
                if let repository = viewModel.repository {
                    headerView(repository: repository)
                }
            }
            .listStyle(GroupedListStyle())
            .alert(isPresented: Binding(optional: $viewModel.error)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.error?.localizedDescription ?? ""),
                    dismissButton: nil
                )
            }
        }
    }

    private var loadingView: some View {
        ZStack {
            Color.systemGroupedBackground
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
        .ignoresSafeArea()
    }

    private func headerView(repository: Repository) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // owner
            HStack(spacing: 8) {
                KFImage(repository.owner.avatarUrl)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 32)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray, style: StrokeStyle(lineWidth: 0.5)))
                Text(repository.owner.login)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // title
            Text(repository.name)
                .font(.title)
                .fontWeight(.bold)

            // description
            Text(repository.description)
                .padding(.bottom, 8)

            // links
            if let homePage = repository.homepage {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .foregroundColor(.secondary)
                    Button {
                        UIApplication.shared.open(homePage, completionHandler: nil)
                    } label: {
                        Text(homePage.absoluteString)
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .font(.subheadline)
            }

            // tagViews
            HStack(spacing: 16) {
                tagView(imageName: "star", title: "Star", count: repository.stargazersCount)
                tagView(imageName: "arrow.triangle.branch", title: "Fork", count: repository.forksCount)
            }
            HStack(spacing: 16) {
                tagView(imageName: "eye", title: "Watch", count: repository.subscribersCount)
                tagView(imageName: "doc.plaintext", title: "Open Issue", count: repository.openIssuesCount)
            }
        }
        .padding(.vertical)
    }

    /// Represents a star, fork, watch or issue count.
    private func tagView(imageName: String, title: LocalizedStringKey, count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: imageName)
                .foregroundColor(.secondary)
                .padding(.trailing, 4)
            Text(formatCount(count: count))
                .font(Font.system(.subheadline, design: .rounded))
                .fontWeight(.medium)
            Text(title)
        }
        .font(.subheadline)
    }
}

#if DEBUG
struct RepositoryView_Previews: PreviewProvider {

    private final class MockRepositoryViewModel: RepositoryViewModelProtocol {
        @Published var repository: Repository?
        @Published var isLoading = true
        @Published var error: Error?

        init() {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.repository = PreviewData.get(jsonFileName: "repository")
                self.isLoading = false
//            }
        }

        func loadRepository() {}
    }

    static var previews: some View {
        NavigationView {
            RepositoryView(viewModel: MockRepositoryViewModel())
                .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.colorScheme, .dark)
    }
}
#endif
