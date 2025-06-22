-- Script de Extração ETL para a Área de Staging
-- Data de Geração: 22 de junho de 2025
-- Autor: Consultoria de TIC

-- O objetivo deste script é extrair dados de sistemas OLTP de diversas empresas
-- associadas ao consórcio de locadoras de veículos e carregá-los em uma área de staging.
-- A área de staging (schema 'staging') serve como um ambiente intermediário para padronização,
-- limpeza e preparação dos dados antes de serem carregados no Data Warehouse (DW).

-- As extrações serão agendadas para ocorrer em horários de baixa demanda nos sistemas OLTP,
-- idealmente fora do horário comercial de pico, para minimizar o impacto nas operações transacionais.
-- Sugere-se uma frequência diária, no final do dia (e.g., 23:00h - 02:00h), para garantir
-- que os dados mais recentes estejam disponíveis para as análises do DW no dia seguinte.

-- No contexto de um ambiente multi-empresa, a coluna 'source_company_id' é crucial para identificar
-- a origem de cada registro. Para este exemplo, utilizaremos IDs fictícios para as empresas.

-- =======================================================================================================
-- Criação do Schema de Staging (se não existir)
-- Este DDL para o schema de staging já foi fornecido em 'etl.sql' e 'etl (1).sql'.
-- Reafirmamos a importância de ter uma estrutura de staging que possa acomodar os dados
-- de todas as fontes OLTP antes da transformação para o DW.
-- Exemplo de estrutura de tabela de staging (já presente em etl.sql):
-- CREATE SCHEMA IF NOT EXISTS staging;
-- CREATE TABLE staging.stg_clientes (
--     cliente_id INT,
--     nome_completo VARCHAR(255),
--     cpf_cnpj VARCHAR(18),
--     tipo_pessoa CHAR(1),
--     email VARCHAR(100),
--     telefone VARCHAR(20),
--     endereco_cidade VARCHAR(100),
--     endereco_estado VARCHAR(50),
--     data_cadastro TIMESTAMP WITH TIME ZONE,
--     source_company_id VARCHAR(50),
--     extraction_date TIMESTAMP WITH TIME ZONE
-- );
-- ... (outras tabelas de staging conforme etl.sql)
-- =======================================================================================================

-- Inserção de dados nas tabelas de Staging
-- As seguintes instruções INSERT INTO SELECT FROM simulam a extração dos dados
-- dos diferentes sistemas OLTP (representados por schemas 'public' ou modelos de outros grupos)
-- para a área de staging.

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_grupos_veiculos
-- Frequência: Diária, após atualização dos grupos nos sistemas OLTP.
-- Horário Sugerido: 00:00h
-- Fontes: Public.grupos_veiculos (grupo 1 - seu grupo), e um esquema hipotético 'grupo2.grupos_veiculos', etc.
-- Observação: Assume-se que os grupos de veículos são padronizados ou mapeados durante o ETL.
-- Para o projeto, vamos replicar o script 'etl (1).sql' que usa 'Empresa_Galeao' como exemplo.
-- Em um cenário real, cada INSERT abaixo seria executado com um 'source_company_id' diferente
-- e apontaria para o schema/tabelas da respectiva empresa.

INSERT INTO staging.stg_grupos_veiculos (grupo_id, nome_grupo, descricao, valor_diaria_base, source_company_id, extraction_date)
SELECT grupo_id, nome_grupo, descricao, valor_diaria_base, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.grupos_veiculos;

-- Exemplo para outra empresa (hipotética 'Empresa_SantosDumont' com um schema 'empresa_santosdumont'):
-- INSERT INTO staging.stg_grupos_veiculos (grupo_id, nome_grupo, descricao, valor_diaria_base, source_company_id, extraction_date)
-- SELECT grupo_id, nome_grupo, descricao, valor_diaria_base, 'Empresa_SantosDumont', CURRENT_TIMESTAMP FROM empresa_santosdumont.grupos_veiculos;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_patios
-- Frequência: Diária, ou conforme mudanças nos dados cadastrais dos pátios.
-- Horário Sugerido: 00:05h
-- Fontes: Public.patios, outros esquemas de pátios.
-- Observação: Endereços podem precisar de padronização.

INSERT INTO staging.stg_patios (patio_id, nome, endereco, data_criacao, source_company_id, extraction_date)
SELECT patio_id, nome, endereco, data_criacao, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.patios;

