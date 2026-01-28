CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    email VARCHAR(80),
    senha VARCHAR(255)
);
ALTER TABLE usuario ADD COLUMN tipo ENUM('admin', 'tecnico') NOT NULL;
ALTER TABLE usuario ADD COLUMN ativo BOOLEAN DEFAULT TRUE;

CREATE TABLE cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100)
);
ALTER TABLE cliente
  ADD COLUMN cpf_cnpj VARCHAR(20) DEFAULT NULL,
  ADD COLUMN endereco TEXT DEFAULT NULL,
  ADD COLUMN observacoes TEXT DEFAULT NULL;

CREATE TABLE metodo_pagamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL
);
ALTER TABLE ordem_servico 
ALTER COLUMN metodo_pagamento_id SET DEFAULT 4;

insert into metodo_pagamento (nome) values('Dinheiro'), ('Cartão de Crédito'), ('Cartão de Débito'), ('Pix'), ('Transferência'), ('Boleto');

CREATE TABLE servico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco_padrao DECIMAL(10,2) NOT NULL
);

CREATE TABLE peca (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco_padrao DECIMAL(10,2) NOT NULL,
    estoque INT DEFAULT 0
);

CREATE TABLE ordem_servico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    usuario_id INT NOT NULL,
    metodo_pagamento_id INT,
    status ENUM('aberta','em_andamento','aguardando_pecas','aguardando_aprovacao','concluida','cancelada') DEFAULT 'aberta',
    data_abertura DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_fechamento DATETIME,
    titulo VARCHAR(200) NOT NULL,
    descricao_entrada TEXT,
    descricao_saida TEXT,
    prioridade ENUM('baixa','media','alta','urgente') DEFAULT 'media',
    desconto_peca DECIMAL(5,2) DEFAULT 0.00,
    valor_servico DECIMAL(10,2) DEFAULT 0.00,
    observacoes TEXT,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id),
    FOREIGN KEY (usuario_id) REFERENCES usuario(id),
    FOREIGN KEY (metodo_pagamento_id) REFERENCES metodo_pagamento(id)
);

CREATE TABLE ordem_servico_servico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ordem_id INT NOT NULL,
    servico_id INT NOT NULL,
    quantidade INT DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(5,2) DEFAULT 0.00,
    FOREIGN KEY (ordem_id) REFERENCES ordem_servico(id),
    FOREIGN KEY (servico_id) REFERENCES servico(id)
);

CREATE TABLE ordem_servico_peca (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ordem_id INT NOT NULL,
    peca_id INT NOT NULL,
    quantidade INT DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(5,2) DEFAULT 0.00,
    FOREIGN KEY (ordem_id) REFERENCES ordem_servico(id),
    FOREIGN KEY (peca_id) REFERENCES peca(id)
);

-- ##### Views para relatórios ##### --

-- View: vw_ordem_servico_servico
-- Mostra os serviços vinculados a cada ordem com cálculo de subtotal:
CREATE VIEW vw_ordem_servico_servico AS
SELECT
    oss.id,
    oss.ordem_id,
    oss.servico_id,
    s.nome AS nome_servico,
    s.preco_padrao AS p_padrao, 
    oss.quantidade,
    oss.preco_unitario,
    oss.desconto,
    (oss.quantidade * oss.preco_unitario * (1 - oss.desconto / 100)) AS subtotal
FROM ordem_servico_servico oss
JOIN servico s ON s.id = oss.servico_id;

-- ##### View: vw_ordem_servico_peca ##### --
-- Mostra as peças vinculadas à ordem com cálculo de subtotal:
CREATE VIEW vw_ordem_servico_peca AS
SELECT
    osp.id,
    osp.ordem_id,
    osp.peca_id,
    p.nome AS nome_peca,
    p.preco_padrao AS p_padrao,
    osp.quantidade,
    osp.preco_unitario,
    osp.desconto,
    (osp.quantidade * osp.preco_unitario * (1 - osp.desconto / 100)) AS subtotal
FROM ordem_servico_peca osp
JOIN peca p ON p.id = osp.peca_id;


