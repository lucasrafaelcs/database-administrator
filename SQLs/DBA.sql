/*
Support Oracle:
E-mail: wanderson.medeiros@3db.net.br
Senha: 
Wpm@210527
*/

A cada inicialização do banco Oracle, parte da memória RAM do computador é alocada para a
SGA (System Global Area) e processos Oracle de segundo plano (Background Process) são
inicializados, visando controlar o banco. Então uma Instância Oracle (Instance) é o conjunto da
SGA (buffers da memória RAM) + processos Oracle de segundo plano (Background), que juntos
oferecem aos vários usuários o acesso ao banco de dados.

SGA – Memória compartilhada por todos os usuários Oracle.
Instância (instance) = SGA + Processos “Background”
-- Uma instancia é um conjunto de estruturas de memoria que gerenciam arquivos de banco de dados
--fila significa sessão "presa" (em espera), mas sessão que já abriu, ou seja, se abriu, tá gastando memória
3)É no arquivo de parâmetros (parameter file) que determinamos as características da instância
(instance)
                           /*Estruturas logicas de armazenamento*/ 

>> Toda unidade logica ainda sim é ligada em uma unidade fisica, em um HD.
>>Gravação sempre sequencial

--Objetos do banco de dados (SEGMENTOS)

* Tabelas -   São as unidades básicas de um SGBD Relacional. É formada por linhas e colunas,
              onde as linhas representam os registros e as colunas os campos da tabela.

* View -      É uma tabela formada por uma pesquisa em uma ou mais tabela-base.

* Procedure - São grupos de comandos SQL que poderão ser ativados pelos usuários

* Indices -   Quando criamos índices para uma tabela, especificando uma coluna, tal tabela é classificada de
              tal forma que, sempre que for mencionada uma query, o sistema usará o índice para Ter acesso
              direto aos dados desejados, ao invés de vasculhar a coluna toda.O objetivo da criação de índices
              é agilizar a recuperação de dados, ou seja, acelerar a procura dos dados na tabela.

* Role -      Agrupamento de privilégios, ou seja, em uma role podemos agrupar diversos privilégios e
              conceder aos usuários, não mais os privilégios e sim as roles.

* Tablespace- Objeto lógico que guarda os arquivos de dados do BD Oracle.

--Blocos no discos (DATABLOCKS)

>> Os objetos são salvos em blocos de dados.
>> Sendo uma unidade minima de armazenamento. Ao criar o banco é necessário criar
   o tamanho do bloco de dados sendo 2,8,4,16,32kb levando em consideração o bloco do HD sendo 8k.
    >>Header tem um endereço para o proximo dado ser encontrado, cabeçalho do dado.
    >>Espaço do bloco
    >>Dados
      * Bancos OLTP = Proposta inicial de comandos DML, recomendação de blocos de
      2kb ou 4kb. Maior velocidade na gravação e demora na leitura.
      * Bancos OLAP = Banco analitico destinado a consultas, recomendação de blocos 
      maiores de 16kb ou 32kb. Maior velocidade na leitura e lentidão na gravação.
      * 8KB seria um tamanho hibrido/padrão para os dois bancos.

--Tamanho ocupado por segmentos (EXTENTS)

>> O conjunto de DATABLOCKS forma um EXTENT ou seja ocupa um tamanho (extensão).
>> Quanto ao armazenamento, os segmentos formam extensões que não necessariamente
   continuos, mas os blocos de dados que compõe uma extensão, são contiguos.
>> Extents são aramazenados em TABLESPCES que são criadas com um tamanho pré-definido
   de extents livres. A medida que os objetos vão sendo alocados, esses extents vão sendo ocupados.

#RESUMO: Ao criar uma tabela (SEGMENT) ela ocupa EXTENTS que são compostos por
DATABLOQS continuos ocupando espaço no disco. Quando essa tabela cresce de tamanho,
ela aloca mais extensão que não necessariamente está continua com o EXTENT incial.

                          /* Estruturas fisica de armazenamento */  

>> As unidades fisicas são traspatentes principalmente para os usuarios. O DBA na maioria 
  dos casos também trabalham com estrututuras logicas a não ser quando preocupa-se especificamente 
  com as estitudas fisicas. Por isso é tão importante conhecer a estrutura, arquitetura e os links
  entre estruturas logicas e fisicas do Oracle.
  Criar objeto > Apontar a uma estrutura Logica > Apontar a uma estrutua fisica

>> DATAFILES - Estruturas fisicas de armazenamento do Banco de Dados Oracle. Os DATAFILES
   compõem as tablespaces e a soma dos seus tamanhos é total de tamanho da tablespace.
                                                          exemplo: tablespace 1gb = datafile 1gb 
   Os datafiles são destinados a diferentes funções de acordo a função da Tablespace assim existindo
   dois tipos: 
    >> Tablespace Permanente - Dicionario de dados (metadata), dados de aplicações.
    >> Tablespace Temporarios - Dados temporarios. Utilizada automaticamente pelo Oracle caso 
                                falte memoria no momento da consulta por exemplo.

>> CONTROLFILE - Arquivos que armazenam informações sobre as estruturas físicas do banco de
   dados (nome, localização, ...). Todos os data files e redo log files são identificados no control
   file, bem como o nome do banco de dados.
   Recomenda-se que se tenha no mínimo dois Control Files, armazenados em discos diferentes (se
   possível).
   São responsaveis pelo controle de funcionamento da base de dados Oracle.
   Toda base de dados deve ter pelo menos um controlfile podendo chegar ao maximo de oito (MULTIPLEXAÇÃO),
   caso haja mais de um, servirão para redundancia pois as informações para START UP ou 
   SHUTDOWN informando se os dois processos foram executados de maneira correta e sincrona.
   Os controlfiles também informam a localização dos datafiles para que o banco possa ser aberto.
   Os controlfiles também armazenam informações como o nome da database, a data de criação
   e a hora (timestamp) e o ultime checkpoint ocorrido com os datafiles.
   >> Sempre quando o banco vai ligar ou desligar ele lê o arquivo de controle, ate mesmo
      para identificar qual arquivo dbf (datafile) a tablespace está gravada.
      
>> REDO LOG FILES -
   Armazenam as transações executadas e confirmadas com COMMIT.
   São os logs de transações. O obejtivo é permitir a maior recuperação de dados comitados.
   Quando executamos um COMMIT, os dados permanecem em memoria, pois o acesso a ela é mais rapido
   do que o acesos a disco. Sendo assim os dados comitados são gravados também nos REDO LOGS, afim
   de recuperação em caso de perdas antes da sincronização com os DATAFILES.
   O Log de transações do Oracle registra imediatamente as mudanças feitas no Banco de Dados
   pelas transações em andamento, para que, se for necessário (em virtude, por exemplo, de uma
   falha), todo o trabalho confirmado seja protegido e recuperado.
   Na SGA existe o Redo Log Buffer que armazena as informações que serão gravadas nos Redo log Files.
          * Um Log Switch (troca de log) ocorre quando o Oracle troca de um redo log para outro.
            Enquanto isto o servidor fica gravando novas transações em outro grupo de log.
   
   >> MODO ARCHIVE - Como os redo log funcionam de maneira circular, os dados sobrescritos em
      determinado momento. Para evitar perda de dados, podemos colocar o banco em modo Archive,
      onde um arquivo é gerado com a copia dos redo a cada mudança de arquivo.
      O arquivo de Archive não é obrigatorio no Oracle porém é amplamente utilizado em
      ambiente de produção.

--Como os arquivos fisicos são armazenados:
 * FILE SYSTEM - Sistema Operacional é a opção padrão, o Oracle requisita a gravação de arquivos
   ao SO que gerencia atraves de seu gerenciador de volumes e grava em seu sistema de arquivos que
   por sua vez avisa ao Oracle a gravação. Podendo ser Windows ou Unix.
 * ASM - Automatic Storage Management onde o Oracle controla o acesso aos seus arquivos, sem passar
   pelo sistema operacional. O SO não conhece os volumes que o Oracle gerencia e nem sabe que existem
   arquivos no espaço em disco destinado ao Oracle. É como se fosse o sistema operacional do oracle, não
   necessitando do gerenciador de volumes do SO padrão. 
   Questões de performance.
>> Arquivos de Parâmetro - São os arquvios lido no momento que um banco de dados sobe, ou seja no  
   no momento em que ele fica operacional. Como parâmetros, são por exemplo a quantidade de memoria,
   parâmetros de sessão etc. 
   São dois tipos de arquivos:
    * SPFILE - A instância do banco de dados lê esse arquivo no momento da incialização. Esse arquivo
               é binario e deixa os parâmetros persistentes.
    * PFILE - É um arquivo idêntico ao SFILE porém é um arquvio texto e pode ser editado manualmente
              pelo usuario.
    >>Escopos:
    --http://www.dba-oracle.com/t_oracle_scope_memory.htm
         >>O scope é um parâmetro usado em conjunto com o comando alter system quando você altera qualquer parâmetro
            de inicialização de um spfile. É vital entender como usar este parâmetro para obter o efeito desejado. 
            Existem três valores que o parâmetro de escopo pode assumir:
             * Em memoria - Para o valor em questão, scope = memory, o Oracle fará a alteração especificada pelo comando
                           alter system para a vida da instância. Na próxima vez que o banco de dados for devolvido,
                            por qualquer motivo, a alteração será revertida para o valor padrão.
                                                                                       SCOPE = MEMORY                         

             * SPFILE -     Alteração válida somente após reinicialização e não vai estar em memoria.
                            Por mais que seja dinâmico, não desejo fazer no mesmo momento.
                                                                                       SCOPE = SPFILE
             * No memso momento e persistente - 
                            Devo trabalhar com um parãmetro dinâmico e deixar em escopo pois ele 
                            tratará como padrão.Booth aplica direto sem reboot e preserva o valor após o reboot.
                            Se quiser que o comando alter system ocorra imediatamente, você pode usar o valor scope = both ,
                            que fará a alteração para a instância atual e a preservará em quaisquer saltos futuros.
                                                                                       SCOPE = BOTH
                                                                                       

      Testando parâmetros = O comando ALTER SESSION SET reconfigura um parâmetro apenas para a sessão
                            corrente ou seja é ideal para se testar algo como por exemplo performance.
                            Ao desligar a ssessão a altearação é desfeita e não está disponivel Para
                            nenhuma outra sessão.
                            Verificar parâmetros: select * from v$parameter;

>> Passwordfile - Um arquivo de senhas criptografado para autenticação no banco de dados.
>> Arquivovs de Backup - Geralmente compostos de DBFs, CONTROLFILES, achivelogs e os arquivos de inicialização.
>> Arquivos de log - São arquivos TRACE, ou .TRC, que servem para monitorar o banco de dados.
>> Arquivos de Alerta - Alert Logs arquivos de alerta automaticos de todas as situações que 
   ocorrem no Banco de dados. 

                                     /*Tablespaces padrões*/ 

>> System e Sysaux - Armazenam toda a parte CORE do banco ou seja, todo o dicionario de dados é armazenados
                     nessas duas tablespaces.O tablespace SYSTEM (tablespace de sistema) é uma parte obrigatória de todo banco de dados Oracle.
                     É onde o Oracle armazena todas as informações necessárias para o seu próprio gerenciamento. Em resumo, SYSTEM é o tablespace
                     mais crítico do banco de dados porque ele contém o dicionário de dados. Se por algum motivo ele se tornar indisponível, a
                     instância do Oracle abortará. Por esse motivo, o tablespace SYSTEM nunca pode ser colocado offline, ao contrário de um 
                     tablespace comum como, por exemplo, o tablespace USERS.
                     A SYSAUX foi criado especialmente para aliviar o tablespace SYSTEM de segmentos associados a algumas aplicações do próprio banco de dados
                     como o Oracle ultra search, Oracle Text e até mesmo segmentos relacionados ao funcionamento
                     do Oracle Enterprise Manager entre outros. Como resultado da criação desse tablespace, 
                     alguns gargalos de I/O freqüentemente associados ao tablespace SYSTEM foram reduzidos ou eliminados. Vale a pena salientar que 
                     não é bom que o tablespace SYSAUX seja colocado no modo offline, pelo fato de correr o risco do banco de dados não funcionar corretamente. 
                     Portanto, podemos dizer que o mesmo é parte integrante e obrigatório em todos os bancos de dados à partir do Oracle 10g. Existe uma view 
                     de dicionário de dados que mostra os ocupantes neste tablespace:
                                select occupant_name, schema_name, space_usage_kbytes from v$sysaux_occupants;
   
>> Undo            - Trabalha com a integridade do banco de dados, auxiliando na leitura consistente.
                     Algumas literaturas também podem chamar a tablespace undo de rollback.
                     Exemplicando, os dados que não estão comitados.
                     Todos os bancos de dados Oracle precisam de um local para armazenar informações a desfazer. O que isso significa? Esse tablespace 
                     que contém seus segmentos de reconstrução em versões anteriores ao Oracle 9i chamado de RBS (tablespace de rollback), possui a 
                     capacidade de recuperar transações incompletas ou abortadas. Um segmento de undo é usado para salvar o valor antigo quando um 
                     processo altera dados de um banco de dados. Ele armazena a localização dos dados e também os dados da forma como se encontravam 
                     antes da modificação. Basicamente, os objetivos dos segmentos de undo são:
                       > Rollback de transação: Quando uma transação modifica uma linha de uma tabela, a imagem original das colunas modificadas é salvas 
                       no segmento de UNDO, e se for feito o rollback da transação, o servidor Oracle restaurará os valores originais gravando os valores 
                       do segmento de UNDO novamente na linha

                      > Recuperação de Transação: Se ocorrer uma falha de instância enquanto houver transações em andamento, o servidor Oracle precisará 
                        desfazer as alterações não submetidas à commit quando o banco de dados for aberto novamente. Esse rollback faz parte da recuperação 
                        da transação. Portanto, a recuperação só é possível porque as alterações feitas no segmento de UNDO também são protegidas pelos 
                        arquivos de redo log online.

                      > Consistência de Leitura: Enquanto houver transações em andamento, outros usuários do banco de dados não deverão ver as alterações não 
                        submetidas à commit feitas nessas transações. Além disso, uma instrução não deverá ver as alterações submetidas à commit após o início 
                        da execução dessa instrução. Os valores antigos (dados de undo) dos segmentos de UNDO também são usados para oferecer aos leitores uma 
                        imagem consistente de uma instrução específica.

>> TEMP           - É utilizada para auxiliar a memória do Oracle em operações mais pesadas.
                    O tablespace TEMP (tablespace temporário) é onde o Oracle armazena todas as suas tabelas temporárias. É o quadro branco ou papel
                    de rascunho do banco de dados. Assim como às vezes precisamos de um lugar para anotar alguns números para pode somá-los, o Oracle
                    também precisa de algum espaço em disco temporário. O Oracle geralmente utiliza o tablespace temporário para armazenar objetos 
                    transitórios durante as classificações e agrupamentos de dados durante a execução de uma SQL contendo as cláusulas ORDER BY e GROUP BY, 
                    entre outras. É importante dizer também que os dados de sessão das tabelas temporárias globais (Global Temporary Tables) também ficam no 
                    tablespace TEMP. Assim como o tablespace SYSTEM é o tablespace mais crítico do banco dados, o tablespace TEMP é o menos crítico do banco 
                    de dados exatamente porque armazena apenas os segmentos temporáriosdurante as operações de classificação de dados e, como tal, no caso de 
                    uma falha, ele pode simplesmente ser dropado e recriado, em vez de ser restaurado e recuperado.

>> USERS          - Tablespace padrão para os usuários.e um usuário criar um objeto, tal como uma tabela ou um índice, sem especificar o tablespace,
                    o Oracle o cria no tablespace padrão do usuário, isso se o tablespace padrão do usuário foi definido para utilizar o tablespace USERS.

                                    /*Estruturas de memoria*/   

A memoria RAM padrão aloacada pelo Oracle no momento da instalação é de 40% da memoria total do servidor.
A memória alocada é divida em compartilhada  que é utilizada por todos os usuários e processos do Oracle e 
a memoria dedicada onde cada usuarios possui o seu propio espaço ou processo.
                                  
>> SGA Memoria Compartilhada (SYSTEM GLOBAL AREA) - Area de memoria compartilhada por todos os usuarios
                                                    da base de daods. Seu objetivos é compartilhar o acesso melhorando assim
                                                    a performance. Cada instância possui a sua propia SGA evitando retrabalho.
      -- Shared Pool - PROCESSANDO COMANDOS SQL
        Todos os comandos SQL são executados pelos processos servidores, dividindo-os em três fases:

         * Parse -   Checa a sintaxe do comando.Checa também os privilégios do usuário, definindo logo após,
             o caminho da pesquisa. Define o plano de execução do comando.

         * Execute - Analisa o requerimento que está no buffer (na “Shared Pool SQL Area”), e
             Faz a leitura física ou lógica (no arquivo datafile ou no Database Buffer Cache).
             Obs.: Na “Shared Pool SQL Area” temos: o texto do comando SQL (ou PL/SQL).

         * Fetch -   Retorna o resultado do comando SQL (geralmente chamada de “tabela-resultado”).
             Obs: Na Shared Pool SQL Area temos dois caches a saber:
             >> Library Cache –       Armazena instruções SQL (e/ou procedimentos) bem como planos de execução
                                      das instruções (ex.: vários usuários (clientes) podem estar executando
                                      uma mesma aplicação compilada).
             >> Data Dictionary Cache – Armazena informações contidas no dicionário de dados do BD,
                                        reduzindo as E/S de disco (o Oracle usa as informações do dicionário do BD
                                        em praticamente todas as operações).
      
      -- Database Buffer Cache
         O Database Buffer Cache são compartilhados por todos os processos de usuário do Oracle conectados à instância (instance)
         consultando na Shared Pool o plano de execução caso ja tenha sido executado por outro usuario. Caso contrario é consultado no HD onde
         lê com menos performance pois o acesso a memoria é mais rapido.
         Quando um usuario faz uma operação de DML, o bloco é copiado para a area de memoria e toda a manipulação passa a ser feita nessa
         area e não no disco. O Database Buffer Cache mantem uma lista com os blocos mais utilizados e vai liberando espaço de acordo
         com os blocos menos utilizados sempre que necessário para acessar informações novas. Ao realizar a operação e efetuar um COMMITos blocos
         do DBBC não são gravados na hora em disco, nesse momento é feita a gravação do REDO LOG e o Database Buffer Cache mantem ainda os
         blocos alterados para que esses sejam gravados em conjunto com outros blocos em um momento oporturno.
         O tamanho do bloco do database buffer cache é determinado no parâmetro DB_BLOCK_SIZE.
         A quantidade de blocos é definida no parâmetro DB_BLOCK_BUFFERS (parâmetros contidos no arquivo de parâmetros do Oracle).

      #RESUMO > Usuario fez o sql > consulta o plano de exeução na Shared Pool > caso esteja consulta o buffer cache.

      -- Redo Log Buffer
         É a araea de memoria correspondente aos REDO LOGS no disco. Assim que uma transação é comitada, ela é guardada no REDO LOG Buffer
         ques escreverá no arquivo de REDO LOG no disco.
      -- Large Pool 
         Para objetos grandes não ocuparem a Shared Pool como por exemplo rotinas de backup. Também permite o paralelismo no Oracle.
      -- Java Pool
         Armazena codigos JAVA e JVM.
      -- Streams Pool 
         Area que armazena o serviço de mensagens para replicação dos dados.


>> PGA Memoria Dedicada (Program Global Area)     - É aloacada uma area de PGA por sessão que auxilia os usuarios com clausulas
                                                    ORDER BY ou DISTINCT, variaveis BIND ou variaveis de sessão.

                                                      /*Processos Backgroud*/ 

   * PMON -      Responsavel por monitorar todos os outros processos. Quando um processo termina irregularmente, é o PMON que libera
                 os dados (lock) e recupera esse processo.

   * SMON -      Tarefas diversas mas como principal a recuperação automatica da instancia no Startup.

   * DBWritern - Responsavel por gravar o conteudo dos Database Buffer Cache nos respectivos datafiles. A gravação ocorre quando
                 o DDBC necessita de espaço então o DBWRITER grava os dados que já foram comitados, liberando espaço para novas transações.
   
   * LGWR      - Faz a ponte entre o REDO LOG BUFFER e os arquivos de REDO LOG FILES. É acionado sempre que o usuario efetua um commit,
                 liberando a entrada do buffer para uma nova transação. A transação gravada pelo LGWR recebe um numero chamado SCN.
   
   * CKPT      - Responsavel por sinalizar ao DBW o momento da gravação do DBBC nos seus datafiles ou seja da memoria para o disco.

   * MMON      - Associado ao WRiter, captura as estatisticas do banco de dados.

   * MMNL      - Grava as estatisticas do banco ASH e parte do AWR em disco.

   * RECO      - Recupera ou finaliza falhas de transações. Somente bases de dados distribuidas. 

                                                  /*Mantendo Controlfile - Conteúdo*/

O arquivo de controle é um arquivo binário necessário para iniciar e operar com sucesso o banco de dados. O arquivo de controle é atualizado constantemente pelo Oracle durante sua utilização, ficando disponível
para escrita apenas quando o banco de dados está aberto, ou seja, OPEN. Caso o arquivo de controle não esteja acessível por alguma razão, o banco de dados não irá funcionar corretamente,
podendo trazer problemas ao iniciar a instância. Todo arquivo de controle é sempre associado somente a um único banco de dados, não podendo existir um arquivo de controle que seja utilizado por mais
de uma instância. Até em ambientes de Real Application Cluster (RAC) existe um arquivo de controle para cada instância.

Um arquivo de controle possui diversas informações de um banco de dados que é requerida pela instância. Durante o processo de startup ou uma operação normal, somente o Oracle Server pode modificar as
informações no arquivo de controle, deste modo, nenhum DBA ou usuário pode modificar seu conteúdo.

As informações que o arquivo de controle possui são:

Nome do banco de dados
Data de criação do banco de dados
Os nomes e localizações de cada datafile e redo log associados ao banco de dados
Informações sobre as tablespaces
Possíveis datafiles com status offline
O histórico de logs
Sobre os archives gerados
Backupsets e backup pieces, gerados pelo RMAN
Backups de datafiles e informações de redo log
Cópia de datafiles
O valor atual do número da sequência do log
Informações de checkpoint
Para cada datafile ou redo log que é adicionado, renomeado, modificado ou excluído do banco de dados, o arquivo de controle é atualizado pelo Oracle Server para garantir a modificação da estrutura física da base.
Essas modificações podem ser:

O Oracle pode identificar os datafiles e redo logs que foram abertos durante o processo de startup
Identificar os arquivos que são necessários ou disponíveis em caso de recuperação do banco de dados
Portanto, para cada modificação na estrutura física do banco de dados, podendo ser feita através do comando ALTER DATABASE, é altamente recomendado que seja feito um backup do seu arquivo de controle para evitar
possíveis problemas no próximo processo de startup do banco de dados.

