#!/bin/bash

############################################################################################################################
#                          SCRIPT DE INSTALAÇÃO ORACLE DATABASE 19C - ORACLE LINUX 8.4                                     #
#                                                                                                                          #
#                                                                                                                          #
# Arquivo de instalação do oracle deve estar dentro do /etc e ter o seguinte nome: LINUX.X64_193000_db_home.zip            #
# Permissões necessárias: chmod +x inst19c.sh                                                                              #
# Executar: ./inst19c.sh                                                                                                   #
#                                                                                                                          #
# Hostname                            = <hostname>                                                                         #
# Ip                                  = <ip>                                                                               #
# Senha do usuário oracle do SO       = <senha_oracle>                                                                     #
# Senha usuário sys                   = <senha_sys>                                                                        #
# Senha usuário system                = <senha_system>                                                                     #
# Nome do pdb                         = <nome_do_pdb>                                                                      #
# Senha do usuário pdb Admin          = <senha_pdbAdmin>                                                                   #
# Memória destinada ao banco, em MB   = <memoria_banco>                                                                    #
# Nome do banco/instancia             = <instancia>                                                                        #
# Senha do usuário root do SO         = <senha_root>                                                                       #
#                                                                                                                          #
############################################################################################################################

##desabilitando firewall
systemctl stop firewalld > /tmp/log_inst19c.txt
systemctl disable firewalld >> /tmp/log_inst19c.txt
echo "========FIREWALL DESABILITADO"

##configurando arquivo de hosts
echo "<ip> <hostname> <hostname>.localdomain" >> /etc/hosts
echo "========ARQUIVO /etc/hosts CONFIGURADO"

##instalando pacote de preinstalação:
echo "=========INSTALANDO ARQUIVO DE PRÉ-INSTALAÇÃO DO ORACLE - log: /tmp/log_inst19c.txt"
yum install oracle-database-preinstall-19c.x86_64 -y >> /tmp/log_inst19c.txt
echo "***finalizado***"

##definir senha para usuário oracle,a senha fica depois do primeiro echo
echo <senha_oracle> | passwd oracle --stdin >> /tmp/log_inst19c.txt
echo "========SENHA DO USUÁRIO ORACLE DEFINIDA"

##criação do oracle_home
mkdir -p /u01/app/oracle/product/19.3.0.0/dbhome_1
chown -R oracle.oinstall /u01
echo "========CRIAÇÃO DO DIRETÓRIO ORACLE_HOME REALIZADA"

##mandar arquivo de instalação para oracle_home
mv /etc/LINUX.X64_193000_db_home.zip /u01/app/oracle/product/19.3.0.0/dbhome_1
chown oracle.oinstall /u01/app/oracle/product/19.3.0.0/dbhome_1/LINUX.X64_193000_db_home.zip

echo "========DESCOMPACTAÇÃO DO INSTALADOR DO ORACLE EM ANDAMENTO - log: /tmp/log_inst19c.txt"
##descompactar instalador com usuário oracle
su - oracle -c "unzip /u01/app/oracle/product/19.3.0.0/dbhome_1/LINUX.X64_193000_db_home.zip -d /u01/app/oracle/product/19.3.0.0/dbhome_1/" >> /tmp/log_inst19c.txt
echo "***finalizado***"

##ajuste a ser feito pós-descompactação, peculiariadade ol8
sed -i 's/#CV_ASSUME_DISTID=OEL5/CV_ASSUME_DISTID=OEL8/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/cv/admin/cvu_config

##criar e preencher arquivo de variáveis de ambiente
echo -e '#!/bin/bash
##########################################################################
# PROGRAMA:\t\tenv-db-<SID>.sh
# Objetivo:\t\tConfigurar variaveis de ambientes
##########################################################################
umask 022
EDITOR=vi;                   export EDITOR
TERM=xterm;                  export TERM
TEMP=/tmp;                   export TEMP
TMPDIR=/tmp;                 export TMPDIR
##########################################################################
# CONFIGURAR AMBIENTE ORACLE  
##########################################################################
export ORACLE_SID=<instancia>
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.3.0.0/dbhome_1
export ORACLE_UNQNAME=<instancia>
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
#export LANG=us_EN.UTF-8
export ORACLE_OWNER=oracle
export ORACLE_TERM=xterm
#########################################################################
# CONFIGURAR PATH        
#########################################################################
export PATH=$ORACLE_HOME/bin:$ORA_CRS_HOME/bin:$PATH:/usr/local/bin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORA_CRS_HOME/lib:/usr/local/lib:$LD_LIBRARY_PATH
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
##########################################################################
# Extra
##########################################################################
alias dba='\''sqlplus "/ as sysdba"'\''' > /home/oracle/env-db-<instancia>.sh

#mudar owner, grupo e permissões
chown oracle.oinstall /home/oracle/env-db-<instancia>.sh
chmod +x /home/oracle/env-db-<instancia>.sh
echo "========CRIADO ARQUIVO DE VARIÁVEIS DE AMBIENTE /home/oracle/env-db-<instancia>.sh"

