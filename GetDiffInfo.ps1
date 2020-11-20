######################################################################
#
#　Diff取得
#
#　説明
#　　入力されたディレクトリのファイル情報のDiffを取得する
#
#
#　変更履歴
#　　・2020/11/21　新規作成
#
######################################################################

# 関数宣言

# メイン関数
Function Main([string]$cDir){

    # 変数宣言
    [string]$dir1
    [string]$dir2

    # 配列宣言
    [object]$tmp1 = @{}
    [object]$tmp2 = @{}

    # レジストリ変更
    ChangeRegistry "1"

    # ディレクトリ入力
    $dir1 = Read-Host "比較元のディレクトリを入力してください。"

    # 入力ディレクトリチェック
    if(!(DirCheck $dir1)){

        return
    
    }

    $dir2 = Read-Host "比較先のディレクトリを入力してください。"

    # 入力ディレクトリチェック
    if(!(DirCheck $dir2)){

        return
    
    }

    # ディレクトリ情報取得
    $tmp1 = GetDirInfo $dir1

    $tmp2 = GetDirInfo $dir2

    # Diff抽出
    OutDiff $cDir $tmp1 $tmp2
   
    # レジストリ変更
    ChangeRegistry "0"

}

# レジストリ変更処理
Function ChangeRegistry([string]$set){

    Set-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" -Name LongPathsEnabled -value $set

}

# ディレクトリチェック
Function DirCheck([string]$dir){

    # 入力チェック
    if($dir -eq ""){

        Write-Host "ディレクトリが入力されていません。"
        return $false
    
    }

    # ディレクトリ存在チェック
    if(!(Test-Path $dir)){

        Write-Host "入力されたディレクトリが存在しません。"
        return $false
    
    }

    return $true

}

# ディレクトリ情報取得
Function GetDirInfo([string]$dir){

    # 配列宣言
    [object]$tmp = @{}

    # ファイル検索
    Get-ChildItem -Path $dir -Filter * -Recurse | Where-Object { !$_.PSIsContainer } | %{

        # ディレクトリパス
        [string]$fullDir = $_.FullName

        # 置換処理
        [string]$changeDir = ReplaceStr $dir $fullDir
				
		# ファイルサイズ
		[string]$size = [decimal]("{0:N2}" -f ($_.Length / 1KB))
				
		# 最終更新日
        [string]$lastUpd =  $_.LastWriteTime.ToString("yyyy/MM/dd hh:mm:ss")

        # 配列への格納
        $tmp.add($changeDir, "$($lastUpd),$($size)")

	}

    return $tmp

}

# 置換処理
Function ReplaceStr([string]$dir, [string]$str){

    # 変数宣言
    [string]$rStr

    $rStr = $str.Replace($dir, "")
            
    return $rStr

}

# Diff抽出処理
Function OutDiff([string]$cDir, [object]$tmp1, [object]$tmp2){

    # 配列宣言
    [object]$result = @()

    $tmp1.keys + $tmp2.keys | Sort-Object | Get-Unique | Where-Object { $tmp1[$_] -ne $tmp2[$_] } |
        %{
            if(!$tmp1.containskey($_)){

                $result += ("only," + $dir2 + $_.Trim())
            
            }elseif(!$tmp2.containskey($_)){

                $result += ("only," + $dir1 + $_.Trim())

            }else{
            
                $result += ("differ," + $dir1 + $_.Trim() + "," + $tmp1[$_] + "," +$dir2 + $_.Trim() + "," + $tmp2[$_] )

            }
        }
    
    $result | Out-File -Append ($cDir + "`\" + "DiffInfo.txt") -Encoding default

}

# ps1ファイルの格納先を取得
[string]$cDir = Split-Path $myInvocation.MyCommand.Path -Parent

# Main関数実行
Main $cDir
