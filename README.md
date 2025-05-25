### DELETAR ESSE README

Estou fazendo ele para facilitar caso queiram mexer em algo ou refazer usando outra IA

## Descrição do projeto

[Link Docs](https://docs.google.com/document/d/1CJpnWyNE_4B8kO2N9JbzJtQpviRrUeAEqrEtUO0f1Ls/edit?usp=sharing)

## Dicionário de Dados

[Link Docs](https://docs.google.com/document/d/1K5Jhc2EFSNiQyqlwt_XlVp-VQizl6GsnHKK9_ORXV0o/edit?usp=sharing)

## Modelo Conceitual:

[Mermaid](https://www.mermaidchart.com/play?utm_source=mermaid_live_editor&utm_medium=toggle#pako:eNp1kkGOgyAUhq9C2PcC3TGUaUw6xaB2ZTIh-saYqBjULqo9zCznHL3YQK0tnTJs-fjfxw8jzlQOeI1Bb0pZaFmnDTKL7gK2jxmaptVqGpFgERMHgtboS568xI5TQgk3hAZZlSfppT54zEUQxTZJDr3Sd_Cxc7bo5ARmqskHM3UGF5UbthVJyD8PLKDJzsIpvvygVmqJhjrF3iMhiYM7CrUHtLbKvVOKC7hGSovO8LI7zakPBVkNhXxmXiZr6EsTmIMz3YWVC-dwVNURnl2fxo-I8jdB9tQWa1UXycXq37Za0D00GSC3MPeUMTmQLbnC0PWX71lD_mVvHqHg-zghInDHtKrrhtLLv5t3d8geao_4iAhlUWQ-iJt2A63cS7-Vyq6_cNXda0P4_AsNVt_v)

```
erDiagram

    CLIENTE ||--|{ RESERVA : faz
    CLIENTE ||--|{ LOCACAO : realiza
    CLIENTE ||--|{ MOTORISTA : autoriza
    MOTORISTA }|--|| LOCACAO : conduz

    RESERVA }|--|| GRUPO_VEICULO : "é para um"
    RESERVA }|--|| PATIO : "é em um"
    RESERVA ||--o{ LOCACAO : "gera uma"

    LOCACAO ||--|| VEICULO : aluga
    LOCACAO }|--|| PATIO : "retira de um"
    LOCACAO }|--o| PATIO : "devolve em um"
    LOCACAO ||--|{ COBRANCA : gera

    VEICULO }|--|| GRUPO_VEICULO : "pertence a um"
    VEICULO }|--o| VAGA : "está em uma"
    VEICULO ||--|{ PRONTUARIO_VEICULO : possui
    VEICULO ||--|{ FOTO_VEICULO : tem
    VEICULO }|--|{ ACESSORIO : possui

    VAGA }|--|| PATIO : "localiza-se em um"

```

## Modelo Lógico

[Mermaid](https://www.mermaidchart.com/play?utm_source=mermaid_live_editor&utm_medium=toggle#pako:eNqdV81yEzEMfpWdnMkL9BZoGDrQwkBhOGTGo3qV1LBr7djeHJr0geA1eDFk7693vW2hlzaRZH3-JH1yTytJOa4uVuv1eqcl6b06XOx0lrl7LPEiy8H83OlgRHOp4GCg9OYsk4VC7dBmp-az_7m6ue2-FyrPPr0fTN82n9-823zONJUoJJVVgY7mZlnthdTVj-zrKDZYnKpIVGgtwTwMS1BFFNNZHBa4J42JGJ2jQUlCqhzypxzQOshHYG-vrrdfbjfXn5geB0JCDtaZ1uGx-VWSI6M4cEZQb5lSNGHv7X-wp--TJPD3jNLhgROP2Lvc3G6D7QjFiIP2BgYtmuMcf_v9P6D3poOpuX4JQwVOkTDolGEepx4Tqtvci_bK4DFQ2533vGeORypqCQk62exqGydtySlIgqR594fvgVLkjHh7-3Leom6ZGo-oZF38B62DR3_9Z5lvTzIIxaLXcFrH7wtc4xMvt2-urjcfMu5JMsKRg6I7jJ722isdQdt-50sacugLJSBXUpEGZaNCthTOCjmiNiVjVcFlTs_aPVirItOT_X-EAwjuM77AwtCXYGRC80oW7iIlAmTiDKBJ7OHOqNCaiYNQglYPsfH1x48ftpubDAzrjW65yxeHJOI03NWKJWp7Khb3Q_CIKAzFzNFKf4vFPsgVsMCJO7CxlIVWn-FoBuAJHMn6dltheR0whB5j12Vc5HmL-conhKLHlWoGXtfqQMLHzotFsq560WtTS7ozoOU8fWdIQRjJ2BhExPYiAVgqa6Mi-T0TTEfUUpWsdUlrxZeaGCdSPPForwjSPwtMosS95cVlTjXaRCrEcr5INV7NZn0CZ3Do-tSQZiXwJy9Oz-CTKtzCRhg4JpYH46uQUBT_xHr5yMnaTuqw5121DNxb_wFyB6o2rOyU6okJ3LgJ66ogyONJ6F6s5_N6TafxE-0i262g9h8fYLdKuJ9Pw3vIO-_hYcmvfxp4P7_b-Myhcfkv06cYIUgFe-Gt-zx9_kdi13PsWvEyEAc0YGbu7clTUfZRlgoW9rCMRV0uRbbqGdLwIv7ze3gMYB_UowlB5yzKA0XNUoe2Qqn23E2eCZxFPjaRo3RtHv9KSXpT5B1eFEfF7kuwTiM19BGeMNHr4LgyPfwWVIq9Co3jSUIBI_KGwKZKjfJ79yDOzaYP9-egeboWZkpqmjJbW6ulqKR8-DCHpbj3Dyge5TE70wMmA9yFhskdokaYnoH75xdfUoT_3IYKNozMi-1L5WdlbZGTtZSuHv8CZ0yIxg)

```
erDiagram
    clientes {
        INT cliente_id PK
        VARCHAR nome_completo
        VARCHAR cpf_cnpj UK
        CHAR tipo_pessoa
        VARCHAR email UK
        VARCHAR telefone
        VARCHAR endereco_cidade
        VARCHAR endereco_estado
        TIMESTAMP data_cadastro
    }
    motoristas {
        INT motorista_id PK
        INT cliente_id FK
        VARCHAR nome_completo
        VARCHAR cnh UK
        VARCHAR cnh_categoria
        DATE cnh_validade
    }
    reservas {
        INT reserva_id PK
        INT cliente_id FK
        INT grupo_id FK
        INT patio_retirada_id FK
        TIMESTAMP data_reserva
        TIMESTAMP data_prevista_retirada
        TIMESTAMP data_prevista_devolucao
        VARCHAR status_reserva
    }
    locacoes {
        INT locacao_id PK
        INT reserva_id FK
        INT cliente_id FK
        INT motorista_id FK
        INT veiculo_id FK
        INT patio_retirada_id FK
        INT patio_devolucao_id FK
        TIMESTAMP data_retirada_real
        TIMESTAMP data_devolucao_prevista
        TIMESTAMP data_devolucao_real
        DECIMAL valor_total_previsto
        DECIMAL valor_total_final
        TEXT protecoes_adicionais
    }
    veiculos {
        INT veiculo_id PK
        VARCHAR placa UK
        VARCHAR chassi UK
        INT grupo_id FK
        INT vaga_atual_id FK
        VARCHAR marca
        VARCHAR modelo
        VARCHAR cor
        INT ano_fabricacao
        VARCHAR mecanizacao
        BOOLEAN ar_condicionado
        VARCHAR status
    }
    grupos_veiculos {
        INT grupo_id PK
        VARCHAR nome_grupo UK
        TEXT descricao
        DECIMAL valor_diaria_base
    }
    patios {
        INT patio_id PK
        VARCHAR nome UK
        VARCHAR endereco
        TIMESTAMP data_criacao
    }
    vagas {
        INT vaga_id PK
        INT patio_id FK
        VARCHAR codigo_vaga
        BOOLEAN ocupada
    }
    cobrancas {
        INT cobranca_id PK
        INT locacao_id FK
        DECIMAL valor
        TIMESTAMP data_emissao
        DATE data_vencimento
        DATE data_pagamento
        VARCHAR status_pagamento
    }
    acessorios {
        INT acessorio_id PK
        VARCHAR nome UK
        TEXT descricao
    }
    veiculos_acessorios {
        INT veiculo_id PK, FK
        INT acessorio_id PK, FK
    }
    prontuarios_veiculos {
        INT prontuario_id PK
        INT veiculo_id FK
        DATE data_ocorrencia
        VARCHAR tipo
        TEXT descricao
        DECIMAL custo
    }
    fotos_veiculos {
        INT foto_id PK
        INT veiculo_id FK
        VARCHAR url_foto
        VARCHAR tipo
        TIMESTAMP data_upload
    }

    clientes ||--o{ motoristas : "autoriza"
    clientes ||--|{ reservas : "faz"
    clientes ||--|{ locacoes : "realiza_pagamento_para"
    motoristas ||--|{ locacoes : "conduz"

    reservas }o--|| locacoes : "pode_gerar"
    reservas ||--|{ grupos_veiculos : "solicita_de_um"
    reservas ||--|{ patios : "prevê_retirada_em"

    locacoes ||--|| veiculos : "aluga_especificamente"
    locacoes }|--|| patios : "retirado_de"
    locacoes }|--o| patios : "devolvido_em"
    locacoes ||--|{ cobrancas : "gera_cobranca_para"

    veiculos }|--|| grupos_veiculos : "pertence_a_um"
    veiculos }o--|| vagas : "ocupa_atualmente_uma"
    veiculos ||--|{ veiculos_acessorios : "possui"
    veiculos ||--|{ prontuarios_veiculos : "tem_historico_em"
    veiculos ||--|{ fotos_veiculos : "tem_foto_em"

    acessorios ||--|{ veiculos_acessorios : "é_um_tipo_de"

    vagas }|--|| patios : "localiza-se_em_um"
```
