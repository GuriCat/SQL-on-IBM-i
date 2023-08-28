# 4 SQL直接実行

<P> </P>

サーバーを使っていると、SQLを直接実行したいシーンがあります。

例えば、一回きりのデータベース操作や、SQLをプログラムに組み込む前の動作確認、あるいは、処理結果の出力ファイルをチェックする、などの目的で、SQLを即時実行できると便利です。

ここではSQLを直接実行する方法として、「対話型SQL」「SQLスクリプト」「db2コマンド」の3つを紹介します。

?> SQLを実行するCLコマンドの「RUNSQL」および「RUNSQLSTM」は、プログラミングのパートで利用します。

![4_SQLを直接実行する方法.jpg](/files/4_SQLを直接実行する方法.jpg)

<P>　</P>

## 4.1 対話型SQL

対話型SQLは57xx-ST1が前提です。5250画面からSTRSQLコマンドで起動し、そのままSQL文を入力して実行できます。SELECT文を実行するとQuery/400に似た画面が表示されます。

<P> </P>

### <u>ワーク2 対話型SQLの実行 (57xx-ST1が使用可能な場合)</u>

<font color="red">>※ ハンズオンに使用するIBM iで57xx-ST1 (IBM DB2 Query Manager and SQL Development Kit for i)が使用<u>できない</u>場合は、このワークはスキップしてください。</font>

**□ W2-1.** IBM i にサインオンして、STRSQLコマンドを実行します。

**□ W2-2.** 対話型SQLの画面が表示されるので、下記のSQLが実行してください。

?> F9で前のコマンドをコピーしたり、F4でプロンプを出してフィールド一覧を表示したりできます。

* 現行スキーマをLMSSxxLIBに指定。
```
> SET CURRENT SCHEMA LMSSXXLIB                     
```

* SELECT文でテーブルLMSSxxLIB/PERSONのデータを表示。
```
> SELECT * FROM PERSON
```

* 住所に「東京」を含むデータを選択して名前(カナ)の昇順にSELECT文を実行。

?> 「含む」の判定にLIKE演算子を使用しています。LIKEのパターンマッチングに使用する「%」(ワイルドカード)は「{％東京％}」(大文字)でも「%{東京}%」(小文字)でも同じ結果が得られます。

```
> SELECT * FROM PERSON WHERE PREF LIKE '{％東京％}' ORDER BY KNNAME
```

* 都道府県ごとにデータを集計(COUNT)し、上位10都道府県を表示。
```
> SELECT PREF, COUNT(PREF) AS NUM FROM PERSON GROUP BY PREF ORDER BY
  NUM DESC FETCH FIRST 10 ROWS ONLY                                 
```

(参考：連番を先頭に付加)

![W2-2_連番を付加するSQL.jpg](/files/W2-2_連番を付加するSQL.jpg)

**□ W2-3.**  (オプション) 「SELECT」とのみ打鍵してF4でプロンプトを出し、「WHERE条件」にカーソルを移動してF4を押すと、フィールド一覧を表示します。

**□ W2-4.** ワークが終了したら、「F3」→「実行キー」で対話型SQLを終了します。

<p>　</p>

## 4.2 SQLスクリプト

「SQLスクリプト」はACSをインストールしたクライアントで実行します。様々なSQLの「例」の呼出しや、SQLアシスト、ソースの整形、Visual ExplainやDBモニターの呼び出し、などなど、非常に機能が充実しています。

SQLを実行した結果はウインドゥ下部に表示され、Excel、CSV、タブ区切り形式などでクライアントに保存できます。ACSの一部としてインストールされるので、今後の主流になるでしょう。

<p>　</p>

### <u>ワーク3 SQLスクリプトの実行</u>

**□ W3-1.** SQLスクリプトの起動にはいくつかの方法がありますが、ACSの5250セッションを使用している場合、ツールバーの歯車アイコンをクリックして起動します。

![ワーク3_SQLスクリプトの実行.jpg](/files/ワーク3_SQLスクリプトの実行.jpg)

