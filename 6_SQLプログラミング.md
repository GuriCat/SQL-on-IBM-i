# 6 SQLプログラミング

<P> </P>

この章ではSQLを利用した、ILE-RPG、OPM-CL、VBS、Javaのサンプル・プログラムをコンパイル・実行します。いずれも、登録者マスターを条件指定付きで検索します。

<P> </P>

---

## 6.1 ILE-RPG 組み込みSQL

プログラム例の最初はILE-RPGの組み込みSQLです。

### 6.1.1 ILE-RPGプログラム：LMSSxxLIB/QRPGLESRC(ILERPGSQL)

```
000100      H DFTACTGRP(*NO) ACTGRP(*NEW) OPTION(*SRCSTMT : *NOUNREF : *NODEBUGIO)
000200       *
000300      D person_rec    E DS                  EXTNAME('LMSSXXLIB/PERSON')
000400      D stmt            S            500
000500      D recNo           S              5P 0 INZ(0)
000600      D dummy           S              1
000700       *
000800      C     *ENTRY        PLIST
000900      C                   PARM                    arg              32
001000       /FREE
001100
001200         stmt = 'SELECT * FROM LMSSXXLIB/PERSON ' +
001300                '         WHERE KJNAME LIKE ''%' + %TRIM(arg) + '%'' ' +
001400                '         FOR FETCH ONLY';
001500
001600         EXEC SQL PREPARE s1 FROM :stmt;
001700         EXEC SQL DECLARE c1 CURSOR FOR s1;
001800         EXEC SQL OPEN c1;
001900
002000         DOW (1 = 1);
002100           EXEC SQL FETCH c1 INTO :person_rec;
002200           IF %SUBST(SQLSTATE : 1 : 2) <> '00';
002300             LEAVE;
002400           ENDIF;
002500           recNo += 1;
002600           DSPLY (%EDITW(recNo : '0     :') + %CHAR(REGNO) + ',' + KJNAME);
002700         ENDDO;
002800
002900         EXEC SQL CLOSE c1;
003000         DSPLY (%CHAR(recNo) + '{件が選択されました。}') '' dummy;
003100
003200         *INLR = *ON;
003300         RETURN;
003400
003500       /END-FREE
```

* 3行目：外部データ構造としてファイル「LMSSxxLIB/PERSON」の定義を参照し、「person_rec」という名前のデータ構造を定義しています。SQLはこのデータ構造に、データベースから読み取ったデータを転送します。
* 21行目：「fetch」命令でデータを1レコード分読取り、ホスト変数「person_rec」に転送します。
* 22行目：SQLプリコンパイラーはSQLSTATEという変数 にSQL命令の戻り値を記録します。この変数の値 をチェックし、前のSQL命令(ここではfetch)が正常終了以外の場合にループを抜けます。

?> SQLSTATEは5バイトで、2文字のクラス・コード値とそれに続く3文字のサブクラス・コード値で構成されています。本来は「データなし」(EOF)を示す「02」と、それ以外のエラーを分け、必要な処理を行なうのが良いでしょう。

