-- Avaliação 02: Modelagem de Data Warehouse
-- Parte 2: 
-- Grupo:
-- Augusto Fernandes Nodari 						DRE: 121131778 
-- Henrique Almico Dias da Silva  					DRE: 124238228
-- João Pedro de Faria Sales  						DRE: 121056457 
-- Vitor Rayol Taranto                              DRE: 121063585



-- DDL para as tabelas da Área de Staging

-- Tabela de Staging para CLIENTE
CREATE TABLE IF NOT EXISTS stg_cliente (
    origem_empresa_id INT NOT NULL, -- Identificador da empresa de origem (1 a 6)
    cliente_id_origem SERIAL NOT NULL, -- ID original do cliente na base transacional
    tipo CHAR(1) NOT NULL,
    nome_razao VARCHAR(100) NOT NULL,
    cpf_cnpj CHAR(14) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    data_carga_dw TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp da carga na staging
    PRIMARY KEY (origem_empresa_id, cliente_id_origem) -- Chave primária composta para unicidade
);

-- Tabela de Staging para CONDUTOR (se for necessário para relatórios específicos)
CREATE TABLE IF NOT EXISTS stg_condutor (
    origem_empresa_id INT NOT NULL,
    condutor_id_origem SERIAL NOT NULL,
    cliente_id_origem INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cnh_numero VARCHAR(20) NOT NULL,
    cnh_categoria VARCHAR(2) NOT NULL,
    cnh_validade DATE NOT NULL,
    data_carga_dw TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (origem_empresa_id, condutor_id_origem)
);

-- Tabela de Staging para GRUPO_VEICULO
CREATE TABLE IF NOT EXISTS stg_grupo_veiculo (
    origem_empresa_id INT NOT NULL,
    grupo_id_origem SERIAL NOT NULL,
    nome VARCHAR(50) NOT NULL,
    tarifa_diaria DECIMAL(10,2) NOT NULL,
    data_carga_dw TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (origem_empresa_id, grupo_id_origem)
);

-- Tabela de Staging para VEICULO
CREATE TABLE IF NOT EXISTS stg_veiculo (
    origem_empresa_id INT NOT NULL,
    veiculo_id_origem SERIAL NOT NULL,
    grupo_id_origem INT NOT NULL,
    placa CHAR(7) NOT NULL,
    chassis VARCHAR(17) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    cor VARCHAR(30),
    mecanizacao VARCHAR(10) NOT NULL,
    ar_condicionado BOOLEAN NOT NULL,
    cadeirinha BOOLEAN NOT NULL,
    data_carga_dw TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (origem_empresa_id, veiculo_id_origem)
);

-- Tabela de Staging para PATIO
CREATE TABLE IF NOT EXISTS stg_patio (
    origem_empresa_id INT NOT NULL,
    patio_id_origem SERIAL NOT NULL,
    nome VARCHAR(100) NOT NULL,
    localizacao VARCHAR(150),
    data_carga_dw TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (origem_empresa_id, patio_id_origem)
);

-- Tabela de Staging para RESERVA
CREATE TABLE IF NOT EXISTS stg_reserva (
    origem_empresa_id INT NOT NULL,
    reserva_id_origem SERIAL NOT NULL,
    cliente_id_origem INT NOT NULL,
    grupo_id_origem INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim_previsto DATE NOT NULL,
    patio_retirada_id_origem INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    data_carga_dw TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (origem_empresa_id, reserva_id_origem)
);

-- Tabela de Staging para LOCACAO
CREATE TABLE IF NOT EXISTS stg_locacao (
    origem_empresa_id INT NOT NULL,
    locacao_id_origem SERIAL NOT NULL,
    reserva_id_origem INT,
    condutor_id_origem INT NOT NULL,
    veiculo_id_origem INT NOT NULL,
    data_retirada TIMESTAMP NOT NULL,
    patio_saida_id_origem INT NOT NULL,
    data_devolucao_prevista TIMESTAMP NOT NULL,
    data_devolucao_real TIMESTAMP,
    patio_chegada_id_origem INT,
    estado_entrega TEXT,
    estado_devolucao TEXT,
    data_carga_dw TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (origem_empresa_id, locacao_id_origem)
);

