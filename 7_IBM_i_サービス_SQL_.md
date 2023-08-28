# 7 IBM i サービス (SQL)

<P> </P>

　
## 7.1 IBM i サービスの概要

この章ではIBM i 6.1から提供されている「IBM i サービス」を取りあげます。

IBM Knowledge Centerによると、「IBM i サービス」とは、「システム提供のSQLビュー、プロシージャー、および関数によりアクセスできる多数のシステム・サービス」をあらわし、OS(Db2 for i)の一部として提供されます。

IBM i サービスの実体は、様々な機能へのSQLインターフェースです。従来はCLプログラムや、システムAPIを使用したプログラムで実現していた機能をSQLで実現できます。しかし、IBM i サービスは、従来のCLコマンドやシステムAPIを置き換えるものでは無く、新しい選択肢と考えるべきでしょう。

CLコマンド、システムAPI、IBM i サービスの簡単な比較を表にしました。

?> 表には記載していませんが、IBM i サービスとCLコマンドのドキュメントは基本的に日本語でIBM Knowledge Centerに記載されており、システムAPIは英語のみとなっています。

![7.1_IBM_i_サービスの概要.jpg](/files/7.1_IBM_i_サービスの概要.jpg)

* CLコマンドはIBM i 運用の基本であり、もっとも広く使われています。IBM i のバージョンが変わっても、CLコマンドの仕様変更がアプリケーションに影響する事はまれです。

?> ただし、コマンドの印刷出力をPFに書き出して情報を得る、などの処理を行っている場合はこの限りではありません。

* システムAPIもCLコマンドと同様に古くから利用されています。システムAPIは非常に広範囲、かつ、高機能であり、CLコマンドで取得できない情報を利用したい場合や、CLコマンドがOUTFILEパラメーターを持たない場合に利用されることが多いでしょう。古いシステムAPIはユーザースペースに各種情報を取得しますが、より新しいAPIはメモリ上のバッファーに直接情報を取得します。このため、より有効に活用するには、ILE言語がサポートする、ポインターや整数型、プロシージャーなどの知識が必要になります。

* IBM i サービスには多数の「例」が提供されており、IBM i とSQLの基本知識があれば難易度はそれほど高くありません。SQLを発行すれば、システムAPIに近いレベルの詳細情報が取得できます。ただし、CLコマンドやシステムAPIと比較すると、カバー範囲は限定されています。また、新しいサービスが最新のIBM i リリースに追加された場合、サポートが終了しているIBM i リリースには反映されないようです。

<p>　</p>

---

IBM i サービスの最大の特徴は、SQLインターフェースを採用していることです。下図は、CLコマンドなど従来の手法と比較した時の、SQLインターフェースのメリットとデメリットです。多くの場合にSQLインターフェースにメリットがありますが、デメリットもあることが分ります。

![7.1_IBM_i_サービスの概要2.jpg](/files/7.1_IBM_i_サービスの概要2.jpg)

CLやAPIが無くなるわけではなく、すでに構築済みの仕組みをIBM i サービスに移行しなくてはならないという事はありません。新たに仕組みを作成する場合や、現行の仕組みを改善する場合に、IBM i サービスの採用を検討するのが現実的でしょう。