-- Para o modelo do aluno Wesley Conceição da Silva, a tabela é 'PATIO' e o campo é 'localizacao'
INSERT INTO staging.stg_patios (patio_id, nome, endereco, data_criacao, source_company_id, extraction_date)
SELECT id_patio, localizacao, localizacao AS endereco, CURRENT_TIMESTAMP AS data_criacao, 'Empresa_Wesley', CURRENT_TIMESTAMP FROM public.PATIO;
-- (Assumindo que 'localizacao' pode ser mapeado para 'nome' e 'endereco' para fins de staging, e que o 'patio_id' é único entre as empresas)

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_vagas
-- Frequência: Diária, para monitoramento de ocupação.
-- Horário Sugerido: 00:10h
-- Fontes: Public.vagas, outros esquemas.

INSERT INTO staging.stg_vagas (vaga_id, patio_id, codigo_vaga, ocupada, source_company_id, extraction_date)
SELECT vaga_id, patio_id, codigo_vaga, ocupada, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.vagas;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_veiculos
-- Frequência: Diária, ou conforme alterações na frota.
-- Horário Sugerido: 00:15h
-- Fontes: Public.veiculos, outros esquemas de veículos.
-- Observação: Mapeamento de 'grupo_id' para 'nome_grupo' e 'descricao' será feito na dimensão.

INSERT INTO staging.stg_veiculos (veiculo_id, placa, chassi, grupo_id, vaga_atual_id, marca, modelo, cor, ano_fabricacao, mecanizacao, ar_condicionado, status, source_company_id, extraction_date)
SELECT veiculo_id, placa, chassi, grupo_id, vaga_atual_id, marca, modelo, cor, ano_fabricacao, mecanizacao, ar_condicionado, status, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.veiculos;

-- Para o modelo do aluno Wesley Conceição da Silva, a tabela é 'VEICULO'. Note que 'grupo_id', 'vaga_atual_id', 'ar_condicionado', 'status' não estão diretamente presentes e podem requerer mapeamento ou tratamento.
INSERT INTO staging.stg_veiculos (veiculo_id, placa, chassi, grupo_id, vaga_atual_id, marca, modelo, cor, ano_fabricacao, mecanizacao, ar_condicionado, status, source_company_id, extraction_date)
SELECT
    id_veiculo,
    placa,
    chassi,
    NULL AS grupo_id, -- Grupo pode ser inferido ou vir de outra tabela no modelo de Wesley.
    NULL AS vaga_atual_id, -- Vaga pode ser inferida via PATIO.veiculo_id no modelo de Wesley.
    marca,
    modelo,
    cor,
    NULL AS ano_fabricacao, -- Não presente diretamente.
    'N/A' AS mecanizacao, -- Não presente diretamente.
    FALSE AS ar_condicionado, -- Não presente diretamente.
    'Disponível' AS status, -- Não presente diretamente.
    'Empresa_Wesley',
    CURRENT_TIMESTAMP
FROM public.VEICULO;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_clientes
-- Frequência: Diária, para capturar novos clientes ou atualizações.
-- Horário Sugerido: 00:20h
-- Fontes: Public.clientes, outros esquemas de clientes.
-- Observação: Implementação de SCD Tipo 2 na DimCliente do DW.

INSERT INTO staging.stg_clientes (cliente_id, nome_completo, cpf_cnpj, tipo_pessoa, email, telefone, endereco_cidade, endereco_estado, data_cadastro, source_company_id, extraction_date)
SELECT cliente_id, nome_completo, cpf_cnpj, tipo_pessoa, email, telefone, endereco_cidade, endereco_estado, data_cadastro, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.clientes;

-- Para o modelo do aluno Wesley Conceição da Silva, a tabela é 'CLIENTE'.
INSERT INTO staging.stg_clientes (cliente_id, nome_completo, cpf_cnpj, tipo_pessoa, email, telefone, endereco_cidade, endereco_estado, data_cadastro, source_company_id, extraction_date)
SELECT
    id_cliente,
    nome AS nome_completo,
    cpf_cnpj,
    tipo AS tipo_pessoa,
    email,
    telefone,
    NULL AS endereco_cidade, -- Não presente diretamente.
    NULL AS endereco_estado, -- Não presente diretamente.
    CURRENT_TIMESTAMP AS data_cadastro, -- Não presente diretamente.
    'Empresa_Wesley',
    CURRENT_TIMESTAMP
