--> SELECT DE VALIDACAO DE UTILIZACAO LOGISTICA
SELECT '[CLIENTE]' AS NOMECLI,
       '[COD]' AS CODMAX,
       '[USUARIO]' AS USERNAME,
       '[SOLUCAO]' AS SOLUCOES,
       '[ERP]' AS ERP,
       '[BD]' AS BD,
       (SELECT COUNT (EM.NUMCAR)
        FROM ERP_MXSCARREG  EM
        INNER JOIN MXMP_ROTA_ROMANEIO MRR ON MRR.ID_ROMANEIO = EM.ID_ROMANEIO
        WHERE EM.DT_CANCEL IS NULL
          AND NVL(EM.DESTINO,'SEM DESTINO') <> 'VENDA BALCAO'
          AND TRUNC (EM.DATAMON) = TRUNC(SYSDATE)) AS ROTEIRIZOU_NA_MAXIMA,
       (SELECT COUNT (EM.NUMCAR)
        FROM ERP_MXSCARREG EM
         WHERE TRUNC (EM.DATAMON) = TRUNC(SYSDATE)
           AND EM.DT_CANCEL IS NULL
           AND EM.ORIGEM_CAR = 'ROT'
           AND NVL(EM.DESTINO,'SEM DESTINO') <> 'VENDA BALCAO'
           AND EM.ID_ROMANEIO NOT IN (SELECT MRR.ID_ROMANEIO FROM MXMP_ROTA_ROMANEIO MRR)) AS ROT_NAO_CONCLUIDA,
       (SELECT COUNT(EM1.NUMCAR) AS COUNT
        FROM ERP_MXSCARREG EM1
        WHERE EM1.DT_CANCEL IS NULL
          AND NVL(EM1.DESTINO,'SEM DESTINO') <> 'VENDA BALCAO'
          AND EM1.ORIGEM_CAR = 'ROT'
          AND TRUNC(EM1.DATAMON) = TRUNC(SYSDATE) ) AS ORIGEM_CAR_MAXIMA,
       (SELECT COUNT(EM1.NUMCAR) AS COUNT
        FROM ERP_MXSCARREG EM1
        WHERE EM1.DT_CANCEL IS NULL
          AND NVL(EM1.DESTINO,'SEM DESTINO') <> 'VENDA BALCAO'
          AND EM1.ORIGEM_CAR = 'ERP'
          AND TRUNC(EM1.DATAMON) = TRUNC(SYSDATE) ) AS ORIGEM_CAR_ERP,                              
       (SELECT max(DATAMON)
        FROM ERP_MXSCARREG  EM
        INNER JOIN MXMP_ROTA_ROMANEIO MRR ON MRR.ID_ROMANEIO = EM.ID_ROMANEIO
        WHERE EM.DT_CANCEL IS NULL
          AND NVL(EM.DESTINO,'SEM DESTINO') <> 'VENDA BALCAO'
          AND TRUNC (EM.DATAMON) >= TRUNC (SYSDATE) -1400) AS ULTIMA_ROT_MAXIMA,
       (SELECT max(DATAMON)
        FROM ERP_MXSCARREG EM
         WHERE TRUNC (EM.DATAMON) >= TRUNC (SYSDATE) -1400
           AND EM.DT_CANCEL IS NULL
           AND EM.ORIGEM_CAR = 'ROT'
           AND NVL(EM.DESTINO,'SEM DESTINO') <> 'VENDA BALCAO'
           AND EM.ID_ROMANEIO NOT IN (SELECT MRR.ID_ROMANEIO FROM MXMP_ROTA_ROMANEIO MRR)) AS  ULTIMA_ROT_NAO_CONCLUIDA,
       (SELECT MAX(TRUNC(DATA_GERACAO))
        FROM MXMP_ENTREGAS
        WHERE DATA_GERACAO >= TRUNC (SYSDATE) -1480) AS ULTIMA_ENTREGA_MOT     
       FROM DUAL;

-------------------------------------------------------------------------------------------------------------------------------
CREATE DATABASE LINK ""
   CONNECT TO "" IDENTIFIED BY ""
   USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=)(PORT=1521))(CONNECT_DATA=(SID=HMG)))';

