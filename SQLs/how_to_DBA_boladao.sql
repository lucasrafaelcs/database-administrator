------------------------------------------------------------------------------------------------------------------------------------------------------

                                              --Alguns feelings de problema de performance--

-- Sempre de olho no painel da AWS para monitorar as filas, no grafana para avaliar recursos.
-- Alertas criticos: Sessions,memory,disk,locked,maybe-problem.
-- CPU alta sem fila, dependendo da periodicidade "normal".
-- CPU alta com fila a pelo menos 10min possivel problema em algum cliente em determinada consulta
-- Problema na sincronização do maxPedido: Carga de dados e as estatisticas ficaram desatualizadas, consulta ruim, consulta nova,alto volume em alguma tabela
-- Identificou o problema, em 15min não resolveu ? Reboot, continua a atuação, e espera mais 15 se não resolveu sobe uma classe da instancia.
-- A instancia maxsolucoes-goya sempre ficará a maior parte do dia com CPU alta e um pouco de fila (8/15) mas não irá parar o ambiente.
-- Instancia XIOS, alta demanda dos clientes STO,LAREDO e REFIL então no inicio do dia costumam dar problemas.
-- Se o alerta do "Rabbit" for acionado, significa que a sincronização do maxPedido está com lentidão e que o ambiente Oracle tb, a aplicação irá escalar
-----recurso e isso ira aumentar a demanda de conexões ainda mais nos bancos.
-- Na duvida para analisar algum problema na aplicação que está afetando o banco de dados falar com o Brunão.
-- Caso tenhamos alguma parada de banco, documentar no servidor Chappie o dia e o motivo para termos historico.
-- Caso identificado algum index positivo, encaminhar para o Atualizador.

------------------------------------------------------------------------------------------------------------------------------------------------------

                                        --Scripts para monitoramento e avaliação de performance--

------------------------------------------------------------------------------------------------------------------------------------------------------
--Avaliar consultas com maior tempo de execução
SELECT DISTINCT SES.PROGRAM EXECUTAVEL,
	ses.osuser,
  ses.blocking_session,
  ses.sql_id,
	TO_CHAR(TRUNC(SES.LAST_CALL_ET / 60 / 60),
			'FM999900') || ':' ||
	TO_CHAR(TRUNC(((SES.LAST_CALL_ET / 60 / 60) -
				  TRUNC(SES.LAST_CALL_ET / 60 / 60)) * 60),
			'FM00') || ':' ||
	TO_CHAR(TRUNC(((((SES.LAST_CALL_ET / 60 / 60) -
				  TRUNC(SES.LAST_CALL_ET / 60 / 60)) * 60) -
				  TRUNC(((SES.LAST_CALL_ET / 60 / 60) -
						TRUNC(SES.LAST_CALL_ET / 60 / 60)) * 60))*60),
			'FM00') TEMPO,
	SES.LAST_CALL_ET TEMPO_EM_SEGUNDOS,
	SES.STATUS,	
	SES.SID SID,
	SES.SERIAL# SERIAL#,
	SQL.SQL_TEXT TEXTO_SQL,
	SES.MACHINE MAQUINA,
	SES.USERNAME USUARIO_ORACLE,
	SES.OSUSER USUARIOS_SO,
    'begin begin rdsadmin.rdsadmin_util.kill( sid    => ''' || SID || ''', serial => ''' || SERIAL# || ''', method => ''IMMEDIATE'' ); end; exception when others then null; end;' COMANDO
FROM GV$SESSION       SES,
       GV$SQL           SQL
 WHERE SES.SQL_ADDRESS = SQL.ADDRESS(+)
   AND SES.TYPE != 'BACKGROUND'
   --AND SES.STATUS = 'ACTIVE'
   --AND SES.USERNAME = ''
 ORDER BY SES.LAST_CALL_ET DESC;
------------------------------------------------------------------------------------------------------------------------------------------------------

--SQLID que está causando problema
 SELECT  S.SQL_ID,S.STATUS, S.LOGON_TIME,TO_CHAR (SYSDATE,'DD/MM/YYYY HH24:MI:SS') HORA_ATUAL,
        'begin rdsadmin.rdsadmin_util.kill( sid => ''' || S.SID || ''', serial => ''' || S.SERIAL# || ''', method => ''IMMEDIATE'' ); end;' KILL_SESSION,
        S.SID,S.SERIAL#,
        S.PROGRAM,S.OSUSER, 
        S.SCHEMANAME, S.MACHINE, 
        S.BLOCKING_SESSION, REPLACE (Q.SQL_FULLTEXT,CHR(0))SQL_TEXT