Como o arquivo de controle armazena informações sobre os checkpoints a cada três segundos, o processo de plano de fundo (CKPT) registra as posições do redo log, essas posições serão utilizadas posteriormente
durante um processo de recuperação do banco de dados, no qual o Oracle irá dizer se todas as entradas dos grupos de redo log serão necessárias para realizar tal recuperação.

                                                    /*Mantendo Redo Log*/


Arquivo de redo log.

Todo banco de dados oracle tem no mínimo dois grupos de arquivos de redo log cada um com pelo menos um arquivo de redo log. Serve pra registrar alteração feitas nos dados.
Para proteger os arquivos contra falha no disco, o oracle suporta arquivos Redo log multiplexado. Você pode manter uma cópia do arquivo em diferentes discos.

As cópias do arquivo de redo log mantidos em discos diferentes são chamados de arquivos de log espelhados. Cada membro de cada grupo de arquivo de log tem um arquivo de log espelhado de um mesmo tamanho.
Os seguintes itens são os valores mais comuns para a coluna STATUS:

• UNUSED indica que o grupo de online rede log nunca recebeu escrito. Este é o estado de um online redo log file que foi recentemente adicionado.

• CURRENT indica o grupo de online rede log corrente.Isto indica que o grupo de online redo log está ativo.

• ACTIVE indica que o grupo de online está ativo, mas não é o grupo de online redo log corrente.Ele é necessário para a recuperação de uma falha.Ele pode ou não estar arquivado.

• INACTIVE indica que um grupo online redo log não é necessário para a recuperação da instância.ele pode ou não estar arquivado. Para obter o nome de todos os membros de um grupo, 
consulte a visão de desempenho dinâmica V$LOGFILE na qual o valor da coluna STATUS pode ser:

-> INVALID indica que o arquivo está inacessível.
-> STALE indica que o conteúdo do arquivo está incompleto. Por exemplo, ao adicionar-se um membro de log file.
-> DELETED indica que o arquivo não está sendo utilizado.
-> NULL indica que o arquivo está em uso

                                              /*Estrutura de armazenamento*/

>> Hierarquia de armazenamento do banco de dados
• Um banco de dados é logicamente agrupado em TableSpaces.
• Um tablespace pode consentir de um ou mais segmentos.
• Quando um segmento é criado, consiste de pelo menos uma extensão, a qual representa um conjunto continuo de blocos. Quando um segmento cresce, novas extensões são adicionadas.
• Um bloco, também chamado de bloco lógico ou bloco oracle, é a maior unidade utilizada para operações de leitura e escrita.
• A figura abaixo apresenta em maio detalhe uma combinação da arquitetura lógica com a arquitetura física.

>> Tipos de Segmentos
Segmentos são objetos que ocupam espaço em um banco de dados. Esta seção descreve os tipo diferentes de segmentos.

 - Table: Tabela, também conhecida como tabela não clusterizada ou não particionada, é a forma mais comum de armazenarem 
          dados dentro de um bloco de dados. Os dados dentro de uma tabela são armazenados em ordem não especifica, e o 
          administrador do banco de dados possui um controle muito pequeno sobre a localização das linhas dentro de u bloco de uma tabela. 
          Todos os dados em uma tabela não particionada devem ser armazenados em uma única tablespace.


 - Table Partition: Escalabilidade e disponibilidade são as maiores preocupações quando existe uma tabela em um banco de dados com alta concorrência 
                    de utilização. Em tais casos, os dados dentro de uma tabela podem ser armazenados em várias partições, cada qual residindo em uma 
                    tablespace diferente. O servidor oracle atualmente suporta o particionamento por uma faixa de valores chave. Se uma tabela estiver 
                    particionada, cada partição é um segmento e os parâmetros de storage podem ser especificados independentemente para cada um deles. 
                    O uso deste tipo de segmento necessita da opção partitioning dentro de oracle 11g enterprise edition.


 - Cluster: As linhas em um cluster são armazenadas baseados em valores de colunas chave.um cluster pode conter uma ou mais tabelas sendo um tipo de 
            segmentos de dados.tabelas em um clusters pertencem ao mesmo segmento e compartilham as mesmas características de armezamento.


- Index: Toda a entrada para um índice especifica são armazenadas dentro de um segmento de índice. Se uma tabela possuir três índices,três segmentos 
         de índices serão utilizados.o propósito deste tipo de segmento é pesquisar linhas de uma tabela baseado em uma chave especifica.

- Index-organized table: Em uma tabela index-organized,os dados são armazenados dentro de um índice baseado no valor da chave.uma tabela index- organized 
                         não necessita de pesquisa em tabela uma vês que todos os dados podem ser recuperados diretamente apartir da arvore do índice.

- Index partition: Um índice pode ser particionado e propagado através de vários tablespaces .neste caso,cada participação do índice corresponde a um segmento 
                 e não pode dividir-se em múltiplos tablespaces.o principal uso de um índice particionado é para minimizar a contenção propagando o 1/0 sobre 
                 o índice .o uso deste tipo de segmento necessita da opção partitioning dentro do oracle 11g enterprise edition

- Undo segment: Um segmento de undo é utilizado por uma transação que está efetuado modificações para um banco de dados.antes de alterar os blocos de dados ou 
                índices,o valor antigo é armazenado no segmento de undo .isto permite que o usuário desfaça as modificações realizadas.

- Temporary segment: Quando u usuário executa comando como CREATE INDEX,SELECT DISTINCT e SELECT GROUP BY,o servidor Oracle tenta realizar as ordenações(sorts)em
                     memória enquanto for possível.quando uma ordenação Necessitar de muito espaço, como na criação de um índice sobre uma tabela grande, resultados 
                     intermediários são escritos para o disco. Segmentos temporários são criados nestes casos.

- Lob segment: Umas ou mais colunas de uma tabela podem ser utilizadas para armazenar grandes objetos(lobs_large objects) como documentos texto,imagens ou vídeos.se a 
               coluna for grande,o servidor oracle armazena estes valores em segmentos separados conhecidos como segmentos lob.a tabela possui somente um localizador 
               ou ponteiro para a localização dos dados lob correspondentes.

- Lob index: Um segmento do tipo log index é criado implicitamente quando um segmento lob é criado.as características de armazenamento do índice lob podem ser especificadas 
             pelo administrador do banco de dados. O propósito do segmento de índice lob é permitir a pesquisa por valoresespecificos em colinas lob.

- Nested table: Uma coluna em uma tabela pode ser composta por uma tabela definida pelo usuário como no caso de itens dentro de um pedido.nestes casos,a tabela interna,
                conhecida como tabela aninhada(nested table)é armazenada como um segmento separado o uso de tabelas aninhadas requer a opção objects do oracle 10g enterprise edition

- Bootstrap segment: O segmento de bootstrap ,também conhecido como segmento de cachê,é criado pelo scriptv sql.bsq quando um banco de dados é criado.este segmento auxilia a 
                     inicialização do cachê do dicionário de dados é aberto por uma istancia.o segmento de bootstrap não pode ser consutado ou atualizado e não necessário de 
                     qualquer manutenção por parte do administradr do banco de dados.

Alocação de Extensões
* Extensão são alocadas quando o segmento é: -Criado -Estendido -Alterado
* Extensões são desalocadas quando o segmento é: -Removido -Alterado -Truncado -Automaticamente redimencionado(somente para segmentos de undo).

>> Extensões utilizadas e livres

Quando uma tablespace é criada, os seus datafiles possuem os seguintes elementos:
    • Um bloco de header,o qual é o primeiro bloco do arquivo. • Uma extensão livre contendo a parte restante do arquivo. Quando os segmentos são criados, alocam espaços 
      a partir das extensões livres da tablespace.o espaço continuo utilizado por um segmento é referenciado como used extent(extensão utilizada).quando os segmentos liberam 
      espaço,as extensões que são liberadas são adicionadas para o pool de extensão livres disponíveis na tablespace.a alocação e liberação freqüente de extensões pode causar 
      a fragmentação do espaço dentro dos datafiles da tablespace.em tablespaces gerenciadas localmente a desfragmentação é verificada de forma automática.

>> Conteúdo dos blocos de dados

Os blocos de dados oracle possuem:
     • Block header: o cabeçalho contem o endereço do bloco de dados ,a estrutura table directory e row directory e entradas de transação que são utilizadas quando transações 
                     efetuam modificações para as linhas do bloco.Os headers de blocos crescem de cima para baixo.
     • Data space: as linhas de dados são inceridas nos blocos de baixo para cima
     • Free Space: O espaço livre de um bloco está localizado no centro permitindo o crescimento do header e do espaço de dados se necessário.o espaço livre de um bloco é inicialmente 
                   continuo.Entretanto,deleções e atualizações podem fragmentar o espaço livre.o servidor oracle pode agrupar o espaço livre de um bloco quando necessário.

>> Parâmetros de utilização de espaço dos blocos

Os parâmetros de utilização do espaço dos blocos podem ser utilizados para controlar o uso do espaço em segmentos de dados e índices.
  >> Parâmetros que controlam a concorrência.
    • INITRANS e MAXTRANS especificam o numero inicial e máximo de entradas de transação,os quais são criados em blocos de índice e dados.As entradas de transação são utilizadas 
      para armazenar informações sobre as transações que estão efetuando modificações para o bloco em um determinado momento
    O parâmetro MINTRANS possui um valor mínimo e default de 1.em geral ,o oracle não recomenda a mudança de parâmetro MINTRANS.
    O parâmetro MAXTRANS foi depreciado no oracle 11g,agora o oracle configura por default o valor 255.