FROM public.CLIENTE;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_motoristas
-- Frequência: Diária.
-- Horário Sugerido: 00:25h
-- Fontes: Public.motoristas. (Pode ser integrado ou não com CLIENTE, dependendo do modelo OLTP)
-- Observação: O modelo do Wesley não possui uma tabela 'motoristas' separada, as informações estão em 'CLIENTE'.
-- Portanto, a extração para stg_motoristas só faria sentido se houver uma fonte dedicada a motoristas.
-- Se o modelo de Wesley for a fonte, precisaríamos adaptar a carga de stg_clientes para incluir CNH, etc.

INSERT INTO staging.stg_motoristas (motorista_id, cliente_id, nome_completo, cnh, cnh_categoria, cnh_validade, source_company_id, extraction_date)
SELECT motorista_id, cliente_id, nome_completo, cnh, cnh_categoria, cnh_validade, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.motoristas;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_reservas
-- Frequência: Diária, para capturar novas reservas.
-- Horário Sugerido: 00:30h
-- Fontes: Public.reservas, outros esquemas de reservas.

INSERT INTO staging.stg_reservas (reserva_id, cliente_id, grupo_id, patio_retirada_id, data_reserva, data_prevista_retirada, data_prevista_devolucao, status_reserva, source_company_id, extraction_date)
SELECT reserva_id, cliente_id, grupo_id, patio_retirada_id, data_reserva, data_prevista_retirada, data_prevista_devolucao, status_reserva, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.reservas;

-- Para o modelo do aluno Wesley Conceição da Silva, a tabela é 'RESERVA'.
INSERT INTO staging.stg_reservas (reserva_id, cliente_id, grupo_id, patio_retirada_id, data_reserva, data_prevista_retirada, data_prevista_devolucao, status_reserva, source_company_id, extraction_date)
SELECT
    id_reserva,
    cliente_id,
    NULL AS grupo_id, -- Não presente diretamente, precisa ser inferido via VEICULO.id_veiculo -> GRUPO_VEICULO.
    patio_retirada_id,
    data_inicio AS data_reserva,
    data_inicio AS data_prevista_retirada, -- O modelo de Wesley usa 'data_inicio' para reserva.
    data_fim AS data_prevista_devolucao,
    status AS status_reserva,
    'Empresa_Wesley',
    CURRENT_TIMESTAMP
FROM public.RESERVA;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_locacoes
-- Frequência: Diária, para capturar novas locações e atualizações de devolução.
-- Horário Sugerido: 00:40h
-- Fontes: Public.locacoes, outros esquemas de locações.

INSERT INTO staging.stg_locacoes (locacao_id, reserva_id, cliente_id, motorista_id, veiculo_id, patio_retirada_id, patio_devolucao_id, data_retirada_real, data_devolucao_prevista, data_devolucao_real, valor_total_previsto, valor_total_final, protecoes_adicionais, source_company_id, extraction_date)
SELECT locacao_id, reserva_id, cliente_id, motorista_id, veiculo_id, patio_retirada_id, data_devolucao_id, data_retirada_real, data_devolucao_prevista, data_devolucao_real, valor_total_previsto, valor_total_final, protecoes_adicionais, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.locacoes;

-- Para o modelo do aluno Wesley Conceição da Silva, a tabela é 'LOCACAO'.
INSERT INTO staging.stg_locacoes (locacao_id, reserva_id, cliente_id, motorista_id, veiculo_id, patio_retirada_id, patio_devolucao_id, data_retirada_real, data_devolucao_prevista, data_devolucao_real, valor_total_previsto, valor_total_final, protecoes_adicionais, source_company_id, extraction_date)
SELECT
    id_locacao,
    reserva_id,
    cliente_id,
    NULL AS motorista_id, -- Não presente diretamente.
    veiculo_id,
    NULL AS patio_retirada_id, -- Não presente diretamente em LOCACAO, precisa ser buscado de RESERVA.
    patio_entrega_id AS patio_devolucao_id,
    CURRENT_TIMESTAMP AS data_retirada_real, -- Não presente diretamente, precisa ser inferido ou adicionado.
    CURRENT_TIMESTAMP AS data_devolucao_prevista, -- Não presente diretamente, precisa ser inferido ou adicionado.
    NULL AS data_devolucao_real, -- Não presente diretamente.
    valor_total AS valor_total_previsto,
    NULL AS valor_total_final, -- Não presente diretamente, precisa ser buscado de COBRANCA.
    NULL AS protecoes_adicionais, -- Não presente diretamente.
    'Empresa_Wesley',
    CURRENT_TIMESTAMP
FROM public.LOCACAO;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_cobrancas
-- Frequência: Diária.
-- Horário Sugerido: 00:50h
-- Fontes: Public.cobrancas, outros esquemas.

