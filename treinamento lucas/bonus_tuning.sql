--CONSULTA DA JOB JOB_TITULOS

EXPLAIN PLAN FOR
SELECT NUMTRANSVENDA,
       DUPLIC,
       PREST,
       DTEMISSAO,
       DTVENC,
       STATUS,
       CODCOB,
       NVL (VALOR, 0)        AS VALOR,
       NVL (VALORDESC, 0)    AS VALORDESC,
       (  ((VALOR - NVL (VALORDESC, 0)) + NVL (TXPERM, 0))
        - NVL (VPAGO, 0)
        + NVL (JUROS, 0))    AS SALDO,
       DTVENCORIG,
       NVL (VALORORIG, 0)    VALORORIG,
       CODCLI,
       VENCIDO,
       INADIMPLENCIA,
       CODFILIAL,
       CODUSUR,
       JUROS,
       TXJUROS,
       DIASATRASO,
       NUMCHEQUE,
       NUMBANCO,
       CLIENTE,
       PROTESTO,
       DTPAG,
       PERCOM,
       CARTORIO,
       NOSSONUMBCO,
       NOSSONUMBCO2,
       LINHADIG,
       LINHADIG2,
       VLTXBOLETO,
       CODSUPERVISOR,
       AGENCIA,
       CODBARRA,
       NUMCARTEIRA,
       ID_ERP,
       RECEBIVEL,
       CODCLIENTENOBANCO,
       ''                    NUMCARTEIRA3
  FROM (SELECT ERP_MXSPREST.NUMTRANSVENDA,
               ERP_MXSPREST.DUPLIC,
               ERP_MXSPREST.PREST,
               ERP_MXSPREST.DTEMISSAO,
               ERP_MXSPREST.DTVENC,
               ERP_MXSPREST.STATUS,
               ERP_MXSPREST.CODCOB,
               NVL (ERP_MXSPREST.VALOR, 0)                  AS VALOR,
               NVL (ERP_MXSPREST.VALORDESC, 0)              AS VALORDESC,
               NVL (ERP_MXSPREST.TXPERM, 0)                 AS TXPERM,
               NVL (ERP_MXSPREST.VPAGO, 0)                  AS VPAGO,
               ERP_MXSPREST.DTVENCORIG,
               NVL (ERP_MXSPREST.VALORORIG, 0)              VALORORIG,
               MXSCLIENT.CODCLI,
               CASE
                   WHEN ERP_MXSPREST.DTVENC >= TRUNC (SYSDATE) THEN 'N'
                   ELSE 'S'
               END                                          AS VENCIDO,
               CASE
                   WHEN     NVL (MXSCOB.MXINAD, 'S') = 'S'
                        AND ERP_MXSPREST.DTVENC + NVL (MXSCOB.MXDIASINAD, 0) <
                            TRUNC (SYSDATE)
                   THEN 'S'
                   ELSE 'N'
               END                                          AS INADIMPLENCIA,
               ERP_MXSPREST.CODFILIAL,
               ERP_MXSPREST.CODUSUR,
               FCALCULAR_JUROS_TITULO (
                   DECODE (NVL (MXSCOB.CALCJUROSCOBRANCA, 'N'),'N', NVL (NVL ( null, MXSCOB.TXJUROS), 0),NVL (MXSCOB.TXJUROS, 0)),
                   ERP_MXSPREST.DTVENC,
                   NVL (ERP_MXSPREST.DTPAG, TRUNC (SYSDATE)),
                   ERP_MXSPREST.CODCOB,
                   ERP_MXSPREST.CODFILIAL,
                   ERP_MXSPREST.VALOR,
                   null,
                   NVL (MXSFILIAL.USADIAUTILFILIAL, 'N'),
                   NVL (ERP_MXSPREST.TXPERMPREVISTO, 0))    JUROS,
                 CASE
                     WHEN ERP_MXSPREST.DTVENC >= TRUNC (SYSDATE)
                     THEN
                         0
                     ELSE
                         DECODE (NVL (MXSCOB.CALCJUROSCOBRANCA, 'N'),
                                 'N', NVL (NVL ( null, MXSCOB.TXJUROS), 0),
                                 NVL (MXSCOB.TXJUROS, 0))
                 END
               / 100                                        AS TXJUROS,
               F_QTDIASVENCIDOS (ERP_MXSPREST.DTVENC,
                                 NVL (ERP_MXSPREST.DTPAG, TRUNC (SYSDATE)),
                                 ERP_MXSPREST.CODCOB,
                                 ERP_MXSPREST.CODFILIAL,
                                 NVL (MXSFILIAL.USADIAUTILFILIAL, 'N'),
                                 'N')                       DIASATRASO,
               ERP_MXSPREST.NUMCHEQUE                       AS NUMCHEQUE,
               ERP_MXSPREST.NUMBANCO                        AS NUMBANCO,
               MXSCLIENT.CLIENTE                            AS CLIENTE,
               NVL (ERP_MXSPREST.PROTESTO, 'N')             PROTESTO,
               ERP_MXSPREST.DTPAG,
               ERP_MXSPREST.PERCOM,
               ERP_MXSPREST.CARTORIO,
               ERP_MXSPREST.NOSSONUMBCO,
               ERP_MXSPREST.NOSSONUMBCO2,
               ERP_MXSPREST.LINHADIG,
               ERP_MXSPREST.LINHADIG2,
               ERP_MXSPREST.VLTXBOLETO,
               ERP_MXSPREST.CODSUPERVISOR,
               ERP_MXSPREST.AGENCIA,
               ERP_MXSPREST.CODBARRA,
               ERP_MXSPREST.NUMCARTEIRA,
               ERP_MXSPREST.ID_ERP,
               ERP_MXSPREST.RECEBIVEL,
               ERP_MXSPREST.CODCLIENTENOBANCO
          FROM ERP_MXSPREST,
               MXSCLIENT,
               MXSUSUARI,
               MXSCOB,
               MXSFILIAL
         WHERE     MXSCOB.CODCOB(+) = ERP_MXSPREST.CODCOB
               AND ERP_MXSPREST.CODOPERACAO != 2
               AND MXSCLIENT.CODOPERACAO != 2
               AND MXSUSUARI.CODOPERACAO(+) != 2
               AND MXSCOB.CODOPERACAO(+) != 2
               AND MXSFILIAL.CODOPERACAO != 2
               AND MXSUSUARI.CODUSUR(+) = ERP_MXSPREST.CODUSUR
               AND MXSCLIENT.CODCLI = ERP_MXSPREST.CODCLI
               AND ERP_MXSPREST.CODCOB <> 'DESD'
               AND ERP_MXSPREST.DTPAG IS NULL
               AND MXSFILIAL.CODIGO = ERP_MXSPREST.CODFILIAL
               AND (   ERP_MXSPREST.NUMTRANSVENDA <> ERP_MXSPREST.DUPLIC
                    OR (NOT REGEXP_LIKE (ERP_MXSPREST.PREST, '^[0-9]+$'))
                    OR (ERP_MXSPREST.NUMTRANSVENDA = ERP_MXSPREST.DUPLIC))
               AND ERP_MXSPREST.CODCOB NOT IN ('DEVP',
                                               'DEVT',
                                               'BNF',
                                               'BNFT',
                                               'BNFR',
                                               'BNTR',
                                               'BNRP',
                                               'CRED')
               AND (   'N' = 'N'
                    OR ( 'N' = 'S' AND ERP_MXSPREST.DTVENC < SYSDATE))
        UNION ALL
        SELECT ERP_MXSPREST.NUMTRANSVENDA,
               ERP_MXSPREST.DUPLIC,
               ERP_MXSPREST.PREST,
               ERP_MXSPREST.DTEMISSAO,
               ERP_MXSPREST.DTVENC,
               ERP_MXSPREST.STATUS,
               ERP_MXSPREST.CODCOB,
               NVL (ERP_MXSPREST.VALOR, 0)                  AS VALOR,
               NVL (ERP_MXSPREST.VALORDESC, 0)              AS VALORDESC,
               NVL (ERP_MXSPREST.TXPERM, 0)                 AS TXPERM,
               NVL (ERP_MXSPREST.VPAGO, 0)                  AS VPAGO,
               ERP_MXSPREST.DTVENCORIG,
               NVL (ERP_MXSPREST.VALORORIG, 0)              VALORORIG,
               MXSCLIENT.CODCLI,
               CASE
                   WHEN ERP_MXSPREST.DTVENC >= TRUNC (SYSDATE) THEN 'N'
                   ELSE 'S'
               END                                          AS VENCIDO,
               CASE
                   WHEN     NVL (MXSCOB.MXINAD, 'S') = 'S'
                        AND ERP_MXSPREST.DTVENC + NVL (MXSCOB.MXDIASINAD, 0) <
                            TRUNC (SYSDATE)
                   THEN
                       'S'
                   ELSE
                       'N'
               END                                          AS INADIMPLENCIA,
               ERP_MXSPREST.CODFILIAL,
               ERP_MXSPREST.CODUSUR,
               FCALCULAR_JUROS_TITULO (
                   DECODE (NVL (MXSCOB.CALCJUROSCOBRANCA, 'N'),
                           'N', NVL (NVL ( null, MXSCOB.TXJUROS), 0),
                           NVL (MXSCOB.TXJUROS, 0)),
                   ERP_MXSPREST.DTVENC,
                   NVL (ERP_MXSPREST.DTPAG, TRUNC (SYSDATE)),
                   ERP_MXSPREST.CODCOB,
                   ERP_MXSPREST.CODFILIAL,
                   ERP_MXSPREST.VALOR,
                   null,
                   NVL (MXSFILIAL.USADIAUTILFILIAL, 'N'),
                   NVL (ERP_MXSPREST.TXPERMPREVISTO, 0))    JUROS,
                 CASE
                     WHEN ERP_MXSPREST.DTVENC >= TRUNC (SYSDATE)
                     THEN
                         0
                     ELSE
                         DECODE (NVL (MXSCOB.CALCJUROSCOBRANCA, 'N'),
                                 'N', NVL (NVL ( null, MXSCOB.TXJUROS), 0),
                                 NVL (MXSCOB.TXJUROS, 0))
                 END
               / 100                                        AS TXJUROS,
               F_QTDIASVENCIDOS (ERP_MXSPREST.DTVENC,
                                 NVL (ERP_MXSPREST.DTPAG, TRUNC (SYSDATE)),
                                 ERP_MXSPREST.CODCOB,
                                 ERP_MXSPREST.CODFILIAL,
                                 NVL (MXSFILIAL.USADIAUTILFILIAL, 'N'),
                                 'N')                       DIASATRASO,
               ERP_MXSPREST.NUMCHEQUE                       AS NUMCHEQUE,
               ERP_MXSPREST.NUMBANCO                        AS NUMBANCO,
               MXSCLIENT.CLIENTE                            AS CLIENTE,
               NVL (ERP_MXSPREST.PROTESTO, 'N')             PROTESTO,
               ERP_MXSPREST.DTPAG,
               ERP_MXSPREST.PERCOM,
               ERP_MXSPREST.CARTORIO,
               ERP_MXSPREST.NOSSONUMBCO,
               ERP_MXSPREST.NOSSONUMBCO2,
               ERP_MXSPREST.LINHADIG,
               ERP_MXSPREST.LINHADIG2,
               ERP_MXSPREST.VLTXBOLETO,
               ERP_MXSPREST.CODSUPERVISOR,
               ERP_MXSPREST.AGENCIA,
               ERP_MXSPREST.CODBARRA,
               ERP_MXSPREST.NUMCARTEIRA,
               ERP_MXSPREST.ID_ERP,
               ERP_MXSPREST.RECEBIVEL,
               ERP_MXSPREST.CODCLIENTENOBANCO
          FROM ERP_MXSPREST,
               MXSCLIENT,
               MXSUSUARI,
               MXSCOB,
               MXSFILIAL
         WHERE     'N' = 'S'
               AND ERP_MXSPREST.CODOPERACAO != 2
               AND MXSCLIENT.CODOPERACAO != 2
               AND MXSUSUARI.CODOPERACAO(+) != 2
               AND MXSCOB.CODOPERACAO(+) != 2
               AND MXSFILIAL.CODOPERACAO != 2
               AND MXSCOB.CODCOB(+) = ERP_MXSPREST.CODCOB
               AND MXSUSUARI.CODUSUR(+) = ERP_MXSPREST.CODUSUR
               AND MXSCLIENT.CODCLI = ERP_MXSPREST.CODCLI
               AND ERP_MXSPREST.CODCOB <> 'DESD'
               AND NOT ERP_MXSPREST.DTPAG IS NULL
               AND ERP_MXSPREST.DTPAG >= TRUNC (SYSDATE) - 60
               AND MXSFILIAL.CODIGO = ERP_MXSPREST.CODFILIAL
               AND (   ERP_MXSPREST.NUMTRANSVENDA <> ERP_MXSPREST.DUPLIC
                    OR (NOT REGEXP_LIKE (ERP_MXSPREST.PREST, '^[0-9]+$')))
               AND ERP_MXSPREST.CODCOB NOT IN ('DEVP',
                                               'DEVT',
                                               'BNF',
                                               'BNFT',
                                               'BNFR',
                                               'BNTR',
                                               'BNRP',
                                               'CRED')
               AND (   'N' = 'N'
                    OR ( 'N' = 'S' AND ERP_MXSPREST.DTVENC < SYSDATE)));

