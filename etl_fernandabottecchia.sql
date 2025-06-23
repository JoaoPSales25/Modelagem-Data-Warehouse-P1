-- Avaliação 02: Modelagem de Data Warehouse
-- Parte 2: 
-- Grupo:
-- Augusto Fernandes Nodari 						DRE: 121131778 
-- Henrique Almico Dias da Silva  					DRE: 124238228
-- João Pedro de Faria Sales  						DRE: 121056457 
-- Vitor Rayol Taranto                              DRE: 121063585

*
* OBJETIVO:
* Este script realiza a Extração e Carga (ETL) de dados dos sistemas operacionais (OLTP) de 6 empresas
* de aluguel de veículos para uma área de Staging centralizada. Ele é projetado para lidar com
* esquemas de banco de dados potencialmente diferentes, mapeando-os para um modelo padronizado.
*
* ESTRUTURA:
* 1.  Criação das tabelas de Staging (se não existirem).
* 2.  Limpeza (TRUNCATE) das tabelas de Staging antes da carga para garantir a reexecução.
* 3.  Carga de dados para cada tabela de Staging usando UNION ALL para consolidar as fontes.
* 4.  Especificação do agendamento de execução (em comentário, para ser configurado em ferramenta externa).
*
* PREMISSAS:
* - Existem conexões (ex: Database Links, Federated Connections) para os bancos das 6 empresas.
* Aqui, são representados pelos prefixos: empresa1, empresa2, ..., empresa6.
* - Para simplificar e garantir a idempotência deste script, a estratégia de carga na Staging é
* TRUNCATE/INSERT (carga completa). Em um ambiente de produção com alto volume, seria
* adotada uma estratégia incremental (delta load) baseada em datas de modificação.
**********************************************************************************************************************/

-- ==================================================================================================================
-- SEÇÃO 1: DEFINIÇÃO DAS TABELAS DA STAGING AREA (DDL)
-- ==================================================================================================================