-- ##### View: vw_ordem_servico_total ##### --
-- Resumo financeiro por ordem:
CREATE VIEW vw_ordem_servico_total AS
SELECT
    os.id AS ordem_id,
    COALESCE(SUM(oss.quantidade * oss.preco_unitario * (1 - oss.desconto / 100)), 0) AS total_servicos,
    COALESCE(SUM(osp.quantidade * osp.preco_unitario * (1 - osp.desconto / 100)), 0) AS total_pecas,
    COALESCE(SUM(oss.quantidade * oss.preco_unitario * (1 - oss.desconto / 100)), 0) +
    COALESCE(SUM(osp.quantidade * osp.preco_unitario * (1 - osp.desconto / 100)), 0) AS total_geral
FROM ordem_servico os
LEFT JOIN ordem_servico_servico oss ON oss.ordem_id = os.id
LEFT JOIN ordem_servico_peca osp ON osp.ordem_id = os.id
GROUP BY os.id;

-- Testando a view --
-- SELECT * FROM vw_ordem_servico_total WHERE ordem_id = 1;


-- ##### Procedure: Atualizar valor total da ordem ##### --
DELIMITER //

CREATE PROCEDURE atualizar_valor_ordem(IN ordemId INT)
BEGIN
    DECLARE total_servico DECIMAL(10,2);
    DECLARE total_peca DECIMAL(10,2);

    SELECT SUM(quantidade * preco_unitario * (1 - desconto / 100))
    INTO total_servico
    FROM ordem_servico_servico
    WHERE ordem_id = ordemId;

    SELECT SUM(quantidade * preco_unitario * (1 - desconto / 100))
    INTO total_peca
    FROM ordem_servico_peca
    WHERE ordem_id = ordemId;

    UPDATE ordem_servico
    SET valor_servico = COALESCE(total_servico, 0),
        desconto_peca = COALESCE(total_peca, 0)
    WHERE id = ordemId;
END //

DELIMITER ;


-- ##### Você pode chamar essa procedure sempre que adicionar ou remover serviços/peças: ##### --
CALL atualizar_valor_ordem(5);



-- Aqui está uma view consolidada que une os principais dados da ordem de serviço com cliente, status, 
-- datas e totais — ideal para dashboards, relatórios gerenciais ou telas de acompanhamento.

-- ##### View: vw_ordem_servico_resumo ##### --
CREATE VIEW vw_ordem_servico_resumo AS
SELECT
    os.id AS ordem_id,
    os.titulo,
    os.status,
    os.prioridade,
    os.data_abertura,
    os.data_fechamento,
    c.nome AS nome_cliente,
    u.nome AS nome_usuario,
    mp.descricao AS metodo_pagamento,
    os.descricao_saida,
    
    -- Totais calculados
    COALESCE(servico_total.total_servicos, 0) AS total_servicos,
    COALESCE(peca_total.total_pecas, 0) AS total_pecas,
    COALESCE(servico_total.total_servicos, 0) + COALESCE(peca_total.total_pecas, 0) AS total_geral

FROM ordem_servico os
JOIN cliente c ON c.id = os.cliente_id
JOIN usuario u ON u.id = os.usuario_id
LEFT JOIN metodo_pagamento mp ON mp.id = os.metodo_pagamento_id

-- Subtotais de serviços
LEFT JOIN (
    SELECT ordem_id,
           SUM(quantidade * preco_unitario * (1 - desconto / 100)) AS total_servicos
    FROM ordem_servico_servico
    GROUP BY ordem_id
) AS servico_total ON servico_total.ordem_id = os.id

-- Subtotais de peças
LEFT JOIN (
    SELECT ordem_id,
           SUM(quantidade * preco_unitario * (1 - desconto / 100)) AS total_pecas
    FROM ordem_servico_peca
    GROUP BY ordem_id
) AS peca_total ON peca_total.ordem_id = os.id;



-- Aqui está uma view filtrável para facilitar dashboards e relatórios gerenciais com foco em ordens
-- abertas e prioridade alta — e também uma query dinâmica para aplicar filtros por status e datas.