**□ W3-2.** SQLスクリプトが起動するので、対話型SQLと同様のSQL文(□W2-2参照)を入力し、「全て実行」(砂時計が重なっているアイコン   )をクリックして実行します。

?> SQLスクリプトには複数のSQL文を記述できます。区切り文字は「;」(セミコロン)です。

* 行スキーマをLMSSxxLIBに指定。
* SELECT文でテーブルLMSSxxLIB/PERSONのデータを表示。
* 住所に「東京」を含むデータを選択して名前(カナ)の昇順にSELECT文を実行。
* 都道府県ごとにデータを集計(COUNT)し、上位10都道府県を表示。

**□ W3-3.** (オプション) SQLスクリプトの機能を確認。

1. 予約語や定数などの文字色や字体が変わる事を確認。
2. 下のペインに表形式で表示された検索結果を右クリックしてメニューを表示し、「結果の保存(S...)」を選択し、テキストやxlsx形式で自PCに保管。
3. 下ペインのタブで「メッセージ」をクリックして実行履歴や警告・エラーなどを、「グローバル変数および特殊レジスター」をクリックして実行環境を確認。
![ワーク3_SQLスクリプトの実行2.jpg](/files/ワーク3_SQLスクリプトの実行2.jpg)
4. SELECT文の末尾に「FOR UPDATE」を追加してSQLを実行し、下ペインの選択されたデータの任意のフィールドを左ダブルクリックしてデータの編集が可能である事を確認。
![ワーク3_SQLスクリプトの実行3.jpg](/files/ワーク3_SQLスクリプトの実行3.jpg)
5. 任意のSQL文(「SELECT * FROM ...」など)を選択し、メニューの「編集(E)」→「SQLフォーマッター」→「選択した項目のフォーマット (Ctrl+Shift+F)」を実行し、選択したSQL文が整形されることを確認。
![ワーク3_SQLスクリプトの実行4.jpg](/files/ワーク3_SQLスクリプトの実行4.jpg)


<p>　</p>

## 4.3 ACSのcldownloadプラグイン

ACSをIBM i上でバッチ実行し、SELECT文の結果を任意のファイル形式(xlsx、CSVなど)でIBM i上に作成できます。この機能ではユーザーの操作が不要なので、例えばスケジューラーで定期的にSQLを実行し、その結果をメールで配信したり、管理情報として蓄積したりすることができます。

具体的には、ACSのjarファイル「acsbundle.jar」をIBM iの任意のディレクトリーに配置し、起動時のコマンド行オプションに「/PLUGIN=cldownload」を、「/sql=」にダブルクォーテーションでSQL文を指定して実行します。

<p>　</p>

### <u>ワーク4 (オプション) ACSのcldownloadプラグインの実行</u>

**□ W4-1.** ACSのjarファイル「acsbundle.jar」をハンズオン用のディレクトリーにアップロード。

?> WindowsにACSを「install_acs_64.js」などのインストーラーで導入した場合のディレクトリーは「C:\Users\(Windowsのユーザー名)\IBM\ClientSolutions」(単一ユーザー)、または、「C:\Users\Public\IBM\ClientSolutions」(マルチユーザー)となり、このディレクトリーに「acsbundle.jar」が存在します。また、IBM iに「ACS PTF」(2020/2/18時点で7.4: SI71900、7.3: SI71934、7.2:SI71935)が適用されている場合は「/QIBM/ProdData/Access/ACS/Base」に「acsbundle.jar」を含めたACSランタイム一式がインストールされています。

(FTP転送の例)
```
C:\>cd \Users\%username%\IBM\ClientSolutions

C:\Users\(Windowsのユーザー名)\IBM\ClientSolutions>ftp (IBM iのホスト名またはIPアドレス)
XXXX に接続しました。
220-QTCP AT XXXX.CO.JP.
220 CONNECTION WILL CLOSE IF IDLE MORE THAN 5 MINUTES.
501 OPTS UNSUCCESSFUL; SPECIFIED SUBCOMMAND NOT RECOGNIZED.
ユーザー (ibmi:(none)): (IBM i のユーザーID)
331 ENTER PASSWORD.
パスワード:(IBM i のパスワード)
230 LMSSXX LOGGED ON.
ftp> cd /tmp/LMSSxx
250-NAMEFMT SET TO 1.
250 "/tmp/LMSSXX" IS CURRENT DIRECTORY.
ftp> bi
200 REPRESENTATION TYPE IS BINARY IMAGE.
ftp> put acsbundle.jar
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO /tmp/LMSSXX/acsbundle.jar
226 FILE TRANSFER COMPLETED SUCCESSFULLY.
ftp: 133955025 バイトが送信されました 68.57秒 1953.47KB/秒。
ftp> quit
221 QUIT SUBCOMMAND RECEIVED.
```

