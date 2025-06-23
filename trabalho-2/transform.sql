-- Avaliação 02: Modelagem de Data Warehouse
-- Parte 2: 
-- Grupo:
-- Augusto Fernandes Nodari 						DRE: 121131778 
-- Henrique Almico Dias da Silva  					DRE: 124238228
-- João Pedro de Faria Sales  						DRE: 121056457 
-- Vitor Rayol Taranto                              DRE: 121063585

INSERT INTO dw.DimTempo (data_completa, ano, mes, dia, trimestre, semestre, dia_da_semana, nome_mes, nome_dia_semana)
SELECT
    datum AS data_completa,
    EXTRACT(YEAR FROM datum) AS ano,
    EXTRACT(MONTH FROM datum) AS mes,
    EXTRACT(DAY FROM datum) AS dia,
    EXTRACT(QUARTER FROM datum) AS trimestre,
    CASE WHEN EXTRACT(QUARTER FROM datum) <= 2 THEN 1 ELSE 2 END AS semestre,
    EXTRACT(ISODOW FROM datum) AS dia_da_semana,
    TO_CHAR(datum, 'TMMonth') AS nome_mes,
    TO_CHAR(datum, 'TMDay') AS nome_dia_semana
FROM (
    SELECT '2020-01-01'::DATE + s.a AS datum
    FROM generate_series(0, 10957) AS s(a)
) AS series_datas
ON CONFLICT (data_completa) DO NOTHING;

INSERT INTO dw.DimPatio (patio_id, nome_patio, endereco_patio)
SELECT DISTINCT
    s.patio_id,
    s.nome,
    s.endereco
FROM staging.stg_patios s
ON CONFLICT DO NOTHING;

INSERT INTO dw.DimGrupoVeiculo (grupo_id, nome_grupo, valor_diaria_base)
SELECT DISTINCT
    s.grupo_id,
    s.nome_grupo,
    s.valor_diaria_base
FROM staging.stg_grupos_veiculos s
ON CONFLICT DO NOTHING;

INSERT INTO dw.DimVeiculo (veiculo_id, placa, marca, modelo, cor, ano_fabricacao, mecanizacao, grupo_nome, grupo_descricao)
SELECT DISTINCT
    sv.veiculo_id,
    sv.placa,
    sv.marca,
    sv.modelo,
    sv.cor,
    sv.ano_fabricacao,
    sv.mecanizacao,
    sgv.nome_grupo,
    sgv.descricao
FROM staging.stg_veiculos sv
JOIN staging.stg_grupos_veiculos sgv ON sv.grupo_id = sgv.grupo_id
ON CONFLICT DO NOTHING;

WITH StagingClientes AS (
    SELECT
        cliente_id,
        nome_completo,
        tipo_pessoa,
        endereco_cidade AS cidade,
        endereco_estado AS estado,
        ROW_NUMBER() OVER(PARTITION BY cliente_id ORDER BY extraction_date DESC) as rn
    FROM staging.stg_clientes
),
UpdatesNeeded AS (
    SELECT
        sc.cliente_id,
        sc.nome_completo,
        sc.tipo_pessoa,
        sc.cidade,
        sc.estado
    FROM StagingClientes sc
    JOIN dw.DimCliente dc ON sc.cliente_id = dc.cliente_id
    WHERE sc.rn = 1 AND dc.versao_atual = TRUE AND
          (sc.nome_completo <> dc.nome_completo OR sc.cidade <> dc.cidade OR sc.estado <> dc.estado)
)
UPDATE dw.DimCliente
SET data_fim = CURRENT_TIMESTAMP, versao_atual = FALSE
WHERE cliente_id IN (SELECT cliente_id FROM UpdatesNeeded) AND versao_atual = TRUE;