--AJUSTE

SELECT NUMTRANSVENDA,
       DUPLIC,
       PREST,
       DTEMISSAO,
       DTVENC,
       STATUS,
       CODCOB,
       NVL (VALOR, 0)        AS VALOR,
       NVL (VALORDESC, 0)    AS VALORDESC,
       (  ((VALOR - NVL (VALORDESC, 0)) + NVL (TXPERM, 0))
        - NVL (VPAGO, 0)
        + NVL (JUROS, 0))    AS SALDO,
       DTVENCORIG,
       NVL (VALORORIG, 0)    VALORORIG,
       CODCLI,
       VENCIDO,
       INADIMPLENCIA,
       CODFILIAL,
       CODUSUR,
       JUROS,
       TXJUROS,
       DIASATRASO,
       NUMCHEQUE,
       NUMBANCO,
       CLIENTE,
       PROTESTO,
       DTPAG,
       PERCOM,
       CARTORIO,
       NOSSONUMBCO,
       NOSSONUMBCO2,
       LINHADIG,
       LINHADIG2,
       VLTXBOLETO,
       CODSUPERVISOR,
       AGENCIA,
       CODBARRA,
       NUMCARTEIRA,
       ID_ERP,
       RECEBIVEL,
       CODCLIENTENOBANCO,
       ''                    NUMCARTEIRA3
  FROM (SELECT A.NUMTRANSVENDA,
               A.DUPLIC,
               A.PREST,
               A.DTEMISSAO,
               A.DTVENC,
               A.STATUS,
               A.CODCOB,
               NVL (A.VALOR, 0)                  AS VALOR,
               NVL (A.VALORDESC, 0)              AS VALORDESC,
               NVL (A.TXPERM, 0)                 AS TXPERM,
               NVL (A.VPAGO, 0)                  AS VPAGO,
               A.DTVENCORIG,
               NVL (A.VALORORIG, 0)              VALORORIG,
               B.CODCLI,
               CASE
                   WHEN A.DTVENC >= TRUNC (SYSDATE) THEN 'N'
                   ELSE 'S'
               END                                          AS VENCIDO,
               CASE
                   WHEN     NVL (D.MXINAD, 'S') = 'S'
                        AND A.DTVENC + NVL (D.MXDIASINAD, 0) <
                            TRUNC (SYSDATE)
                   THEN 'S'
                   ELSE 'N'
               END                                          AS INADIMPLENCIA,
               A.CODFILIAL,
               A.CODUSUR,
               FCALCULAR_JUROS_TITULO (
                   DECODE (NVL (D.CALCJUROSCOBRANCA, 'N'),'N', NVL (NVL ( null, D.TXJUROS), 0),NVL (D.TXJUROS, 0)),
                   A.DTVENC,
                   NVL (A.DTPAG, TRUNC (SYSDATE)),
                   A.CODCOB,
                   A.CODFILIAL,
                   A.VALOR,
                   null,
                   NVL (E.USADIAUTILFILIAL, 'N'),
                   NVL (A.TXPERMPREVISTO, 0))    JUROS,
                 CASE
                     WHEN A.DTVENC >= TRUNC (SYSDATE)
                     THEN
                         0
                     ELSE
                         DECODE (NVL (D.CALCJUROSCOBRANCA, 'N'),
                                 'N', NVL (NVL ( null, D.TXJUROS), 0),
                                 NVL (D.TXJUROS, 0))
                 END
               / 100                                        AS TXJUROS,
               F_QTDIASVENCIDOS (A.DTVENC,
                                 NVL (A.DTPAG, TRUNC (SYSDATE)),
                                 A.CODCOB,
                                 A.CODFILIAL,
                                 NVL (E.USADIAUTILFILIAL, 'N'),
                                 'N')                       DIASATRASO,
               A.NUMCHEQUE                       AS NUMCHEQUE,
               A.NUMBANCO                        AS NUMBANCO,
               B.CLIENTE                            AS CLIENTE,
               NVL (A.PROTESTO, 'N')             PROTESTO,
               A.DTPAG,
               A.PERCOM,
               A.CARTORIO,
               A.NOSSONUMBCO,
               A.NOSSONUMBCO2,
               A.LINHADIG,
               A.LINHADIG2,
               A.VLTXBOLETO,
               A.CODSUPERVISOR,
               A.AGENCIA,
               A.CODBARRA,
               A.NUMCARTEIRA,
               A.ID_ERP,
               A.RECEBIVEL,
               A.CODCLIENTENOBANCO
          FROM ERP_MXSPREST A,
               MXSCLIENT B,
               MXSUSUARI C,
               MXSCOB D,
               MXSFILIAL E
         WHERE     D.CODCOB(+) = A.CODCOB
               AND A.CODOPERACAO != 2
               AND B.CODOPERACAO != 2
               AND C.CODOPERACAO(+) != 2
               AND D.CODOPERACAO(+) != 2
               AND E.CODOPERACAO != 2
               AND C.CODUSUR(+) = A.CODUSUR
               AND B.CODCLI = A.CODCLI
               --AND A.CODCOB <> 'DESD'
               --AND A.DTPAG IS NULL
               AND NVL(TO_CHAR(A.DTPAG,'DD-MM-YYYY'),'00-00-0000') = '00-00-0000'
               AND E.CODIGO = A.CODFILIAL
               AND (   A.NUMTRANSVENDA <> A.DUPLIC
                    OR (NOT REGEXP_LIKE (A.PREST, '^[0-9]+$'))
                    OR (A.NUMTRANSVENDA = A.DUPLIC))
               AND A.CODCOB NOT IN ('DEVP','DESD',
                                               'DEVT',
                                               'BNF',
                                               'BNFT',
                                               'BNFR',
                                               'BNTR',
                                               'BNRP',
                                               'CRED')
               AND (   'N' = 'N'
                    OR ( 'N' = 'S' AND A.DTVENC < SYSDATE))
        UNION ALL
        SELECT A.NUMTRANSVENDA,
               A.DUPLIC,
               A.PREST,
               A.DTEMISSAO,
               A.DTVENC,
               A.STATUS,
               A.CODCOB,
               NVL (A.VALOR, 0)                  AS VALOR,
               NVL (A.VALORDESC, 0)              AS VALORDESC,
               NVL (A.TXPERM, 0)                 AS TXPERM,
               NVL (A.VPAGO, 0)                  AS VPAGO,
               A.DTVENCORIG,
               NVL (A.VALORORIG, 0)              VALORORIG,
               B.CODCLI,
               CASE
                   WHEN A.DTVENC >= TRUNC (SYSDATE) THEN 'N'
                   ELSE 'S'
               END                                          AS VENCIDO,
               CASE
                   WHEN     NVL (D.MXINAD, 'S') = 'S'
                        AND A.DTVENC + NVL (D.MXDIASINAD, 0) <
                            TRUNC (SYSDATE)
                   THEN
                       'S'
                   ELSE
                       'N'
               END                                          AS INADIMPLENCIA,
               A.CODFILIAL,
               A.CODUSUR,
               FCALCULAR_JUROS_TITULO (
                   DECODE (NVL (D.CALCJUROSCOBRANCA, 'N'),
                           'N', NVL (NVL ( null, D.TXJUROS), 0),
                           NVL (D.TXJUROS, 0)),
                   A.DTVENC,
                   NVL (A.DTPAG, TRUNC (SYSDATE)),
                   A.CODCOB,
                   A.CODFILIAL,
                   A.VALOR,
                   null,
                   NVL (E.USADIAUTILFILIAL, 'N'),
                   NVL (A.TXPERMPREVISTO, 0))    JUROS,
                 CASE
                     WHEN A.DTVENC >= TRUNC (SYSDATE)
                     THEN
                         0
                     ELSE
                         DECODE (NVL (D.CALCJUROSCOBRANCA, 'N'),
                                 'N', NVL (NVL ( null, D.TXJUROS), 0),
                                 NVL (D.TXJUROS, 0))
                 END
               / 100                                        AS TXJUROS,
               F_QTDIASVENCIDOS (A.DTVENC,
                                 NVL (A.DTPAG, TRUNC (SYSDATE)),
                                 A.CODCOB,
                                 A.CODFILIAL,
                                 NVL (E.USADIAUTILFILIAL, 'N'),
                                 'N')                       DIASATRASO,
               A.NUMCHEQUE                       AS NUMCHEQUE,
               A.NUMBANCO                        AS NUMBANCO,
               B.CLIENTE                            AS CLIENTE,
               NVL (A.PROTESTO, 'N')             PROTESTO,
               A.DTPAG,
               A.PERCOM,
               A.CARTORIO,
               A.NOSSONUMBCO,
               A.NOSSONUMBCO2,
               A.LINHADIG,
               A.LINHADIG2,
               A.VLTXBOLETO,
               A.CODSUPERVISOR,
               A.AGENCIA,
               A.CODBARRA,
               A.NUMCARTEIRA,
               A.ID_ERP,
               A.RECEBIVEL,
               A.CODCLIENTENOBANCO
          FROM ERP_MXSPREST A,
               MXSCLIENT B,
               MXSUSUARI C,
               MXSCOB D,
               MXSFILIAL E
         WHERE     'N' = 'S'
               AND A.CODOPERACAO != 2
               AND B.CODOPERACAO != 2
               AND C.CODOPERACAO(+) != 2
               AND D.CODOPERACAO(+) != 2
               AND E.CODOPERACAO != 2
               AND D.CODCOB(+) = A.CODCOB
               AND C.CODUSUR(+) = A.CODUSUR
               AND B.CODCLI = A.CODCLI
               --AND A.CODCOB <> 'DESD'
               --AND A.DTPAG IS NOT NULL
               AND NVL(TO_CHAR(A.DTPAG,'DD-MM-YYYY'),'00-00-0000') != '00-00-0000'
               AND A.DTPAG >= TRUNC (SYSDATE) - 60
               AND E.CODIGO = A.CODFILIAL
               AND (   A.NUMTRANSVENDA <> A.DUPLIC
                    OR (NOT REGEXP_LIKE (A.PREST, '^[0-9]+$')))
               AND A.CODCOB NOT IN ( 'DEVP','DESD',
                                               'DEVT',
                                               'BNF',
                                               'BNFT',
                                               'BNFR',
                                               'BNTR',
                                               'BNRP',
                                               'CRED')
               AND (   'N' = 'N'
                    OR ( 'N' = 'S' AND A.DTVENC < SYSDATE)));
                    

CREATE INDEX IDX_DBA_TESTE010 ON ERP_MXSPREST (NVL(TO_CHAR(DTPAG,'DD-MM-YYYY'),'00-00-0000')) ;