?> SQLSTATE クラス・コードのリストは「SQLSTATE クラス・コードのリスト」(https://www.ibm.com/support/knowledgecenter/ja/ssw_ibm_i_74/rzala/rzalaclass.htm)を参照。


* 26行目：データが正常に読み取られたらDSPLY命令で内容を画面に表示します。

　

従来のREAD/WRITEのコーディングと比較してもそれほど難易度は高くないでしょう。

IBM i でデータベースを使用する場合、DDSでPF/LFを作成し、RPGやCOBOLでデータを操作する事が多いと思います。これらDB操作のほとんどはSQLで置き換えできます。

?> ただし、現在問題なく稼働しているアプリケーションを書き換える必要は無いでしょう。グルーピングや件数カウント、トップ10の取得、複雑な条件選択など、SQL機能でプログラム全体の工数が減少し、品質とパフォーマンスの向上が見込める場合に検討をお勧めします。

<p>　</p>

### <u>ワーク7 ILE-RPG 組み込みSQLのコンパイルと実行</u>

<font color="red">※ ハンズオンに使用するIBM iで57xx-ST1 (IBM DB2 Query Manager and SQL Development Kit for i)が使用<u>できない</u>場合は、このワークはスキップしてください。</font>

**□ W7-1.** コマンド「WRKMBRPDM FILE(LMSSxxLIB/QRPGLESRC)」を実行し、メンバー「ILERPGSQL」の3および12行目の「LMSSxxLIB」を割り当てられた値に修正し、オプション14でコンパイル。または、下記コマンドで直接コンパイル。

```
> CRTSQLRPGI OBJ(LMSSxxLIB/ILERPGSQL) SRCFILE(LMSSxxLIB/QRPGLESRC)       
  {プログラム}ILERPGSQL{がライブラリー}LMSSXXLIB{に入れられました。最高の}
    {重大度は}00{。}20/12/XX{の}17:08:30{に作成されました。}             
```

**□ W7-2.** WRKMBRPDMの画面から「ILERPGSQL」にオプション「C」を指定してF4でプロンプトを表示し、パラメーターに任意の漢字1文字を指定して実行。または、下記コマンドで直接プログラムを実行。画面に指定した条件のレコードが表示されることを確認。

```
> CALL PGM(LMSSxxLIB/ILERPGSQL) PARM('{花}')
```

<p>　</p>

## 6.2 CLPでRUNSQL利用

次はOPM-CLの例です。

登録者マスターをSQLで照会して、その結果をワークファイルに保管、RCVFコマンドでワークファイルのデータを読み込んで画面に表示します。

?> RUNSQLコマンドが直接のSELECT文をサポートしていないためワークファイルを経由します。

?> DCLFで定義しているワークファイルをコンパイル前にに対話型SQLなどで作成します。

### 6.2.1 OPM-CLプログラム：LMSSXXLIB/QCLSRC(CLPSQL)

```
000100 /*{コンパイル前に次のコマンドを実行してテーブルを作成}              +
000200   RUNSQL SQL('CREATE TABLE QTEMP.@PERSON AS                         +
000300   (SELECT REGNO,KJNAME,KNNAME FROM LMSSXXLIB/PERSON) WITH NO DATA') +
000400   COMMIT(*NC)                                                       */
000500
000600              PGM        PARM(&ARG)
000700
000800              DCLF       FILE(QTEMP/@PERSON)
000900              DCL        VAR(&ARG) TYPE(*CHAR) LEN(32)
001000              DCL        VAR(&STMT) TYPE(*CHAR) LEN(500)
001100              DCL        VAR(&ROW_COUNT) TYPE(*INT) LEN(4) VALUE(0)
001200
001300              /*{ワークテーブルの削除}*/
001400              RUNSQL     SQL('DROP TABLE QTEMP.@PERSON') COMMIT(*NC)
001500              MONMSG     MSGID(CPF0000 SQL0000)
001600              /*{ワークテーブルの作成}*/
001700              RUNSQL     SQL('CREATE TABLE QTEMP.@PERSON AS (SELECT +
001800                           REGNO,KJNAME,KNNAME FROM +
001900                           LMSSXXLIB/PERSON) WITH NO DATA') COMMIT(*NC)
002000              /*{データの抽出}*/
002100              RUNSQL     SQL('INSERT INTO QTEMP.@PERSON +
002200                           (REGNO,KJNAME,KNNAME) SELECT +
002300                           REGNO,KJNAME,KNNAME FROM LMSSXXLIB.PERSON +
002400                           WHERE KJNAME LIKE ''%' |< &ARG |< '%''') +  
002500                           COMMIT(*NC)
002600
002700  LOOP:       RCVF
002800              MONMSG     MSGID(CPF0864) EXEC(DO)
002900                SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) +
003000                             MSGDTA('{データの終わり。}(' |< +
003100                             %CHAR(&ROW_COUNT) |< '{行読み込み})') +
003200                             TOPGMQ(*EXT) MSGTYPE(*INQ)
003300                GOTO       CMDLBL(EXIT)
003400              ENDDO
003500
003600              CHGVAR     VAR(&ROW_COUNT) VALUE(&ROW_COUNT + 1)
003700              SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) +
003800                           MSGDTA(%CHAR(&ROW_COUNT) |< ', ' |< +
003900                           %CHAR(&REGNO) |< ', ' |< &KJNAME |< ', ' +
004000                           |< &KNNAME) TOPGMQ(*EXT) MSGTYPE(*COMP)
004100              GOTO       CMDLBL(LOOP)
004200
004300  EXIT:       ENDPGM
```

* 14,17～19行目：CREATE TABLEで、カッコ内のSELECT文の構造でワークファイルを作成します。IBM i 7.1以降であれば、OR REPLACE構文を利用して1つのSQLでワークファイルを”存在した場合は削除してから”作成できます。また、ジャーナルをかけていないのでコミットメント制御にCOMMIT(*NC)を指定しています。
* 21～25行目：INSERT文で、副照会のSELECT文で指定したデータをワークファイルに挿入します。
* 27行目：ワークファイルを1レコードずつRCVFで読み取り、内容を画面に表示します。

<p></p>

OPNQRYF＋CPYFRMQRYFと似た処理なので、プログラム要件によって使い分けても良いでしょう。基本的に新規のプログラムはSQLの採用が望まれます。ただし、SQLはシフト欠けや10進データエラーで処理を中断するケースがあり、無条件の移行はお勧めしません。

なお、CLでは組み込みSQLが使えませんが、CLIを利用すればILE-RPG同様のロジックでプログラムを記述できます。CLI API、ILE-CLのポインターや定義済み記憶域などを理解していれば、ワークファイルを使わない、効率の良いプログラムが作成できるでしょう。

<p></p>

### <u>ワーク8 RUNSQLを含むCLPのコンパイルと実行</u>

**□ W8-1.** CLP内から参照するワークファイルを作成。

```
> RUNSQL SQL('CREATE TABLE QTEMP.@PERSON AS (SELECT REGNO,KJNAME,KNNAME FRO
  M LMSSxxLIB/PERSON) WITH NO DATA') COMMIT(*NC)                           
```

**□ W8-2.** コマンド「WRKMBRPDM FILE(LMSSxxLIB/QCLSRC)」を実行し、メンバー「CLPSQL」の19および23行目の「LMSSxxLIB」を割り当てられた値に修正し、オプション14でコンパイル。または、下記コマンドで直接コンパイル。

```
> CRTCLPGM PGM(LMSSxxLIB/CLPSQL) SRCFILE(LMSSxxLIB/QCLSRC)     
  {プログラム}CLPSQL{がライブラリー}LMSSXXLIB{に作成された。}  
```

**□ W8-3.** WRKMBRPDMの画面から「CLPSQL」にオプション「C」を指定してF4でプロンプトを表示し、パラメーターに任意の漢字1文字を指定して実行。または、下記コマンドで直接プログラムを実行。画面に指定した条件のレコードが表示されることを確認。

```
> CALL PGM(LMSSxxLIB/CLPSQL) PARM('{花}')
```

<p>　</p>

## 6.3 VBSでADO.NET(ODBC)

3つめはWindowsで動くVBSのサンプル・プログラムです。メモ帳など任意のテキストエディターで「VBSSQL.vbs」という名前のテキストファイルをWindowsのデスクトップに作成し、次のソースを入力します。

?> スクリプトの文字コードをANSI(シフトJIS)で作成するため、メモ帳で新規作成する場合は「NotePad /a パス名」のようにしてシフトJISを指定します。ユニコードなど、別の文字コードで作成した場合は「名前を付けて保存(A)...」で「文字コード(E)」に「ANSI」を指定して保管します。

### VBScript：C:\Users\(ユーザー名)\Desktop\VBSSQL.vbs

```
0001 Option Explicit
0002 
0003 Dim args, argCnt
0004 Dim conn, stmt, rs, SQLresult
0005 Dim i, recNo
0006 
0007 Set args = WScript.Arguments
0008 argCnt = WScript.Arguments.Count
0009 If argCnt <> 4 Then 
0010   WScript.Echo argCnt & "個の引数が指定されましたが、引数は4個でなくてはなりません。"
0011   WScript.Echo "使用例：CScript //nologo VBSSQL.vbs IBMiホスト名またはIPアドレス ユーザーID パスワード 検索キー"
0012   WScript.Quit
0013 End If
0014 
0015 Set conn = CreateObject("ADODB.Connection")
0016 conn.Open "DRIVER=IBM i Access ODBC Driver" & _
0017           ";SYSTEM=" & args.item(0) & _
0018           ";UID=" & args.item(1) & ";PWD=" & args.item(2) & _  
0019           ";CommitMode=0"           & _  
0020           ";ConnectionType=2"       & _  
0021           ";EXTCOLINFO=1"                
0022 
0023 stmt = "select REGNO, KJNAME, KNNAMEfrom LMSSxxLIB.PERSON where KJNAME like '%" & _
0024        args.item(3) & "%'"
0025 Set rs = CreateObject("ADODB.Recordset")
0026 rs.Open stmt, conn
0027 
0028 SQLresult = "No" & vbTab
0029 'COLHDGを取得
0030 For i = 0 to rs.Fields.Count - 1
0031   if i > 0 Then SQLresult = RTrim(SQLresult) & vbTab
0032   SQLresult = RTrim(SQLresult) & rs.Fields(i).Name
0033 Next
0034 'ブランクの除去
0035 SQLresult = Replace(SQLresult, " ", "")
0036 SQLresult = Replace(SQLresult, "　", "")
0037 WScript.echo RTrim(SQLresult) '見出し行(COLHDG)の出力
0038 
0039 recNo = 1
0040 SQLresult = CStr(recNo) & vbTab
0041 
0042 'EOFまでデータを読み込み
0043 Do Until rs.EOF
0044   For i = 0 to rs.Fields.Count - 1
0045     if i > 0 Then SQLresult = RTrim(SQLresult) & vbTab
0046     SQLresult = RTrim(SQLresult) & rs.Fields(i).Value
0047   Next
0048   recNo = recNo + 1
0049   WScript.echo RTrim(SQLresult) '明細行の出力
0050   SQLresult = CStr(recNo) & vbTab
0051   rs.MoveNext '次の行をfetch
0052 Loop
0053 
0054 rs.Close
0055 conn.Close
0056 Set rs = Nothing
0057 Set conn = Nothing
```

* 7行目：VBSを呼び出すときのパラメーターには、サーバーのIPアドレス、ユーザー、パスワード、検索値を指定します。
* 15～21行目：VBSは「conn」オブジェクトを生成し、指定されたODBCドライバーで、パラメーターの値に従ってデータソースに接続します。

?> 詳細はIBM Knowledge Centerの「Connection string keywords」(https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_74/rzaik/connectkeywords.htm 英文) 参照

  ※	ACSとともに配布されているWindows用ODBCドライバーをインストールすると、複数のODBCドライバーが登録されます。「IBM i Access ODBC Driver」以外は、古いドライバー名で参照するプログラムとの互換性のために残されているので、新規に作成する場合は「IBM i Access ODBC Driver」を指定します。

  ![6.3_VBSでADO.NET_ODBC_.jpg](/files/6.3_VBSでADO.NET_ODBC_.jpg)

* 23～26行目：SQLステートメントを登録、ADOのレコードセットを作成し、オープンします。SQLがサーバーで実行され、結果が利用できるようになります。
* 28行目：画面またはリダイレクトでファイルに出力する際に、後処理がしやすいようにタブ文字(vbTab)をフィールドとフィールドの間に入れます。
* 32行目：データを取得する前に、見出し用にCOLHDGをrsから取得 します。
* 43行目：EOFになるまで1行ずつ読み込んで見出し同様にタブ区切りで出力します。

<p>　</p>

バッチ処理的にユーザーの介入無しに実行するには、Windowsのコマンド・プロンプトからCScriptコマンドで呼び出します。

<p>　</p>

### <u>ワーク9 VB Scriptの実行</u>

**□ W9-1.** Windowsのコマンド・プロンプトを開き、現行ディレクトリーをデスクトップに移動。

```
C:\>cd %userprofile%\desktop
```

**□ W9-2.** メモ帳などのテキスト・エディターでスクリプト23行目の「LMSSxxLIB」を割り当てられた値に修正して保存し、CScriptコマンドでVBSを実行。指定した文字(漢字)を含むデータが表示されることを確認。

```
C:\Users\(Windowsのユーザー名)\Desktop>CScript //nologo VBSSQL.vbs (IBM iのホスト名またはIPアドレス) (ユーザー名) (パスワード) 花
No      登録番号        姓名    姓名（読み）
1       5       花田　蓮大      ﾊﾅﾀﾞ ﾚｵ
2       108     畠山　花帆      ﾊﾀｹﾔﾏ ｶﾎ
3       120     花田　義明      ﾊﾅﾀﾞ ﾖｼｱｷ
～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～
24      900     成田　花帆      ﾅﾘﾀ ｶﾎ
25      920     立花　聖吾      ﾀﾁﾊﾞﾅ ｾｲｺﾞ
```

<p>　</p>

## 6.4 JavaでJDBC利用

プログラム例の最後はJavaプログラムでJDBCを利用した例です。VBSのプログラム例と同じ動作をします。

### 6.4.1 Javaプログラム：C:\Users\(ユーザー名)\Desktop\JDBC.java

```
0001 import java.io.*;
0002 import java.sql.*;
0003 import com.ibm.as400.access.*;
0004 
0005 public class JDBC {
0006 
0007   public static void main(String[] args) throws Exception{
0008 
0009     if (args.length != 4){
0010         System.out.println(args.length +
0011             "個の引数が指定されましたが、引数は4個でなくてはなりません。");
0012         System.out.println("使用例：java -cp .:jt400.jar JDBC " +
0013             "IBMiホスト名またはIPアドレス ユーザーID パスワード 検索キー");
0014         System.exit(1);
0015     }
0016 
0017     Connection conn = null;
0018 
0019     Class.forName("com.ibm.as400.access.AS400JDBCDriver");
0020     conn = DriverManager.getConnection("jdbc:as400:" +
0021            args[0] + ";extended metadata=true;trace=false;", args[1], args[2]);
0022 
0023     Statement stmt = conn.createStatement();
0024     ResultSet rs = stmt.executeQuery(
0025         "select REGNO, KJNAME, KNNAME from LMSSxxLIB.PERSON where KJNAME like '%" +
0026          args[3] + "%'");
0027 
0028     ResultSetMetaData rsmd = rs.getMetaData();
0029 
0030     // COLHDGの取得とブランクの除去
0031     System.out.print("No\t");
0032     for (int i = 1 ; i <= rsmd.getColumnCount() ; i++) {
0033       System.out.print(rsmd.getColumnLabel(i).trim().replaceAll("[　 ]", ""));
0034       if (i < rsmd.getColumnCount()) System.out.print("\t");
0035     }
0036     System.out.println();
0037 
0038     int recNo = 1;
0039 
0040     // EOFまでデータを読み込み
0041     while (rs.next()) {
0042       System.out.print(recNo + "\t");
0043       for (int j = 1 ; j <= rsmd.getColumnCount() ; j++) {
0044         System.out.print(rs.getString(j).trim());
0045         if (j < rsmd.getColumnCount()) System.out.print("\t");
0046       }
0047       System.out.println();
0048       recNo++;
0049 
0050     }
0051     rs.close();
0052     stmt.close();
0053 
0054   }
0055 
0056 }
```

* 9行目：Javaプログラムを呼び出すときのパラメーターには、サーバーのIPアドレス、ユーザー、パスワード、検索値を指定します。
* 17～21行目：「conn」オブジェクトを生成し、指定されたJDBCドライバーで、パラメーターの値に従ってデータソースに接続します。

?> 詳細はIBM Knowledge Centerの「IBM Toolbox for Java: JDBC properties」(https://www.ibm.com/support/knowledgecenter/ja/ssw_ibm_i_74/rzahh/javadoc/com/ibm/as400/access/doc-files/JDBCProperties.html 英文) 参照

* 23～26行目：SQLステートメントと結果セットのオブジェクトを作成します。
* 31行目：画面またはリダイレクトでファイルに出力する際に、後処理がしやすいようにタブ文字(\t)をフィールドとフィールドの間に入れます。
* 33行目：データを取得する前に、見出し用にカラムのラベルを結果セットのメタデータから取得します。replaceAllメソッドの大括弧内には半角および全角のスペースを1文字ずつ記述しており、ラベル内のスペースを除去しています。
41行目：EOFになるまで1行ずつ読み込んで見出し同様にタブ区切りで出力します。

?> コネクションをオープンする時に「extended metadata=true」を指定して拡張情報の取得を可能としています。COLHDGはフィールドのNameプロパティで取り出せます。

<p>　</p>

### <u>ワーク10 JDBCを利用したJavaプログラムのコンパイルと実行 (Windows)</u>

<font color="red">※ ハンズオンに使用するWindows PCでJDK(Javaプログラムのコンパイル環境)が使用<u>できない</u>場合は、このワークはスキップしてください。</font>

**□ W10-1.** Windowsのコマンド・プロンプトを開き、現行ディレクトリーをデスクトップに移動し、メモ帳などのテキスト・エディターで「JDBC.java」の25行目の「LMSSxxLIB」を割り当てられた値に修正して保存し、javacコマンドでJavaプログラムを作成。

?> Javaプログラムのソースファイル「JDBC.java」をutf-8で作成しているので、javacコマンドで「-encoding utf8」を指定します。utf-8を使うのは、シフトJISのソースを記述すると、「\」(半角円記号)がIBM i 側で「\」(半角バックスラッシュ)と認識されない場合があるためです。

```
C:\>cd %userprofile%\desktop

C:\Users\(Windowsのユーザー名)\Desktop>javac -cp .;.\jt400.jar -encoding utf8 JDBC.java
□W10-2. Javaプログラムを実行し、指定した文字(漢字)を含むデータが表示されることを確認。
C:\Users\(Windowsのユーザー名)>java -cp .;.\jt400.jar JDBC (IBM iのホスト名またはIPアドレス) (ユーザー名) (パスワード) 花
No      登録番号        姓名    姓名（読み）
1       5       花田　蓮大      ﾊﾅﾀﾞ ﾚｵ
2       108     畠山　花帆      ﾊﾀｹﾔﾏ ｶﾎ
3       120     花田　義明      ﾊﾅﾀﾞ ﾖｼｱｷ
～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～
24      900     成田　花帆      ﾅﾘﾀ ｶﾎ
25      920     立花　聖吾      ﾀﾁﾊﾞﾅ ｾｲｺﾞ
```

<p>　</p>

### <u>ワーク11 (オプション) JDBCを利用したJavaプログラムのコンパイルと実行 (IBM i)</u>

<font color="red">※ ハンズオンに使用するIBM i で「IBM DEVELOPER KIT FOR JAVA」(57xx-JV1)が使用できない場合は、このワークはスキップしてください。</font>

**□ W11-1.** ACSの通信構成で、ホスト・コード・ページを939(5035の上位互換文字セット)または1399などの英小文字を使える設定にした5250セッションを起動し、サインオン。

**□ W11-2.** QshellおよびJavaの利用には英小文字環境が必要なので、ユーザープロフィールのCCSIDが日本語のデフォルト設定の場合は、CHGJOBコマンドで5035または1399にジョブのCCSIDを変更してIBM i にハンズオン用のディレクトリー「/tmp/LMSSxx」を作成。

```
> CHGJOB CCSID(1399)
> MKDIR DIR('/tmp/LMSSxx')       
  ディレクトリーが作成された。
```

**□ W11-3.** 「JDBC.java」と「jt400.jar」の2つのファイルをハンズオン用のディレクトリーにアップロード。

(FTP転送の例)

```
C:\Users\(Windowsのユーザー名)>ftp (IBM iのホスト名またはIPアドレス)
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
ftp> put JDBC.java
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO /tmp/LMSSXX/JDBC.java
226 FILE TRANSFER COMPLETED SUCCESSFULLY.
ftp: 1749 バイトが送信されました 0.01秒 249.86KB/秒。
ftp> put jt400.jar
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO /tmp/LMSSXX/jt400.jar
226 FILE TRANSFER COMPLETED SUCCESSFULLY.
ftp: 5051754 バイトが送信されました 2.93秒 1725.33KB/秒。
ftp> ls
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
125 LIST STARTED.
jt400.jar
JDBC.java
250 LIST COMPLETED.
ftp: 25 バイトが受信されました 0.00秒 8.33KB/秒。
ftp> quit
221	IT SUBCOMMAND RECEIVED.
```

**□ W11-4.** IBM i 上でJavaプログラムをコンパイルして実行。Windowsでの実行結果と差異が無い事を確認。

```
> QSH CMD('cd /tmp/LMSSxx ; javac -cp .:./jt400.jar JDBC.java')            
  {コマンドは終了状況}0{で正常に終了しました。}                            
> QSH CMD('cd /tmp/LMSSxx ; java -cp .:./jt400.jar JDBC localhost
  (ユーザー名) (パスワード)  花')                                                              

  No      {登録番号}      {姓名}  {姓名（読み）}      
  1       5       {花田　蓮大}    ﾊﾅﾀﾞ ﾚｵ             
  2       108     {畠山　花帆}    ﾊﾀｹﾔﾏ ｶﾎ            
  3       120     {花田　義明}    ﾊﾅﾀﾞ ﾖｼｱｷ           
～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～～
  24      900     {成田　花帆}    ﾅﾘﾀ ｶﾎ                 
  25      920     {立花　聖吾}    ﾀﾁﾊﾞﾅ ｾｲｺﾞ             
  実行キーを押して端末セッションを終了してください。   
```