-- ##### View: vw_ordem_servico_dashboard ##### --
CREATE VIEW vw_ordem_servico_dashboard AS
SELECT
    os.id AS ordem_id,
    os.titulo,
    os.status,
    os.prioridade,
    os.data_abertura,
    os.data_fechamento,
    c.nome AS cliente,
    u.nome AS responsavel,
    mp.descricao AS metodo_pagamento,
    COALESCE(servico_total.total_servicos, 0) AS total_servicos,
    COALESCE(peca_total.total_pecas, 0) AS total_pecas,
    COALESCE(servico_total.total_servicos, 0) + COALESCE(peca_total.total_pecas, 0) AS total_geral
FROM ordem_servico os
JOIN cliente c ON c.id = os.cliente_id
JOIN usuario u ON u.id = os.usuario_id
LEFT JOIN metodo_pagamento mp ON mp.id = os.metodo_pagamento_id
LEFT JOIN (
    SELECT ordem_id, SUM(quantidade * preco_unitario * (1 - desconto / 100)) AS total_servicos
    FROM ordem_servico_servico
    GROUP BY ordem_id
) servico_total ON servico_total.ordem_id = os.id
LEFT JOIN (
    SELECT ordem_id, SUM(quantidade * preco_unitario * (1 - desconto / 100)) AS total_pecas
    FROM ordem_servico_peca
    GROUP BY ordem_id
) peca_total ON peca_total.ordem_id = os.id;

-- Exemplo de filtro: ordens abertas com prioridade alta
SELECT * FROM vw_ordem_servico_dashboard
WHERE status = 'aberta' AND prioridade IN ('alta', 'urgente')
ORDER BY data_abertura DESC;

-- Exemplo de filtro por intervalo de datas
SELECT * FROM vw_ordem_servico_dashboard
WHERE data_abertura BETWEEN '2025-10-01' AND '2025-10-31';

-- Dica extra: índice para performance
-- Para acelerar esses filtros, crie índices:
CREATE INDEX idx_status_prioridade ON ordem_servico(status, prioridade);
CREATE INDEX idx_data_abertura ON ordem_servico(data_abertura);



-- ##### View: vw_relatorio_cliente_ordens ##### --
CREATE VIEW vw_relatorio_cliente_ordens AS
SELECT
    c.id AS cliente_id,
    c.nome AS nome_cliente,
    os.id AS ordem_id,
    os.titulo,
    os.status,
    os.prioridade,
    os.data_abertura,
    os.data_fechamento,
    COALESCE(servico_total.total_servicos, 0) AS total_servicos,
    COALESCE(peca_total.total_pecas, 0) AS total_pecas,
    COALESCE(servico_total.total_servicos, 0) + COALESCE(peca_total.total_pecas, 0) AS total_geral
FROM cliente c
JOIN ordem_servico os ON os.cliente_id = c.id
LEFT JOIN (
    SELECT ordem_id, SUM(quantidade * preco_unitario * (1 - desconto / 100)) AS total_servicos
    FROM ordem_servico_servico
    GROUP BY ordem_id
) servico_total ON servico_total.ordem_id = os.id
LEFT JOIN (
    SELECT ordem_id, SUM(quantidade * preco_unitario * (1 - desconto / 100)) AS total_pecas
    FROM ordem_servico_peca
    GROUP BY ordem_id
) peca_total ON peca_total.ordem_id = os.id;


-- ##### Exportar como CSV direto do MySQL ##### --
SELECT * FROM vw_relatorio_cliente_ordens
INTO OUTFILE '/var/lib/mysql-files/relatorio_clientes.csv'
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
-- Certifique-se de que o MySQL tem permissão para gravar no diretório /var/lib/mysql-files. Você pode alterar o caminho conforme necessário.

-- ##### Dica extra: exportar por período ##### --
SELECT * FROM vw_relatorio_cliente_ordens
WHERE data_abertura BETWEEN '2025-10-01' AND '2025-10-31'
INTO OUTFILE '/var/lib/mysql-files/relatorio_outubro.csv'
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n';