>> Parâmetros que controlam a utilização do espaço de dados

     • PCTFREE para um segmento de dados especifica o porcentual de espaço em cada bloco de dados reservado para o crescimento resultante de 
       atualizações para as linhas do bloco.O default para PCTFREE é 10%

     • PCTUSED para o segmento de dados representa o porcentual mínimo de espaço utilizado que o servidor Oracle tenta Manter para cada bloco de dados na tabela. 
       Um bloco é colocado de volta na lista de blocos livres(free list)quando seu espaço utilizado ficar abaixo do PCTUSED.a free list de um segmento é a lista 
       de blocos que são candidatos para acomodar futuras inserções.Um segmento,por default,é criado por uma lista de blocos livres.Segmentos podem ser criados 
       com um numero maior de lista de blocos livres configurando- se p parâmetro FREELISTS da clausula de storage.O default para PCTUSED é 40%

     • PCTFREE e PCTUSED são calculados como porcentuais de espaço de dados disponíveis, ou seja, o espaço do bloco que resta, após reduzir o espaço do header do tamanho total do bloco.
       Os parâmetros de utilização de espaços dos blocos podem ser especificados somente para segmentos e não podem ser configurados no nível da tablespace.
       Nota:essas configurações só serão utilizadas para tablespaces com gerenciamento do especo dos segmentos no modo manual(ver capitulo 'tables paces e data files’

>> Utilização do espaço de blocos 

Os seguintes passos explicam como espaço dentro de um bloco é utilizado para um segmento de dados, como uma tabela com PCTFREE=20 e PCTUSED=40:
   • Linhas são inseridas no bloco até que a utilização atinja 80% ou (100-PCTFREE). O bloco não está mais disponível para inserções quando as linhas ocupam 80% do espaço disponível para os dados do bloco.
   • Os 20%restantes podem ser utilizados quando o tamanho das linhas aumentarem,por exemplo,no cão de uma coluna que está inicialmente com NULL ser atualizada para um determinado valor.desta forma a utilização do bloco pode exceder os 80% como resultado de atualização.
   • Se linhas forem removidas do bloco ou reduzirem de tamanho como resultado de updates,a utilização do bloco pode ficar abaixo de 80%entretanto,um bloco não é utilizado para inserções até q utilização fique abaixo do PCTUSED,o qual neste exemplo é de 40%
   • Quando a utilização ficar abaixo do PCTUSED, o bloco fica disponível para inserções. Quando novas linhas forem inseridas no bloco, a utilização do mesmo aumenta e o ciclo se repete novamente.

>> Obtendo informações sobre estruturas de armazenamento
-- Visões do dicionário de dados
   • As relações entre tablespaces,datafiles,segmentos e extensões(utilizadas e livres)podem ser visualizadas consultando o dicionário de dados.
     Quando um tablespace com um ou mais data files é criada, uma linha é adicionada para DBA_TABLESPACES.Para cada arquivo no banco de dados,uma 
     linha é adicionada para DBA_DATA_FILES.Neste estagio,o espaço em cada datafile excluindo o header do arquivo,aparece com uma extensão livre na DBA_FREE_SPACE.

   • Quando um segmento é criado, uma linha torna-se visível na DBA_SEGMENTS.O espaço alocado para as extensões deste segmento pode ser visualizado a partir da DBA_EXTENTS,
     enquanto a DBA_FREE_SPACE é ajustada para exibir menos espaço livre nos arquivos onde as extensões foram criadas para o segmento.

>> Todo o espaço em um arquivo(excluindo o bloco de header)deve ser contabilizado para a DBA_ FREE_SPACE ou DBA_EXTENTS.
  - Consultando informações de segmentos:
     DBA_SEGMENTS
                 Informações gerais:
                 • OWNER • SEGMENT_NAME • SEGMENT_TIPE • TABLESPACE_NAME
                 Tamanho
                 • SIZE • BLOCKS
                 Configurações de storage:
                 • INITIAL_EXTENT • NEXT_EXTENT • MIN_EXTENTS • MAX_EXTENTS • PCT_INCREASE
      SELECT header_file, header_block
      FROM dba_segments
      WHERE owner = 'MASTER'
      AND segment_name = 'TALUNO'

>> Consulta a visão DBA_SEGMENTS para verificar o número atual de extensões e blocos alocados para um segmento

   - Obtendo informações sobre as extensões utilizadas
      DBA_EXTENTS
                 Identificação:
                 • OWNER • SEGMENT_NAME • EXTENT_ID
                 Localização e tamanho:
                 • TABLESPACE_NAME • RELATIVE_FNO • FILE_ID • BLOCK_ID • BLOCKS
      SELECT *
      FROM dba_extents
      WHERE owner = 'MASTER'
      AND segment_name = 'TALUNO';


>> Localização e tamanho da tablespace
     dba_free_space 
       • TABLESPACE_NAME • RELATIVE_FNO • FILE_ID • BLOCK_ID • BLOCKS
     SELECT tablespace_name, COUNT(1),
     SUM(bytes)/1024/1024 total,
     MAX(bytes)/1024/1024 maximo
     FROM dba_free_space
     GROUP BY tablespace_name;
   
                                              /*SERVIDOR MULTI-THREADED*/

Cada estação cliente usa um processo Cliente. O Oracle usa a arquitetura de servidor multilinear que envolve os processos despachantes (Dispatchers),
ouvinte (listener) e servidor (sharedserver) – para atender às solicitações dos diversos clientes. Duas filas são formadas: fila de solicitações (Request Queue)
e fila de respostas (Response Queue).
Quando uma aplicação cliente estabelece uma conexão com o Oracle, o listener fornece o endereço de rede de um processo Dispatcher, com o qual o cliente se conecta. O Dispatcher
então pega a solicitação do cliente e coloca-a na fila de solicitações. As solicitações são processadas e os resultados são inseridos na fila de respostas. A partir daí o Dispatcher
retorna os resultados para as aplicações clientes adequadas.


                                              /*CONSULTAS IMPORTANTES*/

--LOGANDO NO SQLPLUS
sqlplus usuario/senha@nomedobd
sqlpus hr/hr@xepdb1 

sqlplus maxsolucoes/yhxbp18637NXCFK!?@189.126.145.43:1521/CCN8L2148728W_high.paas.oracle.com

--ENTERPRISE MANAGER
select dbms_xdb_config.gethttpsport() from dual;
exec DBMS_XDB_CONFIG.SETHTTPSPORT(5502);
https://10.62.38.70:5502/em/login

--CONSULTAR DATAFILES
SELECT FILE_NAME FROM DBA_DATA_FILES;
--CONSULTAR REDO LOG FILES
- SELECT MEMBER FROM V$LOGFILE;
--CONSULTANDO CONTROLFILES
 SELECT VALUE FROM V$PARAMETER WHERE NAME = 'CONTROL_FILES’;

--listener linux
lsnrctl

--pdbs
>> alter pluggable database pdb_study open;
>> alter pluggable database pdb_study save state;

--VERIFICAR ALERT LOGS
tail -f /u01/app/oracle/diag/rdbms/orcl/orcl/trace/alert_orcl.log 
alias alertlog12c='tail -f /u01/app/oracle/diag/rdbms/orcl12c/orcl12c/trace/alert_orcl.log '

--VERIFICAR O ID DO DATAFILE
report schema;

--BKP DATA PUMP
--EXPORT
https://www.youtube.com/watch?v=BVLIiq4lCGE&ab_channel=BaseTreinamentos

mkdir -p /home/bkp_orcl/dumps/orcl_exp -- criando diretorio de export
CREATE OR REPLACE DIRECTORY EXPORT_DEV AS 'C:\oracle\EXPORT_DEV';--criando diretorio no oracle
GRANT READ, WRITE ON DIRECTORY EXPORT_DEV TO SYSTEM;--grant de leitura e escrita para o usuario que irá realizar a operação

SELECT * FROM DBA_DIRECTORIES;--consultar diretorio criados no oracle

EXPORT LINUX:   expdp system/oracle@orcl12c directory=exp_dumps dumpfile=orcl18c_sch_hr.dmp logfile=orcl18c_sch_hr.log FLASHBACK_TIME=systimestamp schemas=HR
                expdp system/oracle@orcl directory=exp_dumps dumpfile=02_orcl12c_sch_lucas.dmp logfile=02_orcl12c_sch_lucas.log FLASHBACK_TIME=systimestamp schemas=LUCAS

EXPORT WINDOWS: expdp system/oracle@xepdb1 SCHEMAS=hr  directory =exp_dumps dumpfile =orcl18c_sch_hr.dmp logfile =orcl18c_sch_hr.log

--IMPORT
https://www.youtube.com/watch?v=2hNA3Xyh9Ig&list=PLuAKZ-JWF4HwiCrb_5-nbOUsqKTmWS5Id&index=6&ab_channel=BaseTreinamentosBaseTreinamentos

mkdir -p /home/oracle/dumps/orcl_imp -- criar diretorio de imp
mv ORCL18C_SCH_HR.DMP /home/oracle/dumps/orcl_imp/ --mover export para a pasta imp
CREATE OR REPLACE DIRECTORY IMP_DUMPS AS '/home/oracle/dumps/orcl_imp';--criando diretorio no oracle
GRANT READ, WRITE ON DIRECTORY IMP_DUMPS TO SYSTEM;--grant de leitura e escrita para o usuario que irá realizar a operação

SELECT * FROM DBA_DIRECTORIES;--consultar diretorio criados no oracle

IMPORT LINUX:  impdp system/oracle@orcl directory=imp_dumps dumpfile=orcl_sch_study.dmp logfile=imp_orcl_sch_study.log schemas=STUDY
--TRANSFORM=OID:N
expdp system/oracle@LOCALHOST:1521/BDMAXIMA directory=DATA_PUMP_DIR dumpfile=fecp.dmp logfile=fecp_dump.log schemas=FECP INCLUDE=TYPE_SPEC,TYPE_BODY,FUNCTION,PACKAGE,SEQUENCE,SYNONYM,INDEX,PROCEDURE,PACKAGE_BODY,TABLE,VIEW,TRIGGER CONTENT=ALL PARALLEL=6

expdp system/oracle@LOCALHOST:1521/BDMAXIMA attach=SYS_EXPORT_SCHEMA_09

impdp system/oracle@LOCALHOST:1521/BDMAXIMA directory=DATA_PUMP_DIR dumpfile=fecp.dmp logfile=fecp_imp.log REMAP_SCHEMA=FECP:WINT23


--BKP RMAN
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
--script para backup
https://www.youtube.com/watch?v=g36XwDUfvhc&ab_channel=TargetDatabase
https://www.youtube.com/watch?v=NkToG7UEE3Y&ab_channel=TargetDatabase
run{
allocate channel c1 device type disk;
allocate channel c2 device type disk;
allocate channel c3 device type disk;

sql 'alter system switch logfile';
sql 'alter system switch logfile';
sql 'alter system switch logfile';
sql 'alter system checkpoint';

backup as compressed backupset full database tag 'FULL_BD' format '/home/oracle/rman/backup_fisico/full_bd-%T-%I-%d-%s.bkp';
backup current controlfile tag 'CTF_FULL' format '/home/oracle/rman/backup_fisico/CTF_FULL-%T-%I-%d-%s.bkp';
backup as compressed backupset spfile tag 'SPF_FULL' format '/home/oracle/rman/backup_fisico/SPF_FULL-%T-%I-%d-%s.bkp';
backup as compressed backupset archivelog all delete all input tag 'ARCH_FULL' format '/home/oracle/rman/backup_fisico/ARCH_FULL-%T-%I-%d-%s.bkp';
}
--restore do backup
https://www.youtube.com/watch?v=nkgmZ3SM40o&ab_channel=TargetDatabaseTargetDatabase

--restore para determinado periodo

run
{
set until time "TO_DATE('DATA','DD/MM/YYYY HH24:MI:SS')";
restore pluggable database pdb_bkp;
recover pluggable database pdb_bkp;
}


-- Consultando Constraints pelo Dicionário de Dados

DESC user_constraints --constrains
DESC user_cons_columns --colunas de constrains

SELECT co.constraint_name,
       co.constraint_type,
       co.search_condition,
       co.r_constraint_name,
       co.delete_rule,
       cc.column_name,
       cc.position,
       co.status
 FROM   user_constraints co
   JOIN user_cons_columns cc ON (co.constraint_name = cc.constraint_name) AND 
                                (co.table_name = cc.table_name)
 WHERE  co.table_name = 'TABELA'
 ORDER BY co.constraint_name,
          cc.position;

select --table_name,
-- constraint_name, columns,
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
--where table_name IN('ERP_MXSLOGRCA');

WITH ref_int_constraints AS
  (SELECT /*+ MATERIALIZE NO_MERGE */ col.owner,
                                      col.table_name,
                                      col.constraint_name,
                                      con.status,
                                      con.r_owner,
                                      con.r_constraint_name,
                                      COUNT(*) col_cnt,
                                      MAX(CASE col.position
                                              WHEN 01 THEN col.column_name
                                          END) col_01,
                                      MAX(CASE col.position
                                              WHEN 02 THEN col.column_name
                                          END) col_02,
                                      MAX(CASE col.position
                                              WHEN 03 THEN col.column_name
                                          END) col_03,
                                      MAX(CASE col.position
                                              WHEN 04 THEN col.column_name
                                          END) col_04,
                                      MAX(CASE col.position
                                              WHEN 05 THEN col.column_name
                                          END) col_05,
                                      MAX(CASE col.position
                                              WHEN 06 THEN col.column_name
                                          END) col_06,
                                      MAX(CASE col.position
                                              WHEN 07 THEN col.column_name
                                          END) col_07,
                                      MAX(CASE col.position
                                              WHEN 08 THEN col.column_name
                                          END) col_08,
                                      MAX(CASE col.position
                                              WHEN 09 THEN col.column_name
                                          END) col_09,
                                      MAX(CASE col.position
                                              WHEN 10 THEN col.column_name
                                          END) col_10,
                                      MAX(CASE col.position
                                              WHEN 11 THEN col.column_name
                                          END) col_11,
                                      MAX(CASE col.position
                                              WHEN 12 THEN col.column_name
                                          END) col_12,
                                      MAX(CASE col.position
                                              WHEN 13 THEN col.column_name
                                          END) col_13,
                                      MAX(CASE col.position
                                              WHEN 14 THEN col.column_name
                                          END) col_14,
                                      MAX(CASE col.position
                                              WHEN 15 THEN col.column_name
                                          END) col_15,
                                      MAX(CASE col.position
                                              WHEN 16 THEN col.column_name
                                          END) col_16,
                                      par.owner parent_owner,
                                      par.table_name parent_table_name,
                                      par.constraint_name parent_constraint_name
   FROM dba_constraints con,
        dba_cons_columns col,
        dba_constraints par
   WHERE con.constraint_type = 'R'
     AND con.owner NOT IN ('ANONYMOUS',
                           'APEX_030200',
                           'APEX_040000',
                           'APEX_SSO',
                           'APPQOSSYS',
                           'CTXSYS',
                           'DBSNMP',
                           'DIP',
                           'EXFSYS',
                           'FLOWS_FILES',
                           'MDSYS',
                           'OLAPSYS',
                           'ORACLE_OCM',
                           'ORDDATA',
                           'ORDPLUGINS',
                           'ORDSYS',
                           'OUTLN',
                           'OWBSYS')
     AND con.owner NOT IN ('SI_INFORMTN_SCHEMA',
                           'SQLTXADMIN',
                           'SQLTXPLAIN',
                           'SYS',
                           'SYSMAN',
                           'SYSTEM',
                           'TRCANLZR',
                           'WMSYS',
                           'XDB',
                           'XS$NULL',
                           'PERFSTAT',
                           'STDBYPERF')
     AND col.owner = con.owner
     AND col.constraint_name = con.constraint_name
     AND col.table_name = con.table_name
     AND par.owner(+) = con.r_owner
     AND par.constraint_name(+) = con.r_constraint_name
   GROUP BY col.owner,
            col.constraint_name,
            col.table_name,
            con.status,
            con.r_owner,
            con.r_constraint_name,
            par.owner,
            par.constraint_name,
            par.table_name),
     ref_int_indexes AS
  (SELECT /*+ MATERIALIZE NO_MERGE */ r.owner,
                                      r.constraint_name,
                                      c.table_owner,
                                      c.table_name,
                                      c.index_owner,
                                      c.index_name,
                                      r.col_cnt
   FROM ref_int_constraints r,
        dba_ind_columns c,
        dba_indexes i
   WHERE c.table_owner = r.owner
     AND c.table_name = r.table_name
     AND c.column_position <= r.col_cnt
     AND c.column_name IN (r.col_01,
                           r.col_02,
                           r.col_03,
                           r.col_04,
                           r.col_05,
                           r.col_06,
                           r.col_07,
                           r.col_08,
                           r.col_09,
                           r.col_10,
                           r.col_11,
                           r.col_12,
                           r.col_13,
                           r.col_14,
                           r.col_15,
                           r.col_16)
     AND i.owner = c.index_owner
     AND i.index_name = c.index_name
     AND i.table_owner = c.table_owner
     AND i.table_name = c.table_name
     AND i.index_type != 'BITMAP'
   GROUP BY r.owner,
            r.constraint_name,
            c.table_owner,
            c.table_name,
            c.index_owner,
            c.index_name,
            r.col_cnt
   HAVING COUNT(*) = r.col_cnt)
SELECT /*+ NO_MERGE */ *
FROM ref_int_constraints c
WHERE NOT EXISTS
    (SELECT NULL
     FROM ref_int_indexes i
     WHERE i.owner = c.owner
       AND i.constraint_name = c.constraint_name )
ORDER BY 1,
         2,
         3;

-- Consultando os objetos do schema

SELECT *
FROM   user_objects
ORDER BY Object_type;

--COMPILAR OBJETOS INVALIDOS SQL
select 'alter '||decode( object_type , 'PACKAGE BODY' ,'PACKAGE' , OBJECT_TYPE) ||' '||object_name||
decode( object_type , 'PACKAGE BODY' ,' compile body;' , ' compile;')
from dba_objects
where status='INVALID' and owner = 'FECP'
order by object_type;

select 'drop ' || object_type || ' "' || owner || '"."' || object_name || '" cascade constraints PURGE;'
from dba_objects
where object_type in ('TABLE','VIEW','PACKAGE','SEQUENCE', 'PROCEDURE', 'FUNCTION', 'INDEX') --AND OBJECT_NAME LIKE 'QUEST%'
and owner = 'MAXHMG' AND TRUNC (CREATED) = TRUNC (SYSDATE)
order by object_type DESC;


BEGIN DBMS_UTILITY.COMPILE_SCHEMA('SANTANA_2031_PRODUCAO',COMPILE_ALL => FALSE); EXCEPTION WHEN OTHERS THEN NULL; END;

-- Consultando a Lixeira

SELECT *
FROM user_recyclebin;

-- Removendo uma Constraint a uma Tabela

ALTER TABLE projects
DROP CONSTRAINT projects_department_id_fk;

ALTER TABLE projects
DROP CONSTRAINT projects_project_id_pk CASCADE;

-- Adicionando uma Constraint a uma Tabela

ALTER TABLE projects
ADD CONSTRAINT projects_department_id_fk FOREIGN KEY (department_id)
REFERENCES departments(department_id);

ALTER TABLE projects
ADD CONSTRAINT projects_project_id_pk PRIMARY KEY(project_id);

-- Desabilitando uma Constraint

ALTER TABLE projects
DISABLE CONSTRAINT projects_department_id_fk;

ALTER TABLE projects
DISABLE CONSTRAINT projects_project_id_pk CASCADE;

-- Habilitando uma Constraint
as ofmjobs
ALTER TABLE projects
ENABLE CONSTRAINT projects_department_id_fk;

ALTER TABLE projects
ENABLE CONSTRAINT projects_project_id_pk;

-- Criando uma Visão

CREATE OR REPLACE VIEW vemployeesdept60
AS SELECT employee_id, first_name, last_name, department_id, salary, commission_pct
FROM employees
WHERE department_id = 60;

DESC vemployeesdept60

-- Recuperando dados utilizando uma Visão

SELECT *
FROM   vemployeesdept60;

--FLASHBACK QUERY
--http://www.dba-oracle.com/t_rman_149_flasbback_query.htm
select name, value from v$parameter where name like '%undo%';--undo_retention
DECLARE
  CURSOR c_employees IS
    SELECT *
    FROM   employees as of timestamp (systimestamp - interval '15' minute);
    
  r_employees  c_employees%ROWTYPE;
  
BEGIN  
  OPEN c_employees;
  LOOP 
    FETCH c_employees INTO r_employees; 
    
    EXIT WHEN c_employees%NOTFOUND; 
    
    UPDATE employees 
    SET    salary = r_employees.salary
    WHERE  employee_id = r_employees.employee_id;
    
  END LOOP; 
  
  CLOSE c_employees;
  
  COMMIT;
END;

--VERIFICAO UNDO

--- dados coletados a cada 10 minutos dos últimos 4 dias para estimar o tamanho do undo_retention
select to_char(begin_time, 'DD-MON-RR HH24:MI')
begin_time,
to_char(end_time, 'DD-MON-RR HH24:MI') end_time,
tuned_undoretention
from v$undostat order by end_time;

-- Monitora os efeitos da execução das
transações na instância corrente do espaço de
undo
SELECT TO_CHAR(BEGIN_TIME, 'MM/DD/YYYY
HH24:MI:SS') BEGIN_TIME,
 TO_CHAR(END_TIME, 'MM/DD/YYYY
HH24:MI:SS') END_TIME,
 UNDOTSN, UNDOBLKS, TXNCOUNT,
MAXCONCURRENCY AS "MAXCON"
 FROM v$UNDOSTAT WHERE rownum <= 144;

 -- Monitora os segmentos de roll back
SELECT s.username,
 s.sid,
 s.serial#,
 t.used_ublk,
 t.used_urec,
 rs.segment_name,
 r.rssize,
 r.status
FROM v$transaction t,
 v$session s,
 v$rollstat r,
 dba_rollback_segs rs
WHERE s.saddr = t.ses_addr
AND t.xidusn = r.usn
AND rs.segment_id = t.xidusn
ORDER BY t.used_ublk DESC;
--APAGAR REGISTROS DUPLICADOS

DECLARE

   CURSOR CADASTROS_DUPLICADOS
   IS
      SELECT ROWID,CGCENT 
      FROM PCCLIENTFV A 
      WHERE ROWID IN 
     (SELECT MIN(ROWID) FROM PCCLIENTFV B WHERE A.CGCENT=B.CGCENT)
     AND A.TIPOOPERACAO = 'A';
BEGIN
   FOR DADOS IN CADASTROS_DUPLICADOS
   LOOP
      DELETE FROM PCCLIENTFV A WHERE ROWID > (SELECT MIN(ROWID) FROM PCCLIENTFV B WHERE A.CGCENT=B.CGCENT)
      AND A.TIPOOPERACAO = 'A';
   END LOOP;
   COMMIT;
END;

BEGIN
   FOR DADOS IN ( SELECT ROWID, CGCENT 
				  FROM PCCLIENTFV A 
				  WHERE ROWID IN 
				 (SELECT MIN(ROWID) FROM PCCLIENTFV B WHERE A.CGCENT=B.CGCENT)
				  AND A.TIPOOPERACAO = 'A') 
   LOOP
      DELETE FROM PCCLIENTFV WHERE ROWID != DADOS.ROWID AND CGCENT = DADOS.CGCENT;
	  COMMIT;
   END LOOP;
END;


-- Criando uma Visão Complexa 

CREATE OR REPLACE VIEW vdepartments_total
(department_id, department_name, minsal, maxsal, avgsal)
AS SELECT e.department_id, d.department_name, MIN(e.salary),
          MAX(e.salary),AVG(e.salary)
FROM employees e 
  JOIN departments d
ON (e.department_id = d.department_id)
GROUP BY e.department_id, department_name;

SELECT * 
FROM   vdepartments_total;

-- Utilizando a Cláusula CHECK OPTION

CREATE OR REPLACE VIEW vemployeesdept100
AS SELECT employee_id, first_name, last_name, department_id, salary
FROM employees
WHERE department_id = 100
WITH CHECK OPTION CONSTRAINT vemployeesdept100_ck;

-- Utilizando a Cláusula READ ONLY

CREATE OR REPLACE VIEW vemployeesdept20
AS SELECT employee_id, first_name, last_name, department_id, salary
FROM employees
WHERE department_id = 20
WITH READ ONLY;

-- Removendo uma Visão

DROP VIEW vemployeesdept20;

-- Criando uma Sequencia

SELECT MAX(employee_id)
FROM   employees;

DROP SEQUENCE employees_seq;

CREATE SEQUENCE employees_seq
START WITH 210
INCREMENT BY 1
NOMAXVALUE 
NOCACHE
NOCYCLE;

-- Consultando Sequencias do pelo Dicionario de Dados

SELECT  *
FROM    user_sequences;

-- Recuperando próximo valor da Sequencia

SELECT employees_seq.NEXTVAL
FROM   dual;

-- Recuperando o valor corrente da Sequencia

SELECT employees_seq.CURRVAL
FROM   dual;

-- Utilizando uma Sequencia 

INSERT INTO employees 
           (employee_id, first_name, last_name, email, 
            phone_number, hire_date, job_id, salary,
            commission_pct, manager_id, department_id)
       VALUES (employees_seq.nextval, 'Paul', 'Simon', 'PSIMO', 
               '525.342.237', TO_DATE('12/02/2020', 'DD/MM/YYYY'), 'IT_PROG', 15000,
               NULL, 103, 60);
COMMIT;

--INSERT ALL Incondicional

-- Comando INSERT ALL Incondicional

INSERT ALL
  INTO employees_history VALUES (employee_id, first_name, last_name, hire_date)
  INTO salary_history    VALUES (employee_id, extract(year from hire_date), extract(month from hire_date), salary, commission_pct)
  SELECT *
  FROM   employees
  WHERE  hire_date > sysdate-365;

-- Comando INSERT Condicional

INSERT ALL
  WHEN hire_date > sysdate - 365 
  THEN
       INTO employees_history VALUES (employee_id, first_name, last_name, hire_date)
       INTO salary_history    VALUES (employee_id, extract(year from hire_date), extract(month from hire_date), salary, commission_pct)
  WHEN  (hire_date > sysdate - 365) AND 
        (job_id = 'IT_PROG')
  THEN 
       INTO IT_PROGAMADORES    VALUES (employee_id, first_name, last_name, salary, hire_date)
  WHEN (hire_date > sysdate - 365) AND
        department_id IN 
                           (SELECT department_id  
                            FROM departments 
                            WHERE location_id IN (SELECT location_id 
                                                  FROM   locations
                                                  WHERE   country_id = 'US'))
  THEN
       INTO living_in_us      VALUES (employee_id, first_name, last_name, salary, hire_date)        
  SELECT *
  FROM employees
  WHERE hire_date > sysdate-365;

--MERGE
--Utilizado para comparar uma tabela destino com uma tabela origem para realizar update/delete/insert em comparativo.
MERGE INTO employees_copy c
USING employees e
ON (c.employee_id = e.employee_id)
WHEN MATCHED THEN
   UPDATE SET 
   c.first_name = e.first_name,
   c.last_name = e.last_name,
   c.email = e.email,
   c.phone_number = e.phone_number,
   c.hire_date = e.hire_date,
   c.job_id = e.job_id,
   c.salary = e.salary,
   c.commission_pct = e.commission_pct,
   c.manager_id = e.manager_id,
   c.department_id = e.department_id
   DELETE WHERE department_id IS NULL
WHEN NOT MATCHED THEN
  INSERT VALUES (e.employee_id, e.first_name, e.last_name, e.email, e.phone_number, e.hire_date, e.job_id,
                 e.salary, e.commission_pct, e.manager_id, e.department_id);
  
COMMIT;

-- Modificando uma Sequencia

ALTER SEQUENCE employees_seq
MAXVALUE 999999
CACHE 20;

-- Estruturas de memoria

SELECT COMPONENT, CURRENT_SIZE, MIN_SIZE, MAX_SIZE
FROM V$SGA_DYNAMIC_COMPONENTS;

--VERIFICANDO QUANTO DE MEMORIA POR USUARIO NA PGA
SELECT spid,
       program,
       pga_max_mem maxpga,
       pga_alloc_mem alloc,
       pga_used_mem used,
       pga_freeable_mem free
FROM V$PROCESS;

SELECT MAX(P.PGA_MAX_MEM)/1024/1024 "PGA MAX MEMORY OF USER SESSION (MB)"
FROM V$PROCESS P, V$SESSION S
WHERE P.ADDR = S.PADDR
    AND S.USERNAME  IS NOT NULL;

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

SELECT s.sid,
       s.serial#,
       s.username,
       s.program,
       s.status,
       s.osuser,
       S.SQL_ID,
       ROUND((p.PGA_USED_MEM/1024/1024), 2) AS pga_mb
  FROM v$session s
       JOIN v$process p ON s.paddr = p.addr
 WHERE s.type != 'BACKGROUND'
 ORDER BY pga_mb DESC ;
 
 
 SELECT round(sum((p.PGA_USED_MEM/1024/1024)),2) AS pga_mb
  FROM v$session s
       JOIN v$process p ON s.paddr = p.addr
 WHERE s.type != 'BACKGROUND'
 ORDER BY pga_mb DESC ;
 

-- Verificando privilegios do usuario

SELECT * FROM USUER_SYS_PRIVS;

select * from dba_role_privs connect by prior granted_role = grantee start with grantee = '&USER' order by 1,2,3;
select * from dba_sys_privs  where grantee = '&USER' or grantee in (select granted_role from dba_role_privs connect by prior granted_role = grantee start with grantee = '&USER') order by 1,2,3;
select * from dba_tab_privs  where grantee = '&USER' or grantee in (select granted_role from dba_role_privs connect by prior granted_role = grantee start with grantee = '&USER') order by 1,2,3,4;

-- Verificando tabelas do usuario

SELECT TABLE_NAME FROM USER_TABLES;

-- Criando tablespace com autoextend

CREATE TABLESPACE RECURSOS_HUMANOS
DATAFILE 'C:/TABLESPACES_ORA_19/RH_01.DBF'
SIZE 100M AUTOEXTEND
ON NEXT 100M
MAXSIZE 2000M;

--Verificar tablespace padrão do user
select username,default_tablespace from dba_users where username = 'DBAOCM';

-- Verificar tablespace e onde estão armazenadas

SELECT TABLESPACE_NAME, FILE_NAME FROM DBA_DATA_FILES;

select   ddf.tablespace_name "TablespaceName"
         , ddf.file_name "DataFile"
         , ddf.bytes/(1024*1024) "Total(MB)"
         , round((ddf.bytes - sum(nvl(dfs.bytes,0)))/(1024*1024),1) "Used(MB)"
         , round(sum(nvl(dfs.bytes,0))/(1024*1024),1) "Free(MB)"
from   sys.dba_free_space dfs left join sys.dba_data_files ddf
on      dfs.file_id = ddf.file_id
group by ddf.tablespace_name, ddf.file_name, ddf.bytes
order by ddf.tablespace_name, ddf.file_name;

SELECT *
FROM dba_tablespaces;

SELECT *
FROM   dba_users;

--Alterar tamanho da tablespace
alter database datafile '/u01/app/oracle/oradata/orcl/undotbs01.dbf' resize 1024m;

-- Consultando a Lixeira

SELECT *
FROM   user_recyclebin
WHERE  original_name = 'EMPLOYEES_COPIA';

-- Restaurando o Objeto a partir da Lixeira

FLASHBACK TABLE EMPLOYEES_COPIA TO BEFORE DROP;

-- Utilizando Flashback Table


GRANT FLASHBACK ON hr.employees_copia2 TO hr;

ALTER TABLE hr.employees_copia2 ENABLE ROW MOVEMENT;

FLASHBACK TABLE hr.employees_copia2 TO TIMESTAMP systimestamp - interval '5' minute;

--FLASHBACK VERSION QUERY
GRANT EXECUTE ON DBMS_FLASHBACK to LUCAS;
ALTER SYSTEM SET UNDO_RETENTION = 172800; -- 172800 segundos = 2880 minutos = 48 horas

SELECT DBMS_FLASHBACK.GET_SYSTEM_CHANGE_NUMBER
FROM   dual;-- Consultar o System Change Number (SCN) atual 

SELECT versions_startscn, 
       versions_starttime, 
       versions_endscn, 
       versions_endtime,
       versions_xid, 
       versions_operation,
       employee_id, 
       first_name, 
       last_name, 
       salary
FROM   employees_copy 
       VERSIONS BETWEEN SCN 2170928 AND 2170965
WHERE  employee_id = 180;-- Consultando o histórico de atualizações da tabela

SELECT versions_startscn, 
       versions_starttime, 
       versions_endscn, 
       versions_endtime,
       versions_xid, 
       versions_operation,
       employee_id, 
       first_name, 
       last_name, 
       salary
FROM   employees_copy 
       VERSIONS BETWEEN timestamp  TO_TIMESTAMP('31/05/2021 10:39:00', 'DD/MM/YYYY HH24:MI:SS') AND 
                                   TO_TIMESTAMP('31/05/2021 11:00:00', 'DD/MM/YYYY HH24:MI:SS')
WHERE  employee_id = 180;-- Consultando o histórico de atualizações da tabela


--INNSERÇÃO EM MASSA NO BANCO
CREATE TABLE TABELA_TESTE_DADOS (
 ID_TESTE INT CONSTRAINT id_teste_pk PRIMARY KEY,
 DESCRICAO VARCHAR2 (30)
);

DROP SEQUENCE TABELA_TESTE_DADOS_seq;
CREATE SEQUENCE TABELA_TESTE_DADOS_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE 
NOCACHE
NOCYCLE;

DECLARE
 v_COUNTER INT := 1;
BEGIN
 LOOP
   INSERT INTO TABELA_TESTE_DADOS (ID_TESTE, DESCRICAO)
   VALUES (v_COUNTER, 'Inserção em massa');
 
   v_COUNTER := v_COUNTER + 1;
 
  EXIT WHEN v_COUNTER > 50000;

 END LOOP;
 COMMIT;
END;

SELECT * FROM TABELA_TESTE_DADOS ORDER BY ID_TESTE ;

--CONSULTANDO DICIONARIO DE DADOS EM PROCEDURE, FUNCTIONS E PACKAGE/

DESC USER_OBJECTS

SELECT object_name, object_type, last_ddl_time, timestamp, status
FROM   user_objects
WHERE  object_type IN ('PROCEDURE', 'FUNCTION');

SELECT object_name, object_type, last_ddl_time, timestamp, status
FROM   all_objects
WHERE  object_type IN ('PROCEDURE', 'FUNCTION');

SELECT   object_name, object_type, status
FROM     user_objects
ORDER BY object_type;

--JOB/PROCEDURE PARA ELIMINAR DETERMINADO PROGRAMA
CREATE OR REPLACE PROCEDURE KILL_SESSION
IS
BEGIN
    FOR DADOS IN (select SID, SERIAL# SERIAL from v$session where schemaname != 'RDSADMIN' and program = 'JDBC Thin Client' and logon_time < sysdate - (1/1440*3) and status = 'INACTIVE') LOOP
        BEGIN 
            EXECUTE IMMEDIATE 'begin rdsadmin.rdsadmin_util.kill( sid => ''' || DADOS.SID || ''', serial => ''' || DADOS.SERIAL || ''', method => ''PROCESS'' ); end;';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;

-- Consultando a Visão Dictionary

DESC dictionary

SELECT *
FROM dictionary
ORDER BY table_name;

SELECT *
FROM dictionary
WHERE table_name = 'USER_TABLES'
ORDER BY table_name;

SELECT *
FROM   dictionary
WHERE  table_name LIKE '%TABLES%'
ORDER BY table_name;

SELECT *
FROM   dict
WHERE  table_name LIKE '%TABLES%'
ORDER BY table_name;

-- Conectar como usuário sys

SELECT *
FROM   dba_objects 
WHERE  owner = 'HR';

SELECT *
FROM   dba_tables
WHERE  owner = 'HR';

SELECT *
FROM   dba_sequences
WHERE  sequence_owner = 'HR';

SELECT *
FROM   dba_views
WHERE  owner = 'HR';

SELECT *
FROM   dba_users;

SELECT *
FROM   dba_tablespaces;

SELECT * 
FROM   dba_data_files;

SELECT * 
FROM   dba_temp_files;

-- Consultando Visões Dinâmicas de Performance

SELECT *
FROM   v$tablespace;

SELECT * 
FROM   v$datafile;

SELECT file#, name, bytes/1024/1024 MB, blocks, status
FROM   v$datafile;

SELECT * 
FROM v$tempfile;

SELECT file#, name, bytes/1024/1024 MB, blocks, status 
FROM   v$tempfile;

SELECT * 
FROM   v$controlfile;

SELECT * 
FROM   v$parameter;

SELECT * 
FROM   v$parameter
WHERE  name = 'db_block_size';

-- Consultando o Código Fonte de Procedures e Funções  do seu usuário

DESC user_source

SELECT line, text
FROM   user_source
WHERE  name = 'PRC_INSERE_EMPREGADO' AND
       type = 'PROCEDURE'
ORDER BY line;

SELECT line, text
FROM   user_source
WHERE  name = 'FNC_CONSULTA_SALARIO_EMPREGADO' AND
       type = 'FUNCTION'
ORDER BY line;

-- Criando usuario

create user aluno
identified by aluno
default tablespace users
temporary tablespace temp
quota unlimited on users;

grant create session to aluno;

GRANT SELECT on hr.employees to aluno;

--USER LUCAS
GRANT CREATE JOB,
DROP ANY PROCEDURE,
ALTER ANY TABLE,
CREATE TABLE,
UNLIMITED TABLESPACE,
EXECUTE ANY PROCEDURE,
ALTER SESSION,
CREATE ANY SEQUENCE,
CREATE VIEW,
CREATE SYNONYM,
DROP ANY INDEX,
ALTER USER,
DELETE ANY TABLE,
UPDATE ANY TABLE,
INSERT ANY TABLE,
DROP ANY TABLE,
CREATE ANY TABLE,
CREATE ANY PROCEDURE,
CREATE ANY INDEX,
SELECT ANY TABLE,
CREATE SESSION TO MAXSOLUCOES,
SELECT ANY DICTIONARY,
CREATE PROCEDURE,
CREATE DATABASE LINK,
CREATE SEQUENCE,
DROP ANY VIEW,
CREATE ANY VIEW TO LUCAS;

CREATE BIGFILE TABLESPACE "TS_CICERO" DATAFILE '/u01/app/oracle/oradata/orcl/ts_cicero01.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M MAXSIZE 2G;
CREATE USER CICERO PROFILE DEFAULT IDENTIFIED BY HakHS#3HiGF DEFAULT TABLESPACE TS_CICERO TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON TS_CICERO;
REVOKE DBA FROM CICERO;
GRANT CONNECT TO CICERO;
GRANT EXECUTE_CATALOG_ROLE TO CICERO;
GRANT SELECT_CATALOG_ROLE TO CICERO;
GRANT CREATE MATERIALIZED VIEW TO CICERO;
GRANT CREATE PROCEDURE TO CICERO;
GRANT CREATE PUBLIC SYNONYM TO CICERO;
GRANT CREATE ROLE TO CICERO;
GRANT CREATE SEQUENCE TO CICERO;
GRANT CREATE SESSION TO CICERO;
GRANT CREATE SYNONYM TO CICERO;
GRANT CREATE TABLE TO CICERO;
GRANT CREATE TRIGGER TO CICERO;
GRANT CREATE TYPE TO CICERO;
GRANT CREATE VIEW TO CICERO;
GRANT CREATE DATABASE LINK TO CICERO;
GRANT DEBUG CONNECT SESSION TO CICERO;
GRANT RESOURCE TO CICERO;
GRANT ALTER SESSION TO CICERO;
GRANT CREATE JOB TO CICERO;
GRANT SELECT ON v_$session to CICERO;

---------------------------------------------------------------

GRANT SELECT ON MAX_HOMOLOG.PCCLIENT to CICERO;
GRANT SELECT ON MAX_HOMOLOG.PCUSUARI to CICERO;
GRANT SELECT ON MAX_HOMOLOG.PCCIDADE to CICERO;
GRANT SELECT ON MAX_HOMOLOG.PCCNAE to CICERO;
GRANT SELECT ON MAX_HOMOLOG.PCCLIESPI to CICERO;
GRANT SELECT ON MAX_HOMOLOG.PCCLIESPI to CICERO;
GRANT SELECT ON MAX_HOMOLOG.PCPRODUT to CICERO;
GRANT SELECT ON MAX_HOMOLOG.PCPREST to CICERO;

--CREATE DATABASE
CREATE DATABASE deocdb
USER SYS IDENTIFIED BY welcome
USER SYSTEM IDENTIFIED BY welcome
LOGFILE GROUP 1 ('/redo-01-a/databases/deocdb/redo-t01-g01-m1.log',
                 '/redo-03-a/databases/deocdb/redo-t01-g01-m2.log') SIZE 100M BLOCKSIZE 512,
        GROUP 2 ('/redo-02-a/databases/deocdb/redo-t01-g02-m1.log',
                 '/redo-04-a/databases/deocdb/redo-t01-g02-m2.log') SIZE 100M BLOCKSIZE 512,
        GROUP 3 ('/redo-01-a/databases/deocdb/redo-t01-g03-m1.log',
                 '/redo-03-a/databases/deocdb/redo-t01-g03-m2.log') SIZE 100M BLOCKSIZE 512,
        GROUP 4 ('/redo-02-a/databases/deocdb/redo-t01-g04-m1.log',
                 '/redo-04-a/databases/deocdb/redo-t01-g04-m2.log') SIZE 100M BLOCKSIZE 512
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 1024
CHARACTER SET UTF8
NATIONAL CHARACTER SET UTF8
EXTENT MANAGEMENT LOCAL
DATAFILE '/u01/oradata/databases/deocdb/system01.dbf'   
    SIZE 700M REUSE AUTOEXTEND ON NEXT 10240K MAXSIZE UNLIMITED
SYSAUX DATAFILE '/u01/oradata/databases/deocdb/sysaux01.dbf'   
    SIZE 550M REUSE AUTOEXTEND ON NEXT 10240K MAXSIZE UNLIMITED
DEFAULT TABLESPACE admin
DATAFILE '/u01/oradata/databases/deocdb/admin-01.dbf'
    SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED  
DEFAULT TEMPORARY TABLESPACE TEMP
TEMPFILE '/u01/oradata/databases/deocdb/temp01.dbf'
    SIZE 20M REUSE AUTOEXTEND ON NEXT 640K MAXSIZE UNLIMITED
UNDO TABLESPACE undo_t1
DATAFILE '/u01/oradata/databases/deocdb/undo_t1-01.dbf'
    SIZE 200M REUSE AUTOEXTEND ON NEXT 5120K MAXSIZE UNLIMITED
ENABLE PLUGGABLE DATABASE
SEED
    FILE_NAME_CONVERT = ('/u01/oradata/databases/deocdb/', 
                         '/u01/oradata/databases/pdbseed/')
    SYSTEM DATAFILES SIZE 125M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
    SYSAUX DATAFILES SIZE 100M
USER_DATA TABLESPACE users
DATAFILE '/u01/oradata/databases/pdbseed/users-01.dbf'
    SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;


--DESCORBIR PASSWORD ORACLE
select  name, password  
        from    user$
        where   name = 'FABIO';--SALVAR SENHA CRIPTOGRAFADA

ALTER USER FABIO IDENTIFIED BY FABIO;--ALTERA PARA USAR
ALTER USER FABIO IDENTIFIED BY SENHA_CRIPTOGRAFADA;--quando você fornece a string da senha no comando ALTER USER após a palavra BY, 
                                                   --o Oracle já entende que o próximo valor é a senha criptografada, portanto, ele a 
                                                   --armazena internamente com este valor. Quando tem que validar a senha, ele aplica o 
                                                  --algoritmo e chave de decriptografia, transformando-a no valor original e faz a validação



-- Consultando a lista de parâmetros de Procedures e Funções 

DESC PRC_INSERE_EMPREGADO

DESC FNC_CONSULTA_SALARIO_EMPREGADO

-- Consultando Erros de Compilação - Comando SHOW ERRORS

SHOW ERRORS PROCEDURE FNC_CONSULTA_SALARIO_EMPREGADO

--DESCOBRIR HEADER DA TABELA
select header_block, tablespace_name from dba_segments where segment_name ='TESTE';
-       31192 SYSTEM


--OBEJCT TYPE
SELECT * FROM ALL_OBJECTS WHERE OBJECT_NAME LIKE '%JSON%' AND OWNER = 'MAXSOLUCOES';

SELECT 'DROP' || ' ' ||OBJECT_TYPE || ' ' ||OBJECT_NAME || ';' FROM ALL_OBJECTS WHERE OBJECT_NAME LIKE '%JSON%' AND OWNER = 'MAXSOLUCOES' AND OBJECT_TYPE != 'TYPE'; -- drop package/synonin

SELECT 'DROP' || ' ' ||OBJECT_TYPE || ' ' ||OBJECT_NAME || ' '||'FORCE;' FROM ALL_OBJECTS WHERE OBJECT_NAME LIKE '%JSON%' AND OWNER = 'MAXSOLUCOES' AND OBJECT_TYPE = 'TYPE';;-- drop type

-- Consultando Erros de Compilação - Visão USER_ERRORS

DESC user_errors

COLUMN position FORMAT a4
COLUMN text FORMAT a60
SELECT line||'/'||position position, text
FROM   user_errors
WHERE  name = 'FNC_CONSULTA_SALARIO_EMPREGADO'
ORDER BY line;

--PROCURAR TABLE E COLUNA NO oracle

    select * from cols 
      where table_name like '%CC%'
      and column_name like '%DT%'

--TRIGGER
CREATE OR REPLACE TRIGGER TRG_CHECK_SALARIO
BEFORE INSERT OR UPDATE ON ALUNO
FOR EACH ROW
 BEGIN
      IF :NEW.SALARIO < 2000 THEN 
          RAISE_APPLICATION_ERROR (-20000,'Valor Incorreto');
      END IF;
 END;
 /
--CONSULTANDO TRIGGER
SELECT TRIGGER_NAME, TRIGGER_BODY FROM USER_TRIGGERS;

--UTILIZANDO TRIGGER PARA BKP DE TABELA
CREATE OR REPLACE TRIGGER LOG_USUARIOS
BEFORE DELETE ON USUARIOS
FOR EACH ROW
BEGIN
     INSERT INTO BKP_USUARIOS VALUES (:OLD.ID, :OLD.NOME);
END;
/
--TRIGGER DE REGISTRO ATUALIZAÇÃO
create or replace TRIGGER TRG_EMPLOYEES_REGISTRO_DE_ATUALIZACAO
BEFORE INSERT OR UPDATE
ON HR.EMPLOYEES
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW

DECLARE
 VALTER       EMPLOYEES.TIPOALTER%TYPE;
BEGIN
        VALTER := 'I';
		IF INSERTING 
        THEN
			VALTER      := 'I';
		ELSIF UPDATING 
        THEN
			VALTER      := 'U';
	    END IF;
 BEGIN  
:NEW.DTATUALIZ := SYSDATE;
:NEW.TIPOALTER := VALTER;

        IF (NVL (:NEW.TIPOALTER, 'I') != 'D')
        THEN
        :NEW.TIPOALTER := VALTER;
        END IF;
 END;

END TRG_EMPLOYEES_REGISTRO_DE_ATUALIZACAO;

--trigger de deny access to logon oracle

CREATE OR REPLACE TRIGGER block_tools_from_prod
  AFTER LOGON ON DATABASE
DECLARE
  v_prog sys.v_$session.program%TYPE;
BEGIN
  SELECT program INTO v_prog
    FROM sys.v_$session
  WHERE  audsid = USERENV('SESSIONID')
    AND  audsid != 0  -- Don't Check SYS Connections
    AND  ROWNUM = 1;  -- Parallel processes will have the same AUDSID's
 
  IF UPPER(v_prog) LIKE '%TOAD%' OR UPPER(v_prog) LIKE '%T.O.A.D%' OR -- Toad
     UPPER(v_prog) LIKE '%SQLNAV%' OR     -- SQL Navigator
     UPPER(v_prog) LIKE '%PLSQLDEV%' OR -- PLSQL Developer
     UPPER(v_prog) LIKE '%BUSOBJ%' OR   -- Business Objects
     UPPER(v_prog) LIKE '%EXCEL%'       -- MS-Excel plug-in
  THEN
     RAISE_APPLICATION_ERROR(-20000, 'Development tools are not allowed here.');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_LOGAUDIT_DISABLED_TRIGGER
BEFORE UPDATE ON USER_triggers
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW

DECLARE
  DADOS USER_TRIGGERS%TYPE; 
BEGIN
  SELECT TRIGGER_NAME, STATUS INTO DADOS
  FROM USER_TRIGGERS
  WHERE  status = 'ENABLED';
  
 IF :NEW.STATUS = 'DISABLED'
  THEN 
      INSERT INTO LOGAUDIT_DISABLED_TRIGGER (DT_DISABLED, TRG_NAME, STATUS) VALUES (SYDATE,DADOS.TRIGGER_NAME, DADOS.STATUS);
 END IF;
END;
/

CREATE OR REPLACE TRIGGER SYSTEM.LOGON_DENY
AFTER LOGON
ON DATABASE
declare
OSUSER varchar2 (200);
HOSTNAME varchar2 (200);
       begin
       select sys_context ('USERENV', 'OS_USER') into OSUSER from dual;
        select sys_context ('USERENV', 'HOST') into HOSTNAME from dual;
        if sys_context('USERENV','SESSION_USER')in ('HR','SCOTT','SALES')
        and sys_context ('USERENV', 'HOST') in ('PC_USER1','PC_USER2')
        then
  raise_application_error(-20001,'Denied!  You are not allowed to logon from host '||HOSTNAME|| ' using '|| OSUSER);
         end if;
 end;
/

CREATE OR REPLACE TRIGGER MAXMINO.TRG_RESTRICAO_ACESSO_MAXGESTAO_JB
AFTER LOGON ON DATABASE
DECLARE
USERNAME VARCHAR2(50);
SID NUMBER;
SERIAL NUMBER;
PROGRAM VARCHAR2(100);
BEGIN
SELECT SID,SERIAL#,PROGRAM,USERNAME INTO SID,SERIAL,PROGRAM,USERNAME FROM V$SESSION WHERE AUDSID=SYS_CONTEXT('userenv','sessionid');
IF USERNAME = 'JORGEBC_1674_PRODUCAO' AND PROGRAM = 'MaxGestao.Api.dll' THEN
RAISE_APPLICATION_ERROR(-20001, '---> USUÁRIO DE S.O. NÃO AUTORIZADO, ACESSO NEGADO <---');
EXECUTE IMMEDIATE 'begin rdsadmin.rdsadmin_util.kill( sid => ''' || SID || ''', serial => ''' || SERIAL || ''', method => ''PROCESS'' ); end;';
END IF;
END;
/

--CRIANDO INDICE
CREATE INDEX EMPLOYEES_LAST_NAME_FIRST_NAME_IDX
ON EMPLOYEES (FIRST_NAME,LAST_NAME);

--REORGANIZANDO O INDICE
ALTER INDEX EMPLOYEES_LAST_NAME_FIRST_NAME_IDX REBUILD;

ALTER INDEX employees_last_name_first_name_idx REBUILD ONLINE;

--CONSULTANDO INDICE
SELECT DISTINCT IX.OWNER,
       IX.INDEX_NAME,
       IC.COLUMN_POSITION,
       IC.COLUMN_NAME,
       IX.INDEX_TYPE,
       IX.UNIQUENESS,
       IX.STATUS,
       IX.TABLE_NAME
FROM ALL_INDEXES IX
  JOIN ALL_IND_COLUMNS IC ON (IX.INDEX_NAME = IC.INDEX_NAME) AND
                              (IX.TABLE_NAME = IC.TABLE_NAME)
WHERE IX.TABLE_NAME = 'MXSCLIENT'
   AND IX.OWNER = 'VOVODELMA_433_PRODUCAO'
   AND IX.INDEX_NAME = 'MXSCLIENT_IX07'
ORDER BY IX.INDEX_NAME, IC.COLUMN_NAME;

--CRIANDO TABELA COM INDICE
CREATE TABLE projects
(project_id    NUMBER(6)    NOT NULL 
   CONSTRAINT project_id_pk PRIMARY KEY 
   USING INDEX (CREATE INDEX project_id_idx ON projects (project_id)
                TABLESPACE USERS),
 project_code  VARCHAR2(10) NOT NULL,
 project_name  VARCHAR2(100) NOT NULL,
 CREATION_DATE DATE DEFAULT sysdate NOT NULL,
 START_DATE    DATE,
 END_DATE      DATE,
 STATUS        VARCHAR2(20) NOT NULL,
 PRIORITY      VARCHAR2(10) NOT NULL,
 BUDGET        NUMBER(11,2) NOT NULL,
 DESCRIPTION   VARCHAR2(400) NOT NULL);
 

--CRIANDO SINONIMOS PRIVADOS
CREATE SYNONYM DEPT
FOR DEPARTMENTS;

--REMOVENDO SINONIMOS
DROP SYNONYM DEPT;
DROP PUBLIC SYNONYM DEPT;

--UTILIZANDO SINONIMOS
SELECT * FROM DEPT;

--LOCKED
select distinct sid from v$mystat;--pegar o sid
select * from v$session where sid = ;--sid
select sid,serial#, 
           status,
           username, 
           osuser,  
           program,  
           blocking_session blocking,  
           event
from v$session where blocking_session is not null;


--DBA_WAITERS e DBA_BLOCKERS. 
Caso estas views não estejam criadas no banco de dados, as mesmas poderão ser criadas 
através do script: $ORACLE_HOME/rdbms/admin/catblock.sql
select waiting_session,holding_session from dba_waiters;

Uma outra forma que temos para visualizar situações com esta é executar o script
- $ORACLE_HOME/rdbms/admin/utllockt.sql > executar @utllockt.sq
Este script é muito útil quando existem várias sessões bloqueadoras e bloqueadas e 
precisamos saber qual sessão iniciou todo o processo de bloqueio.

select * from v$lock where block <> 0;

-Ela irá retornar o Sid que originou a consulta, algo bem mais simples e resumido porém 
rápido no caso de não se lembrar do caminho e nome do Script anterior.

SELECT
    O.OBJECT_NAME,
    S.SID,
    S.SERIAL#,
    P.SPID,
    S.PROGRAM,
    SQ.SQL_FULLTEXT,
    S.LOGON_TIME
FROM
    V$LOCKED_OBJECT L,
    DBA_OBJECTS O,
    V$SESSION S,
    V$PROCESS P,
    V$SQL SQ
WHERE
    L.OBJECT_ID = O.OBJECT_ID
    AND L.SESSION_ID = S.SID
    AND S.PADDR = P.ADDR
    AND S.SQL_ADDRESS = SQ.ADDRESS;

--LOCKED
SELECT L.SESSION_ID,
       S.SERIAL#,
       TO_CHAR(TRUNC(S.LAST_CALL_ET / 60 / 60), 'FM999900') || ':' || 
       TO_CHAR(TRUNC(((S.LAST_CALL_ET / 60 / 60) - TRUNC(S.LAST_CALL_ET / 60 / 60)) * 60), 'FM00') || ':' || 
       TO_CHAR(TRUNC(((((S.LAST_CALL_ET / 60 / 60) - TRUNC(S.LAST_CALL_ET / 60 / 60)) * 60) - TRUNC(((S.LAST_CALL_ET / 60 / 60) - TRUNC(S.LAST_CALL_ET / 60 / 60)) * 60))*60), 'FM00') TEMPO,
       S.PROGRAM,
       S.CLIENT_INFO,
       S.BLOCKING_SESSION,
       DECODE (L.LOCKED_MODE,1,'NO LOCK',2,'ROW SHARE',3,'ROW EXCLUSIVE',4,'SHARE',5,'SHARE ROW EXCL',6,'EXCLUSIVE', NULL) LOCKED_MODE,
       O.OWNER,
       'alter system kill session ''' || S.SID || ',' || S.SERIAL# ||''' immediate;' COMANDO_DESCONEXAO,
       O.OBJECT_TYPE,
       O.OBJECT_NAME,
       L.ORACLE_USERNAME,
       L.OS_USER_NAME,
       S.SQL_ID,
       S.MACHINE
FROM GV$LOCKED_OBJECT L,
     DBA_OBJECTS O,
     GV$SESSION S
WHERE L.OBJECT_ID = O.OBJECT_ID
  AND L.SESSION_ID = S.SID 
  AND S.BLOCKING_SESSION is not null
ORDER BY L.SESSION_ID, O.OBJECT_NAME;

SELECT L.SESSION_ID,
         S.SERIAL#,
     S.PROGRAM,
     S.CLIENT_INFO,
     S.BLOCKING_SESSION,
     O.OWNER,
     O.OBJECT_TYPE,
     O.OBJECT_NAME,
     L.ORACLE_USERNAME,
     L.OS_USER_NAME
FROM GV$LOCKED_OBJECT L, DBA_OBJECTS O, GV$SESSION S
WHERE L.OBJECT_ID = O.OBJECT_ID
 AND L.SESSION_ID = S.SID
 --AND L.INST_ID = S.INST_ID
 AND S.BLOCKING_SESSION is not null
ORDER BY L.SESSION_ID, O.OBJECT_NAME;                 


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
--Por objeto
SELECT DISTINCT SES.PROGRAM EXECUTAVEL,
                OBJ.OBJECT_NAME TABELA,
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
                DECODE(LOC.LOCKED_MODE,
                       1,
                       'NO LOCK',
                       2,
                       'ROW SHARE',
                       3,
                       'ROW EXCLUSIVE',
                       4,
                       'SHARE',
                       5,
                       'SHARE ROW EXCL',
                       6,
                       'EXCLUSIVE',
                       NULL) LOCKED_MODE,
                'alter system kill session ''' || SID || ',' || SERIAL# ||
                ''' immediate;' COMANDO_DESCONEXAO,
                SES.SID SID,
                SES.SERIAL# SERIAL#,
                SQL.SQL_TEXT TEXTO_SQL,
                SES.MACHINE MAQUINA,
                SES.USERNAME USUARIO_ORACLE,
                SES.OSUSER USUARIOS_SO
  FROM V$SESSION       SES,
       V$LOCKED_OBJECT LOC,
       DBA_OBJECTS     OBJ,
       V$SQL           SQL
 WHERE SES.SID = LOC.SESSION_ID
   AND LOC.OBJECT_ID = OBJ.OBJECT_ID
   AND SES.SQL_ADDRESS = SQL.ADDRESS(+)
   AND OBJ.OBJECT_NAME LIKE '%PCMXSINTEGRACAO%'
 ORDER BY SES.LAST_CALL_ET DESC;
--bd todo
SELECT DISTINCT 
SES.PROGRAM EXECUTAVEL,
OBJ.OBJECT_NAME TABELA,
SES.INST_ID,
TO_CHAR(TRUNC(SES.LAST_CALL_ET / 60 / 60), 'FM999900') || ':' || 
TO_CHAR(TRUNC(((SES.LAST_CALL_ET / 60 / 60) - TRUNC(SES.LAST_CALL_ET / 60 / 60)) * 60), 'FM00') || ':' ||
TO_CHAR(TRUNC(((((SES.LAST_CALL_ET / 60 / 60) - TRUNC(SES.LAST_CALL_ET / 60 / 60)) * 60) - TRUNC(((SES.LAST_CALL_ET / 60 / 60) - TRUNC(SES.LAST_CALL_ET / 60 / 60)) * 60))*60), 'FM00') TEMPO,
SES.LAST_CALL_ET TEMPO_EM_SEGUNDOS,
SES.STATUS,
DECODE(LOC.LOCKED_MODE,
        1, 'NO LOCK',
        2, 'ROW SHARE',
        3, 'ROW EXCLUSIVE',
        4, 'SHARE',
        5, 'SHARE ROW EXCL',
        6, 'EXCLUSIVE',
        NULL) LOCKED_MODE,
'alter system kill session ''' || SID || ',' || SERIAL# || ',@' || SES.INST_ID || ''' immediate;' COMANDO_DESCONEXAO,
SES.SID SID,
SES.SERIAL# SERIAL#,
SQL.SQL_TEXT TEXTO_SQL,
SES.MACHINE MAQUINA,
SES.USERNAME USUARIO_ORACLE,
SES.OSUSER USUARIOS_SO
FROM GV$SESSION       SES,
GV$LOCKED_OBJECT LOC,
DBA_OBJECTS     OBJ,
GV$SQL           SQL
WHERE SES.SID = LOC.SESSION_ID
  AND LOC.OBJECT_ID = OBJ.OBJECT_ID
  AND SES.SQL_ADDRESS = SQL.ADDRESS(+)
ORDER BY SES.LAST_CALL_ET DESC;

--lock em plsql
SET SERVEROUTPUT ON
BEGIN
DBMS_OUTPUT.enable (1000000);
FOR do_loop IN (SELECT session_id,
                       a.object_id,
                       a.os_user_name,
                       xidsqn,
                       oracle_username,
                       b.owner OWNER,
                       b.object_name object_name,
                       b.object_type object_type 
                FROM v$locked_object a, dba_objects b 
                WHERE xidsqn != 0
                     AND b.object_id = a.object_id)
 LOOP
       DBMS_OUTPUT.put_line ('Blocking Session   : ' || do_loop.session_id);
       DBMS_OUTPUT.put_line ('Object (Owner/Name): ' || do_loop.owner  || '.'  || do_loop.object_name);
       DBMS_OUTPUT.put_line ('Object Type        : ' || do_loop.object_type);
       DBMS_OUTPUT.put_line ('User               : ' || do_loop.os_user_name);
FOR next_loop IN (SELECT sid 
                  FROM v$lock 
                  WHERE id2 = do_loop.xidsqn
                       AND sid != do_loop.session_id)
  LOOP
     DBMS_OUTPUT.put_line ('Sessions being blocked:  ' || next_loop.sid);
  END LOOP;
 END LOOP;
END;

--LIBRARY CACHE EM LOCK
SELECT /*+ ORDERED */ W1.SID WAITING_SESSION, H1.SID HOLDING_SESSION, W.KGLLKTYPE LOCK_OR_PIN, 
W.KGLLKHDL ADDRESS, DECODE(H.KGLLKMOD,0,'None',1,'Null',2,'Share',3,'Exclusive','Unknown') MODE_HELD, 
DECODE(W.KGLLKREQ,0,'None',1,'Null',2,'Share',3,'Exclusive','Unknown') MODE_REQUESTED FROM DBA_KGLLOCK 
W, DBA_KGLLOCK H, V$SESSION W1, V$SESSION H1 WHERE (((H.KGLLKMOD != 0) AND (H.KGLLKMOD != 1) AND 
((H.KGLLKREQ = 0) OR (H.KGLLKREQ = 1))) AND (((W.KGLLKMOD = 0) OR (W.KGLLKMOD= 1)) AND ((W.KGLLKREQ != 
0) AND (W.KGLLKREQ != 1)))) AND W.KGLLKTYPE = H.KGLLKTYPE AND W.KGLLKHDL = H.KGLLKHDL AND W.KGLLKUSE 
= W1.SADDR AND H.KGLLKUSE = H1.SADDR;


--mais comum
exec rdsadmin.rdsadmin_util.flush_shared_pool;

--menos comum
exec rdsadmin.rdsadmin_util.flush_buffer_cache;

--CURSOR_SHARING
--> https://oracle-base.com/articles/9i/cursor_sharing
CREATE OR REPLACE TRIGGER after_logon_trg_parameter
 AFTER LOGON ON database
 DECLARE
 PRAGMA AUTONOMOUS_TRANSACTION;
 BEGIN
 if ora_login_user = 'DONIZETE_2582_PRODUCAO' then
 execute immediate 'alter session set cursor_sharing=force';
 end if;
END;

--COMMIT_LOGGING
--https://eduardolegatti.blogspot.com/2015/04/abordando-o-commit-assincrono.html
create or replace TRIGGER after_logon_trg_parameter
AFTER LOGON ON database
DECLARE
 USERNAME VARCHAR2(50);
 SID NUMBER;
 SERIAL NUMBER;
BEGIN
 SELECT USERNAME,SID,SERIAL# INTO USERNAME,SID,SERIAL FROM V$SESSION WHERE AUDSID=SYS_CONTEXT('userenv','sessionid');
  if ora_login_user in  ('FCDIST_2540_PRODUCAO','OMNI_1907_PRODUCAO','DANSUL_2858_PRODUCAO') then
   execute immediate 'alter session set COMMIT_LOGGING = BATCH';
  end if;
END;


CREATE OR REPLACE TRIGGER trg_audit_login_database AFTER LOGON ON DATABASE BEGIN

    IF sys_context('USERENV', 'OS_USER') = ( 'MAXSOLUCOES' ) THEN
        INSERT INTO mx_login_denied (
            login_date,
            osuser,
            maquina,
            module,
            owner,
            failed_login
        ) VALUES (
            sysdate,
            sys_context('USERENV', 'OS_USER'),
            sys_context('USERENV', 'HOST'),
            sys_context('USERENV', 'MODULE'),
            ora_dict_obj_owner,
            'N'
        );

    END IF;
EXCEPTION
    WHEN login_denied THEN
        INSERT INTO mx_login_denied (
            login_date,
            osuser,
            maquina,
            module,
            owner,
            failed_login
        ) VALUES (
            sysdate,
            sys_context('USERENV', 'OS_USER'),
            sys_context('USERENV', 'HOST'),
            sys_context('USERENV', 'MODULE'),
            ora_dict_obj_owner,
            'S'
        );

END;
/

CREATE TABLE mx_login_denied (
login_date date,
osuser varchar2 (60),
maquina varchar2 (60),
module varchar2 (60),
owner varchar2 (60),
failed_login varchar2 (5)
);




https://docs.aws.amazon.com/pt_br/AmazonRDS/latest/UserGuide/Appendix.Oracle.CommonDBATasks.System.html
--SESSAO ABERTA DE USUARIO ORACLE/

SELECT SID,SERIAL#,STATUS from v$session where username='';
ALTER SYSTEM KILL SESSION '' immediate;

SELECT  
         'alter system kill session '''
         || SID
         || ','
         || SERIAL#
         || ''' immediate;'
  FROM   V$SESSION
 WHERE   USERNAME = 'C##DBA'
 AND STATUS = 'ACTIVE' ;

--DROPAR SCHEDULER

select owner,job_name,repeat_interval from DBA_SCHEDULER_JOBS order by owner,repeat_interval;

select 'DBMS_SCHEDULER.DROP_JOB(job_name =>''' ||owner|| '.' ||job_name|| ''',defer => false,force => false);'
from DBA_SCHEDULER_JOBS
where owner not like '%MAX%' 
  AND owner not like '%PERFSTAT%';

BEGIN
 DBMS_SCHEDULER.DROP_JOB(JOB_NAME => 'INTEGRADORA_PC');
END;

--CONSULTAR TEMPO DE EXECUÇÃO DAS JOBS RDS
SELECT job_name,
       OWNER,
       TO_CHAR(data_inicio, 'DD-MON-YYYY HH24:MI') AS data_inicio,
       TO_CHAR(data_fim, 'DD-MON-YYYY HH24:MI') AS data_fim,
       trunc(mod(mod(data_fim - data_inicio, 1)*24, 1)*60*60) AS SEGUNDOS
FROM mjobs_info
WHERE job_name = 'JOB_GERAR_LEGENDAS_FV'
  AND data_inicio > sysdate - (1/1440*7800) --7800 representa a quantidade de minutos
ORDER BY SEGUNDOS DESC;

SELECT JOB_NAME,
       OWNER,
       TO_CHAR(DATA_INICIO, 'DD-MON-YYYY HH24:MI') AS DATA_INICIO,
       TO_CHAR(DATA_FIM, 'DD-MON-YYYY HH24:MI') AS DATA_FIM,
       TRUNC(MOD(MOD(DATA_FIM - DATA_INICIO, 1)*24, 1)*60*60) AS SEGUNDOS
FROM MJOBS_INFO
WHERE TRUNC (DATA_INICIO)>= TRUNC(TO_DATE('02/02/2022', 'DD/MM/YYYY'))
  AND JOB_NAME NOT IN ('JOB_COMPUTE_STATISTICS')
ORDER BY SEGUNDOS DESC;

-- Verificar jobs schedulados:
select * from SYS.dba_jobs WHERE BROKEN = 'N'; -- ver INTERVAL  , SCHEMA_USER = owner
select * from SYS.dba_scheduler_jobs where enabled = 'TRUE';  -- ver REPEAT_INTERVAL

-- verificar jobs em execucao:
select * from SYS.dba_jobs_running;
select * from SYS.dba_scheduler_running_jobs;
      
-- verificar jobs executados com falha:      
select * from dba_jobs where failures > 0;  -- deve-se comparar com ultima consulta efetuada pr ver se failures aumentou, se broken = Y o job está desabilitado
select * from SYS.dba_scheduler_job_run_details where status <> 'SUCCEEDED'; -- ver coluna ADDITIONL_INFO

--DEBUG
-->debug on procedure
SET SERVEROUTPUT ON
BEGIN
    BEGIN
      DBMS_OUTPUT.put_line ('DEBUG : Executando procedure');
      LIMPAR_REGISTROS_TABELAS;
     EXCEPTION
         WHEN OTHERS
         THEN DBMS_OUTPUT.put_line ('DEBUG :Erro '|| SQLERRM);
     END;  
      DBMS_OUTPUT.put_line ('DEBUG : Procedure executada com sucesso');
END;

--DROP USER

DROP USER {SCHEMA} CASCADE;
DROP TABLESPACE {TABLESPACE_SCHEMA} INCLUDING CONTENTS AND DATAFILES;


--STATSPACK, UTLBSTAT e UTLESTAT
ORACLE_HOME = /u01/app/oracle/product/12.2.0.1/db_1
cd /u01/app/oracle/product/12.2.0.1/db_1/rdbms/admin/

@/u01/app/oracle/product/12.2.0.1/db_1/rdbms/admin/spcreate.sql (CRIAR O USUARIO PERFSTAT)
-Com o usuario logar no mesmo e executar a package: execute STATSPACK.snap  (duas vezes para inicio e fim)
  >> spreport.sql = STATSPACK (grava no diretorio que chamou o sqlplus, logar como perfstat)

-Com user sys irá executar essses dois comenando para uma estatisticas mais resumida.
  >> utlbstat.sql = start
  >> utlestat.sql = end

-- Verificar tabelas com estatiscas mais velhas que N dias (isso nao significa que a tabela tem estatisticas desatualizadas):
select OWNER, TABLE_NAME, NUM_ROWS, BLOCKS, AVG_ROW_LEN , last_analyzed
from dba_tables where table_name = 'CARD_DETAILS';

-- Verificar indexes com estatiscas mais velhas que N dias (isso nao significa que o indexes tem estatisticas desatualizadas):
select  owner, index_name, table_owner, table_name, blevel, leaf_blocks, distinct_keys, clustering_factor, num_rows, last_analyzed 
from    dba_indexes 
where   last_analyzed > sysdate -10 and owner not in ('SYS');

-- verificar atualizacoes que ainda nao constam nas estatisticas
select      table_owner, table_name, partition_name, inserts, updates, deletes, to_char(timestamp, 'yyyy/mm/dd hh24:mi:ss') AS "TIMESTAMP"            
from        dba_tab_modifications 
where       table_name = 'CARD_DETAILS'
order by    6 desc;



-- verificar historico de estatisticas coletadas (retencao PADRAO de 31 dias):
select * from dba_tab_stats_history 
order by 5 desc;

-- Verificar operacoes de coletas de estatisticas que foram realizadas no BD (manuais e automaticas). Coluna NOTES contem parametros utilizados na coleta.
SELECT      OPERATION, TARGET, START_TIME, 
            (END_TIME - START_TIME) DAY(1) TO SECOND(0) AS DURATION,
            STATUS, NOTES 
FROM        DBA_OPTSTAT_OPERATIONS
ORDER BY    start_time DESC;


--ESTATISTCAS DO OWNER DBMS_STATS
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('MXFECP_DEV',CASCADE=>TRUE);
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('MXFECP_DEV', OPTIONS=>'GATHER', CASCADE=>TRUE, METHOD_OPT=>'FOR ALL COLUMNS SIZE SKEWONLY', NO_INVALIDATE=>FALSE);

--ESTATISTICAS DE UMA TABELA DBMS_STATS
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>'LUCAS', TABNAME=>'FUNC_DEP', cascade=>true); 

--ESTATISTICAS DO BANCO TODO DBMS_STATS
EXEC DBMS_STATS.GATHER_DATABASE_STATS;

--COLETA DE ESTATISTICAS DE SISTEMA
EXECUTE dbms_stats.gather_system_stats ();

--COLETA DE ESTAISTICAS DE SISTEMA COM CARGA DE TRABALHO
EXECUTE dbms_stats.gather_system_stats ('START');
 /* EFETUAR CARGA */
EXECUTE dbms_stats.gather_system_stats ('STOP');

--COLETA DE ESTATISTICAS DE SISTEMA COM INTERVALO 
EXEC DBMS_STATS.GATHER_SYSTEM_STATS('interval', interval => 60); 
--SELECT * FROM sys.aux_stats$ ;

--COLETA DE ESTATISTICAS DE OBJETOS FIXOS DO DICIONARIO DE DADOS
EXECUTE dbms_stats.gather_fixed_objects_stats ();

											  
                        
DBMS_STATS.GATHER_SCHEMA_STATS(ownname => 'STUDY', options=> 'GATHER EMPTY', cascade=> true, estimate_percent=> dbms_stats.auto_sample_size);
DBMS_STATS.GATHER_SCHEMA_STATS(ownname => 'STUDY', options=> 'GATHER STALE', cascade=> true, estimate_percent=> dbms_stats.auto_sample_size);

--VERIFICAR AUTOTASK
SELECT client_name, status FROM dba_autotask_client;

--DESABLE AUTOTASK
exec DBMS_STATS.gather_table_stats('SYS','SCHEDULER$_EVENT_LOG',cascade=>true); 
EXEC DBMS_STATS.GATHER_SCHEMA_STATS ('SYS');
EXECUTE DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;

EXEC DBMS_AUTO_TASK_ADMIN.DISABLE(client_name=>'sql tuning advisor', operation=>NULL, window_name=>NULL);
EXEC DBMS_AUTO_TASK_ADMIN.DISABLE(client_name=>'auto space advisor', operation=>NULL, window_name=>NULL);
EXEC DBMS_AUTO_TASK_ADMIN.DISABLE(client_name=>'auto optimizer stats collection', operation=>NULL, window_name=>NULL);

--TRACE FOR SESSION
--https://docs.aws.amazon.com/pt_br/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.Oracle.html

EXEC rdsadmin.manage_tracefiles.refresh_tracefile_listing;--LISTAR ARQ DE LOGS RDS
SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir('BDUMP')) order by mtime desc;;
SELECT 'BDUMP' || (SELECT regexp_replace(DB_UNIQUE_NAME,'.*(_[A-Z])', '\1') FROM V$DATABASE) AS BDUMP_VARIABLE FROM DUAL;--em caso de replica
SELECT DB_UNIQUE_NAME FROM V$DATABASE;--BDUMP
SELECT TEXT FROM table(rdsadmin.rds_file_util.read_text_file('BDUMP','GOYA_ora_1613.trc'));

-> ENABLE
BEGIN 
  DBMS_MONITOR.SESSION_TRACE_ENABLE(
    session_id => 27 
  , serial_num => 60
  , waits      => true
  , binds      => false);
END;
-> DESABLE
BEGIN
  DBMS_MONITOR.SESSION_TRACE_DISABLE(
    session_id => 27
  , serial_num => 60);
END;

--VERIFICAR ESTATISTICAS DE SISTEMA
SELECT * FROM SYS.AUX_STATS$;

--VALIDAR HITRATIO DO BUFFER CACHE E SHARED_POOL
-->>> https://imasters.com.br/banco-de-dados/ajustando-o-buffer-cache-shared-pool-e-o-log-buffer
--> executar arquivo tuning.sql tim hall
SELECT NAME, VALUE
FROM V$SYSSTAT
WHERE NAME IN ('db block gets from cache', 
               'consistent gets from cache', 
               'physical reads cache');--PERCENTUAL DE HIT RAT NO BUFFER POOL

SELECT NAME, PHYSICAL_READS, DB_BLOCK_GETS, CONSISTENT_GETS,
       1 - (PHYSICAL_READS / (DB_BLOCK_GETS + CONSISTENT_GETS)) "HIT RATIO"
FROM  V$BUFFER_POOL_STATISTICS;--PERCENTUAL DE HIT RAT NO BUFFER POOL

SELECT size_for_estimate, buffers_for_estimate, 
       estd_physical_read_factor, estd_physical_reads
  FROM V$DB_CACHE_ADVICE
 WHERE name = 'DEFAULT'
   AND block_size = (SELECT value 
                       FROM V$PARAMETER 
    			      WHERE name = 'db_block_size')
   AND advice_status = 'ON';--ESTIMATIVA DE ACORDO COM O TAMANHO DO BUFFER

SELECT sum(pinhits) / sum(pins) FROM V$LIBRARYCACHE;--PERCENTUAL SHARED_POOL

SELECT (SUM(GETS - GETMISSES - FIXED)) / SUM(GETS) "ROW CACHE" 
FROM V$ROWCACHE;--PERCENTUAL SHARED_POOL

SELECT gethits,gets,gethitratio * 100 FROM v$librarycache WHERE namespace = 'SQL AREA';
SELECT
   SUM(PINS) "EXECUTIONS",
   SUM(RELOADS) "CACHE MISSES WHILE EXECUTING", SUM (PINS)/SUM(RELOADS) "%"
FROM
   V$LIBRARYCACHE;

SELECT 'Buffer Cache' NAME,
ROUND ( (congets.VALUE + dbgets.VALUE - physreads.VALUE)
* 100
/ (congets.VALUE + dbgets.VALUE),
2
) VALUE
FROM v$sysstat congets, v$sysstat dbgets, v$sysstat physreads
WHERE congets.NAME = 'consistent gets'
AND dbgets.NAME = 'db block gets'
AND physreads.NAME = 'physical reads'
UNION ALL
SELECT 'Execute/NoParse',
DECODE (SIGN (ROUND ( (ec.VALUE - pc.VALUE)
* 100
/ DECODE (ec.VALUE, 0, 1, ec.VALUE),
2
)
),
-1, 0,
ROUND ( (ec.VALUE - pc.VALUE)
* 100
/ DECODE (ec.VALUE, 0, 1, ec.VALUE),
2
)
)
FROM v$sysstat ec, v$sysstat pc
WHERE ec.NAME = 'execute count'
AND pc.NAME IN ('parse count', 'parse count (total)')
UNION ALL
SELECT 'Memory Sort',
ROUND ( ms.VALUE
/ DECODE ((ds.VALUE + ms.VALUE), 0, 1, (ds.VALUE + ms.VALUE))
* 100,
2
)
FROM v$sysstat ds, v$sysstat ms
WHERE ms.NAME = 'sorts (memory)' AND ds.NAME = 'sorts (disk)'
UNION ALL
SELECT 'SQL Area get hitrate', ROUND (gethitratio * 100, 2)
FROM v$librarycache
WHERE namespace = 'SQL AREA'
UNION ALL
SELECT 'Avg Latch Hit (No Miss)',
ROUND ((SUM (gets) - SUM (misses)) * 100 / SUM (gets), 2)
FROM v$latch
UNION ALL
SELECT 'Avg Latch Hit (No Sleep)',
ROUND ((SUM (gets) - SUM (sleeps)) * 100 / SUM (gets), 2)
FROM v$latch;

SELECT NAME, VALUE
FROM VSYSSTAT
WHERE NAME = 'redo buffer allocation retries';--LOG BUFFER, coletar a informação de tempos em tempos o ideal e não ter altreações

SELECT SUBSTR(SQL_TEXT, 1, 100) SQL_TEXT, COUNT(SQL_TEXT) QTD FROM V$SQL HAVING COUNT(SQL_TEXT) > 50 GROUP BY SUBSTR(SQL_TEXT, 1, 100) ORDER BY QTD;-->>sql se repetindo

select snap_id, to_char(snap_time, 'Dy DD-Mon-YYYY HH24:MI:SS') snap_time  from stats$snapshot order by 1 desc;

--TOP QUERYS POR TEMPO DE CPU
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

--TOP QUERYS POR TEMPO DE EXECUÇÃO
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

SELECT
       A.text_subset SQL,
       A.module PROGRAM,
       COUNT (*) QTD 
FROM STATS$SQL_SUMMARY A,
     STATS$SQL_SUMMARY B
WHERE A.hash_value = B.hash_value
  AND A.snap_id =53527
  AND B.snap_id = 53543
  AND A.MODULE IS NOT NULL
GROUP BY  A.text_subset,
          A.module
ORDER BY QTD DESC;

--VERIFICAR TABELAS QUE PRECISAO DE DESFRAGMENTAÇÃO (shrink)
select * from ALL_TAB_MODIFICATIONS WHERE table_owner LIKE '%PRODUCAO' 
AND table_owner = 'DESTRO_1876_PRODUCAO'
--AND table_name NOT IN (SELECT table_name FROM DBA_INDEXES WHERE index_type LIKE 'FUN%')
ORDER BY DELETES DESC;

--SHRINK
SELECT 'ALTER TABLE '||TABLE_OWNER||'.'||TABLE_NAME|| ' ENABLE ROW MOVEMENT;' AS part1,
       'ALTER TABLE '||TABLE_OWNER||'.'||TABLE_NAME|| ' SHRINK SPACE compact;' AS part2,
       'ALTER TABLE '||TABLE_OWNER||'.'||TABLE_NAME|| ' SHRINK SPACE CASCADE;' AS part3,
       'ALTER TABLE '||TABLE_OWNER||'.'||TABLE_NAME|| ' DISABLE ROW MOVEMENT;' AS part4
FROM  ALL_TAB_MODIFICATIONS WHERE table_owner LIKE '%PRODUCAO' 
AND table_owner = 'SCHEMA';

ALTER TABLE DESTRO_1876_PRODUCAO.ERP_MXSLOGRCA ENABLE ROW MOVEMENT;
ALTER TABLE DESTRO_1876_PRODUCAO.ERP_MXSLOGRCA shrink space compact;
alter table DESTRO_1876_PRODUCAO.ERP_MXSLOGRCA shrink space cascade;
ALTER TABLE DESTRO_1876_PRODUCAO.ERP_MXSLOGRCA DISABLE ROW MOVEMENT;

ALTER TABLE EASY_2218_PRODUCAO.MXSHISTORICOCRITICA MODIFY LOB (CRITICA) (SHRINK SPACE);

EXEC DBMS_STATS.GATHER_TABLE_STATS('DESTRO_1876_PRODUCAO','ERP_MXSLOGRCA');

https://www.oracle-world.com/sql-advanced/hwm-high-water-mark/
https://levipereira.wordpress.com/2010/10/19/desfragmentando-tabelas-no-oracle-10g/
https://eduardolegatti.blogspot.com/2008/06/reorganizando-o-tablespace.html

begin
for i in (SELECT obj.owner
,obj.table_name
,(CASE WHEN NVL(idx.cnt, 0) < 1 THEN 'Y' ELSE 'N' END) as shrinkable
FROM dba_tables obj,
(SELECT table_name, COUNT(rownum) cnt
FROM dba_indexes
WHERE index_type LIKE 'FUN%'
GROUP BY table_name) idx
WHERE obj.table_name = idx.table_name(+)
AND obj.tablespace_name = upper('&1') and NVL(idx.cnt,0) < 1)
loop
execute immediate 'alter table '||i.owner||'.'||i.table_name||' enable row movement';
execute immediate 'alter table '||i.owner||'.'||i.table_name||' shrink compact';
execute immediate 'alter table '||i.owner||'.'||i.table_name||' shrink spaceccascade';
execute immediate 'alter table '||i.owner||'.'||i.table_name||' disable row movement';
end loop;
end;
/

--VERIFICAR QUEM ESTÁ MANIPULANDO OBJETOS
SELECT 'begin rdsadmin.rdsadmin_util.kill( sid    => ''' || s.SID || ''', serial => ''' || s.SERIAL# || ''', method => ''PROCESS'' ); end;' COMANDO_KILL,
       --'alter system kill session ''' || s.sid || ',' || s.serial# || ',@' || s.inst_id || ''' immediate;' COMANDO_KILL_2
    s.username ,
    o.object_name ,
    s.sid ,
    s.serial# , 
    s.inst_id ,
    p.spid ,
    s.program ,
    s.machine ,
    s.osuser ,
    s.port ,
    s.logon_time ,
    TO_CHAR(TRUNC(S.LAST_CALL_ET / 60 / 60), 'FM999900') || ':' || 
    TO_CHAR(TRUNC(((S.LAST_CALL_ET / 60 / 60) - TRUNC(S.LAST_CALL_ET / 60 / 60)) * 60), 'FM00') || ':' ||
    TO_CHAR(TRUNC(((((S.LAST_CALL_ET / 60 / 60) - TRUNC(S.LAST_CALL_ET / 60 / 60)) * 60) - TRUNC(((S.LAST_CALL_ET / 60 / 60) - TRUNC(S.LAST_CALL_ET / 60 / 60)) * 60))*60), 'FM00') TEMPO,
    sq.sql_text
FROM gv$locked_object l ,
     dba_objects o ,
     gv$session s ,
     gv$process p ,
     gv$sql sq
WHERE o.object_id = l.object_id
  AND s.sid = l.session_id
  AND s.inst_id = l.inst_id
  AND p.addr = s.paddr
  AND sq.address(+) = s.sql_address
ORDER BY s.username ,
         s.inst_id ,
         s.sid ,
         s.serial# , o.object_name;

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
AND OWNER = 'FCDIST_2540_PRODUCAO'
AND B.PROGRAM = 'Integracao.Extracao.dll';
--https://rcdeveloper.wordpress.com/2011/07/27/oracle-verificar-uso-de-objetos-tabelas-views-etc-pelos-usuarios/
--http://www.basef.com.br/old/oracle/343-consultando-dados-modificados-nas-ultimas-sessoes-do-oracle-com-flashback

--LONG RUNNING QUERIES KILL
SELECT DISTINCT SES.PROGRAM EXECUTAVEL,
  ses.action,
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
	'begin begin rdsadmin.rdsadmin_util.kill( sid    => ''' || SID || ''', serial => ''' || SERIAL# || ''', method => ''IMMEDIATE'' ); end; exception when others then null; end;' COMANDO,
	SES.SID SID,
	SES.SERIAL# SERIAL#,
	SQL.SQL_TEXT TEXTO_SQL,
	SES.MACHINE MAQUINA,
	SES.USERNAME USUARIO_ORACLE,
	SES.OSUSER USUARIOS_SO
  FROM GV$SESSION       SES,
       GV$SQL           SQL
 WHERE SES.SQL_ADDRESS = SQL.ADDRESS(+)
   AND SES.TYPE != 'BACKGROUND'
 ORDER BY SES.LAST_CALL_ET DESC;

 SELECT DISTINCT SES.PROGRAM EXECUTAVEL,
	SES.STATUS,
	SQL.SQL_TEXT TEXTO_SQL,
	SES.USERNAME USUARIO_ORACLE,
	count (*)
  FROM GV$SESSION       SES,
       GV$SQL           SQL
 WHERE SES.SQL_ADDRESS = SQL.ADDRESS(+)
   AND SES.TYPE != 'BACKGROUND'
   AND SQL.SQL_ID = '2y55ktyjdjvxa'
 group by SES.PROGRAM,
	SES.STATUS,
	SQL.SQL_TEXT,
	SES.USERNAME ;


--CONSULTAR SQL_ID NO BANCO

 SELECT S.SID, s.serial#, s.program, s.osuser, s.schemaname, s.machine, t.sql_id, t.sql_text
  FROM V$SQLTEXT T, V$SESSION S
 WHERE S.SQL_HASH_VALUE = T.HASH_VALUE
   AND S.SQL_ADDRESS = T.ADDRESS
   AND S.USERNAME IS NOT NULL
   AND t.sql_id in ('9j0yj352grmn6')
 ORDER BY T.PIECE, S.SID;      --TRAS O SQL DIVIDIDO

 SELECT DISTINCT (S.SID), s.serial#, s.program, s.osuser, s.schemaname, s.machine, t.sql_id, S.SQL_HASH_VALUE, sf.sql_text as sql_full
  FROM V$SQLTEXT T, V$SESSION S, V$SQL SF
 WHERE S.SQL_HASH_VALUE = T.HASH_VALUE
   AND S.SQL_HASH_VALUE = SF.HASH_VALUE
   AND S.SQL_ADDRESS = T.ADDRESS
   AND S.USERNAME IS NOT NULL
   AND t.sql_id in ('b32qz9ygg02vs');    --TRAS O SQL FULL DEPENDENDO DO TAMANHO DO MESMO

--SQL E SESSION EXECUTANDO
--RDS
SELECT  S.SQL_ID,S.STATUS, S.LOGON_TIME,TO_CHAR (SYSDATE,'DD/MM/YYYY HH24:MI:SS') HORA_ATUAL,
        'begin rdsadmin.rdsadmin_util.kill( sid => ''' || S.SID || ''', serial => ''' || S.SERIAL# || ''', method => ''PROCESS'' ); end;' KILL_SESSION,
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

BEGIN

COMMIT;
EXCEPTION
     WHEN OTHERS THEN
        NULL;
END;

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
WHERE SQL_ID = 'g18bpg9w95xdr'; 

SELECT * FROM V$SQLTEXT WHERE SQL_TEXT LIKE '%%';


--CONSULTAR VARIAVEIS BIND
SELECT NAME,TO_CHAR(LAST_CAPTURED,'DD/MM/YYYY HH24:MI:SS'),VALUE_STRING, DATATYPE_STRING 
FROM V$SQL_BIND_CAPTURE WHERE SQL_ID = '';

--CONSULTAR PLANO DE EXECUÇÃO
select * from table(dbms_xplan.display_cursor(sql_id => '46kxxqawfbqm9'));

select * from table(dbms_xplan.display);
EXPLAIN PLAN FOR

--USUARIOS LOGADOS EM DETERMINADO SCHEMA 
SELECT S.SID,     S.SERIAL#,
       S.LOGON_TIME,TO_CHAR (SYSDATE,'DD/MM/YYYY HH24:MI:SS') HORA_ATUAL,
       S.STATUS,  S.PROGRAM,
       S.OSUSER,  S.SCHEMANAME,
       S.MACHINE, S.BLOCKING_SESSION
FROM V$SESSION S
WHERE S.USERNAME = '';
--S.OSUSER NOT IN ('rdsdb','root','rdsmon','MAXIMA','PortalExecutivo','rdshm');

--SQL DOS USUARIOS 
SELECT S.SID,
       S.STATUS,
       S.PROCESS,
       S.SCHEMANAME,
       S.OSUSER,
       A.SQL_TEXT,
       P.PROGRAM
FROM V$SESSION S,
     V$SQLAREA A,
     V$PROCESS P
WHERE S.SQL_HASH_VALUE = A.HASH_VALUE
    AND S.SQL_ADDRESS = A.ADDRESS
    AND S.PADDR = P.ADDR
    AND S.OSUSER != 'root';

 select s.username AS user_erro,a.value AS value, s.sid, c.SQL_TEXT
    from v$sesstat a, v$statname b, v$session s, v$sqlarea c
    where a.statistic# = b.statistic#  
      and s.sid=a.sid 
      and S.SQL_HASH_VALUE = c.HASH_VALUE
      and b.name = 'opened cursors current' 
      and s.username is not null
      order by value desc;

--SESSOES ABERTAS PARA DETERMINADO PROGRAMA
SELECT DISTINCT (USERNAME),
       PROGRAM,
       count (*)
FROM V$SESSION 
WHERE PROGRAM IN ('JDBC Thin Client')
group by SCHEMANAME, PROGRAM;

--SESSOES ABERTAS POR PROGRAMA
SELECT DISTINCT PROGRAM,
       count (*) "SESSION"
FROM V$SESSION 
WHERE PROGRAM NOT IN (SELECT PROGRAM FROM V$SESSION WHERE PROGRAM LIKE '%oracle%')
GROUP BY PROGRAM
ORDER BY COUNT(*) DESC;

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
   AND PROGRAM IN ('JDBC Thin Client')
   AND SCHEMANAME != 'RDSADMIN' 
   AND LOGON_TIME < (SYSDATE - 3/ (24 * 60))--minutos
   AND STATUS = 'INACTIVE'
ORDER BY LOGON_TIME;

--SESSION ABERTAS POR USERNAME

SELECT SCHEMANAME, COUNT(1) FROM V$SESSION WHERE SCHEMANAME LIKE '%PROD%' group by SCHEMANAME order by count(1) desc;

--FINALIZAR SESSAO DE DETERMINADO PROGRAMA
SELECT
'begin rdsadmin.rdsadmin_util.kill( sid => ''' || SID || ''', serial => ''' || SERIAL# || ''', method => ''IMMEDIATE'' ); end;' KILL_SESSION
FROM V$SESSION 
WHERE PROGRAM IN ('JDBC Thin Client')
   AND SCHEMANAME != 'RDSADMIN' 
   AND LOGON_TIME < (SYSDATE - 3/ (24 * 60))
   AND STATUS = 'INACTIVE';

SELECT 'begin rdsadmin.rdsadmin_util.kill( sid => ''' || SID || ''', serial => ''' || SERIAL# || ''', method => ''PROCESS'' ); end;' KILL_SESSION
FROM  V$SESSION WHERE SCHEMANAME = '' ;

--FINALIZAR TUDO
SELECT  S.STATUS, S.SQL_ID,
        S.LOGON_TIME,TO_CHAR (SYSDATE,'DD/MM/YYYY HH24:MI:SS') HORA_ATUAL,
        'begin rdsadmin.rdsadmin_util.kill( sid => ''' || S.SID || ''', serial => ''' || S.SERIAL# || ''', method => ''PROCESS'' ); end;' KILL_SESSION,
        S.PROGRAM,S.OSUSER, 
        S.SCHEMANAME, S.MACHINE
FROM V$SESSION S
WHERE  SCHEMANAME NOT IN ('RDSADMIN', 'SYS', 'rdsmon','rdshm')
   AND S.TYPE != 'BACKGROUND'
   AND LOGON_TIME < (SYSDATE - 5/ (24 * 60));

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
                    WHERE   STATUS = 'ACTIVE'
                        AND SCHEMANAME NOT IN ('RDSADMIN', 'SYS', 'rdsmon','rdshm')
                        AND TYPE != 'BACKGROUND'
                        AND USERNAME IS NOT NULL
                        AND LOGON_TIME < (SYSDATE - 4/ (24 * 60)) 
                        AND USERNAME = UPPER('&USER')) --user especifico
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

--FINALIZAR SESSION NO RDS
begin rdsadmin.rdsadmin_util.kill
(sid => 1318, serial => 42668);
end;
alertl
--BLOQUEAR USER
 select username           as usuario
, account_status AS status
, created                      as data_de_criacao
, default_tablespace     as  tablespace
from dba_users
where default_tablespace like 'TS%'
order by username;

alter user <nome_do_usuário> account lock;
alter user <nome_do_usuário> account unlock;


--TRIGGER AFETER LOGON

--Desconectar uma sessão
rdsadmin.rdsadmin_util.disconnect

--Como cancelar uma instrução SQL em uma sessão
rdsadmin.rdsadmin_util.cancel

-----CALIBRATE IO
DECLARE
lat INTEGER;
iops INTEGER;
mbps INTEGER;

BEGIN
DBMS_RESOURCE_MANAGER.CALIBRATE_IO (1, 10, iops,mbps,lat);
--insert into CALIBRATE_REPORT  select * from DBA_RSRC_IO_CALIBRATE;

DBMS_OUTPUT.PUT_LINE ('MAX_IOPS = ' || iops);
DBMS_OUTPUT.PUT_LINE ('LATENCY = ' || lat);
DBMS_OUTPUT.PUT_LINE ('MAX_MBPS = ' || mbps);
end;


--verificar alert logs no rds aws
SELECT message_text FROM alertlog order by originating_timestamp desc;

select message_text, trunc(originating_timestamp),count (*) from alertlog where message_text like '%Checkpoint not complete%' group by message_text,trunc(originating_timestamp);

SELECT originating_timestamp,message_text FROM alertlog where  message_text like '%PGA memory used by the instance exceeds PGA_AGGREGATE_LIMIT%' order by originating_timestamp desc;

SELECT originating_timestamp,error_instance_id,problem_key,MESSAGE_TEXT FROM alertlog where  problem_key is not null order by originating_timestamp desc;

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

SELECT TABLESPACE_NAME, ROUND(SUM(BYTES)/(1024*1024*1024),2) SUM_GB, ROUND(MAXBYTES/(1024*1024*1024),2) MAX_GB, AUTOEXTENSIBLE FROM DBA_DATA_FILES GROUP BY TABLESPACE_NAME, MAXBYTES,AUTOEXTENSIBLE;

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

SELECT
    table_name,
    num_rows,
    data_gb,
    indx_gb,
    lob_gb,
    total_gb
FROM
    ( SELECT
            data.table_name,
            num_rows,
            nvl(data_gb, 0)                                                            data_gb,
            nvl(indx_gb, 0)                                                            indx_gb,
            nvl(lob_gb, 0)                                                             lob_gb,
            nvl(data_gb, 0) + nvl(indx_gb, 0) + nvl(lob_gb, 0)                         total_gb
        FROM
            ( SELECT
                    a.table_name,
                    a.num_rows,
                    round(SUM(b.bytes) / 1024 / 1024 / 1024,3) AS data_gb
              FROM  dba_tables   a,dba_segments b
                WHERE a.table_name = b.segment_name
                  AND a.owner = b.owner
                  AND a.owner = 'STO_424_PRODUCAO'
                  AND b.segment_type = 'TABLE'
                  AND a.table_name IN ('MXSINTEGRACAOPEDIDO','MXSINTEGRACAOCLIENTE','MXSHISTORICOCRITICA','ERP_MXSLOGRCA','ERP_MXSDOCELETRONICO','MXSHISTORICOCOMPROMISSOS')
                GROUP BY a.table_name,a.num_rows) data,
            ( SELECT
                    a.table_name,
                    round(SUM(b.bytes / 1024 / 1024 / 1024),2) AS indx_gb
                FROM dba_indexes  a, dba_segments b
                WHERE a.index_name = b.segment_name
                    AND a.owner = b.owner
                    AND b.owner = 'STO_424_PRODUCAO'
                    AND b.segment_type = 'INDEX'
                    AND a.table_name IN ('MXSINTEGRACAOPEDIDO','MXSINTEGRACAOCLIENTE','MXSHISTORICOCRITICA','ERP_MXSLOGRCA','ERP_MXSDOCELETRONICO','MXSHISTORICOCOMPROMISSOS')
                GROUP BY a.table_name)indx,
            ( SELECT
                    a.table_name,
                    round(SUM(b.bytes / 1024 / 1024 / 1024),2) AS lob_gb
                FROM dba_lobs a,dba_segments b
                WHERE a.segment_name = b.segment_name
                  AND a.owner = b.owner
                    AND b.owner = 'STO_424_PRODUCAO'
                    AND a.table_name IN ('MXSINTEGRACAOPEDIDO','MXSINTEGRACAOCLIENTE','MXSHISTORICOCRITICA','ERP_MXSLOGRCA','ERP_MXSDOCELETRONICO','MXSHISTORICOCOMPROMISSOS')
                GROUP BY  a.table_name) lob_gb
 WHERE data.table_name = indx.table_name (+)
   AND data.table_name = lob_gb.table_name (+)
    )
ORDER BY table_name;

SELECT   ts.tablespace_name
  , 'SQLDEV:GAUGE:0:100:0:0:'
    ||NVL ( ROUND ( ( ( datafile.bytes - NVL ( freespace.bytes, 0 ) ) / datafile.bytes ) * 100, 2 ), 0 ) percent_used
  , ROUND ( ( ( datafile.bytes         - NVL ( freespace.bytes, 0 ) ) / datafile.bytes ) * 100, 2 ) PCT_USED
  , datafile.bytes                     / 1024 / 1024 allocated
  , ROUND ( datafile.bytes             / 1024 / 1024 - NVL ( freespace.bytes, 0 ) / 1024 / 1024, 2 ) used
  , ROUND ( NVL ( freespace.bytes, 0 )  / 1024 / 1024, 2 ) free
  , datafile.datafiles
  FROM dba_tablespaces ts
  , (SELECT   tablespace_name
      , SUM ( bytes ) bytes
      FROM dba_free_space
      GROUP BY tablespace_name
    ) freespace
  , (SELECT   COUNT ( 1 ) datafiles
      , SUM ( bytes ) bytes
      , tablespace_name
      FROM dba_data_files
      GROUP BY tablespace_name
    ) datafile
  WHERE freespace.tablespace_name (+) = ts.tablespace_name
  AND datafile.tablespace_name (+)   = ts.tablespace_name
  ORDER BY NVL ( ( ( datafile.bytes - NVL ( freespace.bytes, 0 ) ) / datafile.bytes ), 0 ) DESC

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

--VERIFICAR OBJETOS SEGMENTLOBS
-- https://smarttechways.com/2018/07/27/find-table-name-for-lob-objects-segment-in-oracle/
--https://aws.amazon.com/pt/premiumsupport/knowledge-center/rds-oracle-resize-tablespace/
select * from
(select owner,segment_name||'~'||partition_name segment_name,segment_type,bytes/(1024*1024*1024) size_m
from dba_segments
ORDER BY BLOCKS desc) where rownum < 11;

select DISTINCT l.table_name,l.owner,l.segment_name,trunc(sum(s.bytes)/1024/1024/1024,2)  size_m
from dba_extents e, dba_lobs l,dba_segments s
where e.owner = l.owner
and e.segment_name = l.segment_name
and e.segment_name = s.SEGMENT_NAME
and e.segment_type = 'LOBSEGMENT'
group by l.table_name,l.owner,l.segment_name
order by size_m desc;


ACCEPT SCHEMA PROMPT 'Table Owner: '
ACCEPT TABNAME PROMPT 'Table Name:  '
SELECT
 (SELECT TRUNC (SUM(S.BYTES)/1024/1024/1024,2)                                                                                             -- The Table Segment size
  FROM DBA_SEGMENTS S
  WHERE S.OWNER = UPPER('&SCHEMA') AND
       (S.SEGMENT_NAME = UPPER('&TABNAME'))) +b
 (SELECT SUM(S.BYTES)                                                                                                 -- The Lob Segment Size
  FROM DBA_SEGMENTS S, DBA_LOBS L
  WHERE S.OWNER = UPPER('&SCHEMA') AND
       (L.SEGMENT_NAME = S.SEGMENT_NAME AND L.TABLE_NAME = UPPER('&TABNAME') AND L.OWNER = UPPER('&SCHEMA'))) +
 (SELECT TRUNC (SUM(S.BYTES)/1024/1024/1024,2)                                                                                        -- The Lob Index size
  FROM DBA_SEGMENTS S, DBA_INDEXES I
  WHERE S.OWNER = UPPER('&SCHEMA') AND
       (I.INDEX_NAME = S.SEGMENT_NAME AND I.TABLE_NAME = UPPER('&TABNAME') AND INDEX_TYPE = 'LOB' AND I.OWNER = UPPER('&SCHEMA')))
  "TOTAL TABLE SIZE"
FROM DUAL;

select trunc(sum(bytes)/1024/1024/1024,2) "GB", s.segment_name, s.segment_type,S.OWNER
from dba_lobs l, dba_segments s
where s.segment_type = 'LOBSEGMENT'
and l.table_name = 'MXSHISTORICOCRITICA'
and s.segment_name = l.segment_name
group by s.segment_name,s.segment_type,s.owner ORDER BY sum(bytes) DESC;

SELECT a.tablespace_name,
        trunc(b.used_percent, 2) used_percent,
          trunc(b.used_space * a.block_size/1024/1024, 2) used_space_MB,
            c.free_mb,
           trunc(b.tablespace_size * a.block_size/1024/1024, 2) tablespace_max_size_MB 
FROM dba_tablespaces a,
      dba_tablespace_usage_metrics b,
                                    
  (SELECT tablespace_name,
          SUM (bytes) / 1024 / 1024 free_mb 
   FROM dba_free_space 
   GROUP BY tablespace_name) c 
WHERE a.tablespace_name = b.tablespace_name 
  AND b.tablespace_name = c.tablespace_name 
  AND a.contents = 'PERMANENT' 
  AND a.tablespace_name = 'TS_EASY_2218_PRODUCAO';
  
  
SELECT SPACE_ALLOCATED_MB,
        SPACE_USED_MB,
        SPACE_ALLOCATED_MB - SPACE_USED_MB SPACE_RECLAIMABLE_MB 
FROM 
  ( SELECT 
     (SELECT round(s.bytes/1024/1024, 2) MB
      FROM dba_segments s
      JOIN dba_lobs l USING (OWNER,
                             segment_name) 
      WHERE l.table_name = 'MXSHISTORICOCRITICA'
        AND OWNER='EASY_2218_PRODUCAO') SPACE_ALLOCATED_MB,
              
     (SELECT round(nvl((sum(dbms_lob.getlength(CRITICA))),0)/1024/1024, 2) MB
      FROM EASY_2218_PRODUCAO.MXSHISTORICOCRITICA) SPACE_USED_MB 
   FROM DUAL);

---MXSHISTORICOCRITICA
create table mxshistoricocritica_bkp as select * from mxshistoricocritica;

truncate table mxshistoricocritica;
ALTER TABLE mxshistoricocritica MODIFY (ID NUMBER  GENERATED BY DEFAULT AS IDENTITY); 
insert into mxshistoricocritica select * from mxshistoricocritica_bkp;

select max(id) from mxshistoricocritica;
ALTER TABLE mxshistoricocritica MODIFY (ID NUMBER  GENERATED ALWAYS AS IDENTITY (START WITH 2735077 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP NOSCALE)); 

ALTER TABLE mxshistoricocritica MOVE LOB(CRITICA) STORE AS (TABLESPACE TS_CPSOUZA_2789_PRODUCAO);
----------------------------
  

select  b.owner,B.TABLE_NAME,a.blocks, b.blocks hwm, b.empty_blocks  from  dba_segments a, dba_tables b  where  a.segment_name=b.table_name and b.table_name='MXSHISTORICOCRITICA' AND B.OWNER = 'EASY_2218_PRODUCAO';


SELECT a.file_id,
a.file_name,
ceil((nvl(hwm, 1)*&&blksize)/1024) smallest,
ceil(blocks*&&blksize/1024) currsize,
ceil(blocks*&&blksize/1024) -  ceil((nvl(hwm, 1)*&&blksize)/1024) savings
FROM dba_data_files a, 
(select file_id, max(block_id+blocks-1) hwm
from dba_extents where owner='DESTRO_1876_HOMOLOG'
group by file_id) b
where a.file_id = b.file_id;

select t3.*
      from (select t1.table_name
              from all_tables t1, all_tab_columns t2
             where t1.owner ='EASY_2218_PRODUCAO'
               and t1.tablespace_name = 'TS_EASY_2218_PRODUCAO'
               and t1.owner=t2.owner
               and t1.table_name=t2.table_name
          group by t1.table_name
            having sum(decode(t2.data_type,'LONG',1,0))=0
            order by t1.table_name) t3
 left join dba_indexes t4
        on t3.table_name=t4.table_name
       and t4.owner='EASY_2218_PRODUCAO'
       and t4.tablespace_name='TS_EASY_2218_PRODUCAO'
  group by t3.table_name
    having sum(nvl(case when index_type like 'FUNCTION%' then 1 else 0 end,0))=0;
  

--VERIFICAR DADOS DA INSTANCIA
select decode(instr(host_name,'.'),0,host_name,
 substr(host_name,1,instr(host_name,'.')-1)) 
host_name,
 instance_name,d.name dbname, user,
 i.status,to_char(startup_time, 'dd/mm/yy 
hh24:mi:ss') startup_time,
 version, logins, d.open_mode
from v$instance i, v$database d;
--verificar os eventos do “redo log buffer”.
select
     event                            "Evento" ,
     sum(total_waits)                 "Numero de Esperas" ,
     avg(average_wait)/100            "Media de Espera (Segundos)"
     from
       v$session_event
    where
       average_wait > 0
    and event in
   (
      'Log archive I/O','log buffer space','log file sync','log file parallel write','log file sequential read','log file single write'
      ,'Log file init write','log file switch (archiving needed)','log file switch (checkpoint incomplete)','log file switch (clearing log file)'
      ,'log file switch completion','log file switch (private strand flush incomplete)','log switch/archive','log write(even)','log write(odd)'
   )
   group by event
order by 3 desc;

--STATUS DO REDO LOG
select group#,thread#,sequence#,bytes/1024/1024 mbytes,
 members,archived,status,first_change#,
 to_char(first_time,'dd/mm/yyyy hh24:mi:ss') first_time
from v$log;

select substr(lf.member,instr(lf.member,'\',-1)+
 instr(lf.member,'/',-1)+
 instr(lf.member,']',-1)+1) file_name,
 l.bytes/1024/1024 tam,
 l.thread#, l.status,first_change#,
 to_char(first_time,'dd/mm/yyyy hh24:mi:ss') first_time
from v$logfile lf,v$log l
where lf.group# = l.group#
order by lf.member;

SELECT GROUP#, THREAD#, SEQUENCE#, BYTES,
MEMBERS, ARCHIVED,
 STATUS, FIRST_CHANGE#, FIRST_TIME
 FROM V$LOG;

 select trunc(completion_time,’DD’), deleted, count(*)
from v$archived_log
group by trunc(completion_time,’DD’), deleted
order by 1 desc;

SELECT GROUP#, STATUS, MEMBER FROM V$LOGFILE;
--WAITS do banco no momento atual
SELECT SID, EVENT, SECONDS_IN_WAIT FROM V$SESSION_WAIT ORDER BY SECONDS_IN_WAIT;

select sid, event, seconds_in_wait, state
from v$session_wait
where event like '%log%'
order by seconds_in_wait;
/*Se estes eventos aparecerem muito na V$SESSION_WAIT, certamente há um problema de I/O no Banco de Dados
  async disk IO
  control file parallel write
  control file sequential read
  db file parallel write
  db file scattered read =  Um Full Table Scan está ocorrendo
  db file sequential read = Leitura de índice
  direct path read
  direct path write
  log file parallel write
  log file sync*/

--LIMPAR CACHE DE DADOS (LB)
alter system flush buffer_cache;

--LIMPAR SHARED POOL
alter system flush shared_pool;

select ADDRESS, HASH_VALUE from V$SQLAREA where sql_text like '%1 from dual';

--LIMPAR APENAS UMA CONSULTA
https://www.oraclehome.com.br/2013/09/10/flush-de-uma-unica-sql-da-library-cache-shared_pool/

select ADDRESS, HASH_VALUE from V$SQLAREA where sql_text like '%1 from dual';
exec DBMS_SHARED_POOL.PURGE ('C000000760B1DB38,2866845384','C');

--VERIFICAR LIMITE DE SESIONS PARA A INSTANCIA
select a.inst_id, a.value,
        count(b.sid) as sessions_used,
        to_number(a.value) - count(b.sid) as avail_sessions
from gv$parameter a, gv$session b
where a.name='sessions' and a.inst_id=b.inst_id
group by a.inst_id, a.value

--VERIFICAR PEDIDOS USERNAME

SELECT REPLACE (RTRIM (CLIENTE, 'PRODUCAO'), '', ' - ') AS CLIENTE, QTDE_RCAS, QTDE_PED_30DIAS, QTDE_PED_ONTEM, QTDE_PED_HJ
FROM relatorio_clientes ORDER BY qtde_ped_30dias DESC;

BEGIN
RELATORIO_RCA_PED(); 
END; 

--EXECUTE JOB_TITULOS
BEGIN
EXECUTE IMMEDIATE 'BEGIN ' || 'SCHEMA' || '.JOBS.JOB_GERAR_TITULOS(); COMMIT; END;';
END;

--How to dblink

CREATE DATABASE LINK "PODC"
   CONNECT TO "MAXPODC" IDENTIFIED BY VALUES ':1'
   USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=maxsolucoes-podc.cm35ayc6yrqh.us-east-1.rds.amazonaws.com)(PORT=1521))(CONNECT_DATA=(SID=PODC)))';

CREATE DATABASE LINK DB
   CONNECT TO "C##DBA" IDENTIFIED BY oracle
   USING '10.62.38.70:1521/ORCL12C';--BD FULL
   
CREATE DATABASE LINK DB_12C
   CONNECT TO "C##DBA" IDENTIFIED BY oracle
   USING '10.62.38.70:1521/PDB_STUDY';--PDB DE OUTRO BANCO

SELECT * FROM DBA_OBJECTS@DB;
SELECT * FROM STUDY.PRODUTO@DB_12C;

EXECUTE DBMS_SESSION.CLOSE_DATABASE_LINK('LUCAS');--Kill transaction dblink
ALTER SESSION CLOSE DATABASE LINK LUCAS;--close transaction dblink   
DROP  DATABASE LINK LUCAS;--drop


select db_link, logged_on, open_cursors, in_transaction 
from v$dblink;--verificar transactions no dblink

--HOW TO dbms_datapump API
-- https://oracle-base.com/articles/misc/data-pump-api

--create user 1
create user testuser1 identified by oracle
  default tablespace TEST_TS;
--create table
create table testuser1.emp (
  empno number(4,0), 
  ename varchar2(10 byte), 
  job varchar2(9 byte), 
  mgr number(4,0), 
  hiredate date, 
  sal number(7,2), 
  comm number(7,2), 
  deptno number(2,0), 
  constraint pk_emp primary key (empno)
  );
--dml table
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7369,'SMITH','CLERK',7902,to_date('17-DEC-80','DD-MON-RR'),800,null,20);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7499,'ALLEN','SALESMAN',7698,to_date('20-FEB-81','DD-MON-RR'),1600,300,30);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7521,'WARD','SALESMAN',7698,to_date('22-FEB-81','DD-MON-RR'),1250,500,30);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7566,'JONES','MANAGER',7839,to_date('02-APR-81','DD-MON-RR'),2975,null,20);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7654,'MARTIN','SALESMAN',7698,to_date('28-SEP-81','DD-MON-RR'),1250,1400,30);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7698,'BLAKE','MANAGER',7839,to_date('01-MAY-81','DD-MON-RR'),2850,null,30);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7782,'CLARK','MANAGER',7839,to_date('09-JUN-81','DD-MON-RR'),2450,null,10);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7788,'SCOTT','ANALYST',7566,to_date('19-APR-87','DD-MON-RR'),3000,null,20);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7839,'KING','PRESIDENT',null,to_date('17-NOV-81','DD-MON-RR'),5000,null,10);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7844,'TURNER','SALESMAN',7698,to_date('08-SEP-81','DD-MON-RR'),1500,0,30);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7876,'ADAMS','CLERK',7788,to_date('23-MAY-87','DD-MON-RR'),1100,null,20);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7900,'JAMES','CLERK',7698,to_date('03-DEC-81','DD-MON-RR'),950,null,30);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7902,'FORD','ANALYST',7566,to_date('03-DEC-81','DD-MON-RR'),3000,null,20);
insert into testuser1.emp (empno,ename,job,mgr,hiredate,sal,comm,deptno) values (7934,'MILLER','CLERK',7782,to_date('23-JAN-82','DD-MON-RR'),1300,null,10);
commit;

