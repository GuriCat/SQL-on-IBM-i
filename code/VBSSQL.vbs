Option Explicit

Const adOpenStatic = 3 '�J�[�\���^�C�v�͐ÓI�J�[�\��
Const adLockReadOnly = 1 '���b�N�̎�ނ͓ǂݎ���p

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

'COLHDG���擾
For i = 0 to rs.Fields.Count - 1
  if i > 0 Then SQLresult = RTrim(SQLresult) & vbTab
  SQLresult = RTrim(SQLresult) & rs.Fields(i).Name
Next
'�u�����N�̏���
SQLresult = Replace(SQLresult, " ", "")
SQLresult = Replace(SQLresult, "�@", "")
WScript.echo RTrim(SQLresult) '���o���s(COLHDG)�̏o��
SQLresult = ""

'EOF�܂Ńf�[�^��ǂݍ���
Do Until rs.EOF
  For i = 0 to rs.Fields.Count - 1
    if i > 0 Then SQLresult = RTrim(SQLresult) & vbTab
    SQLresult = RTrim(SQLresult) & rs.Fields(i).Value
  Next
  WScript.echo RTrim(SQLresult) '���׍s�̏o��
  SQLresult = ""
  rs.MoveNext '���̍s��fetch
Loop

rs.Close
conn.Close
Set rs = Nothing
Set conn = Nothing
