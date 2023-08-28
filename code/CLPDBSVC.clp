0001.00              PGM        PARM(&GETSTATUS)
0002.00              DCLF       FILE(QTEMP/ACTJOB) ALWVARLEN(*YES)
0003.00              DCL        VAR(&GETSTATUS) TYPE(*CHAR) LEN(32)
0004.00              DCL        VAR(&STMT) TYPE(*CHAR) LEN(500)
0005.00              DCL        VAR(&MSG) TYPE(*CHAR) LEN(500)
0006.00              DCL        VAR(&ROW_COUNT) TYPE(*INT) LEN(4) VALUE(0)
0007.00              DCL        VAR(&CPU_DEC) TYPE(*DEC) LEN(4 2)
0008.00              DCL        VAR(&CPU_CHAR) TYPE(*CHAR) LEN(8)
0009.00
0010.00              /*ワークテーブルの削除*/
0011.00              CHGVAR     VAR(&STMT) VALUE('DROP TABLE QTEMP.ACTJOB')
0012.00              RUNSQL     SQL(&STMT) COMMIT(*NC)
0013.00              MONMSG     MSGID(CPF0000 SQL0000)
0014.00              /*ワークテーブルの作成*/
0015.00              /* IBM I 7.2以降であればOR REPLACEが利用可能*/
0016.00              CHGVAR     VAR(&STMT) VALUE('CREATE TABLE QTEMP.ACTJOB +
0017.00                           AS (SELECT SUBSYSTEM, JOB_NAME, +
0018.00                           AUTHORIZATION_NAME, JOB_TYPE, +
0019.00                           ELAPSED_CPU_PERCENTAGE, FUNCTION_TYPE, +
0020.00                           FUNCTION, JOB_STATUS FROM TABLE +
0021.00                           (QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => +
0022.00                           ''ALL'')) X ) WITH NO DATA')
0023.00              RUNSQL     SQL(&STMT) COMMIT(*NC)
0024.00              /*データの抽出*/
0025.00              CHGVAR     VAR(&STMT) VALUE('INSERT INTO QTEMP.ACTJOB +
0026.00                           SELECT IFNULL(SUBSYSTEM, '' +
0027.00                           ''),IFNULL(JOB_NAME, '' +
0028.00                           ''),IFNULL(AUTHORIZATION_NAME, '' +
0029.00                           ''),IFNULL(JOB_TYPE, '' +
0030.00                           ''),IFNULL(ELAPSED_CPU_PERCENTAGE, +
0031.00                           0),IFNULL(FUNCTION_TYPE, '' +
0032.00                           ''),IFNULL(FUNCTION, '' +
0033.00                           ''),IFNULL(JOB_STATUS, '' '') FROM TABLE +
0034.00                           (QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => +
0035.00                           ''ALL'')) X WHERE JOB_STATUS = +
0036.00                           UCASE(TRIM(''' |< &GETSTATUS |< ''')) +
0037.00                           ORDER BY SUBSYSTEM, JOB_NAME')
0038.00              RUNSQL     SQL(&STMT) COMMIT(*NC)
0039.00
0040.00              SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) +
0041.00                           MSGDTA('状況が' |< &GETSTATUS |< +
0042.00                           'のジョブ。') TOPGMQ(*EXT) MSGTYPE(*COMP)
0043.00
0044.00  LOOP:       RCVF
0045.00              MONMSG     MSGID(CPF0864) EXEC(DO)
0046.00              SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) +
0047.00                           MSGDTA('データの終わり。(' |< +
0048.00                           %CHAR(&ROW_COUNT) |< '行読み込み)') +
0049.00                           TOPGMQ(*EXT) MSGTYPE(*INQ)
0050.00              GOTO       CMDLBL(EXIT)
0051.00              ENDDO
0052.00
0053.00              CHGVAR     VAR(&ROW_COUNT) VALUE(&ROW_COUNT + 1)
0054.00              CHGVAR     VAR(&CPU_DEC) VALUE(&ELAPS00006)
0055.00              CHGVAR     VAR(&CPU_CHAR) VALUE(&CPU_DEC)
0056.00              CHGVAR     VAR(&MSG) VALUE(%SST(&SUBSYSTEM 3 10) |< ', +
0057.00                           ' || %SST(&JOB_NAME 3 28) |< ', ' || +
0058.00                           %SST(&AUTHO00001 3 10) |< ', ' || +
0059.00                           %SST(&JOB_TYPE 3 3) |< ', ' || +
0060.00                           %SST(&CPU_CHAR 4 5) |< '%, ' |> +
0061.00                           %SST(&FUNCT00001 3 3) |< '-' || +
0062.00                           %SST(&FUNCTION 3 10))
0063.00              SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA(&MSG) +
0064.00                           TOPGMQ(*EXT) MSGTYPE(*COMP)
0065.00              GOTO       CMDLBL(LOOP)
0066.00
0067.00  EXIT:       ENDPGM