-- Tabela de Staging para PROTECAO_ADICIONAL (se for relevante para DW)
CREATE TABLE IF NOT EXISTS stg_protecao_adicional (
    origem_empresa_id INT NOT NULL,
    protecao_id_origem SERIAL NOT NULL,
    descricao VARCHAR(100) NOT NULL,
    data_carga_dw TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (origem_empresa_id, protecao_id_origem)
);

-- Tabela de Staging para LOCACAO_PROTECAO (para linkar locações e proteções)
CREATE TABLE IF NOT EXISTS stg_locacao_protecao (
    origem_empresa_id INT NOT NULL,
    locacao_id_origem INT NOT NULL,
    protecao_id_origem INT NOT NULL,
    data_carga_dw TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (origem_empresa_id, locacao_id_origem, protecao_id_origem)
);

-- Tabela de Staging para COBRANCA
CREATE TABLE IF NOT EXISTS stg_cobranca (
    origem_empresa_id INT NOT NULL,
    cobranca_id_origem SERIAL NOT NULL,
    locacao_id_origem INT NOT NULL,
    data_cobranca TIMESTAMP NOT NULL,
    valor_base DECIMAL(12,2) NOT NULL,
    valor_final DECIMAL(12,2),
    status_pagamento VARCHAR(20) NOT NULL,
    data_carga_dw TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (origem_empresa_id, cobranca_id_origem)
);


-- Scripts de Extração ETL para cada sistema fonte
-- As extrações devem ser agendadas diariamente durante a noite/madrugada.

-- EXEMPLO DE EXTRAÇÃO PARA A EMPRESA 1 (seu grupo)
-- As consultas SELECT devem ser adaptadas para o nome do banco de dados/schema da Empresa 1
-- e para as colunas exatas da tabela de origem.

-- Extração de CLIENTE
INSERT INTO stg_cliente (
    origem_empresa_id,
    cliente_id_origem,
    tipo,
    nome_razao,
    cpf_cnpj,
    telefone,
    email
)
SELECT
    1 AS origem_empresa_id,
    c.cliente_id,
    c.tipo,
    c.nome_razao,
    c.cpf_cnpj,
    c.telefone,
    c.email
FROM
    empresa_1_db.public.CLIENTE c
ON CONFLICT (origem_empresa_id, cliente_id_origem) DO UPDATE SET
    tipo = EXCLUDED.tipo,
    nome_razao = EXCLUDED.nome_razao,
    cpf_cnpj = EXCLUDED.cpf_cnpj,
    telefone = EXCLUDED.telefone,
    email = EXCLUDED.email,
    data_carga_dw = CURRENT_TIMESTAMP;

-- Extração de CONDUTOR
INSERT INTO stg_condutor (
    origem_empresa_id,
    condutor_id_origem,
    cliente_id_origem,
    nome,
    cnh_numero,
    cnh_categoria,
    cnh_validade
)
SELECT
    1 AS origem_empresa_id,
    con.condutor_id,
    con.cliente_id,
    con.nome,
    con.cnh_numero,
    con.cnh_categoria,
    con.cnh_validade
FROM
    empresa_1_db.public.CONDUTOR con
ON CONFLICT (origem_empresa_id, condutor_id_origem) DO UPDATE SET
    cliente_id_origem = EXCLUDED.cliente_id_origem,
    nome = EXCLUDED.nome,
    cnh_numero = EXCLUDED.cnh_numero,
    cnh_categoria = EXCLUDED.cnh_categoria,
    cnh_validade = EXCLUDED.cnh_validade,
    data_carga_dw = CURRENT_TIMESTAMP;