FROM GV$SESSION S,
     GV$SQL Q
WHERE S.SQL_ADDRESS = Q.ADDRESS
  AND S.SQL_HASH_VALUE = Q.HASH_VALUE
  AND S.SQL_CHILD_NUMBER = Q.CHILD_NUMBER
  AND S.SQL_ID IN ('')
  AND S.USERNAME IS NOT NULL
  AND S.STATUS != 'KILLED'; 
------------------------------------------------------------------------------------------------------------------------------------------------------

--DETALHES DO SQL UTILIZADO
SELECT PARSING_SCHEMA_NAME, 
       SQL_FULLTEXT,
       ACTION,
       MODULE,
       HASH_VALUE,
       FIRST_LOAD_TIME,
       LAST_LOAD_TIME,
       LAST_ACTIVE_TIME,
       CHILD_NUMBER,
       EXECUTIONS,
       LOADS,
       INVALIDATIONS,
       PARSE_CALLS,
       CHILD_NUMBER
FROM V$SQL
WHERE SQL_ID = ''; 
------------------------------------------------------------------------------------------------------------------------------------------------------

--CONSULTAR VARIAVEIS BIND
SELECT NAME,TO_CHAR(LAST_CAPTURED,'DD/MM/YYYY HH24:MI:SS'),VALUE_STRING, DATATYPE_STRING 
FROM V$SQL_BIND_CAPTURE WHERE SQL_ID = '' AND CHILD_NUMBER =;
------------------------------------------------------------------------------------------------------------------------------------------------------

--PLANO DE EXECUÇÃO
select * from table(dbms_xplan.display);
EXPLAIN PLAN FOR
------------------------------------------------------------------------------------------------------------------------------------------------------

--USUARIOS LOGADOS NA INSTANCIA
SELECT S.SID,     S.SERIAL#,
       S.LOGON_TIME,TO_CHAR (SYSDATE,'DD/MM/YYYY HH24:MI:SS') HORA_ATUAL,
       S.STATUS,  S.PROGRAM,
       S.OSUSER,  S.SCHEMANAME,
       S.MACHINE, S.BLOCKING_SESSION
FROM V$SESSION S
WHERE S.OSUSER NOT IN ('rdsdb','root','rdsmon','MAXIMA','PortalExecutivo','rdshm');
------------------------------------------------------------------------------------------------------------------------------------------------------

--VERIFICANDO QUANTO DE MEMORIA POR USUARIO NA PGA
SELECT A.SID,A.SERIAL#,
       NVL(A.USERNAME, '(oracle)') as username,
       A.MODULE,
       A.PROGRAM,
       TRUNC (B.VALUE/1024/1024) AS MEMORY_MB
FROM V$SESSION A,
     V$SESSTAT B,
     V$STATNAME C
WHERE A.SID = B.SID
    AND B.STATISTIC# = C.STATISTIC#
    AND C.NAME = 'session pga memory'
    and A.PROGRAM IS NOT NULL
ORDER BY B.VALUE DESC;
------------------------------------------------------------------------------------------------------------------------------------------------------

--LOCKED
SELECT DECODE (L.BLOCK, 0, 'Em espera', 'Bloqueando ->') USER_STATUS
,CHR (39) || S.SID || ',' || S.SERIAL# || CHR (39) SID_SERIAL
,(SELECT INSTANCE_NAME FROM GV$INSTANCE WHERE INST_ID = L.INST_ID)
CONN_INSTANCE
,S.SQL_ID
,S.SID
,S.PROGRAM
,S.SCHEMANAME
,OBJECT_NAME
,S.OSUSER
,S.MACHINE
,DECODE (L.TYPE,'RT', 'Redo Log Buffer','TD', 'Dictionary'
,'TM', 'DML','TS', 'Temp Segments','TX', 'Transaction'
,'UL', 'User','RW', 'Row Wait',L.TYPE) LOCK_TYPE
--,ID1
--,ID2
,DECODE (L.LMODE,0, 'None',1, 'Null',2, 'Row Share',3, 'Row Excl.'
,4, 'Share',5, 'S/Row Excl.',6, 'Exclusive'
,LTRIM (TO_CHAR (LMODE, '990'))) LOCK_MODE
,TO_CHAR(TRUNC(S.LAST_CALL_ET / 60 / 60), 'FM999900') || ':' || 
 TO_CHAR(TRUNC(((S.LAST_CALL_ET / 60 / 60) - TRUNC(S.LAST_CALL_ET / 60 / 60)) * 60), 'FM00') || ':' ||
 TO_CHAR(TRUNC(((((S.LAST_CALL_ET / 60 / 60) - TRUNC(S.LAST_CALL_ET / 60 / 60)) * 60) - TRUNC(((S.LAST_CALL_ET / 60 / 60) - TRUNC(S.LAST_CALL_ET / 60 / 60)) * 60))*60), 'FM00') TEMPO