--create directory de export e import
create or replace directory test_dir AS '/u02/dp';
grant read, write on directory test_dir to testuser1;
--import dos types
TRANSFORM=OID:N


--verificação da job do dbms_datapump
select owner_name,
       job_name,
       trim(operation) as operation,
       trim(job_mode) as job_mode,
       state,
       degree,
       attached_sessions,
       datapump_sessions
from   dba_datapump_jobs
order by 1, 2;

--EXPORT SCHEMA
SET SERVEROUTPUT ON
declare
  l_dp_handle       number;
begin
  -- Open a schema export job.
  l_dp_handle := dbms_datapump.open(
    operation   => 'EXPORT',
    job_mode    => 'SCHEMA',
    remote_link => NULL,
    job_name    => 'TESTUSER1_EXPORT',
    version     => 'LATEST');

  -- Specify the dump file name and directory object name.
  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => 'TESTUSER1.dmp',
    directory => 'TEST_DIR');

  -- Specify the log file name and directory object name.
  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => 'expdpTESTUSER1.log',
    directory => 'TEST_DIR',
    filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);

  -- Specify the schema to be exported.
  dbms_datapump.metadata_filter(
    handle => l_dp_handle,
    name   => 'SCHEMA_EXPR',
    value  => '= ''TESTUSER1''');

  dbms_datapump.start_job(l_dp_handle);

  dbms_datapump.detach(l_dp_handle);
