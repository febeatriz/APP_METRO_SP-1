-- Criar o banco de dados
CREATE DATABASE metro_sp;
USE metro_sp;

-- Tabela de cargos
CREATE TABLE cargos (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de usuários
CREATE TABLE usuarios (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    foto_perfil BLOB,
    cargo_id INT UNSIGNED,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cargo_id) REFERENCES cargos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de tipos de extintores
CREATE TABLE Tipos_Extintores (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Linhas
CREATE TABLE Linhas (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    codigo VARCHAR(10) UNIQUE,
    descricao TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Localizações, referenciando a tabela de Linhas
CREATE TABLE Localizacoes (
    ID_Localizacao INT PRIMARY KEY AUTO_INCREMENT,
    Linha_ID INT UNSIGNED,
    Area VARCHAR(50) NOT NULL,
    Subarea VARCHAR(50),
    Local_Detalhado VARCHAR(100),
    Observacoes TEXT,
    FOREIGN KEY (Linha_ID) REFERENCES Linhas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Extintores, referenciando Tipo e Localização
CREATE TABLE Extintores (
    Patrimonio INT PRIMARY KEY,
    Tipo_ID INT UNSIGNED NOT NULL,
    Capacidade VARCHAR(10),
    Codigo_Fabricante VARCHAR(50),
    Data_Fabricacao DATE,
    Data_Validade DATE,
    Ultima_Recarga DATE,
    Proxima_Inspecao DATE,
    Status VARCHAR(20),
    Linha_ID INT UNSIGNED,
    ID_Localizacao INT,
    QR_Code VARCHAR(100),
    Observacoes TEXT,
	FOREIGN KEY (Linha_ID) REFERENCES Linhas(id),
    FOREIGN KEY (Tipo_ID) REFERENCES Tipos_Extintores(id),
    FOREIGN KEY (ID_Localizacao) REFERENCES Localizacoes(ID_Localizacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de Histórico de Manutenção dos Extintores
CREATE TABLE Historico_Manutencao (
    ID_Manutencao INT PRIMARY KEY AUTO_INCREMENT,
    ID_Extintor INT,
    Data_Manutencao DATE NOT NULL,
    Descricao TEXT,
    Responsavel_Manutencao VARCHAR(100),
    Observacoes TEXT,
    FOREIGN KEY (ID_Extintor) REFERENCES Extintores(Patrimonio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inserindo dados de exemplo
-- Cargos
INSERT INTO cargos (nome) VALUES
('Técnico de Segurança'),
('Supervisor de Operações'),
('Engenheiro de Manutenção');

-- Usuários
INSERT INTO usuarios (nome, email, senha, matricula, cargo_id) VALUES
('Carlos Silva', 'carlos.silva@metrosp.com.br', 'senha123', 'MTR001', 1),
('Ana Oliveira', 'ana.oliveira@metrosp.com.br', 'senha123', 'MTR002', 2),
('Roberto Souza', 'roberto.souza@metrosp.com.br', 'senha123', 'MTR003', 3),
('Lucas Silva Barboza', 'lucas.silva@metrosp.com.br', 'senha123', 'MTR004', 3);

-- Tipos de Extintores
INSERT INTO Tipos_Extintores (tipo) VALUES
('N2'),
('Mangueira de Incêndio 1 ½'),
('Mangueira de Incêndio 2 ½'),
('AP – Água Pressurizada'),
('CO2 – Dióxido de Carbono'),
('PQS – Pó Químico Seco'),
('BC – Pó Químico Seco BC'),
('ABC – Pó Químico Seco ABC');

-- Linhas
INSERT INTO Linhas (nome, codigo, descricao) VALUES
('Linha Azul', 'L1', 'Linha principal da zona norte-sul'),
('Linha Verde', 'L2', 'Linha secundária com estações de interconexão'),
('Linha Vermelha', 'L3', 'Linha leste-oeste com alta demanda');

-- Localizações
INSERT INTO Localizacoes (Linha_ID, Area, Subarea, Local_Detalhado, Observacoes) VALUES
(1, 'Estação Sé', 'Plataforma', 'Próximo à escada rolante', 'Alta circulação de pessoas'),
(2, 'Estação Ana Rosa', 'Sala Técnica', 'Próximo ao painel elétrico', 'Acesso restrito'),
(3, 'Estação Barra Funda', 'Área de Embarque', 'Próximo ao guichê de informações', 'Monitoramento de segurança necessário');

-- Extintores
INSERT INTO Extintores (Patrimonio, Tipo_ID, Capacidade, Codigo_Fabricante, Data_Fabricacao, Data_Validade, Ultima_Recarga, Proxima_Inspecao, Status, ID_Localizacao, QR_Code, Observacoes) VALUES
(1001, 4, '10L', 'FAB12345', '2021-01-10', '2026-01-10', '2023-01-10', '2024-01-10', 'Operacional', 1, 'QR001', 'Extintor de Água Pressurizada em bom estado'),
(1002, 5, '6kg', 'FAB67890', '2022-05-15', '2027-05-15', '2023-06-01', '2024-06-01', 'Operacional', 2, 'QR002', 'Extintor de CO2 em bom estado'),
(1003, 8, '4kg', 'FAB11223', '2020-08-20', '2025-08-20', '2023-08-20', '2024-08-20', 'Em Manutenção', 3, 'QR003', 'Extintor ABC com danos leves na carcaça');

-- Histórico de Manutenção
INSERT INTO Historico_Manutencao (ID_Extintor, Data_Manutencao, Descricao, Responsavel_Manutencao, Observacoes) VALUES
(1001, '2023-01-10', 'Recarga e inspeção completa', 'Carlos Silva', 'Nenhuma observação adicional'),
(1002, '2023-06-01', 'Recarga e troca de válvula', 'Ana Oliveira', 'Substituição da válvula devido a desgaste'),
(1003, '2023-08-20', 'Inspeção e reparo leve', 'Roberto Souza', 'Danos leves na carcaça foram reparados');