,S.LAST_CALL_ET TEMPO_EM_SEGUNDOS
,'begin rdsadmin.rdsadmin_util.kill( sid    => ''' || s.SID || ''', serial => ''' || s.SERIAL# || ''', method => ''IMMEDIATE'' ); end;' COMANDO
FROM 
   GV$LOCK L
JOIN 
   GV$SESSION S
ON (L.INST_ID = S.INST_ID
AND L.SID = S.SID)
JOIN GV$LOCKED_OBJECT O
ON (O.INST_ID = S.INST_ID
AND S.SID = O.SESSION_ID)
JOIN DBA_OBJECTS D
ON (D.OBJECT_ID = O.OBJECT_ID)
WHERE (L.ID1, L.ID2, L.TYPE) IN (SELECT ID1, ID2, TYPE
FROM GV$LOCK
WHERE REQUEST > 0)
ORDER BY ID1, ID2, CTIME DESC;
------------------------------------------------------------------------------------------------------------------------------------------------------

--LIMPAR SHARED POOL
exec rdsadmin.rdsadmin_util.flush_shared_pool;
------------------------------------------------------------------------------------------------------------------------------------------------------

--LIMPAR BUFFER CACHE
exec rdsadmin.rdsadmin_util.flush_buffer_cache;
------------------------------------------------------------------------------------------------------------------------------------------------------

--COLETAR ESTATISTICAS
exec pkg_vikings.tyr ('USER',NULL);--stats full schema
exec pkg_vikings.tyr ('USER','TABLE');--stats table schema
------------------------------------------------------------------------------------------------------------------------------------------------------

--DESFRAGMENTAR 
exec pkg_vikings.ragnar ('USER');--full schema
exec pkg_vikings.ivar ('USER','TABLE');--table
------------------------------------------------------------------------------------------------------------------------------------------------------

--WORKLOAD AUMENTA NO FINAL DO MES, COLETAR STATS SYSTEM NO PENULTIMO DIA as 08h
EXEC DBMS_STATS.GATHER_SYSTEM_STATS('interval', interval => 60);
------------------------------------------------------------------------------------------------------------------------------------------------------

--ESCALOU O BANCO QUANDO VOLTAR FAZER:
EXEC DBMS_STATS.GATHER_SYSTEM_STATS('interval', interval => 60);
EXEC DBMS_STATS.GATHER_DATABASE_STATS;
------------------------------------------------------------------------------------------------------------------------------------------------------

--STATSPACK
select snap_id, to_char(snap_time, 'Dy DD-Mon-YYYY HH24:MI:SS') snap_time  from stats$snapshot order by 1 desc;
exec RDSADMIN.RDS_RUN_SPREPORT(1,2);
------------------------------------------------------------------------------------------------------------------------------------------------------

--TOP QUERYS POR TEMPO DE CPU (STATSPACK)
select snap_id, to_char(snap_time, 'Dy DD-Mon-YYYY HH24:MI:SS') snap_time  from stats$snapshot order by 1 desc;--snap do statpack
SELECT A.hash_value,
       A.sql_id,
       A.text_subset,
       A.module,
       trunc((B.cpu_time-A.cpu_time)/1000) "CPU_TIME(ms)",
       B.executions-A.executions executions,
       trunc(decode(B.executions-A.executions, 0, 0, (B.cpu_time-A.cpu_time)/(B.executions-A.executions))/1000) "CPU_TIME_PER_EXEC(ms)"
FROM STATS$SQL_SUMMARY A,
     STATS$SQL_SUMMARY B
WHERE A.hash_value = B.hash_value
  AND A.snap_id = :begin_snap
  AND B.snap_id = :end_snap