**□ W4-2.** ホスト・コード・ページ5035または1399で構成したACSの5250セッションからサインオンし、ACSのプラグインでSQLの結果をファイルに変換。

?> プラグインの詳細はACS導入ディレクトリーの「Documentation/GettingStarted_ja.html」を参照。「/clientfile」で指定した拡張子に合わせた形式でファイルが作成されます。他にもデータ転送プラグインなどが提供されており、「/plugin=dtbatch /(IFSディレクトリー)/(転送定義).dtfx」と指定してデータ転送をIBM i上でバッチ実行する(転送ファイルをIFSに生成)、などが可能です。

?> IBM iのデフォルトのJavaが古いために実行時エラーが発生する場合などは、「ADDENVVAR ENVVAR(JAVA_HOME) VALUE('/QOpenSys/QIBM/ProdData/JavaVM/jdk80/64bit')」の要領でJVMを明示的に指定。

```
> CHGJOB CCSID(1399)
> QSH CMD('java -Dcom.ibm.iaccess.ActLikeExternal=true -jar /tmp/LMSSXX/acs
  bundle.jar /plugin=cldownload /system=127.0.0.1 /clientfile=/tmp/LMSSxx/p
  erson.xlsx /sql="select * from lmssxxlib/person" > /tmp/LMSSxx/cldownload
  .log')                                                                   
  {コマンドは終了状況}0{で正常に終了しました。}                            
> DSPF STMF('/tmp/LMSSxx/cldownload.log')
```

```
  ﾎﾞ[cﾇﾞ: /tmp/LMSSxx/cldownload.log                  
  ﾛﾃｰnﾞ:        1   OF       3 BY  18                 
 {制御}:                                              
                                                      
....+....1....+....2....+....3....+....4....+....5....
 *************{データの始め}****************          
{転送要求が完了しました。}                            
{転送統計}: 00:00:03                                  
{転送された行}: 1,000                                 
 ***********{データの終わり}******************        
```
**□ W4-3.** 生成された「/tmp/LMSSxx/person.xlsx」を、FTPやACSのIFSシステム・プラグイン、NetServerファイル共有などでWindowsにダウンロードし、Excelで開いて内容を確認。

![W4-3_Excel画像.jpg](/files/W4-3_Excel画像.jpg)


<p>　</p>

## 4.4 db2コマンド

「db2」コマンドはLUWでも使われているSQLへのコマンド・ライン・インターフェースです。