IBM i サービスのより詳細な情報は、IBM Knowledge Centerの他、「IBM i Services (SQL)」(https://www.ibm.com/support/pages/ibm-i-services-sql 英文)や、YouTubeの動画「IBM i サービス (SQL) 概説編」(https://www.youtube.com/watch?v=x2hKUbiJxYo )などの参照をお勧めします。

<p>　</p>

## 7.2 IBM i サービス利用例 (特定状態のジョブの表示)

IBM i サービスの利用例として、特定の状態のジョブを表示するOPM-CLプログラムのサンプルを取りあげます。

パラメーターに「状態」を指定してプログラムをCallすると、該当するジョブの情報を画面に表示します。例えば、特定のジョブが「MSGW」や「LCKW」で中断していないかをチェックしたり、ジョブ間の排他制御のために特定のジョブの死活を確認したりできます。このような処理はジョブ制御やメッセージ送信、応答などCL機能との連携が必要となる場合が多いため、IBM i サービスをCLで実装すればすっきり記述できるでしょう。

![7.2_IBM_i_サービス利用例.jpg](/files/7.2_IBM_i_サービス利用例.jpg)

IBM i サービスが提供するテーブル関数「QSYS2.ACTIVE_JOB_INFO」で特定の状態のジョブを照会し、その結果をワークファイルに保管、RCVFコマンドでワークファイルのデータを読み込んで画面に表示します。

6.2.1のサンプル同様にワークファイルを使用しますが、元となるテーブル関数のカラムは「ヌル値使用可能」や「可変長フィールド」の属性を持つため、それぞれコーディングで対応しています。従来の(ILEではない)CLでもIBM i サービスを利用できることがおわかりいただけると思います。

<p>　</p>

### 7.2.1 OPM-CLプログラム：LMSSxxLIB/QCLSRC(CLPDBSVC)

```
000100 /*{コンパイル前に次のコマンドを実行してテーブルを作成}                      +
000200   RUNSQL SQL('CREATE TABLE QTEMP.ACTJOB AS (SELECT SUBSYSTEM, JOB_NAME, AUT +
000300   HORIZATION_NAME, JOB_TYPE, ELAPSED_CPU_PERCENTAGE, FUNCTION_TYPE, FUNCTIO +
000400   N, JOB_STATUS FROM TABLE (QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => ''ALL'') +
000500   ) X ) WITH NO DATA') COMMIT(*NC)                                          */
000600
000700              PGM        PARM(&GETSTATUS)
000800
000900              DCLF       FILE(QTEMP/ACTJOB) ALWVARLEN(*YES)
001000              DCL        VAR(&GETSTATUS) TYPE(*CHAR) LEN(32)
001100              DCL        VAR(&STMT) TYPE(*CHAR) LEN(500)
001200              DCL        VAR(&MSG) TYPE(*CHAR) LEN(500)
001300              DCL        VAR(&ROW_COUNT) TYPE(*INT) LEN(4) VALUE(0)
001400              DCL        VAR(&CPU_DEC) TYPE(*DEC) LEN(4 2)
001500              DCL        VAR(&CPU_CHAR) TYPE(*CHAR) LEN(8)
001600
001700              /*{ワークテーブルの削除}*/
001800              RUNSQL     SQL('DROP TABLE QTEMP.ACTJOB') COMMIT(*NC)
001900              MONMSG     MSGID(CPF0000 SQL0000)
002000              /*{ワークテーブルの作成}*/
002100              RUNSQL     SQL('CREATE TABLE QTEMP.ACTJOB AS (SELECT +
002200                           SUBSYSTEM, JOB_NAME, AUTHORIZATION_NAME, +
002300                           JOB_TYPE, ELAPSED_CPU_PERCENTAGE, +
002400                           FUNCTION_TYPE, FUNCTION, JOB_STATUS FROM +
002500                           TABLE +
002600                           (QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => +
002700                           ''ALL'')) X ) WITH NO DATA') COMMIT(*NC)
002800              /*{データの抽出}*/
002900              RUNSQL     SQL('INSERT INTO QTEMP.ACTJOB SELECT +
003000                           IFNULL(SUBSYSTEM, '' ''),IFNULL(JOB_NAME, +
003100                           '' ''),IFNULL(AUTHORIZATION_NAME, '' +
003200                           ''),IFNULL(JOB_TYPE, '' +
003300                           ''),IFNULL(ELAPSED_CPU_PERCENTAGE, +
003400                           0),IFNULL(FUNCTION_TYPE, '' +
003500                           ''),IFNULL(FUNCTION, '' +
003600                           ''),IFNULL(JOB_STATUS, '' '') FROM TABLE +
003700                           (QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => +
003800                           ''ALL'')) X WHERE JOB_STATUS = +
003900                           UCASE(TRIM(''' |< &GETSTATUS |< ''')) +
004000                           ORDER BY SUBSYSTEM, JOB_NAME') COMMIT(*NC)
004100
004200              SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) +
004300                           MSGDTA(' 状況が ' |< &GETSTATUS |< +
004400                           '{のジョブ。}') TOPGMQ(*EXT) MSGTYPE(*COMP)
004500
004600  LOOP:       RCVF
004700              MONMSG     MSGID(CPF0864) EXEC(DO)
004800                SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) +
004900                             MSGDTA('{データの終わり。}(' |< +
005000                             %CHAR(&ROW_COUNT) |< '{行読み込み})') +
005100                             TOPGMQ(*EXT) MSGTYPE(*INQ)
005200                GOTO       CMDLBL(EXIT)
005300              ENDDO
005400
005500              CHGVAR     VAR(&ROW_COUNT) VALUE(&ROW_COUNT + 1)
005600              CHGVAR     VAR(&CPU_DEC) VALUE(&ELAPS00006)
005700              CHGVAR     VAR(&CPU_CHAR) VALUE(&CPU_DEC)
005800              CHGVAR     VAR(&MSG) VALUE(%SST(&SUBSYSTEM 3 10) |< ', +
005900                           ' || %SST(&JOB_NAME 3 28) |< ', ' || +
006000                           %SST(&AUTHO00001 3 10) |< ', ' || +
006100                           %SST(&JOB_TYPE 3 3) |< ', ' || +
006200                           %SST(&CPU_CHAR 4 5) |< '%, ' |> +
006300                           %SST(&FUNCT00001 3 3) |< '-' || +
006400                           %SST(&FUNCTION 3 10))
006500              SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA(&MSG) +
006600                           TOPGMQ(*EXT) MSGTYPE(*COMP)
006700              GOTO       CMDLBL(LOOP)
006800
006900  EXIT:       ENDPGM
```

* 18～27行目：活動ジョブの情報を取得するIBM i サービスのユーザー定義表関数である「QSYS2.ACTIVE_JOB_INFO」から、空のワークファイルを作成します。
* 29～40行目：再度「QSYS2.ACTIVE_JOB_INFO」を呼出し、指定された状況のジョブ情報をワークファイルに書き込みます。SQL文の中では、IFNULLスカラー関数でヌルの場合は空白を返すようにしています。COALESCEスカラー関数や、非ヌルの文字型にCASTする方法などもあるので、使いやすい方法で良いでしょう。
* 58行目：IBM i の可変長フィールドは、フィールド長が65535以下の場合は2バイト、それ以外は4バイトなので、%SST組み込み関数で長さ以外のデータ部分のみを取り出しています。データ部分を固定長としていますが、本来は最初の2/4バイトで示される長さ分だけ取り出すか、CASTで固定長文字フィールドにするべきでしょう。
* 65～66行目：ワークファイルのデータを画面に出力します。

<p>　</p>

### <u>ワーク12 CLP＋RUNSQLコマンドで特定の状態のジョブを表示</u>

**□ W12-1.** CLP内から参照するワークファイルを作成。

```
> RUNSQL SQL('CREATE TABLE QTEMP.ACTJOB AS (SELECT SUBSYSTEM, JOB_NAME, AUT
  HORIZATION_NAME, JOB_TYPE, ELAPSED_CPU_PERCENTAGE, FUNCTION_TYPE, FUNCTIO
  N, JOB_STATUS FROM TABLE (QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => ''ALL'')
  ) X ) WITH NO DATA') COMMIT(*NC)                                         
```

**□ W12-2.** コマンド「WRKMBRPDM FILE(LMSSxxLIB/QCLSRC)」を実行し、メンバー「CLPDBSVC」をオプション14でコンパイル。または、下記コマンドで直接コンパイル。

```
> CRTCLPGM PGM(LMSSxxLIB/CLPDBSVC) SRCFILE(LMSSxxLIB/QCLSRC)    
  {プログラム}CLPDBSVC{がライブラリー}LMSSXXLIBに作成された。 
```

**□ W12-3.** WRKMBRPDMの画面から「CLPDBSVC」にオプション「C」を指定してF4でプロンプトを表示し、パラメーターにジョブ状況(「DEQW」「TIMW」「RUN」など)を指定して実行。または、下記コマンドで直接プログラムを実行。画面に指定した条件のレコードが表示されることを確認。

```
> CALL PGM(LMSSxxLIB/CLPDBSVC) PARM(SIGW)  
```

{状況がSIGWのジョブ。}                                                  
```
QHTTPSVR, 098757/QTMHHTTP/ADMIN, QTMHHTTP, BCH, 00.00%, PGM-QZHBMAIN      
QHTTPSVR, 098763/QTMHHTTP/ADMIN, QTMHHTTP, BCI, 00.01%, PGM-QZSRLOG       
QHTTPSVR, 098772/QTMHHTTP/ADMIN, QTMHHTTP, BCI, 00.01%, PGM-QZSRHTTP      
QHTTPSVR, 100705/QTMHHTTP/IWAIAS, QTMHHTTP, BCH, 00.00%, PGM-QZHBMAIN     
QHTTPSVR, 100706/QTMHHTTP/IWAIAS, QTMHHTTP, BCI, 00.01%, PGM-QZSRLOG      
QHTTPSVR, 100708/QTMHHTTP/IWAIAS, QTMHHTTP, BCI, 00.01%, PGM-QZSRHTTP     
QSYSWRK, 098715/QDIRSRV/QGLDPUBA, QDIRSRV, ASJ, 00.00%, PGM-QGLDPUBA      
QSYSWRK, 098761/QYPSJSVR/QYPSJSVR, QYPSJSVR, BCH, 00.02%, PGM-jvmStartPa  
{データの終わり。}(8{行読み込み})                                         
```