ORDER BY "CPU_TIME(ms)" DESC;
------------------------------------------------------------------------------------------------------------------------------------------------------

--TOP QUERYS POR TEMPO DE EXECUÇÃO (STATSPACK)
select snap_id, to_char(snap_time, 'Dy DD-Mon-YYYY HH24:MI:SS') snap_time  from stats$snapshot order by 1 desc;--snap do statpack
SELECT A.hash_value,
       A.sql_id,
       A.text_subset,
       A.module,
       trunc((B.elapsed_time-A.elapsed_time)/1000) "ELAPSED_TIME(ms)",
       B.executions-A.executions executions,
       trunc(decode(B.executions-A.executions, 0, 0, (B.elapsed_time-A.elapsed_time)/(B.executions-A.executions))/1000) "ELAPSED_TIME_PER_EXEC(ms)"
FROM STATS$SQL_SUMMARY A,
     STATS$SQL_SUMMARY B
WHERE A.hash_value = B.hash_value
  AND A.snap_id = :begin_snap
  AND B.snap_id = :end_snap
ORDER BY "ELAPSED_TIME(ms)" DESC;
------------------------------------------------------------------------------------------------------------------------------------------------------

--VERIFICAR TABELAS QUE PRECISAO DE DESFRAGMENTAÇÃO (shrink)
select * 
from ALL_TAB_MODIFICATIONS
WHERE table_owner LIKE '%PRODUCAO' 
AND table_owner = 'USER'
--AND table_name NOT IN (SELECT table_name FROM DBA_INDEXES WHERE index_type LIKE 'FUN%')
ORDER BY DELETES DESC;
------------------------------------------------------------------------------------------------------------------------------------------------------

--VERIFICAR QUEM ESTÁ MANIPULANDO OBJETOS
SELECT A.*, B.USERNAME, B.MACHINE, B.STATUS, 	TO_CHAR(TRUNC(B.LAST_CALL_ET / 60 / 60),
			'FM999900') || ':' ||
	TO_CHAR(TRUNC(((B.LAST_CALL_ET / 60 / 60) -
				  TRUNC(B.LAST_CALL_ET / 60 / 60)) * 60),
			'FM00') || ':' ||
	TO_CHAR(TRUNC(((((B.LAST_CALL_ET / 60 / 60) -
				  TRUNC(B.LAST_CALL_ET / 60 / 60)) * 60) -
				  TRUNC(((B.LAST_CALL_ET / 60 / 60) -
						TRUNC(B.LAST_CALL_ET / 60 / 60)) * 60))*60),
			'FM00') TEMPO,
	B.LAST_CALL_ET TEMPO_EM_SEGUNDOS
FROM V$ACCESS A
INNER JOIN V$SESSION B ON A.SID=B.SID
WHERE A.TYPE='TABLE'
AND OWNER = 'USER'
AND B.PROGRAM = 'PROGRAM';
------------------------------------------------------------------------------------------------------------------------------------------------------

--SESSOES ABERTAS POR PROGRAMA
SELECT S.LOGON_TIME,
       TO_CHAR (SYSDATE,'DD/MM/YYYY HH24:MI:SS') HORA_ATUAL,
       S.USERNAME,
       S.PROGRAM,
       S.OSUSER,
       S.MACHINE,
       S.STATUS,
       S.SQL_ID,
       Q.SQL_FULLTEXT
FROM V$SESSION S, V$SQL Q
WHERE S.SQL_ADDRESS = Q.ADDRESS
   AND S.SQL_HASH_VALUE = Q.HASH_VALUE
   AND S.SQL_CHILD_NUMBER = Q.CHILD_NUMBER
   AND PROGRAM IN ('PROGRAMA')
   AND SCHEMANAME != 'RDSADMIN' 
   AND LOGON_TIME < (SYSDATE - 3/ (24 * 60))--minutos
   AND STATUS = 'INACTIVE'
ORDER BY LOGON_TIME;
------------------------------------------------------------------------------------------------------------------------------------------------------

