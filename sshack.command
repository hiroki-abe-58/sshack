#!/bin/bash

# タイトル表示関数
show_title() {
    echo "=================================================="
    echo "          サイレンス トリマー ハック"
    echo "    (音声ファイルの前後に無音を追加するツール)"
    echo "=================================================="
    echo ""
}

# ffmpegがインストールされているか確認
check_ffmpeg() {
    if ! command -v ffmpeg &> /dev/null; then
        echo "エラー: ffmpegがインストールされていません。"
        echo "Homebrewを使ってインストールするには次のコマンドを実行してください:"
        echo "brew install ffmpeg"
        echo ""
        echo "終了するには何かキーを押してください..."
        read -n 1
        exit 1
    fi
}

# メイン処理
main() {
    show_title
    check_ffmpeg
    
    # ファイルパスの入力を求める
    echo "処理したい音声ファイルのパスを入力してください (wav, mp3, m4a対応):"
    read file_path
    
    # ファイルの存在確認と拡張子チェック
    if [ ! -f "$file_path" ]; then
        echo "エラー: ファイル '$file_path' が見つかりません。"
        exit 1
    fi
    
    extension="${file_path##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$extension" != "wav" && "$extension" != "mp3" && "$extension" != "m4a" ]]; then
        echo "エラー: サポートされていないファイル形式です。wav, mp3, m4aのみ対応しています。"
        exit 1
    fi
    
    # 無音の長さを指定
    echo "追加する無音の長さを秒単位で入力してください (小数点第3位まで指定可能):"
    read silence_duration
    
    # 入力値が数値かチェック
    if ! [[ "$silence_duration" =~ ^[0-9]+(\.[0-9]{1,3})?$ ]]; then
        echo "エラー: 無効な数値です。正の数値を入力してください (例: 2 または 1.5)。"
        exit 1
    fi
    
    # 出力ファイル名を生成
    filename=$(basename "$file_path")
    filename_without_ext="${filename%.*}"
    directory=$(dirname "$file_path")
    timestamp=$(date +"%Y%m%d%H%M%S")
    output_file="${directory}/${filename_without_ext}_前後無音_${timestamp}.wav"
    
    echo ""
    echo "処理を開始します..."
    echo "  - 元ファイル: $file_path"
    echo "  - 無音の長さ: ${silence_duration}秒"
    echo "  - 出力ファイル: $output_file"
    echo ""
    
    # ffmpegコマンドを実行
    ffmpeg -i "$file_path" -af "adelay=${silence_duration}s:all=true,apad=pad_dur=${silence_duration}" -y "$output_file" 2>&1
    
    # 処理結果の確認
    if [ $? -eq 0 ]; then
        echo ""
        echo "SUCCESS ${output_file##*/} は保存されました"
    else
        echo ""
        echo "エラー: 処理中に問題が発生しました。"
    fi
    
    echo ""
    echo "終了するには何かキーを押してください..."
    read -n 1
}

# メイン関数を実行
main