-- Tabela de Staging para Pátios
DROP TABLE IF EXISTS STG_Patio;
CREATE TABLE STG_Patio (
    FonteDadosID INT NOT NULL,                     -- Identificador da empresa de origem (1 a 6)
    [cite_start]PatioID_Origem INT NOT NULL,                   -- PK da tabela Pátio na origem [cite: 42, 43]
    [cite_start]EmpresaProprietariaID_Origem INT,              -- FK para a empresa dona do pátio [cite: 8]
    NomePatio VARCHAR(255),
    EnderecoCompleto VARCHAR(500),
    TotalVagas INT,
    DataCarga TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Staging para Clientes
DROP TABLE IF EXISTS STG_Cliente;
CREATE TABLE STG_Cliente (
    FonteDadosID INT NOT NULL,
    [cite_start]ClienteID_Origem INT NOT NULL,                 -- PK da tabela Cliente na origem [cite: 50, 51]
    TipoPessoa VARCHAR(50),
    NomeRazaoSocial VARCHAR(255),
    [cite_start]CPF_CNPJ VARCHAR(20),                          -- Campo unificador para clientes [cite: 51]
    Email VARCHAR(255),
    Telefone1 VARCHAR(50),
    Endereco VARCHAR(500),
    CidadeOrigem VARCHAR(255),
    DataCarga TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Staging para Veículos (Frota)
DROP TABLE IF EXISTS STG_Veiculo;
CREATE TABLE STG_Veiculo (
    FonteDadosID INT NOT NULL,
    [cite_start]VeiculoID_Origem INT NOT NULL,                 -- PK da tabela Veiculo na origem [cite: 46, 47]
    EmpresaProprietariaID_Origem INT,              -- ID da empresa dona do veículo, inferido da sua origem
    Placa VARCHAR(7),
    Chassi VARCHAR(17),
    Marca VARCHAR(100),
    Modelo VARCHAR(100),
    Cor VARCHAR(50),
    Ano SMALLINT,
    [cite_start]TipoTransmissao VARCHAR(50),                   -- 'automatico' ou 'manual' [cite: 40]
    ArCondicionado BOOLEAN,
    [cite_start]CodigoGrupo VARCHAR(100),                      -- Vem da tabela GrupoVeiculo [cite: 44]
    [cite_start]DescricaoGrupo VARCHAR(255),                   -- Vem da tabela GrupoVeiculo [cite: 44]
    DataCarga TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Staging para Reservas
DROP TABLE IF EXISTS STG_Reserva;
CREATE TABLE STG_Reserva (
    FonteDadosID INT NOT NULL,
    [cite_start]ReservaID_Origem INT NOT NULL,                  -- PK da tabela Reserva na origem [cite: 54, 55]
    ClienteID_Origem INT,
    GrupoVeiculoID_Origem INT,
    PatioRetiradaID_Origem INT,
    PatioDevolucaoID_Origem INT,
    DataPrevistaRetirada TIMESTAMPTZ,
    DataPrevistaDevolucao TIMESTAMPTZ,
    StatusReserva VARCHAR(100),
    DataCarga TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Staging para Locações
DROP TABLE IF EXISTS STG_Locacao;
CREATE TABLE STG_Locacao (
    FonteDadosID INT NOT NULL,
    [cite_start]LocacaoID_Origem INT NOT NULL,                 -- PK da tabela Locacao na origem [cite: 56, 57]
    ReservaID_Origem INT,
    [cite_start]ClienteID_Origem INT,                          -- Obtido via JOIN com Condutor->Cliente [cite: 24]
    VeiculoID_Origem INT,
    PatioRetiradaID_Origem INT,
    PatioDevolucaoID_Origem INT,
    DataRetirada TIMESTAMPTZ,
    DataPrevistaDevolucao TIMESTAMPTZ,
    DataRealDevolucao TIMESTAMPTZ,
    KmSaida INT,
    KmChegada INT,
    [cite_start]ValorFinalCobrado DECIMAL,                     -- Obtido via JOIN com Cobranca [cite: 30]
    StatusLocacao VARCHAR(100),
    DataCarga TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ==================================================================================================================
-- SEÇÃO 2: EXECUÇÃO DOS SCRIPTS DE CARGA (ETL)
-- ==================================================================================================================

-- ------------------------------------------------------------------------------------------------------------------
-- CARGA DA TABELA STG_Patio
-- ------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE STG_Patio;
INSERT INTO STG_Patio (FonteDadosID, PatioID_Origem, EmpresaProprietariaID_Origem, NomePatio, EnderecoCompleto, TotalVagas)

[cite_start]-- Extração da Empresa 1 (Galeão), usando o esquema do projeto [cite: 43]
SELECT
    1 AS FonteDadosID,
    p.id AS PatioID_Origem,
    p.empresa_id AS EmpresaProprietariaID_Origem,
    p.nome AS NomePatio,
    p.endereco AS EnderecoCompleto,
    p.total_vagas AS TotalVagas
FROM empresa1.Patio p

UNION ALL

-- Extração da Empresa 2 (Santos Dumont), com esquema simulado diferente
SELECT
    2 AS FonteDadosID,
    p.id_patio AS PatioID_Origem,           -- Mapeamento: id_patio -> PatioID_Origem
    p.id_empresa AS EmpresaProprietariaID_Origem,
    p.nome_filial AS NomePatio,             -- Mapeamento: nome_filial -> NomePatio
    p.logradouro AS EnderecoCompleto,       -- Mapeamento: logradouro -> EnderecoCompleto
    p.capacidade AS TotalVagas              -- Mapeamento: capacidade -> TotalVagas
FROM empresa2.PatiosFiliais p               -- Mapeamento de tabela: PatiosFiliais -> Patio

-- UNION ALL ... (para as empresas 3, 4, 5 e 6)
;

-- ------------------------------------------------------------------------------------------------------------------
-- CARGA DA TABELA STG_Cliente
-- ------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE STG_Cliente;
INSERT INTO STG_Cliente (FonteDadosID, ClienteID_Origem, TipoPessoa, NomeRazaoSocial, CPF_CNPJ, Email, Telefone1, Endereco, CidadeOrigem)

[cite_start]-- Extração da Empresa 1 [cite: 51]
SELECT
    1 AS FonteDadosID,
    c.id AS ClienteID_Origem,
    c.tipo AS TipoPessoa,
    c.nome_razao AS NomeRazaoSocial,
    c.cpf_cnpj AS CPF_CNPJ,
    c.email AS Email,
    c.telefone1 AS Telefone1,
    c.endereco AS Endereco,
    SUBSTRING(c.endereco FROM ',([^,]+)-[A-Z]{2}$') AS CidadeOrigem -- Exemplo de extração de cidade
FROM empresa1.Cliente c

UNION ALL

-- Extração da Empresa 2
SELECT
    2 AS FonteDadosID,
    c.id_cliente AS ClienteID_Origem,
    c.tipo_cliente AS TipoPessoa,           -- Mapeamento: tipo_cliente -> TipoPessoa
    c.nome AS NomeRazaoSocial,
    c.documento AS CPF_CNPJ,                -- Mapeamento: documento -> CPF_CNPJ
    c.email_contato AS Email,
    c.celular AS Telefone1,
    c.endereco_completo AS Endereco,
    c.cidade AS CidadeOrigem
FROM empresa2.CadastroClientes c

-- UNION ALL ... (para as empresas 3, 4, 5 e 6)
;

-- ------------------------------------------------------------------------------------------------------------------
-- CARGA DA TABELA STG_Veiculo
-- ------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE STG_Veiculo;
INSERT INTO STG_Veiculo (FonteDadosID, VeiculoID_Origem, EmpresaProprietariaID_Origem, Placa, Chassi, Marca, Modelo, Cor, Ano, TipoTransmissao, ArCondicionado, CodigoGrupo, DescricaoGrupo)

[cite_start]-- Extração da Empresa 1 [cite: 3, 47]
SELECT
    1 AS FonteDadosID,
    v.id AS VeiculoID_Origem,
    e.id AS EmpresaProprietariaID_Origem,
    v.placa,
    v.chassi,
    v.marca,
    v.modelo,
    v.cor,
    v.ano,
    v.transmissao::varchar AS TipoTransmissao,
    v.ar_condicionado,
    gv.codigo_grupo,
    gv.descricao
FROM empresa1.Veiculo v
JOIN empresa1.GrupoVeiculo gv ON v.grupo_id = gv.id
-- Assume-se que a primeira empresa encontrada no BD de origem é a proprietária da frota
CROSS JOIN (SELECT id FROM empresa1.Empresa LIMIT 1) e

UNION ALL

-- Extração da Empresa 2
SELECT
    2 AS FonteDadosID,
    v.id_veiculo AS VeiculoID_Origem,
    v.id_empresa_proprietaria AS EmpresaProprietariaID_Origem,
    v.placa_veiculo AS Placa,
    v.chassi_veiculo AS Chassi,
    v.fabricante AS Marca,
    v.modelo_carro AS Modelo,
    v.cor_pintura AS Cor,
    v.ano_fabricacao AS Ano,
    v.cambio AS TipoTransmissao,
    v.tem_ar AS ArCondicionado,
    cat.cod_categoria AS CodigoGrupo,
    cat.nome_categoria AS DescricaoGrupo
FROM empresa2.Frota v
JOIN empresa2.Categorias cat ON v.id_categoria = cat.id

-- UNION ALL ... (para as empresas 3, 4, 5 e 6)
;

-- ------------------------------------------------------------------------------------------------------------------
-- CARGA DA TABELA STG_Reserva
-- ------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE STG_Reserva;
INSERT INTO STG_Reserva (FonteDadosID, ReservaID_Origem, ClienteID_Origem, GrupoVeiculoID_Origem, PatioRetiradaID_Origem, PatioDevolucaoID_Origem, DataPrevistaRetirada, DataPrevistaDevolucao, StatusReserva)

[cite_start]-- Extração da Empresa 1 [cite: 55]
SELECT
    1 AS FonteDadosID,
    r.id,
    r.cliente_id,
    r.grupo_id,
    r.patio_retirada_id,
    r.patio_devolucao_id,
    r.data_prev_retirada,
    r.data_prev_devolucao,
    r.status
FROM empresa1.Reserva r

-- UNION ALL ... (para as empresas 2, 3, 4, 5 e 6)
;

-- ------------------------------------------------------------------------------------------------------------------
-- CARGA DA TABELA STG_Locacao
-- ------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE STG_Locacao;
INSERT INTO STG_Locacao (FonteDadosID, LocacaoID_Origem, ReservaID_Origem, ClienteID_Origem, VeiculoID_Origem, PatioRetiradaID_Origem, PatioDevolucaoID_Origem, DataRetirada, DataPrevistaDevolucao, DataRealDevolucao, KmSaida, KmChegada, ValorFinalCobrado, StatusLocacao)

[cite_start]-- Extração da Empresa 1 [cite: 24, 30, 57]
SELECT
    1 AS FonteDadosID,
    l.id AS LocacaoID_Origem,
    l.reserva_id AS ReservaID_Origem,
    co.cliente_id AS ClienteID_Origem,
    l.veiculo_id AS VeiculoID_Origem,
    l.patio_saida_id AS PatioRetiradaID_Origem,
    l.patio_chegada_id AS PatioDevolucaoID_Origem,
    l.data_retirada,
    r.data_prev_devolucao,
    l.data_real_devolucao,
    l.km_saida,
    l.km_chegada,
    cb.valor_final AS ValorFinalCobrado,
    l.status AS StatusLocacao
FROM empresa1.Locacao l
LEFT JOIN empresa1.Reserva r ON l.reserva_id = r.id
LEFT JOIN empresa1.Condutor co ON l.condutor_id = co.id
LEFT JOIN empresa1.Cobranca cb ON l.id = cb.locacao_id

-- UNION ALL ... (para as empresas 2, 3, 4, 5 e 6, com seus respectivos JOINs e mapeamentos)
;


/**********************************************************************************************************************
* SEÇÃO 3: ESPECIFICAÇÃO DOS TEMPOS DE ACIONAMENTO (AGENDAMENTO)
*
* A execução deste script deve ser orquestrada por uma ferramenta de agendamento (scheduler).
* A seguir, a frequência recomendada para cada conjunto de cargas.
*---------------------------------------------------------------------------------------------------------------------
* | Processo de Carga       | Tabelas de Staging Alvo    | Frequência Sugerida | Janela de Execução        |
* |-------------------------|----------------------------|---------------------|---------------------------|
* | Carga de Pátios         | STG_Patio                  | Semanal             | Sábado, 23:00             |
* | Carga de Frota          | STG_Veiculo                | Diária              | Madrugada (ex: 02:00)     |
* | Carga de Clientes       | STG_Cliente                | Diária              | Madrugada (ex: 02:30)     |
* | Carga de Reservas       | STG_Reserva                | A cada 4 horas      | 04:00, 08:00, 12:00, etc. |
* | Carga de Locações       | STG_Locacao                | A cada 2 horas      | Horas pares (02:00, etc.) |
*---------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/

