--> Indices

--{SINTAXE Oracle} -->> CREATE INDEX nome_do_indice ON nome_da_tabela (nome_do_campo); 
--{SINTAXE Postgres} -->> CREATE INDEX nome_do_indice ON public.nome_da_tabela USING btree (nome_do_campo);

/*
Indice SIMPLE

CREATE INDEX IDX_DBA_TESTE_01 ON MXSPRODUT (TO_NUMBER(CODPROD));
DROP INDEX IDX_DBA_TESTE_01;
*/
DESC MXSPRODUT;--avaliar datatypes

SELECT * FROM MXSPRODUT WHERE CODPROD = 5418;
 
/*   
Indices compostos

CREATE INDEX IDX_DBA_TESTE_02 ON ERP_MXSMOV (NUMTRANSVENDA);
DROP INDEX IDX_DBA_TESTE_02;

CREATE INDEX IDX_DBA_TESTE_03 ON ERP_MXSPREST (CODUSUR);
DROP INDEX IDX_DBA_TESTE_03;
*/
DESC ERP_MXSMOV;
DESC ERP_MXSPREST;

SELECT  MOV.NUMPED,
        PREST.NUMTRANSVENDA,
        PREST.CODCLI,
        MOV.CODPROD, 
        MOV.QT, 
        MOV.PTABELA, 
        MOV.CODFILIAL, 
        MOV.DTMOV,  
        PREST.DTVENC, 
        PREST.DTPAG,
        PREST.CODUSUR
FROM ERP_MXSMOV MOV
LEFT JOIN ERP_MXSPREST PREST ON PREST.NUMTRANSVENDA = MOV.NUMTRANSVENDA
WHERE PREST.CODUSUR = 135
  AND PREST.CODCLI = 44381
  AND MOV.DTMOV BETWEEN TO_DATE('01/01/2022','DD/MM/YYYY') AND TO_DATE('01/06/2022','DD/MM/YYYY')
;




/*
Verificar FK que estão sem INDICES

select table_name,
 constraint_name, columns,
'CREATE INDEX '||constraint_name||'_idx ON '||table_name||'('||columns||');' as indice
from
(select table_name, constraint_name, cname1 || nvl2(cname2,','||cname2,null) ||
nvl2(cname3,','||cname3,null) || nvl2(cname4,','||cname4,null) ||
nvl2(cname5,','||cname5,null) || nvl2(cname6,','||cname6,null) ||
nvl2(cname7,','||cname7,null) || nvl2(cname8,','||cname8,null) columns
from ( select b.table_name,  b.constraint_name,
max(decode( position, 1, column_name, null )) cname1,
max(decode( position, 2, column_name, null )) cname2,
max(decode( position, 3, column_name, null )) cname3,
max(decode( position, 4, column_name, null )) cname4,
max(decode( position, 5, column_name, null )) cname5,
max(decode( position, 6, column_name, null )) cname6,
max(decode( position, 7, column_name, null )) cname7,
max(decode( position, 8, column_name, null )) cname8, count(*) col_cnt
from (select substr(table_name,1,30) table_name,
substr(constraint_name,1,30) constraint_name,
substr(column_name,1,30) column_name, position
from user_cons_columns ) a, user_constraints b
where a.constraint_name = b.constraint_name and b.constraint_type = 'R'
group by b.table_name, b.constraint_name) cons
where col_cnt > ALL
( select count(*) from user_ind_columns i
where i.table_name = cons.table_name and i.column_name in 
(cname1, cname2, cname3, cname4, cname5, cname6, cname7, cname8 )
and i.column_position <= cons.col_cnt group by i.index_name))
*/