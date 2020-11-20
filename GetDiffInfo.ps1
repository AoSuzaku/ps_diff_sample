######################################################################
#
#　Diff取得
#
#　説明
#　　入力されたディレクトリのファイル情報のDiffを取得する
#
#
#　変更履歴
#　　・2020/11/XX　新規作成
#
######################################################################

# 関数宣言

# メイン関数
Function Main(){

    # 変数宣言
    [string]$dir1
    [string]$dir2

    # 配列宣言
    [string[][][][]]$tmp1 = @()
    [string[][][][]]$tmp2 = @()

    # レジストリ変更
    ChangeRegistry "1"

    # ディレクトリ入力
    $dir1 = Read-Host "比較元のディレクトリを入力してください。"

    # ディレクトリが存在しない場合
    if(!(DirCheck $dir1)){

        Write-Host "入力されたディレクトリが存在しません。"
        return
    
    }

    $dir2 = Read-Host "比較先のディレクトリを入力してください。"

    # ディレクトリが存在しない場合
    if(!(DirCheck $dir2)){

        Write-Host "入力されたディレクトリが存在しません。"
        return
    
    }

    # ディレクトリ情報取得
    $tmp1 = GetDirInfo $dir1

    $tmp2 = GetDirInfo $dir2

    #for($i = 0; $i -lt $tmp1.Length; $i++){
    
    #    Write-Host $tmp1[$i]

    #}
    
    # レジストリ変更
    ChangeRegistry "0"

}

# レジストリ変更処理
Function ChangeRegistry([string]$set){

    Set-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" -Name LongPathsEnabled -value $set

}

# ディレクトリチェック
Function DirCheck([string]$dir){

    # ディレクトリ存在チェック
    if(!(Test-Path $dir)){

        return $false
    
    }

    return $true

}

# ディレクトリ情報取得
Function GetDirInfo([string]$dir){

    # 配列宣言
    [string[][][][]]$tmp = @()

    # ファイル検索
    Get-ChildItem -Path $dir -Filter * -Recurse | Where-Object { !$_.PSIsContainer } | %{

        # ディレクトリパス
        [string]$fullDir = $_.FullName

        # 置換処理
        [string]$changeDir = ReplaceStr $fullDir
				
		# ファイルサイズ
		[string]$size = [decimal]("{0:N2}" -f ($_.Length / 1KB))
				
		# 最終更新日
        [string]$lastUpd =  $_.LastWriteTime.ToString("yyyy/MM/dd hh:mm:ss")

        # 配列への格納
        $tmp += ,@($changeDir, $fullDir, $size, $lastUpd)

	}

    return $tmp

}

# 置換処理
Function ReplaceStr([string]$str){

    # 変数宣言
    [string]$rStr

    $rStr = $str.Replace("\\jeis.co.jp\jeisfs\root\150_7_カードシステム部\", "").Replace("00_共通\", "").Replace("01605340_カードFEP系PJ\","")
    $rStr = $rStr.Replace("G:\共有ドライブ\", "").Replace("【01605340】カードFEP系プロジェクト\", "").Replace("カード00_共通1\", "").Replace("カード00_共通2\", "").Replace("カード00_共通3\", "").Replace("カード00_共通4\", "").Replace("カード00_共通5\", "").Replace("カード00_共通6\", "")
            
    return $rStr

}

# Main関数実行
Main
