# codespaces-railstutorial-check

Railsチュートリアルの Codespaces のテンプレート（[codespaces-railstutorial](https://github.com/yasslab/codespaces-railstutorial)・[codespaces-railstutorial-v8](https://github.com/yasslab/codespaces-railstutorial-v8)）が、受講者と同じ手順で起動するかを毎朝確かめます。

テンプレートは、リポジトリを変えていなくても、外の物（gem・イメージ・証明書など）が変わって壊れることがあります。受講者より先に気づくための見張りです。

## 何を確かめるか

`check.sh` が、テンプレートの `.devcontainer/Dockerfile` をビルドし、そのコンテナで次の順に動かします。

1. `bundle install`（`devcontainer.json` の `updateContentCommand`）
2. `bin/rails test`
3. `bin/rails console` が起動するか
4. `bin/rails server`（`postAttachCommand`）を起動し、トップページに「セットアップ完了です」とロゴ画像が出るか

VS Code の拡張（Ruby LSP・Solargraph）と、GitHub 側の Codespaces の不調は確かめません。

テンプレートの中に workflow を置かないのは、「Use this template」で受講者のリポジトリにも写り、受講者のところでも毎日動いてしまうためです。

## 手元で動かす

```sh
git clone --depth 1 https://github.com/yasslab/codespaces-railstutorial-v8.git template
./check.sh template
```