end;
/

--CREATE USER RECEIVE IMPORT
create user testuser2 identified by oracle
default tablespace TEST_TS;
grant create session, create table, create type to testuser2;

--IMPOT DO SCHEMA
SET SERVEROUTPUT ON
declare
  l_dp_handle       number;
begin
  -- Open a schema import job.
  l_dp_handle := dbms_datapump.open(
    operation   => 'IMPORT',
    job_mode    => 'SCHEMA',
    remote_link => NULL,
    job_name    => 'TESTUSER2_IMPORT',
    version     => 'LATEST');

  -- Specify the schema to be imported.
  dbms_datapump.metadata_filter(
    handle => l_dp_handle,
    name   => 'SCHEMA_EXPR',
    value  => '= ''TESTUSER1''');

  -- Specify the dump file name and directory object name.
  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => 'TESTUSER1.dmp',
    directory => 'TEST_DIR');

  -- Specify the log file name and directory object name.
  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => 'impdpTESTUSER2.log',
    directory => 'TEST_DIR',
    filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);

  -- Perform a REMAP_SCHEMA from SCOTT to SCOTT2.
  dbms_datapump.metadata_remap(
    handle     => l_dp_handle,
    name       => 'REMAP_SCHEMA',
    old_value  => 'TESTUSER1',
    value      => 'TESTUSER2');

  dbms_datapump.start_job(l_dp_handle);

  dbms_datapump.detach(l_dp_handle);