INSERT INTO staging.stg_cobrancas (cobranca_id, locacao_id, valor, data_emissao, data_vencimento, data_pagamento, status_pagamento, source_company_id, extraction_date)
SELECT cobranca_id, locacao_id, valor, data_emissao, data_vencimento, data_pagamento, status_pagamento, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.cobrancas;

-- Para o modelo do aluno Wesley Conceição da Silva, a tabela é 'COBRANCA'.
INSERT INTO staging.stg_cobrancas (cobranca_id, locacao_id, valor, data_emissao, data_vencimento, data_pagamento, status_pagamento, source_company_id, extraction_date)
SELECT
    id_cobranca,
    locacao_id,
    valor_pago AS valor,
    CURRENT_TIMESTAMP AS data_emissao, -- Não presente diretamente.
    CURRENT_TIMESTAMP AS data_vencimento, -- Não presente diretamente.
    data_pagamento,
    'Pago' AS status_pagamento, -- Assumindo 'Pago' se há registro de cobrança.
    'Empresa_Wesley',
    CURRENT_TIMESTAMP
FROM public.COBRANCA;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_acessorios
-- Frequência: Semanal, ou conforme adição de novos acessórios.
-- Horário Sugerido: Sábados, 01:00h
-- Fontes: Public.acessorios, outros esquemas.

INSERT INTO staging.stg_acessorios (acessorio_id, nome, descricao, source_company_id, extraction_date)
SELECT acessorio_id, nome, descricao, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.acessorios;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_veiculos_acessorios
-- Frequência: Semanal, ou conforme adição/remoção de acessórios dos veículos.
-- Horário Sugerido: Sábados, 01:10h
-- Fontes: Public.veiculos_acessorios, outros esquemas.

INSERT INTO staging.stg_veiculos_acessorios (veiculo_id, acessorio_id, source_company_id, extraction_date)
SELECT veiculo_id, acessorio_id, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.veiculos_acessorios;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_prontuarios_veiculos
-- Frequência: Diária, para capturar registros de manutenção.
-- Horário Sugerido: 01:00h
-- Fontes: Public.prontuarios_veiculos, outros esquemas.

INSERT INTO staging.stg_prontuarios_veiculos (prontuario_id, veiculo_id, data_ocorrencia, tipo, descricao, custo, source_company_id, extraction_date)
SELECT prontuario_id, veiculo_id, data_ocorrencia, tipo, descricao, custo, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.prontuarios_veiculos;

-- -------------------------------------------------------------------------------------------------------
-- Extração para staging.stg_fotos_veiculos
-- Frequência: Semanal, ou conforme adição de novas fotos.
-- Horário Sugerido: Sábados, 01:20h
-- Fontes: Public.fotos_veiculos, outros esquemas.

INSERT INTO staging.stg_fotos_veiculos (foto_id, veiculo_id, url_foto, tipo, data_upload, source_company_id, extraction_date)
SELECT foto_id, veiculo_id, url_foto, tipo, data_upload, 'Empresa_Galeao', CURRENT_TIMESTAMP FROM public.fotos_veiculos;

-- =======================================================================================================
-- Observações Finais sobre o Script ETL de Staging:
-- 1. Mapeamento de Schemas/Tabelas: Para um ambiente real, 'public' seria substituído pelos
--    nomes dos schemas ou bancos de dados de cada empresa associada.
-- 2. Diferenças de Schema: Foi necessário fazer adaptações (e.g., NULLs para campos ausentes,
--    assunções de valores padrão) para integrar o modelo de Wesley Conceição da Silva, que possui
--    algumas diferenças em relação ao esquema base do seu grupo. Em um projeto real,
--    essas diferenças seriam tratadas com maior detalhe, incluindo a criação de mapeamentos
--    explícitos e regras de transformação complexas.
-- 3. Chaves Naturais: A unificação de dados de múltiplas fontes via chaves naturais (e.g., 'cliente_id')
--    na área de staging pode gerar conflitos se IDs não forem globalmente únicos.
--    O uso de 'source_company_id' combinado com o 'id' original ajuda a manter a unicidade
--    e rastreabilidade.
-- 4. Tempos de Acionamento: Os horários sugeridos são apenas exemplos. A frequência e o
--    cronograma reais dependeriam da volumetria dos dados, da criticidade da informação e
--    das janelas de manutenção disponíveis em cada sistema OLTP.
-- 5. Tratamento de Erros: Em um ambiente de produção, este script seria parte de um pipeline
--    ETL mais robusto, com tratamento de erros, logs e mecanismos de reprocessamento.
-- =======================================================================================================