INSERT INTO dw.DimCliente (cliente_id, nome_completo, tipo_pessoa, cidade, estado, data_inicio, data_fim, versao_atual)
SELECT
    s.cliente_id,
    s.nome_completo,
    s.tipo_pessoa,
    s.cidade,
    s.estado,
    CURRENT_TIMESTAMP as data_inicio,
    NULL as data_fim,
    TRUE as versao_atual
FROM (
    SELECT
        cliente_id,
        nome_completo,
        tipo_pessoa,
        endereco_cidade AS cidade,
        endereco_estado AS estado
    FROM staging.stg_clientes
) s
WHERE s.cliente_id IN (
    SELECT cliente_id FROM StagingClientes WHERE rn = 1
    EXCEPT
    SELECT cliente_id FROM dw.DimCliente WHERE versao_atual = TRUE
) OR s.cliente_id IN (SELECT cliente_id FROM UpdatesNeeded);


INSERT INTO dw.FatoReservas (reserva_id, sk_data_reserva, sk_data_prevista_retirada, sk_cliente, sk_grupo_veiculo, sk_patio_retirada, status_reserva)
SELECT
    sr.reserva_id,
    dt_res.sk_tempo,
    dt_ret.sk_tempo,
    dc.sk_cliente,
    dgv.sk_grupo_veiculo,
    dp.sk_patio,
    sr.status_reserva
FROM staging.stg_reservas sr
JOIN dw.DimTempo dt_res ON dt_res.data_completa = sr.data_reserva::DATE
JOIN dw.DimTempo dt_ret ON dt_ret.data_completa = sr.data_prevista_retirada::DATE
JOIN dw.DimCliente dc ON dc.cliente_id = sr.cliente_id AND dc.versao_atual = TRUE
JOIN dw.DimGrupoVeiculo dgv ON dgv.grupo_id = sr.grupo_id
JOIN dw.DimPatio dp ON dp.patio_id = sr.patio_retirada_id
ON CONFLICT (reserva_id) DO NOTHING;

INSERT INTO dw.FatoLocacoes (locacao_id, sk_data_retirada, sk_data_devolucao, sk_cliente, sk_veiculo, sk_patio_retirada, sk_patio_devolucao, valor_total_previsto, valor_total_final, dias_locacao_previstos, dias_locacao_reais)
SELECT
    sl.locacao_id,
    dt_ret.sk_tempo,
    dt_dev.sk_tempo,
    dc.sk_cliente,
    dv.sk_veiculo,
    dp_ret.sk_patio,
    dp_dev.sk_patio,
    sl.valor_total_previsto,
    sl.valor_total_final,
    (sl.data_devolucao_prevista::DATE - sl.data_retirada_real::DATE) AS dias_locacao_previstos,
    CASE WHEN sl.data_devolucao_real IS NOT NULL THEN (sl.data_devolucao_real::DATE - sl.data_retirada_real::DATE) ELSE NULL END AS dias_locacao_reais
FROM staging.stg_locacoes sl
JOIN dw.DimTempo dt_ret ON dt_ret.data_completa = sl.data_retirada_real::DATE
LEFT JOIN dw.DimTempo dt_dev ON dt_dev.data_completa = sl.data_devolucao_real::DATE
JOIN dw.DimCliente dc ON dc.cliente_id = sl.cliente_id AND dc.versao_atual = TRUE
JOIN dw.DimVeiculo dv ON dv.veiculo_id = sl.veiculo_id
JOIN dw.DimPatio dp_ret ON dp_ret.patio_id = sl.patio_retirada_id
LEFT JOIN dw.DimPatio dp_dev ON dp_dev.patio_id = sl.patio_devolucao_id
ON CONFLICT (locacao_id) DO UPDATE SET
    sk_data_devolucao = EXCLUDED.sk_data_devolucao,
    sk_patio_devolucao = EXCLUDED.sk_patio_devolucao,
    valor_total_final = EXCLUDED.valor_total_final,
    dias_locacao_reais = EXCLUDED.dias_locacao_reais;