end;
/

--SELECT EM TABELA PARA TODOS OS USERNAME
--1
create table PCPRODUT_COUNT (CLIENTE VARCHAR2(150),QTDE NUMBER(9));
--2
DECLARE
    VALOR NUMBER (9);
    CLI VARCHAR2(150);
    SELECT1 VARCHAR2(1500);
BEGIN 
    FOR DADOS IN (SELECT DISTINCT ALL_USERS.USERNAME, ALL_USERS.USERNAME || '.MXSPRODUT' AS TABELA FROM ALL_USERS INNER JOIN all_tables ON (ALL_USERS.USERNAME = all_tables.OWNER) WHERE all_tables.table_name = 'MXSPRODUT' AND USERNAME LIKE '%PRODUCAO%') LOOP
		SELECT1 :=
            'SELECT ''[USUARIO]'' AS CLIENTE, COUNT (1) AS QTDE FROM [TABELA]';
        SELECT1 := REPLACE (REPLACE (SELECT1, '[USUARIO]', DADOS.USERNAME), '[TABELA]', DADOS.TABELA);
		EXECUTE IMMEDIATE SELECT1 INTO CLI, VALOR;		
        INSERT INTO PCPRODUT_COUNT (CLIENTE,QTDE) VALUES (CLI,VALOR);
        COMMIT;
    END LOOP;