-- Extração de GRUPO_VEICULO
INSERT INTO stg_grupo_veiculo (
    origem_empresa_id,
    grupo_id_origem,
    nome,
    tarifa_diaria
)
SELECT
    1 AS origem_empresa_id,
    gv.grupo_id,
    gv.nome,
    gv.tarifa_diaria
FROM
    empresa_1_db.public.GRUPO_VEICULO gv
ON CONFLICT (origem_empresa_id, grupo_id_origem) DO UPDATE SET
    nome = EXCLUDED.nome,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    data_carga_dw = CURRENT_TIMESTAMP;

-- Extração de VEICULO
INSERT INTO stg_veiculo (
    origem_empresa_id,
    veiculo_id_origem,
    grupo_id_origem,
    placa,
    chassis,
    marca,
    modelo,
    cor,
    mecanizacao,
    ar_condicionado,
    cadeirinha
)
SELECT
    1 AS origem_empresa_id,
    v.veiculo_id,
    v.grupo_id,
    v.placa,
    v.chassis,
    v.marca,
    v.modelo,
    v.cor,
    v.mecanizacao,
    v.ar_condicionado,
    v.cadeirinha
FROM
    empresa_1_db.public.VEICULO v
ON CONFLICT (origem_empresa_id, veiculo_id_origem) DO UPDATE SET
    grupo_id_origem = EXCLUDED.grupo_id_origem,
    placa = EXCLUDED.placa,
    chassis = EXCLUDED.chassis,
    marca = EXCLUDED.marca,
    modelo = EXCLUDED.modelo,
    cor = EXCLUDED.cor,
    mecanizacao = EXCLUDED.mecanizacao,
    ar_condicionado = EXCLUDED.ar_condicionado,
    cadeirinha = EXCLUDED.cadeirinha,
    data_carga_dw = CURRENT_TIMESTAMP;

-- Extração de PATIO
INSERT INTO stg_patio (
    origem_empresa_id,
    patio_id_origem,
    nome,
    localizacao
)
SELECT
    1 AS origem_empresa_id,
    p.patio_id,
    p.nome,
    p.localizacao
FROM
    empresa_1_db.public.PATIO p
ON CONFLICT (origem_empresa_id, patio_id_origem) DO UPDATE SET
    nome = EXCLUDED.nome,
    localizacao = EXCLUDED.localizacao,
    data_carga_dw = CURRENT_TIMESTAMP;

-- Extração de RESERVA
INSERT INTO stg_reserva (
    origem_empresa_id,
    reserva_id_origem,
    cliente_id_origem,
    grupo_id_origem,
    data_inicio,
    data_fim_previsto,
    patio_retirada_id_origem,
    status
)
SELECT
    1 AS origem_empresa_id,
    r.reserva_id,
    r.cliente_id,
    r.grupo_id,
    r.data_inicio,
    r.data_fim_previsto,
    r.patio_retirada_id,
    r.status
FROM
    empresa_1_db.public.RESERVA r
ON CONFLICT (origem_empresa_id, reserva_id_origem) DO UPDATE SET
    cliente_id_origem = EXCLUDED.cliente_id_origem,
    grupo_id_origem = EXCLUDED.grupo_id_origem,
    data_inicio = EXCLUDED.data_inicio,
    data_fim_previsto = EXCLUDED.data_fim_previsto,
    patio_retirada_id_origem = EXCLUDED.patio_retirada_id_origem,
    status = EXCLUDED.status,
    data_carga_dw = CURRENT_TIMESTAMP;

-- Extração de LOCACAO
INSERT INTO stg_locacao (
    origem_empresa_id,
    locacao_id_origem,
    reserva_id_origem,
    condutor_id_origem,
    veiculo_id_origem,
    data_retirada,
    patio_saida_id_origem,
    data_devolucao_prevista,
    data_devolucao_real,
    patio_chegada_id_origem,
    estado_entrega,
    estado_devolucao
)
SELECT
    1 AS origem_empresa_id,
    l.locacao_id,
    l.reserva_id,
    l.condutor_id,
    l.veiculo_id,
    l.data_retirada,
    l.patio_saida_id,
    l.data_devolucao_prevista,
    l.data_devolucao_real,
    l.patio_chegada_id,
    l.estado_entrega,
    l.estado_devolucao
