import ComposableArchitecture
import Entity
import GitHubAPIClient
import SwiftUI
import UserDefaultsClient
import WebKit

public struct RepositoryDetail: Reducer {
  public struct State: Equatable {
    let repository: Repository

    @BindingState var isWebViewLoading = true

    public init(repository: Repository) {
      self.repository = repository
    }
  }
  
  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
      }
    }
  }
}

public struct RepositoryDetailView: View {
  let store: StoreOf<RepositoryDetail>
  
  public init(store: StoreOf<RepositoryDetail>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      SimpleWebView(
        url: viewStore.repository.htmlUrl,
        isLoading: viewStore.$isWebViewLoading
      )
      .overlay(alignment: .center) {
        if viewStore.isWebViewLoading {
          ProgressView()
        }
      }
      .navigationBarTitleDisplayMode(.inline)
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
