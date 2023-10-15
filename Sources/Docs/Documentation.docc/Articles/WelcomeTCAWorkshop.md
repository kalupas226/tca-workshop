# TCA Workshop へようこそ！

## Workshop について

TCA Workshop では、実践的なアプリケーションを開発することを通して、The Composable Architecture (TCA) についての基礎やテクニックを学ぶことができます。

Workshop 中に出てきた疑問はいつでも質問してもらって大丈夫なので、一緒に TCA を学んでいきましょう！

## Workshop を進めるための準備

Workshop を進める前にいくつかの確認や準備をしておきましょう。

### Xcode の準備

Workshop を進めるためには Xcode が必要です。  

- Xcode 15 がインストールされていること
- Xcode を使って何らかの iOS アプリが Simulator でビルドできること

上記が満たされていることを確認しましょう。

### リポジトリのクローン

Workshop を進めるための下準備が済んであるリポジトリを用意してあります。  
まずは以下の URL からリポジトリをクローンして、Xcode で `App/TCAWorkshop.xcodeproj` を開いてみましょう。

[](https://github.com/kalupas226/tca-workshop.git)

このリポジトリには Workshop を進める際に利用する `main` branch と Workshop 完了後のコード例が含まれている `complete` branch が存在します。  
complete branch を見てしまうとネタバレになってしまい面白くないと思うので、Workshop が終わるまでは見ないようにしてください。

### GitHub の Personal Access Token の準備

Workshop では、GitHub の API を利用することになります。  
GitHub の API は Personal Access Token (PAT) を利用することで、より多くの回数のリクエストが行えるようになります。  
無闇やたらに API を利用するわけではないですが、Workshop を円滑に進めるための準備として PAT を用意してもらいます。

[personal access token (classic) の作成](https://docs.github.com/ja/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#personal-access-token-classic-%E3%81%AE%E4%BD%9C%E6%88%90) を参考に PAT を作成してください。  
GitHub の API を利用するために必要な、`repo` scope が最低限設定されていれば問題ありません。

PAT を用意できたら、PAT をコピーし Xcode Project の Build Settings にある User-Defined 内の `GITHUB_PERSONAL_ACCESS_TOKEN` に設定してください。

![](pat-user-defined.png)

### Workshop のプロジェクト構造

Workshop のために用意されたプロジェクトは SwiftPM によってマルチモジュール化された状態となっています。  
マルチモジュールについては Workshop の本質ではないですが、Workshop をスムーズに進めるために簡単にプロジェクト構造について説明しておきます。

![](project-structure.png)

Project Navigator から見える上のような図のそれぞれを簡単に説明すると、以下のような構造となっています。

- 1: アプリのエントリポイントなどが格納されています。Workshop 中では、`App.swift` 以外には触れることはないと思います。マルチモジュール化されたモジュールのうち、必要なモジュールを import し、アプリのエントリポイントに繋ぎこむことで、実装したアプリを起動させることができます。
- 2: `Sources` 配下にあるのが各モジュールとなっています。Workshop に必要なモジュールは既に用意されているため、必要に応じてモジュール内のファイルを編集してもらったり、モジュール内にファイルを新規作成してもらうことで Workshop が進んでいきます。
- 3: `Tests` 配下には、各モジュールに対応したテストが格納されています。こちらも Workshop で必要なものは既に用意しているため、必要に応じてファイルを編集して Workshop を進めてもらいます。

上記の通り、Workshop は基本的に「マルチモジュールとは何か」を理解していなくても進められる構成となることを意識して作成しています。  
もちろん、マルチモジュールに関する疑問が生じた時も遠慮なく質問してもらえればと思います！

## Workshop を始める準備が整いました

それでは <doc:TableOfContents> を早速始めていきましょう！