FROM
    empresa_1_db.public.LOCACAO l
ON CONFLICT (origem_empresa_id, locacao_id_origem) DO UPDATE SET
    reserva_id_origem = EXCLUDED.reserva_id_origem,
    condutor_id_origem = EXCLUDED.condutor_id_origem,
    veiculo_id_origem = EXCLUDED.veiculo_id_origem,
    data_retirada = EXCLUDED.data_retirada,
    patio_saida_id_origem = EXCLUDED.patio_saida_id_origem,
    data_devolucao_prevista = EXCLUDED.data_devolucao_prevista,
    data_devolucao_real = EXCLUDED.data_devolucao_real,
    patio_chegada_id_origem = EXCLUDED.patio_chegada_id_origem,
    estado_entrega = EXCLUDED.estado_entrega,
    estado_devolucao = EXCLUDED.estado_devolucao,
    data_carga_dw = CURRENT_TIMESTAMP;

-- Extração de PROTECAO_ADICIONAL
INSERT INTO stg_protecao_adicional (
    origem_empresa_id,
    protecao_id_origem,
    descricao
)
SELECT
    1 AS origem_empresa_id,
    pa.protecao_id,
    pa.descricao
FROM
    empresa_1_db.public.PROTECAO_ADICIONAL pa
ON CONFLICT (origem_empresa_id, protecao_id_origem) DO UPDATE SET
    descricao = EXCLUDED.descricao,
    data_carga_dw = CURRENT_TIMESTAMP;

-- Extração de LOCACAO_PROTECAO
INSERT INTO stg_locacao_protecao (
    origem_empresa_id,
    locacao_id_origem,
    protecao_id_origem
)
SELECT
    1 AS origem_empresa_id,
    lp.locacao_id,
    lp.protecao_id
FROM
    empresa_1_db.public.LOCACAO_PROTECAO lp
ON CONFLICT (origem_empresa_id, locacao_id_origem, protecao_id_origem) DO UPDATE SET
    data_carga_dw = CURRENT_TIMESTAMP;


-- Extração de COBRANCA
INSERT INTO stg_cobranca (
    origem_empresa_id,
    cobranca_id_origem,
    locacao_id_origem,
    data_cobranca,
    valor_base,
    valor_final,
    status_pagamento
)
SELECT
    1 AS origem_empresa_id,
    c.cobranca_id,
    c.locacao_id,
    c.data_cobranca,
    c.valor_base,
    c.valor_final,
    c.status_pagamento
FROM
    empresa_1_db.public.COBRANCA c
ON CONFLICT (origem_empresa_id, cobranca_id_origem) DO UPDATE SET
    locacao_id_origem = EXCLUDED.locacao_id_origem,
    data_cobranca = EXCLUDED.data_cobranca,
    valor_base = EXCLUDED.valor_base,
    valor_final = EXCLUDED.valor_final,
    status_pagamento = EXCLUDED.status_pagamento,
    data_carga_dw = CURRENT_TIMESTAMP;


-- **IMPORTANTE:**
-- Para as outras 5 empresas, blocos de INSERT INTO similares a esses seriam replicados.
-- Cada bloco teria um 'origem_empresa_id' diferente (2, 3, 4, 5, 6) e o SELECT FROM
-- seria adaptado para os nomes dos bancos de dados e tabelas da respectiva empresa.
-- Ex:
-- INSERT INTO stg_cliente (...)
-- SELECT 2 AS origem_empresa_id, c.id_cliente, ...
-- FROM empresa_2_db.public.Clientes c
-- ON CONFLICT (...) DO UPDATE SET ...