--FINALIZAR TODAS AS CONEXÕES DO USUARIO
SET SERVEROUTPUT ON
SET VERIFY OFF
BEGIN    
    DBMS_OUTPUT.ENABLE(NULL);
    FOR CUR_TAB IN (SELECT  SID, 
                            USERNAME,
                            PROGRAM,
                            OSUSER,
                            SQL_ID,
                            'begin rdsadmin.rdsadmin_util.kill( sid => ''' || SID || ''', serial => ''' || SERIAL# || ''', method => ''PROCESS'' ); end;' as CMD
                    FROM    V$SESSION 
                    WHERE   CHEMANAME NOT IN ('RDSADMIN', 'SYS', 'rdsmon','rdshm')
                        AND TYPE != 'BACKGROUND'
                        AND USERNAME = 'USER')
                        LOOP
        BEGIN
          EXECUTE IMMEDIATE CUR_TAB.CMD;
          COMMIT;
          dbms_output.put_line(CUR_TAB.SQL_ID ||' '|| '- Programa: ' || CUR_TAB.PROGRAM ||' '||'-'||' '|| 'Osuser: ' || CUR_TAB.OSUSER ||' '||'-'||' '||'Schema:' ||  CUR_TAB.USERNAME);
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao eliminar sessão ' || CUR_TAB.SID || '. ' || SQLERRM);
        END;
    END LOOP;
END;
------------------------------------------------------------------------------------------------------------------------------------------------------

--verificar alert logs no rds aws
SELECT message_text FROM alertlog order by originating_timestamp desc;

select message_text, trunc(originating_timestamp),count (*) from alertlog where message_text like '%Checkpoint not complete%' group by message_text,trunc(originating_timestamp);

SELECT originating_timestamp,message_text FROM alertlog where  message_text like '%PGA memory used by the instance exceeds PGA_AGGREGATE_LIMIT%' order by originating_timestamp desc;

SELECT originating_timestamp,error_instance_id,problem_key,MESSAGE_TEXT FROM alertlog where  problem_key is not null order by originating_timestamp desc;
------------------------------------------------------------------------------------------------------------------------------------------------------

--TAMANHO DE OBJETOS NO BANCO
select * from 
(select owner, segment_name, trunc(sum(bytes)/1024/1024/1024,2) "SIZE GB"
      from dba_segments
      where segment_type = 'TABLE'
      and segment_name = 'MXSTABPR'
      group by segment_name, owner
      order by 3 desc)
where rownum <= 10;

SELECT T.TABLE_NAME AS "TABLE NAME",
       TO_CHAR (T.NUM_ROWS,'999G999G999G999D99') AS "ROWS",
       TRUNC((T.BLOCKS * 8192)/1024/1024/1024,2) AS "SIZE GB", 
       T.LAST_ANALYZED AS "LAST ANALYZED"       
FROM   DBA_TABLES T
WHERE T.OWNER = 'STO_424_PRODUCAO'
  --AND OWNER LIKE '%_PRODUCAO'
  AND T.NUM_ROWS IS NOT NULL
ORDER BY T.NUM_ROWS DESC;
------------------------------------------------------------------------------------------------------------------------------------------------------

--TAMANHO DOS SCHEMAS
SELECT OWNER,
       TABLESPACE_NAME,
       TRUNC (SUM(BYTES)/1024/1024/1024,2) "GB"
FROM DBA_SEGMENTS
GROUP BY OWNER,TABLESPACE_NAME
ORDER BY GB DESC;

SELECT tablespace_name,segment_type,
       TRUNC (SUM(BYTES)/1024/1024/1024,2) "GB" 
FROM DBA_SEGMENTS
WHERE OWNER = 'FECP'
GROUP BY tablespace_name, segment_type
ORDER BY GB DESC;
------------------------------------------------------------------------------------------------------------------------------------------------------

-- Mostra a relação de tamanhos das tabelas de um determinado schema
SELECT t.table_name AS "Table Name",
       t.TABLESPACE_NAME AS "Table space",
       t.num_rows AS "Rows",
       t.avg_row_len AS "Avg Row Len",
       Trunc((t.blocks * p.value)/1024) AS "Size KB", -- numero de blocos X o seu tamanho em KBs
       t.last_analyzed AS "Last Analyzed"       
FROM   dba_tables t,
       v$parameter p
WHERE t.owner = 'NOME_SCHEMA'
AND   p.name = 'db_block_size'
ORDER BY 5 desc
------------------------------------------------------------------------------------------------------------------------------------------------------

