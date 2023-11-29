--> Avaliação de performance
https://www.linkedin.com/pulse/planos-de-execu%C3%A7%C3%A3o-queries-em-oracle-e-postgresql-marcio/?originalSubdomain=pt
https://www.fabioprado.net/2011/03/analisando-o-plano-de-execucao-para.html
http://tech.azi.com.br/planoconsultapostgresql/

--> exemplo 01
EXPLAIN PLAN FOR
SELECT L.ID                       AS ID1_63_1_,
       L.ID_CLIENTE               AS ID_CLIENTE8_63_1_,
       L.COORD_FIXA               AS COORD_FIXA2_63_1_,
       L.DATA_GERACAO_GEOCODE     AS DATA_GERACAO_GEOCO3_63_1_,
       L.POR_CEP                  AS POR_CEP4_63_1_,
       L.LATITUDE                 AS LATITUDE5_63_1_,
       L.LONGITUDE                AS LONGITUDE6_63_1_,
       L.PRECISAO                 AS PRECISAO7_63_1_,
       C.ID                          AS ID1_5_0_,
       C.BAIRRO                      AS BAIRRO2_5_0_,
       C.CEP                         AS CEP3_5_0_,
       C.CGC                         AS CGC4_5_0_,
       C.CLIENTE                     AS CLIENTE5_5_0_,
       C.COMPLEMENTO                 AS COMPLEMENTO6_5_0_,
       C.EMAIL                       AS EMAIL7_5_0_,
       C.EMAILNFE                    AS EMAILNFE8_5_0_,
       C.ENDERECO                    AS ENDERECO9_5_0_,
       C.ESTADO                      AS ESTADO10_5_0_,
       C.FANTASIA                    AS FANTASIA11_5_0_,
       C.LATITUDE                    AS LATITUDE12_5_0_,
       C.LONGITUDE                   AS LONGITUDE13_5_0_,
       C.MUNICIPIO                   AS MUNICIPIO14_5_0_,
       C.NUMERO                      AS NUMERO15_5_0_,
       C.PONTO_REFENCIA              AS PONTO_REFENCIA16_5_0_
  FROM MXMP_LOCALIZACAO_CLIENTE  L
       LEFT  JOIN MXMI_CLIENTES C ON L.ID_CLIENTE = C.ID    
 WHERE L.ID_CLIENTE = 12220
 ORDER BY  1;
 
 SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY);
Plan hash value: 2305888063
 
------------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name                     | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |                          |     1 | 30101 |    28  (15)| 00:00:01 |
|   1 |  SORT ORDER BY                  |                          |     1 | 30101 |    28  (15)| 00:00:01 |
|   2 |   NESTED LOOPS OUTER            |                          |     1 | 30101 |    27  (12)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL            | MXMP_LOCALIZACAO_CLIENTE |     1 |    44 |    23   (9)| 00:00:01 |
|   4 |    VIEW PUSHED PREDICATE        | MXMI_CLIENTES            |     1 | 30057 |     4  (25)| 00:00:01 |
|   5 |     NESTED LOOPS                |                          |     1 |   302 |     3   (0)| 00:00:01 |
|   6 |      TABLE ACCESS BY INDEX ROWID| MXSCLIENT                |     1 |   283 |     2   (0)| 00:00:01 |
|*  7 |       INDEX UNIQUE SCAN         | MXSCLIENT_PK             |     1 |       |     1   (0)| 00:00:01 |
|   8 |      TABLE ACCESS BY INDEX ROWID| MXSCIDADE                |     1 |    19 |     1   (0)| 00:00:01 |
|*  9 |       INDEX UNIQUE SCAN         | MXSCIDADE_PK             |     1 |       |     0   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - filter(TO_NUMBER("L"."ID_CLIENTE")=12220)
   7 - access("MXSCLIENT"."CODCLI"="L"."ID_CLIENTE")
       filter(TO_NUMBER("MXSCLIENT"."CODCLI")=12220)
   9 - access("MXSCIDADE"."CODCIDADE"="MXSCLIENT"."CODCIDADE")