?> db2コマンドの解説はIBM Knowledge Center (https://www.ibm.com/support/knowledgecenter/ja/ssw_ibm_i_74/rzahz/rzahzdb2utility.htm)などを参照。

ホスト・コード・ページに英小文字が使える「939」または「1399」を指定した5250エミュレーターからサインオンし、ジョブまたはユーザープロフィールのCCSIDにホスト・コード・ページと同じ値(939の場合は5035)に設定し、Qshellから「db2 “SQL文”」で実行できます。

5250端末以外からも、WindowsやLinuxなどのシェルからsshでIBM i のPASEシェルに接続してdb2コマンドを実行できます。

?> Permissionエラーになる時は、「ln -s /QOpenSys/usr/bin/qsh /QOpenSys/usr/bin/db2」を実行しておきます (参照：https://comp.sys.ibm.as400.misc.narkive.com/hIIXY1N0/using-db2-under-pase) 。PASE環境ではbashも使えるので、シェルスクリプトやPythonなどのスクリプト言語と組み合わせて使うと効果的でしょう。

<p>　</p>

### <u>ワーク5 db2コマンドの実行</u>

<font color="red">※ ハンズオンに使用するIBM iで57xx-SS1 オプション30 (QSHELL)が使用<u>できない</u>場合は、このワークはスキップしてください。</font>

**□ W5-1.** ACSの通信構成で、ホスト・コード・ページを939(5035の上位互換文字セット)または1399などの英小文字を使える設定にした5250セッションを起動し、サインオン。

**□ W5-2**. Qshellの利用には英小文字環境が必要なので、ユーザープロフィールのCCSIDが日本語のデフォルト設定の場合は、CHGJOBコマンドで5035または1399にジョブのCCSIDを変更してQshellを起動。

?> Qshell対話式セッションの利用方法はIBM Knowledge Center (https://www.ibm.com/support/knowledgecenter/ja/ssw_ibm_i_74/rzahz/rzahzcommands.htm )などを参照。出力は画面幅で折り返されていますが、F11を押すとQuery/400のように1行表示になり、F19/F20で左右に横スクロールして結果を確認できます。

```
> chgjob ccsid(1399)   
> qsh                  
```

**□ W5-3.** Qshellから「db2 -i」を実行して対話式SQLセッションを起動し、対話型SQLと同様(□W2-2参照)のSQL文を入力して実行。

* 現行スキーマをLMSSxxLIBに指定。
* SELECT文でテーブルLMSSxxLIB/PERSONのデータを表示。
* 住所に「東京」を含むデータを選択して名前(カナ)の昇順にSELECT文を実行。
* 都道府県ごとにデータを集計(COUNT)し、上位10都道府県を表示。

(実行例)
```
                              QSH{コマンド入力}                                
                                                                               
  $                                                                            
> db2 -i                                                                       
  DB2>                                                                         
> SET CURRENT SCHEMA LMSSXXLIB                                                 
  DB20000I  THE SQL COMMAND COMPLETED SUCCESSFULLY.                            
  DB2>                                                                         
> SELECT * FROM PERSON                                                         
                                                                               
  REGNO   KJNAME                 KNNAME               GENDER  TEL          MOBI
  ------- ---------------------- -------------------- ------- ------------ ----
       1  {滝川　厚}             ﾀｷｶﾞﾜ ｱﾂｼ            M       0539725342   0808
       2  {川西　節男}           ｶﾜﾆｼ ｾﾂｵ             M       0749915677   0902
～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～
     999  {野上　裕次郎}         ﾉｶﾞﾐ ﾕｳｼﾞﾛｳ          X       0247626730   0803
    1000  {藤島　勝義}           ﾌｼﾞｼﾏ ｶﾂﾖｼ           M       0192596977   0807
                                                                               
  1000 RECORD(S) SELECTED.                                                     
                                                                               
  DB2>                                                                         
> SELECT * FROM PERSON WHERE PREF LIKE '{％東京％}' ORDER BY KNNAME            
                                                                               
  REGNO   KJNAME                 KNNAME               GENDER  TEL          MOBI
  ------- ---------------------- -------------------- ------- ------------ ----
     599  {上野　浩之}           ｱｶﾞﾉ ﾋﾛﾕｷ            M       0328373596   0808
     918  {安東　孝次}           ｱﾝﾄﾞｳ ｺｳｼﾞ           M       0344740393   0904
～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～
     193  {松村　穂乃花}         ﾏﾂﾑﾗ ﾎﾉｶ             F       0325719255   0904
     681  {吉原　正一}           ﾖｼﾜﾗ ｼｮｳｲﾁ           M       0380476270   0904
                                                                               
   18 RECORD(S) SELECTED.                                                      
                                                                               
  DB2>                                                                         
> SELECT PREF, COUNT(PREF) AS NUM FROM PERSON GROUP BY PREF ORDER BY NUM DESC F
  ETCH FIRST 10 ROWS ONLY 
                          
  PREF       NUM          
  ---------- -----------  
  {岡山県　}          32  
  {熊本県　}          29  
  {沖縄県　}          29  
  {山梨県　}          27  
  {鳥取県　}          27  
  {京都府　}          27  
  {徳島県　}          26  
  {三重県　}          24  
  {福島県　}          24  
  {香川県　}          24  
                          
   10 RECORD(S) SELECTED. 
                          
  DB2>                    
> quit                    
  $                    
```

**□ W5-4.** 「DB2>」プロンプトから「help」でdb2対話型セッションの組み込みコマンド一覧を表示。動作の確認が終了したら、「quit」または「exit」でSQL対話型セッションを終了。

**□ W5-5.** 次に、Qshellからdb2コマンドのパラメーターで対話型SQLと同様(□W2-2参照)のSQL文を指定して実行。

?> Qshellで直接実行する場合、メタ文字(「!」「*」「?」「[」)のパターン展開を抑止するため、引用符(クォーテーションなど)を指定します。

* SELECT文でテーブルLMSSxxLIB/PERSONのデータを表示。

?>db2コマンドを直接(対話型ではなく)使用する場合はsetが効かないため、SELECT文で修飾ライブラリー名を使用します。

* 住所に「東京」を含むデータを選択して名前(カナ)の昇順にSELECT文を実行。
* 都道府県ごとにデータを集計(COUNT)し、上位10都道府県を表示。

(実行例)
```
                              QSHコマンド入力                                
                                                                               
  $                                                                            
> db2 'SELECT * FROM LMSSXXLIB.PERSON'                                         
                                                                               
  REGNO   KJNAME                 KNNAME               GENDER  TEL          MOBI
  ------- ---------------------- -------------------- ------- ------------ ----
       1  {滝川　厚}             ﾀｷｶﾞﾜ ｱﾂｼ            M       0539725342   0808
       2  {川西　節男}           ｶﾜﾆｼ ｾﾂｵ             M       0749915677   0902
～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～
     999  {野上　裕次郎}         ﾉｶﾞﾐ ﾕｳｼﾞﾛｳ          X       0247626730   0803
    1000  {藤島　勝義}           ﾌｼﾞｼﾏ ｶﾂﾖｼ           M       0192596977   0807
                                                                               
  1000 RECORD(S) SELECTED.                                                     
                                                                               
  $                                                                            
> db2 "SELECT * FROM LMSSXXLIB.PERSON WHERE PREF LIKE '{％東京％}' ORDER BY KNN
  AME"                                                                         
                                                                               
  REGNO   KJNAME                 KNNAME               GENDER  TEL          MOBI
  ------- ---------------------- -------------------- ------- ------------ ----
     599  {上野　浩之}           ｱｶﾞﾉ ﾋﾛﾕｷ            M       0328373596   0808
     918  {安東　孝次}           ｱﾝﾄﾞｳ ｺｳｼﾞ           M       0344740393   0904
～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～
     193  {松村　穂乃花}         ﾏﾂﾑﾗ ﾎﾉｶ             F       0325719255   0904
     681  {吉原　正一}           ﾖｼﾜﾗ ｼｮｳｲﾁ           M       0380476270   0904
                                                                               
   18 RECORD(S) SELECTED.                                                      
                                                                               
  $                                                                            
> db2 'SELECT PREF, COUNT(PREF) AS NUM FROM LMSSXXLIB.PERSON GROUP BY PREF ORDE
  R BY NUM DESC FETCH FIRST 10 ROWS ONLY' 
                                          
  PREF       NUM                          
  ---------- -----------                  
  {岡山県　}          32                  
  {熊本県　}          29 
  {沖縄県　}          29 
  {山梨県　}          27 
  {鳥取県　}          27 
  {京都府　}          27 
  {徳島県　}          26 
  {三重県　}          24 
  {福島県　}          24 
  {香川県　}          24 
                         
   10 RECORD(S) SELECTED.
                         
  $                      
```

**□ W5-6.** 動作の確認が終了したら、F3キーでQshellを終了します。

?> F12キーでCLのDSCJOBコマンドのようにQshellセッションを一時的に切断できます。このキーは端末ウィンドウをクローズするだけで、Qshellセッションを終了させるわけではありません。切断したQshellセッションは、STRQSHを再び実行すれば再表示できます。
