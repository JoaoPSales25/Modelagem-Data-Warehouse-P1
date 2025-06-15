

CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE dw.DimTempo (
    sk_tempo SERIAL PRIMARY KEY,
    data_completa DATE NOT NULL UNIQUE,
    ano INT NOT NULL,
    mes INT NOT NULL,
    dia INT NOT NULL,
    trimestre INT NOT NULL,
    semestre INT NOT NULL,
    dia_da_semana INT NOT NULL,
    nome_mes VARCHAR(20) NOT NULL,
    nome_dia_semana VARCHAR(20) NOT NULL,
    feriado BOOLEAN DEFAULT FALSE
);

CREATE TABLE dw.DimCliente (
    sk_cliente SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    nome_completo VARCHAR(255) NOT NULL,
    tipo_pessoa CHAR(1) NOT NULL,
    cidade VARCHAR(100),
    estado VARCHAR(50),
    data_inicio TIMESTAMP NOT NULL,
    data_fim TIMESTAMP,
    versao_atual BOOLEAN DEFAULT TRUE
);

CREATE TABLE dw.DimVeiculo (
    sk_veiculo SERIAL PRIMARY KEY,
    veiculo_id INT NOT NULL,
    placa VARCHAR(10) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    cor VARCHAR(30) NOT NULL,
    ano_fabricacao INT NOT NULL,
    mecanizacao VARCHAR(20) NOT NULL,
    grupo_nome VARCHAR(50) NOT NULL,
    grupo_descricao TEXT
);

CREATE TABLE dw.DimPatio (
    sk_patio SERIAL PRIMARY KEY,
    patio_id INT NOT NULL,
    nome_patio VARCHAR(100) NOT NULL,
    endereco_patio VARCHAR(255) NOT NULL
);

CREATE TABLE dw.DimGrupoVeiculo (
    sk_grupo_veiculo SERIAL PRIMARY KEY,
    grupo_id INT NOT NULL,
    nome_grupo VARCHAR(50) NOT NULL,
    valor_diaria_base DECIMAL(10, 2) NOT NULL
);

CREATE TABLE dw.FatoLocacoes (
    locacao_id INT PRIMARY KEY,
    sk_data_retirada INT NOT NULL,
    sk_data_devolucao INT,
    sk_cliente INT NOT NULL,
    sk_veiculo INT NOT NULL,
    sk_patio_retirada INT NOT NULL,
    sk_patio_devolucao INT,
    valor_total_previsto DECIMAL(10, 2) NOT NULL,
    valor_total_final DECIMAL(10, 2),
    dias_locacao_previstos INT,
    dias_locacao_reais INT,
    quantidade_locacoes INT DEFAULT 1,
    CONSTRAINT fk_data_retirada FOREIGN KEY (sk_data_retirada) REFERENCES dw.DimTempo(sk_tempo),
    CONSTRAINT fk_data_devolucao FOREIGN KEY (sk_data_devolucao) REFERENCES dw.DimTempo(sk_tempo),
    CONSTRAINT fk_cliente FOREIGN KEY (sk_cliente) REFERENCES dw.DimCliente(sk_cliente),
    CONSTRAINT fk_veiculo FOREIGN KEY (sk_veiculo) REFERENCES dw.DimVeiculo(sk_veiculo),
    CONSTRAINT fk_patio_retirada FOREIGN KEY (sk_patio_retirada) REFERENCES dw.DimPatio(sk_patio),
    CONSTRAINT fk_patio_devolucao FOREIGN KEY (sk_patio_devolucao) REFERENCES dw.DimPatio(sk_patio)
);

CREATE TABLE dw.FatoReservas (
    reserva_id INT PRIMARY KEY,
    sk_data_reserva INT NOT NULL,
    sk_data_prevista_retirada INT NOT NULL,
    sk_cliente INT NOT NULL,
    sk_grupo_veiculo INT NOT NULL,
    sk_patio_retirada INT NOT NULL,
    status_reserva VARCHAR(20),
    quantidade_reservas INT DEFAULT 1,
    CONSTRAINT fk_data_reserva FOREIGN KEY (sk_data_reserva) REFERENCES dw.DimTempo(sk_tempo),
    CONSTRAINT fk_data_prevista_retirada FOREIGN KEY (sk_data_prevista_retirada) REFERENCES dw.DimTempo(sk_tempo),
    CONSTRAINT fk_cliente FOREIGN KEY (sk_cliente) REFERENCES dw.DimCliente(sk_cliente),
    CONSTRAINT fk_grupo_veiculo FOREIGN KEY (sk_grupo_veiculo) REFERENCES dw.DimGrupoVeiculo(sk_grupo_veiculo),
    CONSTRAINT fk_patio_retirada FOREIGN KEY (sk_patio_retirada) REFERENCES dw.DimPatio(sk_patio)
);