-------------------------------------------------------------------------------------------------------------------------------
--maxsolucoes(postgres)
CREATE OR REPLACE VIEW public.mxsolucoes
AS SELECT c."CodigoMaxima",
    c."RazaoSocial",
    a."OutroErp",
    a."Schema",
    d."Nome" AS "BD",
    string_agg(o."Descricao"::text, ','::text) AS "Solucao"
   FROM "Licenca" l
     LEFT JOIN "Oferta" o ON l."CodigoOferta" = o."Codigo"
     LEFT JOIN "Cliente" c ON l."CodigoCliente" = c."Codigo"
     LEFT JOIN "Ambiente" a ON c."Codigo" = a."CodigoCliente"
     LEFT JOIN "Conexao" d ON d."Codigo" = a."CodigoConexao"
  WHERE a."Schema"::text ~~ '%_PRODUCAO%'::text AND d."Descricao"::text ~~ 'Oracle US%'::text
  GROUP BY c."CodigoMaxima", c."RazaoSocial", a."OutroErp", a."Schema", d."Nome"
  ORDER BY d."Nome", a."Schema";

select "CodigoMaxima","RazaoSocial",(case when "OutroErp" = 'S' then 'OERP' else 'Winthor' end)"ERP","Schema","BD","Solucao" 
from view_solucoes_logistica;

--------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_RELATORIO_UTILIZIZACAO_LOGISTICA
IS
    SELECT1   VARCHAR2(4000);
    CLI       VARCHAR2(4000);
    CLI2      VARCHAR2(4000);
    V1        NUMBER(20);
    V2        NUMBER(20);
    V3        NUMBER(20);
    V4        NUMBER(20);
    V5        DATE;
    V6        DATE;
    V7        DATE;
    COD       NUMBER(20);
    SOLUC     VARCHAR2 (200);
    ERP       VARCHAR2 (10);
    BDM       VARCHAR2 (10);


BEGIN
    --EXECUTE IMMEDIATE 'TRUNCATE TABLE MXSRELATORIOLOGISTICA@MAXIMATECH';

    FOR DADOS
        IN (SELECT A.USERNAME,B.OUTROERP, B.SOLUCAO, B.RAZAOSOCIAL,B.BD,B.CODIGOMAXIMA
            FROM ALL_USERS A
             INNER JOIN mxsolucoes@MAXIMATECH B ON B.SCHEMA = A.USERNAME
            WHERE A.USERNAME LIKE '%PRODUCAO%'
              AND REGEXP_LIKE(B.SOLUCAO, 'maxMot') OR REGEXP_LIKE(B.SOLUCAO, 'maxRot'))
    LOOP
        SELECT1 :=
       'SELECT ''[CLIENTE]''AS NOMECLI,
       ''[COD]'' AS CODMAX,
       ''[USUARIO]'' AS USERNAME,
       ''[SOLUCAO]'' AS SOLUCOES,
       ''[ERP]'' AS ERP,
       ''[BD]'' AS BD,
       (SELECT COUNT (EM.NUMCAR)
        FROM [USUARIO].ERP_MXSCARREG  EM
        INNER JOIN [USUARIO].MXMP_ROTA_ROMANEIO MRR ON MRR.ID_ROMANEIO = EM.ID_ROMANEIO
        WHERE EM.DT_CANCEL IS NULL
          AND NVL(EM.DESTINO,''SEM DESTINO'') <> ''VENDA BALCAO''
          AND TRUNC (EM.DATAMON) >= TRUNC (SYSDATE)) AS ROTEIRIZOU_NA_MAXIMA,
       (SELECT COUNT (EM.NUMCAR)
        FROM [USUARIO].ERP_MXSCARREG EM
         WHERE TRUNC (EM.DATAMON) >= TRUNC (SYSDATE)
           AND EM.DT_CANCEL IS NULL
           AND EM.ORIGEM_CAR = ''ROT''
           AND NVL(EM.DESTINO,''SEM DESTINO'') <> ''VENDA BALCAO''
           AND EM.ID_ROMANEIO NOT IN (SELECT MRR.ID_ROMANEIO FROM [USUARIO].MXMP_ROTA_ROMANEIO MRR)) AS ROT_NAO_CONCLUIDA,
       (SELECT COUNT(EM1.NUMCAR) AS COUNT
        FROM [USUARIO].ERP_MXSCARREG EM1
        WHERE EM1.DT_CANCEL IS NULL
          AND NVL(EM1.DESTINO,''SEM DESTINO'') <> ''VENDA BALCAO''
          AND EM1.ORIGEM_CAR = ''ROT''
          AND TRUNC(EM1.DATAMON) >= TRUNC (SYSDATE) ) AS ORIGEM_CAR_MAXIMA,
       (SELECT COUNT(EM1.NUMCAR) AS COUNT
        FROM [USUARIO].ERP_MXSCARREG EM1
        WHERE EM1.DT_CANCEL IS NULL
          AND NVL(EM1.DESTINO,''SEM DESTINO'') <> ''VENDA BALCAO''
          AND EM1.ORIGEM_CAR = ''ERP''
          AND TRUNC(EM1.DATAMON) >= TRUNC (SYSDATE) ) AS ORIGEM_CAR_ERP,
       (SELECT max(DATAMON)
        FROM [USUARIO].ERP_MXSCARREG  EM
        INNER JOIN [USUARIO].MXMP_ROTA_ROMANEIO MRR ON MRR.ID_ROMANEIO = EM.ID_ROMANEIO
        WHERE EM.DT_CANCEL IS NULL
          AND NVL(EM.DESTINO,''SEM DESTINO'') <> ''VENDA BALCAO''
          AND TRUNC (EM.DATAMON) >= TRUNC (SYSDATE) -1400) AS ULTIMA_ROT_MAXIMA,
       (SELECT max(DATAMON)
        FROM [USUARIO].ERP_MXSCARREG EM
         WHERE TRUNC (EM.DATAMON) >= TRUNC (SYSDATE) -1400
           AND EM.DT_CANCEL IS NULL
           AND EM.ORIGEM_CAR = ''ROT''
           AND NVL(EM.DESTINO,''SEM DESTINO'') <> ''VENDA BALCAO''
           AND EM.ID_ROMANEIO NOT IN (SELECT MRR.ID_ROMANEIO FROM [USUARIO].MXMP_ROTA_ROMANEIO MRR)) AS  ULTIMA_ROT_NAO_CONCLUIDA,
       (SELECT MAX(TRUNC(DATA_GERACAO))
        FROM [USUARIO].MXMP_ENTREGAS
        WHERE DATA_GERACAO >= TRUNC (SYSDATE) -1480) AS ULTIMA_ENTREGA_MOT
       FROM DUAL';