EXPLAIN PLAN FOR
SELECT L.ID                       AS ID1_63_1_,
       L.ID_CLIENTE               AS ID_CLIENTE8_63_1_,
       L.COORD_FIXA               AS COORD_FIXA2_63_1_,
       L.DATA_GERACAO_GEOCODE     AS DATA_GERACAO_GEOCO3_63_1_,
       L.POR_CEP                  AS POR_CEP4_63_1_,
       L.LATITUDE                 AS LATITUDE5_63_1_,
       L.LONGITUDE                AS LONGITUDE6_63_1_,
       L.PRECISAO                 AS PRECISAO7_63_1_,
       C.BAIRROENT                      AS BAIRRO2_5_0_,
       C.CEPENT                         AS CEP3_5_0_,
       C.CEPENT                         AS CGC4_5_0_,
       C.CLIENTE                     AS CLIENTE5_5_0_,
       C.COMPLEMENTOENT                 AS COMPLEMENTO6_5_0_,
       C.EMAIL                       AS EMAIL7_5_0_,
       C.EMAILNFE                    AS EMAILNFE8_5_0_,
       C.ENDERENT                    AS ENDERECO9_5_0_,
       C.ESTENT                      AS ESTADO10_5_0_,
       C.FANTASIA                    AS FANTASIA11_5_0_,
       C.LATITUDE                    AS LATITUDE12_5_0_,
       C.LONGITUDE                   AS LONGITUDE13_5_0_,
       CI.NOMECIDADE                   AS MUNICIPIO14_5_0_,
       C.NUMEROENT                      AS NUMERO15_5_0_,
       C.PONTOREFER              AS PONTO_REFENCIA16_5_0_
  FROM MXMP_LOCALIZACAO_CLIENTE  L
       LEFT JOIN MXSCLIENT C ON C.CODCLI = L.ID_CLIENTE           
       INNER JOIN MXSCIDADE CI ON CI.CODCIDADE = C.CODCIDADE
 WHERE L.ID_CLIENTE = '12220';

 Plan hash value: 1416157019
 
-----------------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name                           | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |                                |     1 |   260 |     5   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                        |                                |     1 |   260 |     5   (0)| 00:00:01 |
|   2 |   NESTED LOOPS                       |                                |     1 |   216 |     3   (0)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID       | MXSCLIENT                      |     1 |   197 |     2   (0)| 00:00:01 |
|*  4 |     INDEX UNIQUE SCAN                | MXSCLIENT_PK                   |     1 |       |     1   (0)| 00:00:01 |
|   5 |    TABLE ACCESS BY INDEX ROWID       | MXSCIDADE                      |     1 |    19 |     1   (0)| 00:00:01 |
|*  6 |     INDEX UNIQUE SCAN                | MXSCIDADE_PK                   |     1 |       |     0   (0)| 00:00:01 |
|   7 |   TABLE ACCESS BY INDEX ROWID BATCHED| MXMP_LOCALIZACAO_CLIENTE       |     1 |    44 |     2   (0)| 00:00:01 |
|*  8 |    INDEX RANGE SCAN                  | MXMP_LOCALIZACAO_CLIENTE_IX_RR |     1 |       |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("C"."CODCLI"='12220')
   6 - access("CI"."CODCIDADE"="C"."CODCIDADE")
   8 - access("L"."ID_CLIENTE"='12220')

 
 -----------------------------------------------------------------------------------
