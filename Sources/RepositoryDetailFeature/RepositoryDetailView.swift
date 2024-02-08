import ComposableArchitecture
import Dependencies
import Entity
import GitHubAPIClient
import SwiftUI
import UserDefaultsClient
import WebKit

@Reducer
public struct RepositoryDetail {
  @ObservableState
  public struct State: Equatable {
    let repository: Repository

    var isFavoriteRepository = false
    var isWebViewLoading = true

    public init(repository: Repository) {
      self.repository = repository
    }
  }
  
  public enum Action: BindableAction {
    case onAppear
    case favoriteButtonTapped
    case binding(BindingAction<State>)
  }

  public init() {}

  @Dependency(\.userDefaultsClient) var userDefaultsClient

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .onAppear:
        let repositories = userDefaultsClient.getFavoriteRepositories()
        if repositories.contains(where: { $0.id == state.repository.id }) {
          state.isFavoriteRepository = true
        }
        return .none
      case .favoriteButtonTapped:
        if state.isFavoriteRepository {
          userDefaultsClient.deleteFavoriteRepository(
            state.repository.id
          )
        } else {
          userDefaultsClient.addFavoriteRepository(
            state.repository
          )
        }
        state.isFavoriteRepository.toggle()
        return .none
      case .binding:
        return .none
      }
    }
  }
}

public struct RepositoryDetailView: View {
  @Bindable var store: StoreOf<RepositoryDetail>

  public init(store: StoreOf<RepositoryDetail>) {
    self.store = store
  }

  public var body: some View {
    SimpleWebView(
      url: store.repository.htmlUrl,
      isLoading: $store.isWebViewLoading
    )
    .overlay(alignment: .center) {
      if store.isWebViewLoading {
        ProgressView()
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          store.send(.favoriteButtonTapped)
        } label: {
          if store.isFavoriteRepository {
            Image(systemName: "heart.fill")
          } else {
            Image(systemName: "heart")
          }
        }
        .disabled(store.isWebViewLoading)
      }
    }
  }
}

struct SimpleWebView: UIViewRepresentable {
  let url: URL
  @Binding var isLoading: Bool

  private let webView = WKWebView()

  func makeUIView(context: Context) -> some UIView {
    webView.load(.init(url: url))
    webView.navigationDelegate = context.coordinator
    return webView
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, WKNavigationDelegate {
    let parent: SimpleWebView

    init(_ parent: SimpleWebView) {
      self.parent = parent
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      parent.isLoading = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      parent.isLoading = false
    }
  }
}

#Preview {
  RepositoryDetailView(
    store: .init(
      initialState: RepositoryDetail.State(
        repository: .mock(id: 1)
      )
    ) {
      RepositoryDetail()
    }
  )
}
