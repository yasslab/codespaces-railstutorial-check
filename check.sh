#!/usr/bin/env bash
# 受講者と同じ順で Codespaces のテンプレートを起動し、トップページが出るかを確かめる。
#   使い方: check.sh <テンプレートを checkout したディレクトリ>
# devcontainer.json の updateContentCommand（bundle install）と
# postAttachCommand（rails server）をなぞる。VS Code の拡張は確かめない。
set -euo pipefail

dir=$(cd "$1" && pwd)
tag="cs-check-$(basename "$dir" | tr '[:upper:]' '[:lower:]')"

echo "::group::docker build ($tag)"
docker build -t "$tag" "$dir/.devcontainer"
echo "::endgroup::"

# Codespaces はリポジトリを vscode（uid 1000）で開くので、書けるようにしておく
chmod -R a+rwX "$dir"

docker run --rm -v "$dir:/workspace" -w /workspace "$tag" bash -c '
  set -euo pipefail
  echo "::group::ruby・bundler の版"
  ruby -v; bundle -v
  echo "::endgroup::"

  echo "::group::bundle install（updateContentCommand）"
  bundle install
  echo "::endgroup::"

  echo "::group::rails test"
  bin/rails test
  echo "::endgroup::"

  echo "::group::rails console"
  echo "puts \"console ok: #{Rails.version}\"" | bin/rails console 2>&1 | tee /tmp/console.log
  grep -q "console ok:" /tmp/console.log
  echo "::endgroup::"

  echo "::group::rails server（postAttachCommand）とトップページ"
  # 前の実行の pid ファイルが残っていると「A server is already running」で起動しない
  rm -f tmp/pids/server.pid
  bin/rails server -b 127.0.0.1 -p 3000 > /tmp/server.log 2>&1 &
  for i in $(seq 1 60); do curl -fs -o /dev/null http://127.0.0.1:3000/ && break; sleep 1; done
  curl -fsS http://127.0.0.1:3000/ > /tmp/top.html || { cat /tmp/server.log; exit 1; }
  grep -q "セットアップ完了です" /tmp/top.html
  logo=$(grep -o "src=\"[^\"]*railstutorial[^\"]*\"" /tmp/top.html | head -1 | cut -d\" -f2)
  echo "ロゴ: $logo"
  curl -fsS -o /dev/null "http://127.0.0.1:3000/${logo#/}"
  echo "トップページとロゴを確かめた"
  echo "::endgroup::"
'