--> exemplo 02
EXPLAIN PLAN FOR
SELECT entrega0_.ID                                            AS ID1_50_,
         entrega0_.ACURACIA                                      AS ACURACIA2_50_,
         entrega0_.ID_CARREGAMENTO                               AS ID_CARREGAMENTO18_50_,
         entrega0_.ID_CLIENTE                                    AS ID_CLIENTE19_50_,
         entrega0_.DATA_CHECKIN                                  AS DATA_CHECKIN3_50_,
         entrega0_.DATA_INICIO_DESCARGA                          AS DATA_INICIO_DESCAR4_50_,
         entrega0_.DATA_INICIO_RECEBIMENTO                       AS DATA_INICIO_RECEBI5_50_,
         entrega0_.DATA_PRIMEIRA_SINCRONIZACAO                   AS DATA_PRIMEIRA_SINC6_50_,
         entrega0_.DATA_SINCRONIZACAO                            AS DATA_SINCRONIZACAO7_50_,
         entrega0_.DATA_TERMINO_DESCARGA                         AS DATA_TERMINO_DESCA8_50_,
         entrega0_.DATA_TERMINO_RECEBIMENTO                      AS DATA_TERMINO_RECEB9_50_,
         entrega0_.FOTO_ASS_DIGITAL                              AS FOTO_ASS_DIGITAL20_50_,
         entrega0_.FOTO_CHECKIN                                  AS FOTO_CHECKIN21_50_,
         entrega0_.ID_ENDERECO_ENT_PED                           AS ID_ENDERECO_ENT_P10_50_,
         entrega0_.LATITUDE                                      AS LATITUDE11_50_,
         entrega0_.LATITUDE_CHECKIN                              AS LATITUDE_CHECKIN12_50_,
         entrega0_.LONGITUDE                                     AS LONGITUDE13_50_,
         entrega0_.LONGITUDE_CHECKIN                             AS LONGITUDE_CHECKIN14_50_,
         entrega0_.ID_MOTIVO_FURO_SEQUENCIA                      AS ID_MOTIVO_FURO_SE22_50_,
         entrega0_.OBSERVACOES                                   AS OBSERVACOES15_50_,
         entrega0_.REAGENDADO                                    AS REAGENDADO16_50_,
         entrega0_.SITUACAO                                      AS SITUACAO17_50_,
         entrega0_.ID_USUARIO                                    AS ID_USUARIO23_50_,
         (SELECT NVL (MXSCLIENTENDENT.MUNICENT, MXSCLIENT.MUNICENT)
            FROM MXSCLIENT
                 LEFT JOIN MXSCLIENTENDENT
                     ON MXSCLIENT.CODCLI = MXSCLIENTENDENT.CODCLI
           WHERE     MXSCLIENTENDENT.CODENDENTCLI =
                     entrega0_.ID_ENDERECO_ENT_PED
                 AND MXSCLIENT.CODCLI = entrega0_.ID_CLIENTE)    AS formula0_
    FROM MXMP_ENTREGAS entrega0_
   WHERE     entrega0_.ID_USUARIO = 4
         AND entrega0_.DATA_TERMINO_DESCARGA >= TO_DATE('08/05/2023 00:00:00','DD/MM/YYYY HH24:MI:SS')
         AND entrega0_.DATA_TERMINO_DESCARGA <= TO_DATE('08/05/2023 11:00:00','DD/MM/YYYY HH24:MI:SS')
         AND (EXISTS (SELECT carregamen1_.ID
                      FROM MXMI_CARREGAMENTOS carregamen1_
                      WHERE carregamen1_.ID = entrega0_.ID_CARREGAMENTO))
ORDER BY entrega0_.DATA_TERMINO_DESCARGA ASC;

SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY);

Plan hash value: 4106594078
 
