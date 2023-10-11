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

上記が問題ないことを確認しましょう。

### GitHub の Personal Access Token の準備

Workshop では、GitHub の API を利用することになります。  
GitHub の API は Personal Access Token (PAT) を利用することで、より多くの回数のリクエストが行えるようになります。  
無闇やたらに API を利用するわけではないですが、Workshop を円滑に進めるための準備として PAT を用意してもらいます。

[personal access token (classic) の作成](https://docs.github.com/ja/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#personal-access-token-classic-%E3%81%AE%E4%BD%9C%E6%88%90) を参考に PAT を作成してください。  
GitHub の API を利用するために必要な、`repo` scope が最低限設定されていれば問題ありません。

PAT を用意できたら、PAT をコピーし Xcode Project の Build Settings にある User-Defined 内の `GITHUB_PERSONAL_ACCESS_TOKEN` に設定してください。

![](pat-user-defined.png)

## Workshop を始める準備が整いました

準備が整ったところで、<doc:TableOfContents> を早速始めていきましょう！
