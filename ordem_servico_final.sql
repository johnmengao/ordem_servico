/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.3-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: ordem_servico
-- ------------------------------------------------------
-- Server version	11.8.3-MariaDB-0+deb13u1 from Debian

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(80) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `cpf_cnpj` varchar(20) DEFAULT NULL,
  `endereco` text DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `cliente` VALUES
(1,'João Hilton','(86)99939-5337','jharquitetura@teresinashopping.com.br','','',''),
(2,'Raineria Silva Bastos','(86)98149-0217','reidomathe@gmail.com','','Av. Raul Lopes, 1000.',''),
(3,'Danillo','(86)99913-7607','','','',''),
(4,'Denhilson ','(86)99974-4397','','','',''),
(5,'Filipe Santos','(86)995578631','','','',''),
(6,'Lucas Borges','(86)98843-1266','','','','');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `metodo_pagamento`
--

DROP TABLE IF EXISTS `metodo_pagamento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `metodo_pagamento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descricao` varchar(50) NOT NULL,
  `metodo_pagamento_id` int(11) DEFAULT 4,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metodo_pagamento`
--

LOCK TABLES `metodo_pagamento` WRITE;
/*!40000 ALTER TABLE `metodo_pagamento` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `metodo_pagamento` VALUES
(1,'Dinheiro',4),
(2,'Cartão de Crédito',4),
(3,'Cartão de Débito',4),
(4,'Pix',4),
(5,'Transferência',4),
(6,'Boleto',4);
/*!40000 ALTER TABLE `metodo_pagamento` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `movimentacao_financeira`
--

DROP TABLE IF EXISTS `movimentacao_financeira`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimentacao_financeira` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` enum('entrada','saida') NOT NULL,
  `origem` enum('peca','servico') NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `valor` decimal(10,2) NOT NULL,
  `metodo_pagamento_id` int(11) DEFAULT NULL,
  `data_movimento` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `metodo_pagamento_id` (`metodo_pagamento_id`),
  CONSTRAINT `movimentacao_financeira_ibfk_1` FOREIGN KEY (`metodo_pagamento_id`) REFERENCES `metodo_pagamento` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimentacao_financeira`
--

LOCK TABLES `movimentacao_financeira` WRITE;
/*!40000 ALTER TABLE `movimentacao_financeira` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `movimentacao_financeira` VALUES
(1,'entrada','servico','Ordem de serviço #1 concluída',130.00,4,'2025-11-05 17:11:06'),
(2,'entrada','servico','Ordem de serviço #2 concluída',120.00,4,'2025-10-19 17:00:00'),
(3,'entrada','servico','Ordem de serviço #3 concluída',130.00,4,'2025-11-14 17:30:00'),
(4,'entrada','servico','Ordem de serviço #4 concluída',40.00,4,'2025-11-11 11:50:00'),
(6,'entrada','servico','Ordem de serviço #5 concluída',40.00,4,'2025-12-04 17:27:57'),
(7,'entrada','servico','Ordem de serviço #6 concluída',112.00,4,'2025-12-11 13:14:33');
/*!40000 ALTER TABLE `movimentacao_financeira` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `ordem_servico`
--

DROP TABLE IF EXISTS `ordem_servico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ordem_servico` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cliente_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `metodo_pagamento_id` int(11) DEFAULT NULL,
  `status` enum('aberta','em_andamento','aguardando_pecas','aguardando_aprovacao','concluida','cancelada') DEFAULT 'aberta',
  `data_abertura` datetime DEFAULT current_timestamp(),
  `data_fechamento` datetime DEFAULT NULL,
  `titulo` varchar(200) NOT NULL,
  `descricao_entrada` text DEFAULT NULL,
  `descricao_saida` text DEFAULT NULL,
  `prioridade` enum('baixa','media','alta','urgente') DEFAULT 'media',
  `desconto_peca` decimal(5,2) DEFAULT 0.00,
  `valor_servico` decimal(10,2) DEFAULT 0.00,
  `observacoes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cliente_id` (`cliente_id`),
  KEY `usuario_id` (`usuario_id`),
  KEY `metodo_pagamento_id` (`metodo_pagamento_id`),
  CONSTRAINT `ordem_servico_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`id`),
  CONSTRAINT `ordem_servico_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`),
  CONSTRAINT `ordem_servico_ibfk_3` FOREIGN KEY (`metodo_pagamento_id`) REFERENCES `metodo_pagamento` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ordem_servico`
--

LOCK TABLES `ordem_servico` WRITE;
/*!40000 ALTER TABLE `ordem_servico` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `ordem_servico` VALUES
(1,1,1,4,'concluida','2025-10-28 16:19:33','2025-11-05 17:11:06','Apresentando lentidão e teclado com defeito','Apresentando lentidão;\r\nRealizar orçamento do teclado.','Manutenção de sistema;\r\nInstalação de teclado.','media',0.00,0.00,'Deixando carregador; \r\nO cliente vai deixar o teclado para a substituição.'),
(2,2,4,4,'concluida','2025-10-14 18:00:00','2025-10-19 17:00:00','Computador liga e não dá sinal de vídeo','Liga mas sem sinal de vídeo;\r\nFazer revisão geral.','Realizado manutenção de sistema operacional, limpeza interna de gabinete e atualização de versão de sistema do win10 para o win11.\r\n\r\n','media',0.00,0.00,'Computador desktop.'),
(3,3,4,4,'concluida','2025-11-07 14:30:00','2025-11-19 08:59:03','Apresentando lentidão fazer revisão geral.','Apresentando lentidão fazer revisão geral.','Instalação de SSD M2 e a transferência do sistema operacional do HD para o SSD M2para o\r\nmesmo.','media',0.00,0.00,'Notebook Dell; Deixando mochila e carregador. O SSD o cliente deixou.'),
(4,4,4,4,'concluida','2025-11-11 10:40:00','2025-11-11 11:50:00','Ativação de suite de escritório.','Realizar a ativação de programa.','Ativação de suite de escritório.','media',0.00,0.00,''),
(5,5,4,4,'concluida','2025-12-04 16:47:59','2025-12-04 17:27:57','Notebook sem carregar','Notebook sem carregar, fazer verificação.','Reparo no carregador.','media',0.00,0.00,'Notebook Acer A31G-R2SE.'),
(6,6,4,4,'concluida','2025-12-11 11:41:40','2025-12-11 13:14:33','Substituir teclado','Fazer substituição de teclado. ','Substituição de teclado;\r\nReparo de carcaça;\r\nLimpeza interna.','media',0.00,0.00,'Notebook Asus K45A-VX114Q;\r\nDeixando teclado e carregador;\r\n');
/*!40000 ALTER TABLE `ordem_servico` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `ordem_servico_peca`
--

DROP TABLE IF EXISTS `ordem_servico_peca`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ordem_servico_peca` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ordem_id` int(11) NOT NULL,
  `peca_id` int(11) NOT NULL,
  `quantidade` int(11) DEFAULT 1,
  `preco_unitario` decimal(10,2) NOT NULL,
  `desconto` decimal(5,2) DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `ordem_id` (`ordem_id`),
  KEY `peca_id` (`peca_id`),
  CONSTRAINT `ordem_servico_peca_ibfk_1` FOREIGN KEY (`ordem_id`) REFERENCES `ordem_servico` (`id`),
  CONSTRAINT `ordem_servico_peca_ibfk_2` FOREIGN KEY (`peca_id`) REFERENCES `peca` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ordem_servico_peca`
--

LOCK TABLES `ordem_servico_peca` WRITE;
/*!40000 ALTER TABLE `ordem_servico_peca` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `ordem_servico_peca` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `ordem_servico_servico`
--

DROP TABLE IF EXISTS `ordem_servico_servico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ordem_servico_servico` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ordem_id` int(11) NOT NULL,
  `servico_id` int(11) NOT NULL,
  `quantidade` int(11) DEFAULT 1,
  `preco_unitario` decimal(10,2) NOT NULL,
  `desconto` decimal(5,2) DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `ordem_id` (`ordem_id`),
  KEY `servico_id` (`servico_id`),
  CONSTRAINT `ordem_servico_servico_ibfk_1` FOREIGN KEY (`ordem_id`) REFERENCES `ordem_servico` (`id`),
  CONSTRAINT `ordem_servico_servico_ibfk_2` FOREIGN KEY (`servico_id`) REFERENCES `servico` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ordem_servico_servico`
--

LOCK TABLES `ordem_servico_servico` WRITE;
/*!40000 ALTER TABLE `ordem_servico_servico` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `ordem_servico_servico` VALUES
(1,1,3,1,130.00,0.00),
(2,2,6,1,120.00,0.00),
(3,3,8,1,130.00,0.00),
(4,4,10,1,40.00,0.00),
(5,5,12,1,40.00,0.00),
(13,6,4,1,60.00,30.00),
(14,6,14,1,50.00,30.00),
(15,6,15,1,50.00,30.00);
/*!40000 ALTER TABLE `ordem_servico_servico` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `peca`
--

DROP TABLE IF EXISTS `peca`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `peca` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `preco_padrao` decimal(10,2) NOT NULL,
  `estoque` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `peca`
--

LOCK TABLES `peca` WRITE;
/*!40000 ALTER TABLE `peca` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `peca` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `recuperacao_senha`
--

DROP TABLE IF EXISTS `recuperacao_senha`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `recuperacao_senha` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `token` varchar(100) DEFAULT NULL,
  `criado_em` datetime DEFAULT current_timestamp(),
  `valido_ate` datetime DEFAULT (current_timestamp() + interval 1 day),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recuperacao_senha`
--

LOCK TABLES `recuperacao_senha` WRITE;
/*!40000 ALTER TABLE `recuperacao_senha` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `recuperacao_senha` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `servico`
--

DROP TABLE IF EXISTS `servico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `servico` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `preco_padrao` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servico`
--

LOCK TABLES `servico` WRITE;
/*!40000 ALTER TABLE `servico` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `servico` VALUES
(1,'Manutenção de sistema operacional',100.00),
(3,'Manutenção de sistema operacional e instalação de tecado.',130.00),
(4,'Limpeza interna de desktop',60.00),
(5,'Limpeza interna de notebook',70.00),
(6,'Manutenção de sistema operacional e limpeza interna de desktop',120.00),
(7,'Manutenção de sistema operacional e limpeza interna de notebook',130.00),
(8,'Cópia completa de sistema operacional e dados até 50GB.',120.00),
(9,'Cópia completa de sistema operacional e dados acima de 50GB.',150.00),
(10,'Ativação ou instalação remota de suite de escritório',40.00),
(11,'Ativação ou instalação de suite de escritório',50.00),
(12,'Reparo de fonte de notebook',40.00),
(13,'Substituição de Teclado; Limpeza interna; Reparo de carcaça',100.00),
(14,'Reparo simples de carcaça',50.00),
(15,'Instalação de teclado',50.00),
(16,'Reparo de carcaça',80.00);
/*!40000 ALTER TABLE `servico` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(80) NOT NULL,
  `email` varchar(80) DEFAULT NULL,
  `senha` varchar(255) DEFAULT NULL,
  `tipo` enum('admin','tecnico') NOT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `usuario` VALUES
(1,'Administrador','admin@teste.com','scrypt:32768:8:1$hBGzE2U4hCs8pz4C$be6845234ac754cbf627e27be74db931436ec312ca0ddc00491a0d84e026e224598ee74d2cb998564e1782c5e1903a2deb39a08d95c20f726ff0eaa4cfa96236','admin',1),
(4,'João Henrique','suporte.joaohenrique@gmail.com','scrypt:32768:8:1$wpvrlnxWysfOEuwB$c313a563d8be5821a196b9141b46c19f3d89b332c9028379a5275ca66b3e6352a52a7d6e71ee020c5a7d20ce519a170b12019de75017a91186b2978a90df2a72','tecnico',1);
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Temporary table structure for view `vw_fluxo_caixa_consolidado`
--

DROP TABLE IF EXISTS `vw_fluxo_caixa_consolidado`;
/*!50001 DROP VIEW IF EXISTS `vw_fluxo_caixa_consolidado`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_fluxo_caixa_consolidado` AS SELECT
 1 AS `movimentacao_id`,
  1 AS `tipo`,
  1 AS `origem`,
  1 AS `descricao`,
  1 AS `valor_consolidado`,
  1 AS `metodo_pagamento`,
  1 AS `data_movimento` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_ordem_servico_dashboard`
--

DROP TABLE IF EXISTS `vw_ordem_servico_dashboard`;
/*!50001 DROP VIEW IF EXISTS `vw_ordem_servico_dashboard`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_ordem_servico_dashboard` AS SELECT
 1 AS `ordem_id`,
  1 AS `titulo`,
  1 AS `status`,
  1 AS `prioridade`,
  1 AS `data_abertura`,
  1 AS `data_fechamento`,
  1 AS `cliente`,
  1 AS `responsavel`,
  1 AS `metodo_pagamento`,
  1 AS `total_servicos`,
  1 AS `total_pecas`,
  1 AS `total_geral` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_ordem_servico_peca`
--

DROP TABLE IF EXISTS `vw_ordem_servico_peca`;
/*!50001 DROP VIEW IF EXISTS `vw_ordem_servico_peca`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_ordem_servico_peca` AS SELECT
 1 AS `id`,
  1 AS `ordem_id`,
  1 AS `peca_id`,
  1 AS `nome_peca`,
  1 AS `p_padrao`,
  1 AS `quantidade`,
  1 AS `preco_unitario`,
  1 AS `desconto`,
  1 AS `subtotal` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_ordem_servico_resumo`
--

DROP TABLE IF EXISTS `vw_ordem_servico_resumo`;
/*!50001 DROP VIEW IF EXISTS `vw_ordem_servico_resumo`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_ordem_servico_resumo` AS SELECT
 1 AS `ordem_id`,
  1 AS `titulo`,
  1 AS `status`,
  1 AS `prioridade`,
  1 AS `data_abertura`,
  1 AS `data_fechamento`,
  1 AS `nome_cliente`,
  1 AS `nome_usuario`,
  1 AS `metodo_pagamento`,
  1 AS `descricao_saida`,
  1 AS `total_servicos`,
  1 AS `total_pecas`,
  1 AS `total_geral` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_ordem_servico_servico`
--

DROP TABLE IF EXISTS `vw_ordem_servico_servico`;
/*!50001 DROP VIEW IF EXISTS `vw_ordem_servico_servico`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_ordem_servico_servico` AS SELECT
 1 AS `id`,
  1 AS `ordem_id`,
  1 AS `servico_id`,
  1 AS `nome_servico`,
  1 AS `p_padrao`,
  1 AS `quantidade`,
  1 AS `preco_unitario`,
  1 AS `desconto`,
  1 AS `subtotal` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_ordem_servico_total`
--

DROP TABLE IF EXISTS `vw_ordem_servico_total`;
/*!50001 DROP VIEW IF EXISTS `vw_ordem_servico_total`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_ordem_servico_total` AS SELECT
 1 AS `ordem_id`,
  1 AS `total_servicos`,
  1 AS `total_pecas`,
  1 AS `total_geral` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_relatorio_cliente_ordens`
--

DROP TABLE IF EXISTS `vw_relatorio_cliente_ordens`;
/*!50001 DROP VIEW IF EXISTS `vw_relatorio_cliente_ordens`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_relatorio_cliente_ordens` AS SELECT
 1 AS `cliente_id`,
  1 AS `nome_cliente`,
  1 AS `ordem_id`,
  1 AS `titulo`,
  1 AS `status`,
  1 AS `prioridade`,
  1 AS `data_abertura`,
  1 AS `data_fechamento`,
  1 AS `total_servicos`,
  1 AS `total_pecas`,
  1 AS `total_geral` */;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_fluxo_caixa_consolidado`
--

/*!50001 DROP VIEW IF EXISTS `vw_fluxo_caixa_consolidado`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_fluxo_caixa_consolidado` AS select `mf`.`id` AS `movimentacao_id`,`mf`.`tipo` AS `tipo`,`mf`.`origem` AS `origem`,`mf`.`descricao` AS `descricao`,case when `mf`.`tipo` = 'entrada' then `mf`.`valor` when `mf`.`tipo` = 'saida' then -`mf`.`valor` end AS `valor_consolidado`,`mp`.`descricao` AS `metodo_pagamento`,`mf`.`data_movimento` AS `data_movimento` from (`movimentacao_financeira` `mf` left join `metodo_pagamento` `mp` on(`mp`.`id` = `mf`.`metodo_pagamento_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_ordem_servico_dashboard`
--

/*!50001 DROP VIEW IF EXISTS `vw_ordem_servico_dashboard`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_ordem_servico_dashboard` AS select `os`.`id` AS `ordem_id`,`os`.`titulo` AS `titulo`,`os`.`status` AS `status`,`os`.`prioridade` AS `prioridade`,`os`.`data_abertura` AS `data_abertura`,`os`.`data_fechamento` AS `data_fechamento`,`c`.`nome` AS `cliente`,`u`.`nome` AS `responsavel`,`mp`.`descricao` AS `metodo_pagamento`,coalesce(`servico_total`.`total_servicos`,0) AS `total_servicos`,coalesce(`peca_total`.`total_pecas`,0) AS `total_pecas`,coalesce(`servico_total`.`total_servicos`,0) + coalesce(`peca_total`.`total_pecas`,0) AS `total_geral` from (((((`ordem_servico` `os` join `cliente` `c` on(`c`.`id` = `os`.`cliente_id`)) join `usuario` `u` on(`u`.`id` = `os`.`usuario_id`)) left join `metodo_pagamento` `mp` on(`mp`.`id` = `os`.`metodo_pagamento_id`)) left join (select `ordem_servico_servico`.`ordem_id` AS `ordem_id`,sum(`ordem_servico_servico`.`quantidade` * `ordem_servico_servico`.`preco_unitario` * (1 - `ordem_servico_servico`.`desconto` / 100)) AS `total_servicos` from `ordem_servico_servico` group by `ordem_servico_servico`.`ordem_id`) `servico_total` on(`servico_total`.`ordem_id` = `os`.`id`)) left join (select `ordem_servico_peca`.`ordem_id` AS `ordem_id`,sum(`ordem_servico_peca`.`quantidade` * `ordem_servico_peca`.`preco_unitario` * (1 - `ordem_servico_peca`.`desconto` / 100)) AS `total_pecas` from `ordem_servico_peca` group by `ordem_servico_peca`.`ordem_id`) `peca_total` on(`peca_total`.`ordem_id` = `os`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_ordem_servico_peca`
--

/*!50001 DROP VIEW IF EXISTS `vw_ordem_servico_peca`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_ordem_servico_peca` AS select `osp`.`id` AS `id`,`osp`.`ordem_id` AS `ordem_id`,`osp`.`peca_id` AS `peca_id`,`p`.`nome` AS `nome_peca`,`p`.`preco_padrao` AS `p_padrao`,`osp`.`quantidade` AS `quantidade`,`osp`.`preco_unitario` AS `preco_unitario`,`osp`.`desconto` AS `desconto`,`osp`.`quantidade` * `osp`.`preco_unitario` * (1 - `osp`.`desconto` / 100) AS `subtotal` from (`ordem_servico_peca` `osp` join `peca` `p` on(`p`.`id` = `osp`.`peca_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_ordem_servico_resumo`
--

/*!50001 DROP VIEW IF EXISTS `vw_ordem_servico_resumo`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_ordem_servico_resumo` AS select `os`.`id` AS `ordem_id`,`os`.`titulo` AS `titulo`,`os`.`status` AS `status`,`os`.`prioridade` AS `prioridade`,`os`.`data_abertura` AS `data_abertura`,`os`.`data_fechamento` AS `data_fechamento`,`c`.`nome` AS `nome_cliente`,`u`.`nome` AS `nome_usuario`,`mp`.`descricao` AS `metodo_pagamento`,`os`.`descricao_saida` AS `descricao_saida`,coalesce(`servico_total`.`total_servicos`,0) AS `total_servicos`,coalesce(`peca_total`.`total_pecas`,0) AS `total_pecas`,coalesce(`servico_total`.`total_servicos`,0) + coalesce(`peca_total`.`total_pecas`,0) AS `total_geral` from (((((`ordem_servico` `os` join `cliente` `c` on(`c`.`id` = `os`.`cliente_id`)) join `usuario` `u` on(`u`.`id` = `os`.`usuario_id`)) left join `metodo_pagamento` `mp` on(`mp`.`id` = `os`.`metodo_pagamento_id`)) left join (select `ordem_servico_servico`.`ordem_id` AS `ordem_id`,sum(`ordem_servico_servico`.`quantidade` * `ordem_servico_servico`.`preco_unitario` * (1 - `ordem_servico_servico`.`desconto` / 100)) AS `total_servicos` from `ordem_servico_servico` group by `ordem_servico_servico`.`ordem_id`) `servico_total` on(`servico_total`.`ordem_id` = `os`.`id`)) left join (select `ordem_servico_peca`.`ordem_id` AS `ordem_id`,sum(`ordem_servico_peca`.`quantidade` * `ordem_servico_peca`.`preco_unitario` * (1 - `ordem_servico_peca`.`desconto` / 100)) AS `total_pecas` from `ordem_servico_peca` group by `ordem_servico_peca`.`ordem_id`) `peca_total` on(`peca_total`.`ordem_id` = `os`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_ordem_servico_servico`
--

/*!50001 DROP VIEW IF EXISTS `vw_ordem_servico_servico`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_ordem_servico_servico` AS select `oss`.`id` AS `id`,`oss`.`ordem_id` AS `ordem_id`,`oss`.`servico_id` AS `servico_id`,`s`.`nome` AS `nome_servico`,`s`.`preco_padrao` AS `p_padrao`,`oss`.`quantidade` AS `quantidade`,`oss`.`preco_unitario` AS `preco_unitario`,`oss`.`desconto` AS `desconto`,`oss`.`quantidade` * `oss`.`preco_unitario` * (1 - `oss`.`desconto` / 100) AS `subtotal` from (`ordem_servico_servico` `oss` join `servico` `s` on(`s`.`id` = `oss`.`servico_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_ordem_servico_total`
--

/*!50001 DROP VIEW IF EXISTS `vw_ordem_servico_total`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_ordem_servico_total` AS select `os`.`id` AS `ordem_id`,coalesce(sum(`oss`.`quantidade` * `oss`.`preco_unitario` * (1 - `oss`.`desconto` / 100)),0) AS `total_servicos`,coalesce(sum(`osp`.`quantidade` * `osp`.`preco_unitario` * (1 - `osp`.`desconto` / 100)),0) AS `total_pecas`,coalesce(sum(`oss`.`quantidade` * `oss`.`preco_unitario` * (1 - `oss`.`desconto` / 100)),0) + coalesce(sum(`osp`.`quantidade` * `osp`.`preco_unitario` * (1 - `osp`.`desconto` / 100)),0) AS `total_geral` from ((`ordem_servico` `os` left join `ordem_servico_servico` `oss` on(`oss`.`ordem_id` = `os`.`id`)) left join `ordem_servico_peca` `osp` on(`osp`.`ordem_id` = `os`.`id`)) group by `os`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_relatorio_cliente_ordens`
--

/*!50001 DROP VIEW IF EXISTS `vw_relatorio_cliente_ordens`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_relatorio_cliente_ordens` AS select `c`.`id` AS `cliente_id`,`c`.`nome` AS `nome_cliente`,`os`.`id` AS `ordem_id`,`os`.`titulo` AS `titulo`,`os`.`status` AS `status`,`os`.`prioridade` AS `prioridade`,`os`.`data_abertura` AS `data_abertura`,`os`.`data_fechamento` AS `data_fechamento`,coalesce(`servico_total`.`total_servicos`,0) AS `total_servicos`,coalesce(`peca_total`.`total_pecas`,0) AS `total_pecas`,coalesce(`servico_total`.`total_servicos`,0) + coalesce(`peca_total`.`total_pecas`,0) AS `total_geral` from (((`cliente` `c` join `ordem_servico` `os` on(`os`.`cliente_id` = `c`.`id`)) left join (select `ordem_servico_servico`.`ordem_id` AS `ordem_id`,sum(`ordem_servico_servico`.`quantidade` * `ordem_servico_servico`.`preco_unitario` * (1 - `ordem_servico_servico`.`desconto` / 100)) AS `total_servicos` from `ordem_servico_servico` group by `ordem_servico_servico`.`ordem_id`) `servico_total` on(`servico_total`.`ordem_id` = `os`.`id`)) left join (select `ordem_servico_peca`.`ordem_id` AS `ordem_id`,sum(`ordem_servico_peca`.`quantidade` * `ordem_servico_peca`.`preco_unitario` * (1 - `ordem_servico_peca`.`desconto` / 100)) AS `total_pecas` from `ordem_servico_peca` group by `ordem_servico_peca`.`ordem_id`) `peca_total` on(`peca_total`.`ordem_id` = `os`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2025-12-17  9:52:52