END;
--3
select * from PCPRODUT_COUNT ORDER BY QTDE DESC;

--(POSTGREE)
--https://codefibershq.com/blog/useful-postgresql-pgsql-queries-commands-and-snippets
--https://dbaclass.com/postgres-db-scripts/

> Identificar e finalizar query
select * from pg_stat_activity where "usename"= 'maxadmin' and state = 'active' AND QUERY LIKE '%SELECT c.%';
select 'SELECT pg_terminate_backend('||pid||');' from pg_stat_activity where "usename"= 'maxadmin' and state = 'active' AND QUERY LIKE '%SELECT c.%';

> Verificar oferta de produtos por ambiente
select l."CodigoCliente",a."Schema",D."Nome" as "BD",a."Alias" as "Ambiente",l."QuantidadeLicenca",o."Descricao",c."RazaoSocial"
from "Licenca" l 
left join "Oferta" o on (l."CodigoOferta" = o."Codigo") 
left join "Cliente" c ON  (l."CodigoCliente" = c."Codigo" )
left JOIN "Ambiente" a ON (c."Codigo" = a."CodigoCliente")
lefT join "Conexao" d ON (d."Codigo" = A."CodigoConexao")
where l."Status" ='A'
and c."Status" ='A'
and l."CodigoCliente" not in (1684,1688,1704)
and c."RazaoSocial" not like 'Máxima%'
order by c."Codigo" ;

select 
	c."CodigoMaxima",
	c."RazaoSocial",
	a."Alias" as "AmbienteNuvem",
	a."Schema",
	d."Nome" as "BD",
	string_agg(O."Descricao", ',') as "Solucao"
from "Licenca" l
left join "Oferta" o on (l."CodigoOferta" = o."Codigo")
left join "Cliente" c on (l."CodigoCliente" = c."Codigo" )
left join "Ambiente" a on (c."Codigo" = a."CodigoCliente")
left join "Conexao" d on (d."Codigo" = A."CodigoConexao")
where c."Status" = 'A'
  and  a."Schema" like '%_PRODUCAO%'
  and d."Descricao" like 'Oracle US%'
group by
	c."CodigoMaxima",
	c."RazaoSocial",
	a."Alias",
	a."Schema",
	d."Nome"
order by
	d."Nome",
	a."Schema" ;
	
select * from "Conexao" c 


> Validar versões por ambiente
SELECT A."Alias",
B."CodigoAmbiente",
A."Schema",
C."Nome" as "BD",
B."IntegracaoExtrator",
B."IntegracaoPV",
D."LinkAcesso" as "Server Base",
D."LinkAcessoPDV" as "Server PDV",
D."Versao"
FROM "Ambiente" A
INNER JOIN "Extrator" B ON B."CodigoAmbiente" = A."Codigo"
INNER JOIN "Conexao" C ON C."Codigo" = A."CodigoConexao"
INNER JOIN "RotinaVersao" D ON A."Codigo" = D."CodigoAmbiente"
WHERE D."Versao" like '3.%'
AND D."CodigoRotina" = 21;

> Validar versões por ambiente
SELECT 
B."CodigoMaxima",
A."Alias",
A."Schema",
C."Nome" as "BD"
FROM "Ambiente" A
INNER JOIN "Conexao" C ON C."Codigo" = A."CodigoConexao"
INNER JOIN  "Cliente" B on B."Codigo" = a."CodigoCliente"
INNER JOIN "RotinaVersao" D ON A."Codigo" = D."CodigoAmbiente"
WHERE D."CodigoRotina" = 29;

SELECT A."Alias",
B."CodigoAmbiente",
A."Schema",
C."Nome" as "BD",
B."IntegracaoExtrator",
B."IntegracaoPV"
FROM "Ambiente" A
INNER JOIN "Extrator" B ON B."CodigoAmbiente" = A."Codigo"
INNER JOIN "Conexao" C ON C."Codigo" = A."CodigoConexao"
WHERE A."CodigoConexao" = 49;--banco MINO

SELECT 
C."Nome" as "BD",
count (*)
FROM "Ambiente" A
INNER JOIN "Conexao" C ON C."Codigo" = A."CodigoConexao"
where A."Schema" like '%PRODUCAO%' --or A."Schema" like '%HOMOLOG%'
and C."Descricao" like 'Oracle US%'
group by C."Nome"
order by C."Nome";

SELECT
B."CodigoMaxima" "codcli",
B."Nome" "Nome Cliente",
D."Descricao" "Cluster",
C."Nome" as "BD",
A."OutroErp" ,
A."Unificado",
A."Schema" "SCHEMA_BD"
FROM "Ambiente" A
INNER JOIN "Conexao" C ON C."Codigo" = A."CodigoConexao"
INNER JOIN "Cliente" B on B."Codigo" = a."CodigoCliente"
INNER join "Cluster" d ON d."Codigo" = a."CodigoCluster"
where A."Schema" like '%PRODUCAO%'
and C."Descricao" like 'Oracle US%'
order by "BD","Nome Cliente"

SELECT 
A."Schema",
C."Nome" 
FROM "Ambiente" A
INNER JOIN "Conexao" C ON C."Codigo" = A."CodigoConexao"
where C."Nome" = 'DUNO'
group by A."Schema",
C."Nome" 
order by A."Schema";

--VERSÃO MAXPEDIDO
select distinct uc."CodigoCliente" "Código Cliente Nuvem", cli."CodigoMaxima" "Código Cliente Máxima", cli."Nome" "Nome Cliente", anu."Id" "Código Usuario Nuvem", anu."NormalizedUserName" "Login", u."Nome", 
versao."VersaoApk"
from "AspNetUsers" anu 
inner join "Usuario" u on u."Codigo" = anu."Id" 
inner join "UsuarioCliente" uc on uc."CodigoUsuario" = u."Codigo" 
inner join "Cliente" cli on cli."Codigo" = uc."CodigoCliente" 
inner join "Licenca" lic on lic."CodigoCliente" = uc."CodigoCliente" and lic."CodigoOferta" = 11 -- MAXPEDIDO
inner join "UsuarioAmbiente" uam on uam."CodigoUsuario" = u."Codigo" 
inner join "Ambiente" amb on amb."Codigo" = uam."CodigoAmbiente" and amb."CodigoCliente" = cli."Codigo" 
inner join (select distinct u."Codigo", rv."Versao" "VersaoApk" from "Usuario" u 
            inner join "RotinaVersaoUsuario" rvu on rvu."CodigoUsuario" = u."Codigo" 
            inner join "RotinaVersao" rv on rv."Codigo" = rvu."CodigoRotinaVersao" 
            where rv."CodigoRotina" = 21
            and rv."Versao" not like '3.2%' 
            and u."TipoUsuario" = 6) versao on versao."Codigo" = u."Codigo" 
where u."TipoUsuario" = 6 and u."Status" = true 
and u."Codigo" in (select "CodigoUsuario" from "RotinaVersaoUsuario" rvu where "CodigoRotinaVersao" in (select "Codigo" from "RotinaVersao" rv where "CodigoRotina" = 21))
and cli."Status" = 'A'
and amb."Schema" like '%PRODUCAO'
order by cli."Nome", anu."NormalizedUserName";


