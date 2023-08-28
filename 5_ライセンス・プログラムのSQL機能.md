# 5 ライセンス・プログラムのSQL機能

<P> </P>

IBM i には、SQLを活用してプログラミング無しで容易にデータを取得できるライセンス・プログラムがいくつか提供されています。

具体的には「DB2 Web Query for i」をはじめとし、5250画面からSQLを利用したQueryを定義できる「Query管理機能」や、WebブラウザからSQLを定義して再利用が可能な「Access for Web/Mobile」があります。

?> WebQueryは当ガイドでは取りあげません。IBMからインターネットに多くの情報が提供されているので、そちらを参照ください。

これらのライセンス・プログラムは、既存のQuery/400の定義(*QRYDFN)を取り込んで再利用する機能も備えています。これを利用すれば既存のQueryのモダナイゼーションを効率よく実施できるでしょう。

?> インポートしたQMQRYはQuery/400の機能を完全に再現できるわけではありません。制約事項などの詳細は各ライセンス・プログラムのマニュアルを参照ください。

　
![5_ライセンス・プログラムのSQL機能.jpg](/files/5_ライセンス・プログラムのSQL機能.jpg)

なお、既存のQuery/400定義の棚卸にはIBMが"as is”(現状のまま)で提供している「Query/400 Discovery Tool」が役立つかもしれません。

