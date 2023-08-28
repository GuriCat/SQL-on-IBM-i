             PGM        PARM(&GETSTATUS)
             DCLF       FILE(QTEMP/ACTJOB) ALWVARLEN(*YES)
             DCL        VAR(&GETSTATUS) TYPE(*CHAR) LEN(32)
             DCL        VAR(&STMT) TYPE(*CHAR) LEN(500)
             DCL        VAR(&MSG) TYPE(*CHAR) LEN(500)
             DCL        VAR(&ROW_COUNT) TYPE(*INT) LEN(4) VALUE(0)
             DCL        VAR(&CPU_DEC) TYPE(*DEC) LEN(4 2)
             DCL        VAR(&CPU_CHAR) TYPE(*CHAR) LEN(8)

             /*ワークテーブルの削除*/
             CHGVAR     VAR(&STMT) VALUE('DROP TABLE QTEMP.ACTJOB')
             RUNSQL     SQL(&STMT) COMMIT(*NC)
             MONMSG     MSGID(CPF0000 SQL0000)
             /*ワークテーブルの作成*/
             /* IBM I 7.2以降であればOR REPLACEが利用可能*/
             CHGVAR     VAR(&STMT) VALUE('CREATE TABLE QTEMP.ACTJOB +
                          AS (SELECT SUBSYSTEM, JOB_NAME, +
                          AUTHORIZATION_NAME, JOB_TYPE, +
                          ELAPSED_CPU_PERCENTAGE, FUNCTION_TYPE, +
                          FUNCTION, JOB_STATUS FROM TABLE +
                          (QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => +
                          ''ALL'')) X ) WITH NO DATA')
             RUNSQL     SQL(&STMT) COMMIT(*NC)
             /*データの抽出*/
             CHGVAR     VAR(&STMT) VALUE('INSERT INTO QTEMP.ACTJOB +
                          SELECT IFNULL(SUBSYSTEM, '' +
                          ''),IFNULL(JOB_NAME, '' +
                          ''),IFNULL(AUTHORIZATION_NAME, '' +
                          ''),IFNULL(JOB_TYPE, '' +
                          ''),IFNULL(ELAPSED_CPU_PERCENTAGE, +
                          0),IFNULL(FUNCTION_TYPE, '' +
                          ''),IFNULL(FUNCTION, '' +
                          ''),IFNULL(JOB_STATUS, '' '') FROM TABLE +
                          (QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => +
                          ''ALL'')) X WHERE JOB_STATUS = +
                          UCASE(TRIM(''' |< &GETSTATUS |< ''')) +
                          ORDER BY SUBSYSTEM, JOB_NAME')
             RUNSQL     SQL(&STMT) COMMIT(*NC)

             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) +
                          MSGDTA('状況が' |< &GETSTATUS |< +
                          'のジョブ。') TOPGMQ(*EXT) MSGTYPE(*COMP)

 LOOP:       RCVF
             MONMSG     MSGID(CPF0864) EXEC(DO)
             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) +
                          MSGDTA('データの終わり。(' |< +
                          %CHAR(&ROW_COUNT) |< '行読み込み)') +
                          TOPGMQ(*EXT) MSGTYPE(*INQ)
             GOTO       CMDLBL(EXIT)
             ENDDO

             CHGVAR     VAR(&ROW_COUNT) VALUE(&ROW_COUNT + 1)
             CHGVAR     VAR(&CPU_DEC) VALUE(&ELAPS00006)
             CHGVAR     VAR(&CPU_CHAR) VALUE(&CPU_DEC)
             CHGVAR     VAR(&MSG) VALUE(%SST(&SUBSYSTEM 3 10) |< ', +
                          ' || %SST(&JOB_NAME 3 28) |< ', ' || +
                          %SST(&AUTHO00001 3 10) |< ', ' || +
                          %SST(&JOB_TYPE 3 3) |< ', ' || +
                          %SST(&CPU_CHAR 4 5) |< '%, ' |> +
                          %SST(&FUNCT00001 3 3) |< '-' || +
                          %SST(&FUNCTION 3 10))
             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA(&MSG) +
                          TOPGMQ(*EXT) MSGTYPE(*COMP)
             GOTO       CMDLBL(LOOP)

 EXIT:       ENDPGM