>Script para alterar via banco para os Integradores Extrator e PDV
DO $$DECLARE DADOS RECORD;
BEGIN
FOR DADOS IN
SELECT B."CodigoAmbiente"
FROM "Ambiente" A
INNER JOIN "Extrator" B ON B."CodigoAmbiente" = A."Codigo"
WHERE A."CodigoConexao" = 49
LOOP
UPDATE "Extrator" SET "IntegracaoExtrator" = 'http://intext-hmg.solucoesmaxima.com.br:81/api/v1/' WHERE "CodigoAmbiente" = DADOS."CodigoAmbiente";
UPDATE "Extrator" SET "IntegracaoPV" = 'https://intpdv-02.solucoesmaxima.com.br:81/api/v1/' WHERE "CodigoAmbiente" = DADOS."CodigoAmbiente";
END LOOP;
END$$;
--query running
SELECT sa.pid,
       age(now(),sa.xact_start) query_time,
       sa.usename, 
       sa.application_name, 
       sa.client_addr,
       sa.state, 
       sa.query,
       sa.wait,
       'SELECT pg_terminate_backend('||sa.pid||');' as kill
FROM pg_catalog.pg_stat_activity sa 

SELECT pid, datname, query, extract(epoch from now()) - extract(epoch from xact_start) AS duration, case
WHEN wait_event IS NULL THEN 'CPU' 
ELSE wait_event_type||':'||wait_event end wait FROM pg_stat_activity
WHERE query!=current_query() AND xact_start IS NOT NULL ORDER BY 4 DESC;


-- show number of connections
select count(*) from pg_stat_activity;

-- or
SELECT sum(numbackends) FROM pg_stat_database;

-- show running queries (> 9.2)
SELECT pid,
       age(clock_timestamp(), query_start),
       usename,
       query
FROM pg_stat_activity
WHERE query != '<IDLE>'
  AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start DESC;

-- show long running queries (> 9.2)
SELECT pid,
       now() - pg_stat_activity.query_start AS duration,
       query,
       STATE
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';

-- check autovacuum & analyze status
SELECT schemaname,
       relname,
       vacuum_count,
       last_vacuum,
       autovacuum_count
       last_autovacuum,
       last_analyze,
       last_autoanalyze
FROM pg_stat_user_tables;

-- check autovacuum & tup status (simple)
SELECT relname,
       n_tup_ins,
       n_tup_upd,
       n_tup_del,
       n_tup_hot_upd,
       n_live_tup,
       n_dead_tup,
       last_vacuum,
       last_autovacuum,
       last_autoanalyze
FROM pg_stat_all_tables
WHERE n_dead_tup > 0;

-- check autovacuum & tup status (advanced)
SELECT schemaname,
       relname,
       n_live_tup,
       n_dead_tup,
       last_autovacuum
FROM pg_stat_all_tables
ORDER BY n_dead_tup /(n_live_tup * current_setting('autovacuum_vacuum_scale_factor')::float8 + current_setting('autovacuum_vacuum_threshold')::float8) DESC

-- kill running query
SELECT pg_cancel_backend(procpid);

-- kill idle query
SELECT pg_terminate_backend(procpid);

-- vacuum command
VACUUM (VERBOSE, ANALYZE);

-- show all database users
SELECT * FROM pg_user;

-- show all locks
SELECT t.relname,
       l.locktype,
       page,
       virtualtransaction,
       pid,
       MODE,
       GRANTED
FROM pg_locks l,
     pg_stat_all_tables t
WHERE l.relation = t.relid
ORDER BY relation ASC;

-- show all tables and their size
SELECT datname, pg_size_pretty(pg_database_size(datname))
FROM pg_database
ORDER BY pg_database_size(datname) DESC;
                                                
-- show how much space tables and indexes are taking up
SELECT relname AS TABLE_NAME,
       pg_size_pretty(pg_total_relation_size(relid)) AS total,
       pg_size_pretty(pg_relation_size(relid)) AS internal,
       pg_size_pretty(pg_table_size(relid) - pg_relation_size(relid)) AS EXTERNAL,
       pg_size_pretty(pg_indexes_size(relid)) AS indexes
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- show cache hit rates (should not be less than 0.99)
SELECT sum(heap_blks_read) AS heap_read, sum(heap_blks_hit) AS heap_hit, (sum(heap_blks_hit) - sum(heap_blks_read)) / sum(heap_blks_hit) AS ratio
FROM pg_statio_user_tables;

-- show table index usage rates (should not be less than 0.99)
SELECT relname,
       100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used,
                                              n_live_tup rows_in_table
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;

-- show how many indexes are in cache
SELECT sum(idx_blks_read) AS idx_read, sum(idx_blks_hit) AS idx_hit, (sum(idx_blks_hit) - sum(idx_blks_read)) / sum(idx_blks_hit) AS ratio
FROM pg_statio_user_indexes;
                                                                                              
-- show tracking execution statistics of all SQL statements executed by a server
SELECT userid,
       dbid,
       queryid,
       query,
       calls,
       (total_time / 1000 / 60) AS total_minutes,
       (total_time/calls) AS average_time_ms,
       min_time,
       max_time,
       mean_time,
       stddev_time,
       ROWS,
       shared_blks_hit,
       shared_blks_read,
       shared_blks_dirtied,
       shared_blks_written,
       local_blks_hit,
       local_blks_read,
       local_blks_dirtied,
       local_blks_written,
       temp_blks_read,
       temp_blks_written,
       blk_read_time,
       blk_write_time
FROM pg_stat_statements
ORDER BY average_time_ms DESC LIMIT 100

-- Table and index detailed stats
WITH table_stats AS
  (SELECT psut.relname,
          psut.n_live_tup,
          1.0 * psut.idx_scan / greatest(1, psut.seq_scan + psut.idx_scan) AS index_use_ratio
   FROM pg_stat_user_tables psut
   ORDER BY psut.n_live_tup DESC),
     table_io AS
  (SELECT psiut.relname,
          sum(psiut.heap_blks_read) AS table_page_read,
          sum(psiut.heap_blks_hit) AS table_page_hit,
          sum(psiut.heap_blks_hit) / greatest(1, sum(psiut.heap_blks_hit) + sum(psiut.heap_blks_read)) AS table_hit_ratio
   FROM pg_statio_user_tables psiut
   GROUP BY psiut.relname
   ORDER BY table_page_read DESC),
     index_io AS
  (SELECT psiui.relname,
          psiui.indexrelname,
          sum(psiui.idx_blks_read) AS idx_page_read,
          sum(psiui.idx_blks_hit) AS idx_page_hit,
          1.0 * sum(psiui.idx_blks_hit) / greatest(1.0, sum(psiui.idx_blks_hit) + sum(psiui.idx_blks_read)) AS idx_hit_ratio
   FROM pg_statio_user_indexes psiui
   GROUP BY psiui.relname,
            psiui.indexrelname
   ORDER BY sum(psiui.idx_blks_read) DESC)
SELECT ts.relname,
       ts.n_live_tup,
       ts.index_use_ratio,
       ti.table_page_read,
       ti.table_page_hit,
       ti.table_hit_ratio,
       ii.indexrelname,
       ii.idx_page_read,
       ii.idx_page_hit,
       ii.idx_hit_ratio
FROM table_stats ts
LEFT OUTER JOIN table_io ti ON ti.relname = ts.relname
LEFT OUTER JOIN index_io ii ON ii.relname = ts.relname
ORDER BY ti.table_page_read DESC,
         ii.idx_page_read DESC;
                                                   
-- Number of table rows per table
SELECT 
  nspname AS schemaname,relname,reltuples
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE 
  nspname NOT IN ('pg_catalog', 'information_schema') AND
  relkind='r' 
ORDER BY reltuples DESC;

select
    table_name,
    pg_size_pretty(pg_total_relation_size(table_name))AS table_size,
    pg_size_pretty(pg_relation_size(table_name)) AS table_data_size,
    pg_size_pretty(pg_indexes_size(table_name)) AS table_index_size,
    (SELECT reltuples FROM pg_class WHERE relname = table_name) AS row_count
FROM
    information_schema.tables
WHERE
    table_type = 'BASE TABLE' AND
    table_schema = 'public'
ORDER BY
    row_count desc;

-- Locks: https://jaketrent.com/post/find-kill-locks-postgres
-- Listing locks
SELECT pid
FROM pg_locks l
JOIN pg_class t ON l.relation = t.oid
WHERE t.relkind = 'r'
  AND t.relname = 'search_hit';
  
-- Matching queries with locks
SELECT pid,
       state,
       usename,
       query,
       query_start
FROM pg_stat_activity
WHERE pid in
    (SELECT pid
     FROM pg_locks l
     JOIN pg_class t ON l.relation = t.oid
     AND t.relkind = 'r'
     WHERE t.relname = 'search_hit' );

-- Killing locks
SELECT pg_cancel_backend(11929);

-- or
SELECT pg_terminate_backend(11929);

select pid 
from pg_locks l 
join pg_class t on l.relation = t.oid 
where t.relkind = 'r'
and t.relname = 'search_hit';
                                                   
-- Permissions management                                              
REVOKE SELECT ON "table_name" FROM user_name;
\z table_name
GRANT SELECT (id, name, ...) ON "table_name" TO user_name;

-- Replication management

-- On primary
select * from pg_stat_replication;

-- On replica
select * from pg_stat_wal_receiver;

--Uteis
SELECT pid, usename, age(now(),xact_start) query_time, query FROM pg_stat_activity WHERE state='active';
SELECT sa.pid,age(now(),sa.xact_start) query_time,sa.usename, sa.application_name, sa.client_addr, sa.state, sa.query 
FROM pg_catalog.pg_stat_activity sa ;
SELECT count(*) FROM pg_stat_activity WHERE state='idle';

SELECT schemaname, relname, n_live_tup,n_dead_tup, last_autoanalyze, last_analyze, last_autovacuum, last_vacuum,
autovacuum_count+vacuum_count vacuum_count, analyze_count+autoanalyze_count analyze_count 
FROM pg_stat_user_tables
ORDER BY 5 DESC;

SELECT pid, datname, query, extract(epoch from now()) - extract(epoch from xact_start) AS duration, case
WHEN wait_event IS NULL THEN 'CPU' 
ELSE wait_event_type||':'||wait_event end wait FROM pg_stat_activity
WHERE query!=current_query() AND xact_start IS NOT NULL ORDER BY 4 DESC;

select * FROM pg_catalog.pg_stat_activity;

SELECT sa.pid,
       age(now(),sa.xact_start) query_time,
       sa.usename, 
       sa.application_name, 
       sa.client_addr,
       sa.state, 
       sa.query,
       sa.wait_event,
       sa.wait_event_type ,
       'SELECT pg_terminate_backend('||sa.pid||');' as kill
FROM pg_catalog.pg_stat_activity sa
where QUERY not in ('SHOW TRANSACTION ISOLATION LEVEL','SET extra_float_digits = 3','SET SESSION CHARACTERISTICS AS TRANSACTION READ WRITE');

SELECT userid::regrole, dbid, query,calls
FROM pg_stat_statements 
ORDER BY blk_read_time + blk_write_time desc  
LIMIT 20;  


--Fragment
SELECT
  current_database(), schemaname, tablename, /*reltuples::bigint, relpages::bigint, otta,*/
  ROUND((CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages::float/otta END)::numeric,1) AS tbloat,
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END AS wastedbytes,
  iname, /*ituples::bigint, ipages::bigint, iotta,*/
  ROUND((CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages::float/iotta END)::numeric,1) AS ibloat,
  CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes
FROM (
  SELECT
    schemaname, tablename, cc.reltuples, cc.relpages, bs,
    CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)) AS otta,
    COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
  FROM (
    SELECT
      ma,bs,schemaname,tablename,
      (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
      (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM (
      SELECT
        schemaname, tablename, hdr, ma, bs,
        SUM((1-null_frac)*avg_width) AS datawidth,
        MAX(null_frac) AS maxfracsum,
        hdr+(
          SELECT 1+count(*)/8
          FROM pg_stats s2
          WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
        ) AS nullhdr
      FROM pg_stats s, (
        SELECT
          (SELECT current_setting('block_size')::numeric) AS bs,
          CASE WHEN substring(v,12,3) IN ('8.0','8.1','8.2') THEN 27 ELSE 23 END AS hdr,
          CASE WHEN v ~ 'mingw32' THEN 8 ELSE 4 END AS ma
        FROM (SELECT version() AS v) AS foo
      ) AS constants
      GROUP BY 1,2,3,4,5
    ) AS foo
  ) AS rs
  JOIN pg_class cc ON cc.relname = rs.tablename
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = rs.schemaname AND nn.nspname <> 'information_schema'
  LEFT JOIN pg_index i ON indrelid = cc.oid
  LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
) AS sml
ORDER BY tbloat DESC;


--Monitorar transações da tabela
SELECT relname, 
       n_live_tup "all rows",
       n_tup_ins "rows insert",
       n_tup_upd "rows update",
       n_tup_del "rows delete",
       n_dead_tup "dead tuples",
       last_analyze,
       now() "sysdate"
FROM pg_stat_all_tables
--where relname = 'prow_usuario_ponto_venda'
ORDER BY n_dead_tup  desc;

--Limpar stats da tabela
SELECT pg_stat_reset_single_table_counters('prow_usuario_ponto_venda'::regclass);

--Coletar stats
VACUUM(FULL, VERBOSE, ANALYZE) public.PROW_USUARIO_PONTO_VENDA;
analyze public.PROW_USUARIO_PONTO_VENDA;

--coletar ddl do postgres
select CONCAT( '{"columns": [', coalesce(cols_metadata, ''), '], "indexes": [', coalesce(indexes_metadata, ''), '], "tables":[', coalesce(tbls_metadata, ''), '], "server_name": "', '', '", "version": "', '', '"}' ) as " " from ( select array_to_string( array_agg( CONCAT( '{"schema":"', cols.table_schema, '","table":"', cols.table_name, '","name":"', cols.column_name, '","type":"', replace(cols.data_type, '"', ''), '","nullable":', case when(cols.IS_NULLABLE = 'YES') then 'true' else 'false' end, ',"collation":"', coalesce(cols.COLLATION_NAME, ''), '"}' ) ), ',' ) as cols_metadata from information_schema.columns cols where cols.table_schema not in ('information_schema', 'pg_catalog') ) cols, ( select array_to_string( array_agg( CONCAT( '{"schema":"', schema_name, '","table":"', table_name, '","name":"', index_name, '","column":"', replace(col_name :: text, '"', E'\"'), '","index_type":"', index_type, '","cardinality":', cardinality, ',"size":', index_size, ',"unique":', is_unique, ',"direction":"', lower(direction), '"}' ) ), ',' ) as indexes_metadata from ( select tnsp.nspname as schema_name, trel.relname as table_name, pg_relation_size(tnsp.nspname || '.' || trel.relname) as index_size, irel.relname as index_name, am.amname as index_type, a.attname as col_name, (case when i.indisunique = true then 'true' else 'false' end) as is_unique, irel.reltuples as cardinality, 1 + Array_position(i.indkey, a.attnum) as column_position, case o.OPTION & 1 when 1 then 'DESC' else 'ASC' end as direction from pg_index as i join pg_class as trel on trel.oid = i.indrelid join pg_namespace as tnsp on trel.relnamespace = tnsp.oid join pg_class as irel on irel.oid = i.indexrelid join pg_am as am on irel.relam = am.oid cross join lateral unnest (i.indkey) with ordinality as c (colnum, ordinality) left join lateral unnest (i.indoption) with ordinality as o (option, ordinality) on c.ordinality = o.ordinality join pg_attribute as a on trel.oid = a.attrelid and a.attnum = c.colnum where tnsp.nspname not like 'pg_%' group by tnsp.nspname, trel.relname, irel.relname, am.amname, i.indisunique, irel.reltuples, a.attname, array_position(i.indkey, a.attnum), o.OPTION order by column_position ) x ) indexes_metadata, ( select array_to_string( array_agg( CONCAT( '{', '"schema":"', TABLE_SCHEMA, '",', '"table":"', TABLE_NAME, '",', '"rows":', coalesce( ( select s.n_live_tup from pg_stat_user_tables s where tbls.TABLE_SCHEMA = s.schemaname and tbls.TABLE_NAME = s.relname ), 0 ), ', "type":"', TABLE_TYPE, '",', '"engine":"",', '"collation":""}' ) ), ',' ) as tbls_metadata from information_schema.tables tbls where tbls.TABLE_SCHEMA not in ('information_schema', 'pg_catalog') ) tbls, ( select array_to_string( array_agg( CONCAT( '{"name":"', conf.name, '","value":"', replace(conf.setting, '"', E'\"'), '"}' ) ), ',' ) as config_metadata from pg_settings conf ) config;

--ALTERAÇÃO PREFIXO
/* ETAPA POSTGRES */

-- Modificar a coluna Nome (Caso esteja incorreto) colocando o prefixo correto
select * from "Usuario" u where u."Codigo" in (select "Id" from "AspNetUsers" anu where upper(anu."NormalizedUserName") like 'JCDISTR%')

-- Modificar a coluna NormalizedUserName (SEMPRE VALOR MAIÚSCULO) e a coluna UserName (CASE IGUAL CADASTRADO NO PREFIXOLOGIN do CLIENTE) usando o prefixo correto
select * from "AspNetUsers" anu where upper(anu."NormalizedUserName") like 'JCDISTR%'

-- Modificar o prefixo do cliente 
select * from "Cliente" c where c."CodigoMaxima" = 2844

update "Usuario" set "Nome" = 'HIPERVENDAS.SysMax' where "Codigo" = 74159;
update "AspNetUsers" set "NormalizedUserName" = replace("NormalizedUserName",'HIPERVENDA.','HIPERVENDAS.') where upper("NormalizedUserName") like 'HIPERVENDA%';
update "Cliente" set "PrefixoLogin" = 'HIPERVENDAS' where "CodigoMaxima" = 2138;


delete from "UsuarioAmbiente" where "CodigoUsuario" in (select "Id"  from "AspNetUsers" anu where upper(anu."NormalizedUserName") like 'YANGZI%' and "Id" <> 72283);
delete from "Usuario" u where u."Codigo" in (select "Id" from "AspNetUsers" anu where upper(anu."NormalizedUserName") like 'YANGZI%') and "Codigo" <> 72283;
delete  from "AspNetUsers" anu where upper(anu."NormalizedUserName") like 'YANGZI%' and "Id" <> 72283;

/* ETAPA ORACLE */

-- Alterar coluna LOGIN e coluna NOME (Caso esteja incorreto) colocando o prefixo correto 
edit mxsusuarios;
UPDATE MXSUSUARIOS SET LOGIN = REPLACE(LOGIN,'ADICAO.','ABC.');

-- Alterar coluna LOGIN e coluna NOME (Caso esteja incorreto) colocando o prefixo correto
edit maximausuarios;
UPDATE maximausuarios SET LOGIN = REPLACE(LOGIN,'ADICAO.','ABC.') where codigo = 64241;



--DECRYPT SENHA BD WINTHOR
 - select NOME_GUERRA, decrypt(senhabd,usuariobd) from pcempr where matricula=1;

--CLUSTER E BD
select * from "Ambiente";

select c."Nome" ,a."Alias",a."Schema",a."CodigoCluster",d."Descricao"  from "Ambiente" a
inner join "Conexao" c on (a."CodigoConexao" = c."Codigo")
inner join "Cluster" d on (d."Codigo" = a."CodigoCluster") 
where c."Codigo" in (select e."Codigo" from "Conexao" e where e."Nome" like '%RITA%')
order by c."Nome";

--MYSQL
-> https://www.mysqltutorial.org/mysql-administration/

SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST ORDER BY DB DESC;
SHOW PROCESSLIST;
show full processlist;
kill <ID>;
/*
ID: Representa a identificação do processo no banco de dados;
User: Usuário conectado no banco. Além dos usuários, pode exibir os seguintes valores:
system user: Atividade que está sendo executada internamente em uma thread, pelo próprio MySQL. Neste caso, não possui informações na coluna Host (veja abaixo);
unauthenticated user: Está ligada a uma thread que foi iniciada com um cliente (client), mas que ainda não foi autenticada;
event_scheduler: Referente a threads de monitoramento agendado;
Host: Hostname do cliente que está conectado. Geralmente são exibidos no formato hostname:porta;
DB: Indica qual banco de dados foi selecionado pelo usuário. Exibe null se nenhum foi selecionado;
Command: O tipo de comando que está sendo executado no momento. Não é a query em si, mas o tipo de comando, que pode ser um dos valores abaixo:
Binlog Dump: Thread no servidor principal (master), indicando que logs binarios estão sendo enviados para um servidor secundario (slave);
Change user: A thread está executando comando para troca de usuário;
Close stmt: A thread está fechando um statement;
Connect: Um servidor de replicação (slave) está conectado ao principal (master);
Connect Out: Um servidor de replicação (slave) está se conectando ao principal (master);
Create DB: A thread está executando um comando de criação de banco;
Daemon: Indica que a thread está trabalhando internamente para o servidor e não está disponível para clients;
Debug: Thread está gerando informações de debug;
Delayed insert: Thread é um gerenciador de inserts com delay;
Drop DB: A thread está executando um comando de remoção (drop) de banco;
Error: Indica que a thread está com problema. O manual não explica muito este item, mas me parece bastante obvio. 🙂
Execute: A thread está executando um comando (prepared statement);
Fetch: A thread está recuperando os resultados de um comando (prepared statement). (Vem após o execute);
Field List: A thread está recuperando informações referentes as colunas da tabela;
Init DB: A thread está selecionando o banco de dados padrão;
Kill: A thread está encerrando (matando) outra thread;
Long Data: A thread está recuperando um volume grande de informações ao executar um comando (prepared statement);
Ping: Thread está trabalhando em um ping que recebeu;
Prepare: Thread está preparando um comando (statement) para execução;
Processlist: A thread está providenciando as informações para o comando que mostrei logo acima;
Query: A thread está executando um statement;
Quit: Thread está sendo encerrada;
Refresh: A thread está atualizando/renovando informações de tabelas, logs, caches, reiniciando variáveis de status ou informações relativas a servidores de replicação;
Register Slave: Thread está registrando um servidor secundario (slave);
Reset stmt: A thread está reiniciando um comando (prepared statement);
Set option: A thread está definindo uma configuração para execução de comandos pelo cliente;
Shutdown: A thread está desligando o servidor;
Sleep: A thread está aguardando novos comandos;
Statistics: A thread está recuperando informações sobre o servidor;
Table Dump: A thread está executando um comando de remoção (drop) de tabela;
Time: Não utilizado.
Time: Tempo em segundos que a thread está no estado (Command) atual;
State: Exibe uma ação, evento ou status que indica o que a thread está fazendo. Esta coluna possui um número grande de valores possíveis. Basicamente, ela mostra em qual etapa do command atual ela está. Consulte o manual do MySQL (8.14.2 General Thread States) para ver uma lista completa dos valores possíveis para esta coluna;
Info: Mostra o statement que está sendo executado no momento ou NULL se não estiver executando nada. Se o comando inicial foi uma chamada para uma procedure e ela está executando um select no momento, o comando exibido será o select. No ‘modo tabela’, esta coluna exibe apenas os 100 primeiros caracteres;
*/