--Ajuste de overhead em determinada tabela de cliente especifico (FALHA NA SINCRONIZAÇÃO/LENTIDAO)

  ALTER USER SCHEMA ACCOUNT LOCK;
  BEGIN
      FOR KILL_SESSION IN (SELECT 'begin rdsadmin.rdsadmin_util.kill( sid => ''' || SID || ''', serial => ''' || SERIAL# || ''', method => ''IMMEDIATE'' );exception when others then null; end;' AS CMD 
                         FROM V$SESSION WHERE USERNAME = 'SCHEMA')
        LOOP
          BEGIN
            EXECUTE IMMEDIATE KILL_SESSION.CMD; 
            EXIT WHEN KILL_SESSION.CMD IS NULL;
          END;
        END LOOP;
        
       FOR KILL_SESSION_LOCKED IN (SELECT 'begin rdsadmin.rdsadmin_util.kill( sid => ''' || a.SID || ''', serial => ''' || a.SERIAL# || ''', method => ''IMMEDIATE'' );exception when others then null; end;' AS CMD 
                                FROM v$session a, v$locked_object b, all_objects c where b.object_id = c.object_id and a.sid = b.session_id and c.owner = 'SCHEMA')
        LOOP
          BEGIN
            EXECUTE IMMEDIATE KILL_SESSION_LOCKED.CMD; 
            EXIT WHEN KILL_SESSION_LOCKED.CMD IS NULL;
          END;
        END LOOP; 
  END;
  
  EXEC PKG_VIKINGS.IVAR ('SCHEMA','TABELA');--desfragmentação e coleta de estatisticas
  
  ALTER USER SCHEMA ACCOUNT UNLOCK;




    BEGIN
      FOR KILL_SESSION IN (SELECT 'begin rdsadmin.rdsadmin_util.kill( sid => ''' || SID || ''', serial => ''' || SERIAL# || ''', method => ''IMMEDIATE'' );exception when others then null; end;' AS CMD 
                         FROM V$SESSION WHERE USERNAME LIKE '%_PRODUCAO%')
        LOOP
          BEGIN
            EXECUTE IMMEDIATE KILL_SESSION.CMD; 
            EXIT WHEN KILL_SESSION.CMD IS NULL;
          END;
        END LOOP;
        
       FOR KILL_SESSION_LOCKED IN (SELECT 'begin rdsadmin.rdsadmin_util.kill( sid => ''' || a.SID || ''', serial => ''' || a.SERIAL# || ''', method => ''IMMEDIATE'' );exception when others then null; end;' AS CMD 
                                FROM v$session a, v$locked_object b, all_objects c where b.object_id = c.object_id and a.sid = b.session_id and c.owner LIKE '%_PRODUCAO%')
        LOOP
          BEGIN
            EXECUTE IMMEDIATE KILL_SESSION_LOCKED.CMD; 
            EXIT WHEN KILL_SESSION_LOCKED.CMD IS NULL;
          END;
        END LOOP; 
  END;
------------------------------------------------------------------------------------------------------------------------------------------------------

--URGENTE, PRECISA CRIAR UM INDEX PARA TODOS OS CLIENTES DA INSTANCIA

DECLARE
VERRO VARCHAR2 (4000);
VSTATUS NUMBER(5);
BEGIN
FOR DADOS IN (SELECT USERNAME FROM DBA_USERS WHERE USERNAME LIKE '%_PRODUCAO' ORDER BY DBMS_RANDOM.RANDOM)
   LOOP
    BEGIN 
    EXECUTE IMMEDIATE 'CREATE INDEX ' || DADOS.USERNAME || '.IDX_DBA_NOME_DO_INDEX ON ' || DADOS.USERNAME ||'.TABELA (COLUNAS)';
    VSTATUS:= 1;
    
    EXCEPTION WHEN OTHERS THEN
    VERRO := SUBSTR ('CODE >> ' || SQLCODE || ' MSG >> ' || SQLERRM || ' STACK >> ' || DBMS_UTILITY.FORMAT_CALL_STACK,0,4000);
    VSTATUS := 2; 
    END;
    
    IF VSTATUS = 1
    THEN DBMS_OUTPUT.put_line ('Successfully Created Index completed -->>' || ' User ' || DADOS.USERNAME);
    ELSE
    DBMS_OUTPUT.put_line ('Imcompleted Index error -->>' || ' User ' || DADOS.USERNAME || ' ERRO: ' || VERRO);
    END IF;
  
   END LOOP;
END;
------------------------------------------------------------------------------------------------------------------------------------------------------