##copiar arquivo de configuração SGBD para /home/oracle/env-db-<instancia>
cp /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp /home/oracle
chown oracle.oinstall /home/oracle/db_install.rsp

##editar arquivo anterior com os parâmetros necessários
sed -i 's/oracle\.install\.option=.*/oracle.install.option=INSTALL_DB_SWONLY/g' /home/oracle/db_install.rsp
sed -i 's/UNIX_GROUP_NAME=/UNIX_GROUP_NAME=oinstall/g' /home/oracle/db_install.rsp
sed -i 's|INVENTORY_LOCATION=|INVENTORY_LOCATION=/u01/app/oraInventory|g' /home/oracle/db_install.rsp
sed -i 's|ORACLE_HOME=|ORACLE_HOME=/u01/app/oracle/product/19.3.0.0/dbhome_1|g' /home/oracle/db_install.rsp
sed -i 's|ORACLE_BASE=|ORACLE_BASE=/u01/app/oracle|g' /home/oracle/db_install.rsp
sed -i 's|oracle.install.db.InstallEdition=|oracle.install.db.InstallEdition=EE|g' /home/oracle/db_install.rsp
sed -i 's|oracle.install.db.OSDBA_GROUP=|oracle.install.db.OSDBA_GROUP=dba|g' /home/oracle/db_install.rsp
sed -i 's|oracle.install.db.OSOPER_GROUP=|oracle.install.db.OSOPER_GROUP=oper|g' /home/oracle/db_install.rsp
sed -i 's|oracle.install.db.OSBACKUPDBA_GROUP=|oracle.install.db.OSBACKUPDBA_GROUP=backupdba|g' /home/oracle/db_install.rsp
sed -i 's|oracle.install.db.OSDGDBA_GROUP=|oracle.install.db.OSDGDBA_GROUP=dgdba|g' /home/oracle/db_install.rsp
sed -i 's|oracle.install.db.OSKMDBA_GROUP=|oracle.install.db.OSKMDBA_GROUP=kmdba|g' /home/oracle/db_install.rsp
sed -i 's|oracle.install.db.OSRACDBA_GROUP=|oracle.install.db.OSRACDBA_GROUP=racdba|g' /home/oracle/db_install.rsp
sed -i 's|oracle.install.db.rootconfig.executeRootScript=|oracle.install.db.rootconfig.executeRootScript=true|g' /home/oracle/db_install.rsp
sed -i 's|oracle.install.db.rootconfig.configMethod=|oracle.install.db.rootconfig.configMethod=ROOT|g' /home/oracle/db_install.rsp
echo "========RESPONSE FILE /HOME/ORACLE/DB_INSTALL.RSP AJUSTADO"

##Fazer a instalação passando o responsefile que foi configurado
##atenção: echo oracle passa a senha do usuário root para instalador executar runInstaller
echo "========INSTALAÇÃO DO SOFTWARE DO ORACLE DATABASE EM ANDAMENTO"
echo <senha_root> | su - oracle -c "/u01/app/oracle/product/19.3.0.0/dbhome_1/runInstaller -silent -responseFile /home/oracle/db_install.rsp"
echo "***finalizado***"

##copiar arquivo de configuração do listener para o home do oracle
cp /u01/app/oracle/product/19.3.0.0/dbhome_1/assistants/netca/netca.rsp /home/oracle
chown oracle.oinstall /home/oracle/netca.rsp

##criação do listener com valores padrões
echo "========CRIAÇÃO DO LISTENER EM ANDAMENTO"
su - oracle -c "/u01/app/oracle/product/19.3.0.0/dbhome_1/bin/netca -silent -responsefile /home/oracle/netca.rsp"
echo "***finalizado***"

##colocar arquivo de variáveis no bash_profile pra que sejam carregadas a cada login
echo ". /home/oracle/env-db-<instancia>.sh" >> /home/oracle/.bash_profile

##criação do banco de dados co dbca modo silent
echo "========CRIAÇÃO DO BANCO DE DADOS EM ANDAMENTO"
su - oracle -c "/u01/app/oracle/product/19.3.0.0/dbhome_1/bin/dbca -silent -createDatabase                                                                \
     -templateName General_Purpose.dbc                                         \
     -gdbname <instancia> -sid  <instancia> -responseFile NO_VALUE             \
     -characterSet AL32UTF8                                                    \
     -sysPassword <senha_sys>                                                  \
     -systemPassword <senha_system>                                            \
     -createAsContainerDatabase true                                           \
     -numberOfPDBs 1                                                           \
     -pdbName <nome_do_pdb>                                                    \
     -pdbAdminPassword <senha_pdbAdmin>                                        \
     -databaseType MULTIPURPOSE                                                \
     -memoryMgmtType auto_sga                                                  \
     -totalMemory <memoria_banco>                                              \
     -redoLogFileSize 200                                                      \
     -emConfiguration NONE                                                     \
     -ignorePreReqs"
echo "***finalizado***"
