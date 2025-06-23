-- Avaliação 02: Modelagem de Data Warehouse
-- Parte 2: 
-- Grupo:
-- Augusto Fernandes Nodari 						DRE: 121131778 
-- Henrique Almico Dias da Silva  					DRE: 124238228
-- João Pedro de Faria Sales  						DRE: 121056457 
-- Vitor Rayol Taranto                              DRE: 121063585


-- Relatório A: Controle de Pátio
WITH UltimaLocalizacaoVeiculo AS (
    SELECT
        fl.sk_veiculo,
        fl.sk_patio_devolucao,
        ROW_NUMBER() OVER(PARTITION BY fl.sk_veiculo ORDER BY fl.sk_data_devolucao DESC) as rn
    FROM dw.FatoLocacoes fl
    WHERE fl.sk_data_devolucao IS NOT NULL
)
SELECT
    dp.nome_patio AS patio,
    dv.grupo_nome,
    dv.marca,
    dv.modelo,
    dv.mecanizacao,
    COUNT(DISTINCT ulv.sk_veiculo) AS total_veiculos
FROM UltimaLocalizacaoVeiculo ulv
JOIN dw.DimVeiculo dv ON ulv.sk_veiculo = dv.sk_veiculo
JOIN dw.DimPatio dp ON ulv.sk_patio_devolucao = dp.sk_patio
WHERE ulv.rn = 1
GROUP BY
    dp.nome_patio,
    dv.grupo_nome,
    dv.marca,
    dv.modelo,
    dv.mecanizacao
ORDER BY
    patio,
    total_veiculos DESC;


-- Relatório B: Controle das Locações Ativas
SELECT
    dv.grupo_nome,
    COUNT(fl.locacao_id) AS total_locacoes_ativas,
    AVG(CURRENT_DATE - dt_ret.data_completa) AS media_dias_alugado_ate_agora,
    AVG(fl.dias_locacao_previstos - (CURRENT_DATE - dt_ret.data_completa)) AS media_dias_restantes_previstos
FROM dw.FatoLocacoes fl
JOIN dw.DimVeiculo dv ON fl.sk_veiculo = dv.sk_veiculo
JOIN dw.DimTempo dt_ret ON fl.sk_data_retirada = dt_ret.sk_tempo
WHERE fl.sk_data_devolucao IS NULL
GROUP BY
    dv.grupo_nome
ORDER BY
    total_locacoes_ativas DESC;


-- Relatório C: Controle de Reservas Futuras

SELECT
    dgv.nome_grupo,
    dp.nome_patio AS patio_retirada,
    dc.cidade AS cidade_cliente,
    (dt_ret.data_completa - CURRENT_DATE) AS dias_para_retirada,
    COUNT(fr.reserva_id) AS total_reservas
FROM dw.FatoReservas fr
JOIN dw.DimGrupoVeiculo dgv ON fr.sk_grupo_veiculo = dgv.sk_grupo_veiculo
JOIN dw.DimPatio dp ON fr.sk_patio_retirada = dp.sk_patio
JOIN dw.DimCliente dc ON fr.sk_cliente = dc.sk_cliente
JOIN dw.DimTempo dt_ret ON fr.sk_data_prevista_retirada = dt_ret.sk_tempo
WHERE fr.status_reserva = 'Ativa' AND dt_ret.data_completa >= CURRENT_DATE
GROUP BY
    dgv.nome_grupo,
    patio_retirada,
    cidade_cliente,
    dias_para_retirada
ORDER BY
    dias_para_retirada ASC,
    total_reservas DESC;


-- Relatório D: Grupos de Veículos Mais Alugados

SELECT
    dv.grupo_nome,
    dc.cidade AS cidade_cliente,
    COUNT(fl.locacao_id) AS total_locacoes
FROM dw.FatoLocacoes fl
JOIN dw.DimVeiculo dv ON fl.sk_veiculo = dv.sk_veiculo
JOIN dw.DimCliente dc ON fl.sk_cliente = dc.sk_cliente
GROUP BY
    dv.grupo_nome,
    cidade_cliente
ORDER BY
    total_locacoes DESC;


-- Análise: Matriz de Movimentação entre Pátios (Cadeia de Markov)

WITH MovimentacaoContagem AS (
    SELECT
        dp_ret.nome_patio AS patio_origem,
        dp_dev.nome_patio AS patio_destino,
        COUNT(fl.locacao_id) AS total_viagens
    FROM dw.FatoLocacoes fl
    JOIN dw.DimPatio dp_ret ON fl.sk_patio_retirada = dp_ret.sk_patio
    JOIN dw.DimPatio dp_dev ON fl.sk_patio_devolucao = dp_dev.sk_patio
    WHERE fl.sk_patio_devolucao IS NOT NULL
    GROUP BY
        patio_origem,
        patio_destino
),
TotalSaidasPorPatio AS (
    SELECT
        mc.patio_origem,
        SUM(mc.total_viagens) AS total_saidas
    FROM MovimentacaoContagem mc
    GROUP BY
        mc.patio_origem
)
SELECT
    mc.patio_origem,
    mc.patio_destino,
    (mc.total_viagens::DECIMAL / tsp.total_saidas) * 100 AS percentual_movimentacao
FROM MovimentacaoContagem mc
JOIN TotalSaidasPorPatio tsp ON mc.patio_origem = tsp.patio_origem
ORDER BY
    mc.patio_origem,
    percentual_movimentacao DESC;