SELECT1 := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE (REPLACE (SELECT1, '[USUARIO]', DADOS.USERNAME),'[SOLUCAO]',DADOS.SOLUCAO),'[ERP]',DADOS.OUTROERP),'[CLIENTE]',DADOS.RAZAOSOCIAL),'[BD]',DADOS.BD),'[COD]',DADOS.CODIGOMAXIMA);


         EXECUTE IMMEDIATE SELECT1 INTO CLI,COD,CLI2,SOLUC,ERP,BDM,V1,V2,V3,V4,V5,V6,V7;

        INSERT INTO MXSRELATORIOLOGISTICA@MAXIMATECH (CLIENTE,SCHEMA,CODIGOMX,SOLUCOES,OUTROERP,BDMX,ROTEIRIZOU_NA_MAXIMA,ROT_NAO_CONCLUIDA,ORIGEM_CAR_MAXIMA,ORIGEM_CAR_ERP, ULTIMA_ROT_MAXIMA,ULTIMA_ROT_NAO_CONCLUIDA,ULTIMA_ENTREGA_MOT,DATA_COLETA)
         VALUES (CLI,CLI2,COD,SOLUC,ERP,BDM,V1,V2,V3,V4,V5,V6,V7,SYSDATE);
        COMMIT;
    END LOOP;

END PRC_RELATORIO_UTILIZIZACAO_LOGISTICA;
/
--EXEC PRC_RELATORIO_UTILIZIZACAO_LOGISTICA ();

--------------------------------------------------------------------------------------------------------------------------------
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'JOB_DBA_RELATORIO_LOGISTICA'
      ,start_date      => LOCALTIMESTAMP
      ,repeat_interval => 'FREQ=DAILY,BYHOUR=22'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'BEGIN PRC_RELATORIO_UTILIZIZACAO_LOGISTICA(); END;'
      ,comments        => 'Relatorio de utilizacao Logistica'
    );

  SYS.DBMS_SCHEDULER.ENABLE (name => 'JOB_DBA_RELATORIO_LOGISTICA');
END;
/
---------------------------------------------------------------------------------------------------------------------------------
