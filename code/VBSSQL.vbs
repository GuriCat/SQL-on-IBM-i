Option Explicit

Const adOpenStatic = 3 'カーソルタイプは静的カーソル
Const adLockReadOnly = 1 'ロックの種類は読み取り専用

Dim args
Dim conn, stmt, rs, SQLresult
Dim i

Set args = WScript.Arguments
Set conn = CreateObject("ADODB.Connection")
conn.Open "DRIVER=IBM i Access ODBC Driver;SYSTEM=" & args.item(0) & _
          ";UID=" & args.item(1) & ";PWD=" & args.item(2) & ";EXTCOLINFO=1"

stmt = "select * from GURILIB.TOKMSP where TKBANG like '02_10'"
Set rs = CreateObject("ADODB.Recordset")
rs.Open stmt, conn, adOpenStatic, adLockReadOnly

'COLHDGを取得
For i = 0 to rs.Fields.Count - 1
  if i > 0 Then SQLresult = RTrim(SQLresult) & vbTab
  SQLresult = RTrim(SQLresult) & rs.Fields(i).Name
Next
'ブランクの除去
SQLresult = Replace(SQLresult, " ", "")
SQLresult = Replace(SQLresult, "　", "")
WScript.echo RTrim(SQLresult) '見出し行(COLHDG)の出力
SQLresult = ""

'EOFまでデータを読み込み
Do Until rs.EOF
  For i = 0 to rs.Fields.Count - 1
    if i > 0 Then SQLresult = RTrim(SQLresult) & vbTab
    SQLresult = RTrim(SQLresult) & rs.Fields(i).Value
  Next
  WScript.echo RTrim(SQLresult) '明細行の出力
  SQLresult = ""
  rs.MoveNext '次の行をfetch
Loop

rs.Close
conn.Close
Set rs = Nothing
Set conn = Nothing