?> マニュアルなど全て英語。入手方法など詳細は「Query/400 Discovery Tool」(https://www.ibm.com/support/pages/query400-discovery-tool-0 )を参照。

</p>　</p>

## 5.1 QMQRY

Query管理機能(以下QMQRYと呼称)を解説します。

QMQRYはIBM i オペレーティング・システムの機能で、さまざまなDb2プラットフォーム上のリレーショナル・データベースのデータにアクセスし、その結果を報告するための共通の方式を提供します。

QMQRYには様々な機能があります。

* STRQMコマンドでQuery/400に似たメニューでQMQRYを作成

?> STRQMコマンドは「IBM DB2 Query Manager and SQL Development Kit for i」(57xx-ST1)に含まれます(https://www.ibm.com/support/knowledgecenter/ja/ssw_ibm_i_74/rbam6/ST1.htm 参照)。QMQRYの(CRT|DLT|RTV|STR|WRK)QMQRYおよび(CRT|DLT|RTV|WRK)QMFORMコマンドはOSのカテゴリーに含まれます。

* Query/400の定義(*QRYDFN)のインポート
* SQL文を構成する変数をQMQRY実行時に動的に指定
* SQL文や出力の書式はソースを直接編集も可能
* DRDAで他のDBサーバーに接続してSQLを実行

より詳細な情報はマニュアル「Query管理プログラミング バージョン6 リリース1」(SC88-4018)などを参照ください。

STRQMコマンドを実行すると、「DB2 FOR IBM I QUERY管理機能」画面が表示され、新しいQMQRYを作成できます。Query/400同様に、「ファイルの指定」、「フィールドの選択および順序付け」、「レコードの選択」などを指定し、対話型にQMQRYを作成・編集・管理・実行できます。

![5.1_QMQRY.jpg](/files/5.1_QMQRY.jpg)

---

STRQMを使用せず、SQL文をソースに記述して容易にQMQRYを作成できます。作業の流れを下図に示します。

![5.1_QMQRY2.jpg](/files/5.1_QMQRY2.jpg)

</p>　</p>

### <u>ワーク6 QMQRYの作成と実行</u>

**□ W6-1.** 新規にQMQRYを作成する例。ソースファイル「LMSSxxLIB/QQMQRYSRC」をレコード長79で作成し、メンバー「QMQRYSQL」に “住所に任意の値を含むデータを選択して名前(カナ)の昇順でソート” するSQLを記述。実行時に内容を動的に展開する部分は「&変数名」と指定。
```
> CRTSRCPF FILE(LMSSxxLIB/QQMQRYSRC) RCDLEN(79) IGCDTA(*YES) 
  ライブラリーLMSSXXLIBにファイルQQMQRYSRCが作成された。
> STRSEU SRCFILE(LMSSxxLIB/QQMQRYSRC) SRCMBR(QMQRYSQL)
```
```
桁 . . . . . :    1  71            編集                   LMSSXXLIB/QQMQRYSRC
 SEU==>                                                                QMQRYSQL
 FMT **  ...+... 1 ...+... 2 ...+... 3 ...+... 4 ...+... 5 ...+... 6 ...+... 7 
        ****************** データの始め ***************************************
0001.00 SELECT * FROM LMSSXXLIB/PERSON                                         
0002.00          WHERE PREF LIKE &PARM                                         
0003.00          ORDER BY KNNAME                                               
        ***************** データの終わり **************************************
```

**□ W6-2.** CRTQMQRYコマンドでオブジェクト*QMQRYを作成。

```
> CRTQMQRY QMQRY(LMSSxxLIB/QMQRYSQL) SRCFILE(LMSSXXLIB/QQMQRYSRC)
```

**□ W6-3.** 作成したQMQRYをSTRQMQRYコマンドで実行して画面に表示。この時に置換変数に検索条件を指定。

```
> STRQMQRY QMQRY(LMSSxxLIB/QMQRYSQL) SETVAR((PARM '''{％東京％}'''))
```
```
                                 報告書の表示                                   
 QUERY. . . . .:   LMSSXXLIB/QMQRYSQL        幅 . . . .:       284              
書式 . . . . .:   *SYSDFT                   桁 . . . .:         1              
制御 . . . . .                                                                 
  行    ....+....1....+....2....+....3....+....4....+....5....+....6....+....7. 
           登録番号    姓名                    姓名（読み）          性別     
          ----------  ----------------------  --------------------  ------  --- 
 000001         599    上野　浩之             ｱｶﾞﾉ ﾋﾛﾕｷ             M       032 
 000002         918    安東　孝次             ｱﾝﾄﾞｳ ｺｳｼﾞ            M       034 
 000003         660    岩瀬　仁継             ｲﾜｾ ﾏｻﾂｸﾞ             M       031 
 000004          95    柏木　温人             ｶｼﾜｷﾞ ﾊﾙﾄ             M       035 
 000005         984    北山　成康             ｷﾀﾔﾏ ﾅﾘﾔｽ             M       039 
 000006         305    木下　伸浩             ｷﾉｼﾀ ﾉﾌﾞﾋﾛ            M       030 
 000007          14    高谷　安               ｺｳﾔ ﾔｽｼ               M       037 
 000008         484    武田　英紀             ﾀｹﾀﾞ ﾋﾃﾞﾉﾘ            M       031 
 000009         621    塚本　隆二             ﾂｶﾓﾄ ﾘｭｳｼﾞ            X       031 
 000010         511    永田　国男             ﾅｶﾞﾀ ｸﾆｵ              M       034 
 000011         423    長田　洋次             ﾅｶﾞﾀ ﾖｳｼﾞ             M       038 
 000012         409    西　章一               ﾆｼ ｼｮｳｲﾁ              M       031 
 000013          47    野中　慶太             ﾉﾅｶ ｹｲﾀ               M       031 
 000014         101    秦　健介               ﾊﾀ ｹﾝｽｹ               M       038 
                                                                       続く ... 
 F3= 終了   F12= 取消し   F19= 左   F20= 右   F21= 分割                         
                                                                                
```

**□ W6-4.** 既存のQuery/400定義を取り込んたQMQRYを作成。ハンズオンでは下記設定で作成した*QRYDFNオブジェクト「LMSSxxLIB/QRY400」を使用。

|QUERY定義オプション|指定値|
|------------------|-----|
|ファイル選択指定|LMSSxxLIB/PERSON|
|フィールドの選択および順序付け|REGNO(登録番号)、KJNAME(姓名)、GENDER(性別)、PREF(都道府県)、ADDR1(住所１)|
|レコードの選択|PREF LIKE '{％福％}'|
|分類フィールドの選択|PREF昇順|
|計算機能の選択|PREF カウント|
|報告書の切れ目の定義|PREF 切れ目レベル1|
|出力タイプおよび出力形式の選択|出力のタイプ「印刷装置」、カバー・ページの印刷「N」、ページ見出し「登録者リスト（県別）」|

(RUNQRYコマンドの実行)
```
> RUNQRY QRY(LMSSxxLIB/QRY400) QRYFILE((LMSSxxLIB/PERSON)) OUTTYPE(*PRINTER)
```

(印刷出力)
```
20/12/04  14:33:04                  登録者リスト（県別）                    ページ     1
 登録番号    姓名                    性別    都道府県    住所１
      32     富沢　貞次               X      福井県　    越前市
      50     山上　茂志               X                  大野市
     109     森田　愛佳               F                  敦賀市
     115     津田　勝彦               M                  坂井市
～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～
     666     市原　翔平               M                  朝倉市
     690     小村　来実               F                  筑紫郡那珂川町
     813     藤田　利昭               M                  北九州市若松区
     917     奥　芳太郎               X                  福津市
                                       ｶｳﾝﾄ 18
                                       最終合計
                                       ｶｳﾝﾄ 64
***  報　告　書　の　終　わ　り  ***
```

**□ W6-5.** 書式定義を取り込むソースファイル「LMSSxxLIB/QQMFORMSRC」をレコード長150で作成。

```
> CRTSRCPF FILE(LMSSxxLIB/QQMFORMSRC) RCDLEN(150) IGCDTA(*YES)  
  {ライブラリー}LMSSXXLIB{にファイル}QQMFORMSRC{が作成された。}
```

**□ W6-6.** RTVQMQRYコマンド、および、RTVQMFORMコマンドでQuery/400の定義をソースファイルに取り込む。

```
> RTVQMQRY QMQRY(LMSSxxLIB/QRY400) SRCFILE(LMSSxxLIB/QQMQRYSRC) SRCMBR(NEWQ
  RY400) ALWQRYDFN(*YES)                                                   
  {派生情報を使用して}RTVQMQRY{コマンドが完了した。}                       
> RTVQMFORM QMFORM(LMSSxxLIB/QRY400) SRCFILE(LMSSxxLIB/QQMFORMSRC) SRCMBR(N
  EWQRY400F) ALWQRYDFN(*YES)                                               
  {派生情報を使用して}RTVQMFORM{コマンドが完了した。}                      

```

**□ W6-7.** ソースメンバー「LMSSxxLIB/QQMQRYSRC(NEWQRY400)」のライブラリー名をハンズオン用ライブラリーに修正

```
. 桁. . . . . :    1  67            編集                   LMSS01LIB/QQMQRYSRC 
 SEU==>                                                              NEWQRY400
 FMT **  ...+... 1 ...+... 2 ...+... 3 ...+... 4 ...+... 5 ...+... 6 ...+..     
        ****************** データの始め **************************************
0001.00 H QM4 05 Q 01 E V W E R 01 03 19/21/01 17:02                            
0002.00 V 1001 050                                                              
0003.00 V 5001 004 *HEX                                                         
0004.00 SELECT                                                                  
0005.00   ALL       REGNO, KJNAME, GENDER, PREF, (PREF), ADDR1                  
0006.00   FROM      LMSSXXLIB/PERSON T01                                        
0007.00   WHERE     PREF LIKE '{％福％}'                                        
0008.00   ORDER BY  004 ASC                                                     
        ***************** データの終わり *************************************
```

**□ W6-8.** 取り込んだソースから新しいQMQRYとQMFORMを作成。

```
> CRTQMQRY QMQRY(LMSSxxLIB/NEWQRY400) SRCFILE(LMSSxxLIB/QQMQRYSRC)     
> CRTQMFORM QMFORM(LMSSxxLIB/NEWQRY400F) SRCFILE(LMSSxxLIB/QQMFORMSRC)
```

**□ W6-9.** 作成したQMQRYを、QMFORMを指定して実行。元のQuery(0参照)と出力内容を比較。

```
> OVRPRTF FILE(QPQXPRTF) PAGESIZE(*N 100)                                  
> STRQMQRY QMQRY(LMSSxxLIB/NEWQRY400) OUTPUT(*PRINT) QMFORM(LMSSxxLIB/NEWQR
  Y400F)                                                                   
```

(印刷出力)
```
                                        登録者リスト（県別）
                                                        ｶｳﾝﾄ
 登録番号    姓名                    性別    都道府県   PREF         住所１
----------  ----------------------  ------  ----------  ----------  ---------------------
       32    富沢　貞次             X        福井県　    福井県　    越前市
       50    山上　茂志             X                    福井県　    大野市
      109    森田　愛佳             F                    福井県　    敦賀市
      115    津田　勝彦             M                    福井県　    坂井市
～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～
      666    市原　翔平             M                    福岡県　    朝倉市
      690    小村　来実             F                    福岡県　    筑紫郡那珂川町
      813    藤田　利昭             M                    福岡県　    北九州市若松区
      917    奥　芳太郎             X                    福岡県　    福津市
                                                        ----------
                                                     *          18
                                                        ==========
                                                                64
20/12/04 14:44:10                                                                           2
```

<p>　</p>

## 5.2 Access for Web/Mobile (解説のみ)

Access for WebはIBM i システム上のさまざまなリソースへのWebブラウザー・ベースのアクセスを提供します。多くの機能の1つに「SQLの実行」があり、WebブラウザだけでSQLを活用できます。

?> IBM i Access for Web(5770-XH2)は、IBM i Access Family(5770-XW1)のファミリー製品で、XW1のライセンスで利用できます。2001年9月に提供が開始され、その後も機能を追加しており、2015年5月にはIBM i Access Mobileが同梱されるようになりました。

![5.2_Access_for_Web.jpg](/files/5.2_Access_for_Web.jpg)

単にSQLを実行するだけではなく、ウィザードによるガイドや、実行結果のローカルへの保存、SQL文の保存と再利用が可能です。これらはモバイル機器でも利用できるので、あらかじめ定義したSQLをタブレットで実行することもできます。

Access for Wenbは「URLインターフェース」を提供しており、Webサービス的な使い方も可能です。例えばSQLの実行は「iWADbExec」なので、下のURLは、「October」をパラメーターマーカーに設定して「Monthly sales」というSQLリクエストを実行、結果を「October.pdf」に保管する、リクエストを表します。

![5.2_Access_for_Web2.jpg](/files/5.2_Access_for_Web2.jpg)

Access for WebはSQL以外の機能も豊富であり、インストール・構成も容易なので、一度評価する事をお勧めします。
