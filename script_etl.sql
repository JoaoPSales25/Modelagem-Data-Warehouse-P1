-- Avaliação 02: Modelagem de Data Warehouse
-- Parte 2: 
-- Grupo:
-- Augusto Fernandes Nodari 						DRE: 121131778 
-- Henrique Almico Dias da Silva  					DRE: 124238228
-- João Pedro de Faria Sales  						DRE: 121056457 
-- Vitor Rayol Taranto                              DRE: 121063585
CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE staging.stg_grupos_veiculos (
    grupo_id INT,
    nome_grupo VARCHAR(50),
    descricao TEXT,
    valor_diaria_base DECIMAL(10, 2),
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_patios (
    patio_id INT,
    nome VARCHAR(100),
    endereco VARCHAR(255),
    data_criacao TIMESTAMP WITH TIME ZONE,
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_vagas (
    vaga_id INT,
    patio_id INT,
    codigo_vaga VARCHAR(20),
    ocupada BOOLEAN,
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_veiculos (
    veiculo_id INT,
    placa VARCHAR(10),
    chassi VARCHAR(17),
    grupo_id INT,
    vaga_atual_id INT,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    cor VARCHAR(30),
    ano_fabricacao INT,
    mecanizacao VARCHAR(20),
    ar_condicionado BOOLEAN,
    status VARCHAR(20),
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_clientes (
    cliente_id INT,
    nome_completo VARCHAR(255),
    cpf_cnpj VARCHAR(18),
    tipo_pessoa CHAR(1),
    email VARCHAR(100),
    telefone VARCHAR(20),
    endereco_cidade VARCHAR(100),
    endereco_estado VARCHAR(50),
    data_cadastro TIMESTAMP WITH TIME ZONE,
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_motoristas (
    motorista_id INT,
    cliente_id INT,
    nome_completo VARCHAR(255),
    cnh VARCHAR(11),
    cnh_categoria VARCHAR(5),
    cnh_validade DATE,
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_reservas (
    reserva_id INT,
    cliente_id INT,
    grupo_id INT,
    patio_retirada_id INT,
    data_reserva TIMESTAMP WITH TIME ZONE,
    data_prevista_retirada TIMESTAMP WITH TIME ZONE,
    data_prevista_devolucao TIMESTAMP WITH TIME ZONE,
    status_reserva VARCHAR(20),
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_locacoes (
    locacao_id INT,
    reserva_id INT,
    cliente_id INT,
    motorista_id INT,
    veiculo_id INT,
    patio_retirada_id INT,
    patio_devolucao_id INT,
    data_retirada_real TIMESTAMP WITH TIME ZONE,
    data_devolucao_prevista TIMESTAMP WITH TIME ZONE,
    data_devolucao_real TIMESTAMP WITH TIME ZONE,
    valor_total_previsto DECIMAL(10, 2),
    valor_total_final DECIMAL(10, 2),
    protecoes_adicionais TEXT,
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_cobrancas (
    cobranca_id INT,
    locacao_id INT,
    valor DECIMAL(10, 2),
    data_emissao TIMESTAMP WITH TIME ZONE,
    data_vencimento DATE,
    data_pagamento DATE,
    status_pagamento VARCHAR(20),
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_acessorios (
    acessorio_id INT,
    nome VARCHAR(100),
    descricao TEXT,
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_veiculos_acessorios (
    veiculo_id INT,
    acessorio_id INT,
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_prontuarios_veiculos (
    prontuario_id INT,
    veiculo_id INT,
    data_ocorrencia DATE,
    tipo VARCHAR(50),
    descricao TEXT,
    custo DECIMAL(10, 2),
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);

CREATE TABLE staging.stg_fotos_veiculos (
    foto_id INT,
    veiculo_id INT,
    url_foto VARCHAR(255),
    tipo VARCHAR(50),
    data_upload TIMESTAMP WITH TIME ZONE,
    source_company_id VARCHAR(50),
    extraction_date TIMESTAMP WITH TIME ZONE
);




INSERT INTO staging.stg_grupos_veiculos (grupo_id, nome_grupo, descricao, valor_diaria_base, source_company_id, extraction_date)
SELECT grupo_id, nome_grupo, descricao, valor_diaria_base, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.grupos_veiculos;

INSERT INTO staging.stg_patios (patio_id, nome, endereco, data_criacao, source_company_id, extraction_date)
SELECT patio_id, nome, endereco, data_criacao, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.patios;

INSERT INTO staging.stg_vagas (vaga_id, patio_id, codigo_vaga, ocupada, source_company_id, extraction_date)
SELECT vaga_id, patio_id, codigo_vaga, ocupada, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.vagas;

INSERT INTO staging.stg_veiculos (veiculo_id, placa, chassi, grupo_id, vaga_atual_id, marca, modelo, cor, ano_fabricacao, mecanizacao, ar_condicionado, status, source_company_id, extraction_date)
SELECT veiculo_id, placa, chassi, grupo_id, vaga_atual_id, marca, modelo, cor, ano_fabricacao, mecanizacao, ar_condicionado, status, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.veiculos;

INSERT INTO staging.stg_clientes (cliente_id, nome_completo, cpf_cnpj, tipo_pessoa, email, telefone, endereco_cidade, endereco_estado, data_cadastro, source_company_id, extraction_date)
SELECT cliente_id, nome_completo, cpf_cnpj, tipo_pessoa, email, telefone, endereco_cidade, endereco_estado, data_cadastro, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.clientes;

INSERT INTO staging.stg_motoristas (motorista_id, cliente_id, nome_completo, cnh, cnh_categoria, cnh_validade, source_company_id, extraction_date)
SELECT motorista_id, cliente_id, nome_completo, cnh, cnh_categoria, cnh_validade, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.motoristas;

INSERT INTO staging.stg_reservas (reserva_id, cliente_id, grupo_id, patio_retirada_id, data_reserva, data_prevista_retirada, data_prevista_devolucao, status_reserva, source_company_id, extraction_date)
SELECT reserva_id, cliente_id, grupo_id, patio_retirada_id, data_reserva, data_prevista_retirada, data_prevista_devolucao, status_reserva, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.reservas;

INSERT INTO staging.stg_locacoes (locacao_id, reserva_id, cliente_id, motorista_id, veiculo_id, patio_retirada_id, patio_devolucao_id, data_retirada_real, data_devolucao_prevista, data_devolucao_real, valor_total_previsto, valor_total_final, protecoes_adicionais, source_company_id, extraction_date)
SELECT locacao_id, reserva_id, cliente_id, motorista_id, veiculo_id, patio_retirada_id, patio_devolucao_id, data_retirada_real, data_devolucao_prevista, data_devolucao_real, valor_total_previsto, valor_total_final, protecoes_adicionais, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.locacoes;

INSERT INTO staging.stg_cobrancas (cobranca_id, locacao_id, valor, data_emissao, data_vencimento, data_pagamento, status_pagamento, source_company_id, extraction_date)
SELECT cobranca_id, locacao_id, valor, data_emissao, data_vencimento, data_pagamento, status_pagamento, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.cobrancas;

INSERT INTO staging.stg_acessorios (acessorio_id, nome, descricao, source_company_id, extraction_date)
SELECT acessorio_id, nome, descricao, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.acessorios;

INSERT INTO staging.stg_veiculos_acessorios (veiculo_id, acessorio_id, source_company_id, extraction_date)
SELECT veiculo_id, acessorio_id, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.veiculos_acessorios;

INSERT INTO staging.stg_prontuarios_veiculos (prontuario_id, veiculo_id, data_ocorrencia, tipo, descricao, custo, source_company_id, extraction_date)
SELECT prontuario_id, veiculo_id, data_ocorrencia, tipo, descricao, custo, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.prontuarios_veiculos;

INSERT INTO staging.stg_fotos_veiculos (foto_id, veiculo_id, url_foto, tipo, data_upload, source_company_id, extraction_date)
SELECT foto_id, veiculo_id, url_foto, tipo, data_upload, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.fotos_veiculos;