-- ##### Tabela de recuperacao de senha ##### --
CREATE TABLE recuperacao_senha (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT,
  token VARCHAR(100),
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE recuperacao_senha
ADD COLUMN valido_ate DATETIME DEFAULT (NOW() + INTERVAL 1 DAY);



-- ##### MOVIMENTACAO FINANCEIRA #### --
CREATE TABLE movimentacao_financeira (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tipo ENUM('entrada','saida') NOT NULL,
  origem ENUM('peca','servico') NOT NULL,
  descricao VARCHAR(255),
  valor DECIMAL(10,2) NOT NULL,
  metodo_pagamento_id INT,
  data_movimento DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (metodo_pagamento_id) REFERENCES metodo_pagamento(id)
);

-- ##### Consultas por período ##### --
-- Por dia:
SELECT SUM(valor) FROM movimentacao_financeira
WHERE DATE(data_movimento) = CURDATE();

-- Por mês:
SELECT SUM(valor) FROM movimentacao_financeira
WHERE MONTH(data_movimento) = MONTH(CURDATE()) AND YEAR(data_movimento) = YEAR(CURDATE());

-- Por ano:SELECT SUM(valor) FROM movimentacao_financeira
WHERE YEAR(data_movimento) = YEAR(CURDATE());

-- Totais por forma de pagamento
SELECT mp.nome, SUM(mf.valor) AS total
FROM movimentacao_financeira mf
JOIN metodo_pagamento mp ON mf.metodo_pagamento_id = mp.id
GROUP BY mp.nome;

-- ##### view para saídas financeiras ##### --
-- Registrar e visualizar compras de peças ou outras despesas --
CREATE VIEW vw_movimentacao_saida AS
SELECT
    mf.id AS movimentacao_id,
    mf.origem,
    mf.descricao,
    mf.valor,
    mp.descricao AS metodo_pagamento,
    mf.data_movimento
FROM movimentacao_financeira mf
LEFT JOIN metodo_pagamento mp ON mp.id = mf.metodo_pagamento_id
WHERE mf.tipo = 'saida';

-- Movimentação de saída por data de fechamento de ordem de serviço --
SELECT * FROM vw_movimentacao_saida ORDER BY data_movimento DESC;

-- Somar por período --
SELECT
    DATE(mf.data_movimento) AS data,
    SUM(mf.valor) AS total
FROM vw_movimentacao_saida mf
GROUP BY DATE(mf.data_movimento);

-- vw_fluxo_caixa_consolidado --
-- une entradas e saídas da tabela movimentacao_financeira, permitindo visualizar 
-- o fluxo de caixa com sinal positivo para entradas e negativo para saídas.
CREATE VIEW vw_fluxo_caixa_consolidado AS
SELECT
    mf.id AS movimentacao_id,
    mf.tipo,
    mf.origem,
    mf.descricao,
    CASE
        WHEN mf.tipo = 'entrada' THEN mf.valor
        WHEN mf.tipo = 'saida' THEN -mf.valor
    END AS valor_consolidado,
    mp.descricao AS metodo_pagamento,
    mf.data_movimento
FROM movimentacao_financeira mf
LEFT JOIN metodo_pagamento mp ON mp.id = mf.metodo_pagamento_id;

-- Total por dia: --
SELECT DATE(data_movimento) AS data, SUM(valor_consolidado) AS saldo
FROM vw_fluxo_caixa_consolidado
GROUP BY DATE(data_movimento)
ORDER BY data;

-- Total por mês: --
SELECT DATE_FORMAT(data_movimento, '%Y-%m') AS mes, SUM(valor_consolidado) AS saldo
FROM vw_fluxo_caixa_consolidado
GROUP BY mes
ORDER BY mes;

-- Total por forma de pagamento: --
SELECT metodo_pagamento, SUM(valor_consolidado) AS saldo
FROM vw_fluxo_caixa_consolidado
GROUP BY metodo_pagamento;

-- Benefícios:
-- Permite gerar gráficos de saldo por período;
-- Facilita auditoria e análise de lucratividade;
-- Pode ser usado para exportar relatórios financeiros.





