----------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                     |     1 |    57 |   770  (17)| 00:00:01 |
|   1 |  NESTED LOOPS                |                     |     1 |    37 |     2   (0)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| MXSCLIENTENDENT     |     1 |    20 |     1   (0)| 00:00:01 |
|*  3 |    INDEX UNIQUE SCAN         | MXSCLIENTENDENT_PK  |     1 |       |     0   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID| MXSCLIENT           |     1 |    17 |     1   (0)| 00:00:01 |
|*  5 |    INDEX UNIQUE SCAN         | MXSCLIENT_PK        |     1 |       |     0   (0)| 00:00:01 |
|   6 |  SORT ORDER BY               |                     |     1 |    57 |   770  (17)| 00:00:01 |
|   7 |   NESTED LOOPS               |                     |     1 |    57 |   767  (17)| 00:00:01 |
|*  8 |    TABLE ACCESS FULL         | MXMP_ENTREGAS       |     1 |    50 |   767  (17)| 00:00:01 |
|*  9 |    INDEX UNIQUE SCAN         | IDX_ERP_MXSCARREG01 |     1 |     7 |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("MXSCLIENTENDENT"."CODCLI"=:B1 AND "MXSCLIENTENDENT"."CODENDENTCLI"=:B2)
   5 - access("MXSCLIENT"."CODCLI"=:B1)
   8 - filter("ENTREGA0_"."DATA_TERMINO_DESCARGA">=TO_DATE(' 2023-05-08 00:00:00', 
              'syyyy-mm-dd hh24:mi:ss') AND "ENTREGA0_"."ID_USUARIO"=4 AND 
              "ENTREGA0_"."DATA_TERMINO_DESCARGA"<=TO_DATE(' 2023-05-08 11:00:00', 'syyyy-mm-dd 
              hh24:mi:ss') AND "ENTREGA0_"."ID_CARREGAMENTO"<>'-1' AND "ENTREGA0_"."ID_CARREGAMENTO"<>'0')
   9 - access("ERP_MXSCARREG"."NUMCAR"="ENTREGA0_"."ID_CARREGAMENTO")
       filter("ERP_MXSCARREG"."NUMCAR"<>'0' AND "ERP_MXSCARREG"."NUMCAR"<>'-1')


CREATE INDEX IDX_DBA_MXMP_ENTREGAS ON MXMP_ENTREGAS (ID_USUARIO,DATA_TERMINO_DESCARGA);
DROP INDEX IDX_DBA_MXMP_ENTREGAS;

Plan hash value: 1648850510
 
------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name                  | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                       |     1 |    57 |     4   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                |                       |     1 |    37 |     2   (0)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| MXSCLIENTENDENT       |     1 |    20 |     1   (0)| 00:00:01 |
|*  3 |    INDEX UNIQUE SCAN         | MXSCLIENTENDENT_PK    |     1 |       |     0   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID| MXSCLIENT             |     1 |    17 |     1   (0)| 00:00:01 |
|*  5 |    INDEX UNIQUE SCAN         | MXSCLIENT_PK          |     1 |       |     0   (0)| 00:00:01 |
|   6 |  NESTED LOOPS                |                       |     1 |    57 |     2   (0)| 00:00:01 |
|*  7 |   TABLE ACCESS BY INDEX ROWID| MXMP_ENTREGAS         |     1 |    50 |     2   (0)| 00:00:01 |
|*  8 |    INDEX RANGE SCAN          | IDX_DBA_MXMP_ENTREGAS |     1 |       |     1   (0)| 00:00:01 |
|*  9 |   INDEX UNIQUE SCAN          | IDX_ERP_MXSCARREG01   |     1 |     7 |     0   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("MXSCLIENTENDENT"."CODCLI"=:B1 AND "MXSCLIENTENDENT"."CODENDENTCLI"=:B2)
   5 - access("MXSCLIENT"."CODCLI"=:B1)
   7 - filter("ENTREGA0_"."ID_CARREGAMENTO"<>'-1' AND "ENTREGA0_"."ID_CARREGAMENTO"<>'0')
   8 - access("ENTREGA0_"."ID_USUARIO"=4 AND "ENTREGA0_"."DATA_TERMINO_DESCARGA">=TO_DATE(' 
              2023-05-08 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND 
              "ENTREGA0_"."DATA_TERMINO_DESCARGA"<=TO_DATE(' 2023-05-08 11:00:00', 'syyyy-mm-dd 
              hh24:mi:ss'))
   9 - access("ERP_MXSCARREG"."NUMCAR"="ENTREGA0_"."ID_CARREGAMENTO")
       filter("ERP_MXSCARREG"."NUMCAR"<>'0' AND "ERP_MXSCARREG"."NUMCAR"<>'-1')


       Plan hash value: 743239198
 
---------------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name                  | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                       |     1 |    57 |    12   (9)| 00:00:01 |
|   1 |  NESTED LOOPS                         |                       |     1 |    37 |     2   (0)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID         | MXSCLIENTENDENT       |     1 |    20 |     1   (0)| 00:00:01 |
|*  3 |    INDEX UNIQUE SCAN                  | MXSCLIENTENDENT_PK    |     1 |       |     0   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID         | MXSCLIENT             |     1 |    17 |     1   (0)| 00:00:01 |
|*  5 |    INDEX UNIQUE SCAN                  | MXSCLIENT_PK          |     1 |       |     0   (0)| 00:00:01 |
|   6 |  SORT ORDER BY                        |                       |     1 |    57 |    12   (9)| 00:00:01 |
|   7 |   NESTED LOOPS                        |                       |     1 |    57 |     9   (0)| 00:00:01 |
|*  8 |    TABLE ACCESS BY INDEX ROWID BATCHED| MXMP_ENTREGAS         |     1 |    50 |     9   (0)| 00:00:01 |
|*  9 |     INDEX RANGE SCAN                  | IDX_DBA_MXMP_ENTREGAS |    29 |       |     1   (0)| 00:00:01 |
|* 10 |    INDEX UNIQUE SCAN                  | IDX_ERP_MXSCARREG01   |     1 |     7 |     0   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("MXSCLIENTENDENT"."CODCLI"=:B1 AND "MXSCLIENTENDENT"."CODENDENTCLI"=:B2)
   5 - access("MXSCLIENT"."CODCLI"=:B1)
   8 - filter("ENTREGA0_"."DATA_TERMINO_DESCARGA">=TO_DATE(' 2023-05-08 00:00:00', 'syyyy-mm-dd 
              hh24:mi:ss') AND "ENTREGA0_"."DATA_TERMINO_DESCARGA"<=TO_DATE(' 2023-05-08 11:00:00', 'syyyy-mm-dd 
              hh24:mi:ss') AND "ENTREGA0_"."ID_CARREGAMENTO"<>'-1' AND "ENTREGA0_"."ID_CARREGAMENTO"<>'0')
   9 - access("ENTREGA0_"."ID_USUARIO"=4)
  10 - access("ERP_MXSCARREG"."NUMCAR"="ENTREGA0_"."ID_CARREGAMENTO")
       filter("ERP_MXSCARREG"."NUMCAR"<>'0' AND "ERP_MXSCARREG"."NUMCAR"<>'-1')


------------------------------------------------------------------------------------------

--> exemplo 03
EXPLAIN PLAN FOR
  SELECT MXSMIXCLIENTES.CODCLI,
         MXSMIXCLIENTES.CODPROD,
         MXSMIXCLIENTES.CODAUXILIAR,
         MXSMIXCLIENTES.CODFILIAL,
         MXSMIXCLIENTES.NUMTRANSVENDA,
         MXSMIXCLIENTES.DTSAIDA,
         MXSMIXCLIENTES.CODPLPAG,
         MXSMIXCLIENTES.CODCOB,
         MXSMIXCLIENTES.PTABELA,
         MXSMIXCLIENTES.PUNIT,
         MXSMIXCLIENTES.QT,
         MXSMIXCLIENTES.ATUALIZID,
         MXSMIXCLIENTES.CODOPERACAO,
         MXSMIXCLIENTES.PLPAGDESCRICAO
    FROM MXSMIXCLIENTES
         INNER JOIN SYNC_D_MXSCLIENT
             ON (MXSMIXCLIENTES.CODCLI = SYNC_D_MXSCLIENT.CODCLI)
   WHERE     CODOPERACAO != 2
         AND SYNC_D_MXSCLIENT.CODUSUARIO = 22697
         AND TO_NUMBER (TO_CHAR (TRUNC (DTSAIDA), 'RRRRMMDD')) >=
             TO_NUMBER (TO_CHAR (TRUNC (SYSDATE)
                        - TO_NUMBER (PKG_UTIL.OBTERCONFIGURACAO ('GERAR_DADOS_MIX_CLIENTES_DIAS','30')),'RRRRMMDD'))
ORDER BY ATUALIZID;
Plan hash value: 1534314394
 
------------------------------------------------------------------------------------------
| Id  | Operation           | Name               | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |                    |   259 | 23828 |   510  (51)| 00:00:01 |
|   1 |  SORT ORDER BY      |                    |   259 | 23828 |   510  (51)| 00:00:01 |
|   2 |   NESTED LOOPS      |                    |   259 | 23828 |   509  (51)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL| MXSMIXCLIENTES     | 10349 |   818K|   504  (50)| 00:00:01 |
|*  4 |    INDEX UNIQUE SCAN| DELTA_MXSCLIENT_PK |     1 |    11 |     0   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - filter(TO_NUMBER(TO_CHAR(TRUNC(INTERNAL_FUNCTION("MXSMIXCLIENTES"."DTSAIDA"
              )),'RRRRMMDD'))>=TO_NUMBER(TO_CHAR(TRUNC(SYSDATE@!)-TO_NUMBER("PKG_UTIL"."OBTERCON
              FIGURACAO"('GERAR_DADOS_MIX_CLIENTES_DIAS','30')),'RRRRMMDD')) AND 
              "MXSMIXCLIENTES"."CODOPERACAO"<>2)
   4 - access("MXSMIXCLIENTES"."CODCLI"="SYNC_D_MXSCLIENT"."CODCLI" AND 
              "SYNC_D_MXSCLIENT"."CODUSUARIO"=22697)

 
 CREATE INDEX IDX_DBA_DTSAIDA ON MXSMIXCLIENTES (TO_NUMBER (TO_CHAR (TRUNC (DTSAIDA), 'RRRRMMDD')));

Plan hash value: 273316057
 
------------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name               | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                    |   259 | 27195 |    37  (17)| 00:00:01 |
|   1 |  SORT ORDER BY                        |                    |   259 | 27195 |    37  (17)| 00:00:01 |
|   2 |   NESTED LOOPS                        |                    |   259 | 27195 |    36  (14)| 00:00:01 |
|*  3 |    TABLE ACCESS BY INDEX ROWID BATCHED| MXSMIXCLIENTES     | 10349 |   950K|    31   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN                  | IDX_DBA_DTSAIDA    |  1863 |       |     7   (0)| 00:00:01 |
|*  5 |    INDEX UNIQUE SCAN                  | DELTA_MXSCLIENT_PK |     1 |    11 |     0   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - filter("MXSMIXCLIENTES"."CODOPERACAO"<>2)
   4 - access(TO_NUMBER(TO_CHAR(TRUNC(INTERNAL_FUNCTION("DTSAIDA")),'RRRRMMDD'))>=TO_NUMBER(TO_CHAR(
              TRUNC(SYSDATE@!)-TO_NUMBER("PKG_UTIL"."OBTERCONFIGURACAO"('GERAR_DADOS_MIX_CLIENTES_DIAS','30')),'RR
              RRMMDD')))
   5 - access("MXSMIXCLIENTES"."CODCLI"="SYNC_D_MXSCLIENT"."CODCLI" AND 
              "SYNC_D_MXSCLIENT"."CODUSUARIO"=22697)

-----------------------------------------------------------------------------------------------

--> exemplo 04
EXPLAIN PLAN FOR
SELECT MXSTABPR.CODPROD,MXSTABPR.NUMREGIAO,NVL(MXSTABPR.PVENDA,0) "PVENDA",MXSTABPR.PVENDA1,MXSTABPR.PVENDA2,MXSTABPR.PVENDA3,
       MXSTABPR.PVENDA4,MXSTABPR.PVENDA5,MXSTABPR.PVENDA6,MXSTABPR.PVENDA7,MXSTABPR.PRECOMINIMOVENDA,MXSTABPR.PERDESCFOB,
       MXSTABPR.DESCONTAFRETE,MXSTABPR.VLST,MXSTABPR.PERDESCMAX,MXSTABPR.CODST,MXSTABPR.PERCDESCSIMPLESNAC,MXSTABPR.PVENDAATAC,
       MXSTABPR.PVENDAATAC1,MXSTABPR.PVENDAATAC2,MXSTABPR.PVENDAATAC3,MXSTABPR.PVENDAATAC4,MXSTABPR.PVENDAATAC5,MXSTABPR.PVENDAATAC6,
       MXSTABPR.PVENDAATAC7,MXSTABPR.PERDESCMAXBALCAO,MXSTABPR.VLIPI,MXSTABPR.VLULTENTMES,MXSTABPR.PVENDASEMIMPOSTO1,
       MXSTABPR.PVENDASEMIMPOSTO2,MXSTABPR.PVENDASEMIMPOSTO3,MXSTABPR.PVENDASEMIMPOSTO4,MXSTABPR.PVENDASEMIMPOSTO5,
       MXSTABPR.PVENDASEMIMPOSTO6,MXSTABPR.PVENDASEMIMPOSTO7,MXSTABPR.PVENDAATACSEMIMPOSTO1,MXSTABPR.PVENDAATACSEMIMPOSTO2,
       MXSTABPR.PVENDAATACSEMIMPOSTO3,MXSTABPR.PVENDAATACSEMIMPOSTO4,MXSTABPR.PVENDAATACSEMIMPOSTO5,MXSTABPR.PVENDAATACSEMIMPOSTO6,
       MXSTABPR.PVENDAATACSEMIMPOSTO7,MXSTABPR.PTABELASEMIMPOSTO1,MXSTABPR.PTABELASEMIMPOSTO2,MXSTABPR.PTABELASEMIMPOSTO3,MXSTABPR.PTABELASEMIMPOSTO4,
       MXSTABPR.PTABELASEMIMPOSTO5,MXSTABPR.PTABELASEMIMPOSTO6,MXSTABPR.PTABELASEMIMPOSTO7,MXSTABPR.PTABELAATACSEMIMPOSTO1,
       MXSTABPR.PTABELAATACSEMIMPOSTO2,MXSTABPR.PTABELAATACSEMIMPOSTO3,MXSTABPR.PTABELAATACSEMIMPOSTO4,MXSTABPR.PTABELAATACSEMIMPOSTO5,
       MXSTABPR.PTABELAATACSEMIMPOSTO6,MXSTABPR.PTABELAATACSEMIMPOSTO7,MXSTABPR.CUSTOPRECIFIC,MXSTABPR.PRECOREVISTA,
       MXSTABPR.PTABELA,MXSTABPR.PRECOFAB,MXSTABPR.DTINICIOVALIDADE,MXSTABPR.DTFIMVALIDADE,MXSTABPR.CALCULARIPI,MXSTABPR.PRECOMAXCONSUM,
       MXSTABPR.PRECOMAXCONSUMTAB,MXSTABPR.ATUALIZID,MXSTABPR.DTATUALIZ,MXSTABPR.CODOPERACAO,MXSTABPR.DTULTALTPVENDA,MXSTABPR.MARGEM,
       MXSTABPR.PRECOMINIMOTABELA,MXSTABPR.VLFCPST,MXSTABPR.CALCULARFECPSTVENDA,MXSTABPR.PERACRESCMAX,MXSTABPR.DOCNUM_ITMNUM,
       MXSTABPR.VLR_ICMS_ST_SIMPLES,MXSTABPR.VLR_ICMS_ST_NORMAL,MXSTABPR.ALIQ_ICMS,MXSTABPR.PERCIPI
  FROM MXSTABPR
       INNER JOIN MXSPRODUT ON (MXSPRODUT.CODPROD = MXSTABPR.CODPROD)
       INNER JOIN SYNC_D_MXSREGIAO ON (SYNC_D_MXSREGIAO.NUMREGIAO = MXSTABPR.NUMREGIAO)
 WHERE     MXSTABPR.CODOPERACAO != 2
   AND MXSPRODUT.CODOPERACAO != 2
   AND SYNC_D_MXSREGIAO.CODUSUARIO = 7733;
   --AND NVL (MXSTABPR.PVENDA, 0) != 0;
   
 SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY);
 
 CREATE INDEX IDX_DBA_PVENDA ON MXSTABPR (NVL(PVENDA,0));

Plan hash value: 920130096
 
--------------------------------------------------------------------------------------------
| Id  | Operation               | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |                  |   759 |   134K|    48  (15)| 00:00:01 |
|*  1 |  HASH JOIN              |                  |   759 |   134K|    48  (15)| 00:00:01 |
|   2 |   MERGE JOIN CARTESIAN  |                  |   759 | 12903 |     4   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL    | SYNC_D_MXSREGIAO |     2 |    16 |     2   (0)| 00:00:01 |
|   4 |    BUFFER SORT          |                  |   485 |  4365 |     2   (0)| 00:00:01 |
|*  5 |     INDEX FAST FULL SCAN| IDX_MXSPRODUT07  |   485 |  4365 |     1   (0)| 00:00:01 |
|*  6 |   TABLE ACCESS FULL     | MXSTABPR         | 15519 |  2485K|    44  (16)| 00:00:01 |
--------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("SYNC_D_MXSREGIAO"."NUMREGIAO"="MXSTABPR"."NUMREGIAO" AND 
              "MXSPRODUT"."CODPROD"="MXSTABPR"."CODPROD")
   3 - filter("SYNC_D_MXSREGIAO"."CODUSUARIO"=7733)
   5 - filter("MXSPRODUT"."CODOPERACAO"<>2)
   6 - filter("MXSTABPR"."CODOPERACAO"<>2)

Plan hash value: 920130096
 
--------------------------------------------------------------------------------------------
| Id  | Operation               | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |                  |    38 |  6878 |    48  (15)| 00:00:01 |
|*  1 |  HASH JOIN              |                  |    38 |  6878 |    48  (15)| 00:00:01 |
|   2 |   MERGE JOIN CARTESIAN  |                  |   759 | 12903 |     4   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL    | SYNC_D_MXSREGIAO |     2 |    16 |     2   (0)| 00:00:01 |
|   4 |    BUFFER SORT          |                  |   485 |  4365 |     2   (0)| 00:00:01 |
|*  5 |     INDEX FAST FULL SCAN| IDX_MXSPRODUT07  |   485 |  4365 |     1   (0)| 00:00:01 |
|*  6 |   TABLE ACCESS FULL     | MXSTABPR         |   776 |   124K|    44  (16)| 00:00:01 |
--------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("SYNC_D_MXSREGIAO"."NUMREGIAO"="MXSTABPR"."NUMREGIAO" AND 
              "MXSPRODUT"."CODPROD"="MXSTABPR"."CODPROD")
   3 - filter("SYNC_D_MXSREGIAO"."CODUSUARIO"=7733)
   5 - filter("MXSPRODUT"."CODOPERACAO"<>2)
   6 - filter(NVL("PVENDA",0)<>0 AND "MXSTABPR"."CODOPERACAO"<>2)
Plan hash value: 920130096
 
--------------------------------------------------------------------------------------------
| Id  | Operation               | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |                  |    38 |  6878 |    48  (15)| 00:00:01 |
|*  1 |  HASH JOIN              |                  |    38 |  6878 |    48  (15)| 00:00:01 |
|   2 |   MERGE JOIN CARTESIAN  |                  |   759 | 12903 |     4   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL    | SYNC_D_MXSREGIAO |     2 |    16 |     2   (0)| 00:00:01 |
|   4 |    BUFFER SORT          |                  |   485 |  4365 |     2   (0)| 00:00:01 |
|*  5 |     INDEX FAST FULL SCAN| IDX_MXSPRODUT07  |   485 |  4365 |     1   (0)| 00:00:01 |
|*  6 |   TABLE ACCESS FULL     | MXSTABPR         |   776 |   124K|    44  (16)| 00:00:01 |
--------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("SYNC_D_MXSREGIAO"."NUMREGIAO"="MXSTABPR"."NUMREGIAO" AND 
              "MXSPRODUT"."CODPROD"="MXSTABPR"."CODPROD")
   3 - filter("SYNC_D_MXSREGIAO"."CODUSUARIO"=7733)
   5 - filter("MXSPRODUT"."CODOPERACAO"<>2)
   6 - filter(NVL("PVENDA",0)<>0 AND "MXSTABPR"."CODOPERACAO"<>2)
