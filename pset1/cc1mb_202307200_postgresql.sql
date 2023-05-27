-- Robson Júnior Schultz Dias
-- CC1Mb

-- Deletar banco de dados e usuário caso já existam.
DROP DATABASE IF EXISTS uvv;
DROP USER IF EXISTS robson;

-- Criar um novo usuário.
CREATE USER robson CREATEDB CREATEROLE ENCRYPTED PASSWORD 'MayonnaiseOnAnEscalator';

-- Criar um novo banco de dados.
CREATE DATABASE uvv WITH OWNER robson
    					 TEMPLATE template0
    					 ENCODING 'UTF8'
    					 LC_COLLATE 'pt_BR.UTF-8'
    	      			 LC_CTYPE 'pt_BR.UTF-8'
    					 ALLOW_CONNECTIONS true;

-- Conceder todas as permissões ao usuário.
GRANT ALL PRIVILEGES ON DATABASE uvv TO robson;

-- Conectar ao banco de dados
\c 'dbname=uvv user=robson password=MayonnaiseOnAnEscalator'

-- Criar um novo SCHEMA e tornar o usuário dono.
CREATE SCHEMA lojas AUTHORIZATION robson;  

-- Alterar o SEARCH_PATH padrão para o schema lojas.
SET SEARCH_PATH TO lojas, "$user", public;

-- Alterar o SEARCH_PATH do usuario para o schema lojas.
ALTER USER robson SET SEARCH_PATH TO lojas, "$user", public;

-- Criar a tabela lojas.
CREATE TABLE lojas (
                loja_id 				NUMERIC(38)  NOT NULL,
                nome 					VARCHAR(255) NOT NULL,
                endereco_web 			VARCHAR(100),
                endereco_fisico 		VARCHAR(512),
                latitude 				NUMERIC,
                longitude 	   			NUMERIC,
                logo 					BYTEA,
                logo_mime_type 			VARCHAR(512),
                logo_arquivo   			VARCHAR(512),
                logo_charset   			VARCHAR(512),
                logo_ultima_atualizacao DATE,
                CONSTRAINT pk_lojas PRIMARY KEY (loja_id)
);

-- Adicionar comentarios para a tabela lojas e suas colunas. 
COMMENT ON TABLE  lojas 							IS 'Contém informações sobre as lojas do sistema, como nome, endereço físico, endereço web e outras informações relevantes. Essa tabela é útil para rastrear informações específicas de cada loja.';
COMMENT ON COLUMN lojas.loja_id 				  	IS 'Número de identificação da loja. Chave primária da tabela lojas.';
COMMENT ON COLUMN lojas.nome 					  	IS 'Nome da respectiva loja.';
COMMENT ON COLUMN lojas.endereco_web 			  	IS 'Endereço web da respectiva loja.';
COMMENT ON COLUMN lojas.endereco_fisico		  		IS 'Endereço de onde se localiza a loja fisicamente.';
COMMENT ON COLUMN lojas.latitude 				  	IS 'Latitude do endereço da loja.';
COMMENT ON COLUMN lojas.longitude 			  		IS 'Longitude do endereço da loja.';
COMMENT ON COLUMN lojas.logo 					  	IS 'Logo da loja.';
COMMENT ON COLUMN lojas.logo_mime_type 		  		IS 'Define o tipo de mídia do logo da loja.';
COMMENT ON COLUMN lojas.logo_arquivo 			  	IS 'Arquivo do logo da respectiva loja.';
COMMENT ON COLUMN lojas.logo_charset 			  	IS 'Define o charset do logo da respectiva loja.';
COMMENT ON COLUMN lojas.logo_ultima_atualizacao 	IS 'Define a última data onde houve uma atualização no logo da loja.';

-- Adicionar as check constraints da tabela lojas.
ALTER TABLE lojas
ADD CONSTRAINT end_fisico_ou_web
CHECK (
    endereco_fisico IS NOT NULL OR
    endereco_web    IS NOT NULL
);

ALTER TABLE lojas
ADD CONSTRAINT latitude_longitude_iguais
CHECK (
    (latitude  IS NULL AND 
     longitude IS NULL) 
    OR 
    (latitude  IS NOT NULL AND 
     longitude IS NOT NULL)
);

ALTER TABLE lojas
ADD CONSTRAINT info_logo_iguais
CHECK (
    (logo                    IS NULL AND 
     logo_mime_type          IS NULL AND 
     logo_arquivo            IS NULL AND 
     logo_charset            IS NULL AND 
     logo_ultima_atualizacao IS NULL)
    OR 
    (logo                    IS NOT NULL AND 
     logo_mime_type          IS NOT NULL AND 
     logo_arquivo            IS NOT NULL AND 
     logo_charset            IS NOT NULL AND 
     logo_ultima_atualizacao IS NOT NULL)
);

ALTER TABLE    lojas
ADD CONSTRAINT loja_id_positivo
CHECK (
    loja_id > 0
);

-- Criar a tabela produtos.
CREATE TABLE produtos (
                produto_id 				  NUMERIC(38)    NOT NULL,
                nome 					  VARCHAR(255) 	 NOT NULL,
                preco_unitario 			  NUMERIC(10,2),
                detalhes 				  BYTEA,
                imagem 					  BYTEA,
                imagem_mime_type 		  VARCHAR(512),
                imagem_arquivo 			  VARCHAR(512),
                imagem_charset 			  VARCHAR(512),
                imagem_ultima_atualizacao DATE,
                CONSTRAINT pk_produtos PRIMARY KEY (produto_id)
);

-- Adicionar comentarios para a tabela produtos e suas colunas.
COMMENT ON TABLE  produtos								IS 'Armazena informações sobre os produtos oferecidos pelas lojas. Pode incluir detalhes como nome do produto, detalhes, preço e outras informações relevantes para identificar e gerenciar os produtos disponíveis.';
COMMENT ON COLUMN produtos.produto_id 				 	IS 'Número de identificação do produto. Chave primária da tabela produtos.';
COMMENT ON COLUMN produtos.nome 					 	IS 'Nome do respectivo produto.';
COMMENT ON COLUMN produtos.preco_unitario 			 	IS 'Preço por unidade do respectivo produto.';
COMMENT ON COLUMN produtos.detalhes 				 	IS 'Detalhes sobre o determinado produto.';
COMMENT ON COLUMN produtos.imagem 					 	IS 'Imagem do produto.';
COMMENT ON COLUMN produtos.imagem_mime_type 		 	IS 'Define o tipo de mídia da imagem do produto.';
COMMENT ON COLUMN produtos.imagem_arquivo 			 	IS 'Arquivo de imagem usado para determinado produto.';
COMMENT ON COLUMN produtos.imagem_charset 			 	IS 'Define o charset da imagem do produto.';
COMMENT ON COLUMN produtos.imagem_ultima_atualizacao   	IS 'Define a ultima data em que foi atualizada a imagem do produto.';

-- Adicionar as check constraints da tabela produtos.
ALTER TABLE    produtos
ADD CONSTRAINT produtos_preco_positivo_ou_0
CHECK (
    preco_unitario >= 0
);

ALTER TABLE    produtos
ADD CONSTRAINT produto_id_positivo
CHECK (
    produto_id > 0
);

ALTER TABLE    produtos
ADD CONSTRAINT info_imagem_iguais
CHECK (
    (imagem                    IS NULL AND 
     imagem_mime_type          IS NULL AND 
     imagem_arquivo            IS NULL AND 
     imagem_charset            IS NULL AND 
     imagem_ultima_atualizacao IS NULL)
    OR 
    (imagem                    IS NOT NULL AND 
     imagem_mime_type          IS NOT NULL AND 
     imagem_arquivo            IS NOT NULL AND 
     imagem_charset            IS NOT NULL AND 
     imagem_ultima_atualizacao IS NOT NULL)
);

-- Criar a tabela estoques.
CREATE TABLE estoques (
                estoque_id NUMERIC(38) NOT NULL,
                loja_id    NUMERIC(38) NOT NULL,
                produto_id NUMERIC(38) NOT NULL,
                quantidade NUMERIC(38) NOT NULL,
                CONSTRAINT pk_estoques PRIMARY KEY (estoque_id)
);

-- Adicionar comentarios para a tabela estoques e suas colunas.
COMMENT ON TABLE  estoques				IS 'Registra o estoque atual de produtos disponíveis nas lojas. Essa tabela pode conter informações como identificador do produto, quantidade disponível e outras informações relacionadas ao gerenciamento do estoque.';
COMMENT ON COLUMN estoques.estoque_id 	IS 'Número de identificação do estoque. Chave primária da tabela estoques.';
COMMENT ON COLUMN estoques.loja_id    	IS 'Número de identificação da loja. Chave estrangeira da tabela lojas.';
COMMENT ON COLUMN estoques.produto_id 	IS 'Número de identificação do produto. Chave estrangeira da tabela produtos.';
COMMENT ON COLUMN estoques.quantidade 	IS 'Define a quantidade de certo produto que uma respectiva loja possui.';

-- Adicionar as check constraints da tabela estoques.
ALTER TABLE    estoques
ADD CONSTRAINT estoque_id_positivo
CHECK (
    estoque_id > 0
);

ALTER TABLE    estoques
ADD CONSTRAINT estoques_loja_id_positivo
CHECK (
    loja_id > 0
);

ALTER TABLE    estoques
ADD CONSTRAINT estoques_produto_id_positivo
CHECK (
    produto_id > 0
);

ALTER TABLE    estoques
ADD CONSTRAINT estoques_quantidade_positiva_ou_0
CHECK (
    quantidade >= 0
);


-- Criar a tabela clientes.
CREATE TABLE clientes (
                cliente_id NUMERIC(38)  NOT NULL,
                email 	   VARCHAR(255) NOT NULL,
                nome 	   VARCHAR(255) NOT NULL,
                telefone1  VARCHAR(20),
                telefone2  VARCHAR(20),
                telefone3  VARCHAR(20),
                CONSTRAINT pk_clientes PRIMARY KEY (cliente_id)
);

-- Adicionar comentarios para a tabela clientes e suas colunas.
COMMENT ON TABLE  clientes				IS 'Armazena informações sobre os clientes do sistema, como nome, e-mail, informações de contato e outras informações relevantes para identificar e interagir com os clientes.';
COMMENT ON COLUMN clientes.cliente_id 	IS 'Número de identificação do cliente. Chave primária da tabela clientes.';
COMMENT ON COLUMN clientes.email 	  	IS 'E-mail do respectivo aluno.';
COMMENT ON COLUMN clientes.nome 	  	IS 'Nome do respectivo aluno.';
COMMENT ON COLUMN clientes.telefone1  	IS 'Primeira opção de telefone do aluno.';
COMMENT ON COLUMN clientes.telefone2  	IS 'Segunda opção de telefone do aluno.';
COMMENT ON COLUMN clientes.telefone3  	IS 'Terceira opção de telefone do aluno.';

-- Adicionar as check constraints da tabela clientes.
ALTER TABLE    clientes
ADD CONSTRAINT cliente_id_positivo
CHECK (
    cliente_id > 0
);

-- Criar a tabela envios.
CREATE TABLE envios (
                envio_id 		 NUMERIC(38)  NOT NULL,
                loja_id 		 NUMERIC(38)  NOT NULL,
                cliente_id 		 NUMERIC(38)  NOT NULL,
                endereco_entrega VARCHAR(512) NOT NULL,
                status 			 VARCHAR(15)  NOT NULL,
                CONSTRAINT pk_envios PRIMARY KEY (envio_id)
);

-- Adicionar comentarios para a tabela envios e suas colunas.
COMMENT ON TABLE  envios						IS 'Mantém registros de informações de envio para os pedidos processados. Pode incluir detalhes como número de rastreamento, endereço de entrega, status de envio e outras informações relacionadas à entrega dos pedidos aos clientes.';
COMMENT ON COLUMN envios.envio_id 		  		IS 'Número de identificação do envio. Chave primária da tabela envios.';
COMMENT ON COLUMN envios.loja_id 		  	  	IS 'Número de identificação da loja. Chave estrangeira da tabela lojas.';
COMMENT ON COLUMN envios.cliente_id 	  	  	IS 'Número de identificação do cliente. Chave estrangeira da tabela clientes.';
COMMENT ON COLUMN envios.endereco_entrega   	IS 'Endereço para onde deverá ser entregue o pedido.';
COMMENT ON COLUMN envios.status 		  	  	IS 'Define o status da entraga. Valores válidos: CRIADO, ENVIADO, TRANSITO e ENTREGUE.';

-- Adicionar as check constraints da tabela envios.
ALTER TABLE    envios
ADD CONSTRAINT envio_id_posivivo
CHECK (
    envio_id > 0
);

ALTER TABLE    envios
ADD CONSTRAINT envios_loja_id_positivo
CHECK (
    loja_id > 0
);

ALTER TABLE    envios
ADD CONSTRAINT envios_cliente_id_positivo
CHECK (
    cliente_id > 0
);

ALTER TABLE    envios
ADD CONSTRAINT status_envio
CHECK (
    status IN ('CRIADO', 'ENVIADO', 'TRANSITO', 'ENTREGUE')
);

-- Criar a tabela pedidos.
CREATE TABLE pedidos (
                pedido_id  NUMERIC(38) NOT NULL,
                data_hora  TIMESTAMP   NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                status 	   VARCHAR(15) NOT NULL,
                loja_id    NUMERIC(38) NOT NULL,
                CONSTRAINT pk_pedidos PRIMARY KEY (pedido_id)
);

-- Adicionar comentarios para a tabela pedidos e suas colunas.
COMMENT ON TABLE  pedidos				IS 'Registra os pedidos feitos pelos clientes, incluindo detalhes como número do pedido, data, cliente associado e status do pedido.';
COMMENT ON COLUMN pedidos.pedido_id  	IS 'Número de identificação do pedido. Chave primária da tabela pedidos.';
COMMENT ON COLUMN pedidos.data_hora  	IS 'Mostra a data e hora quando foi feito o pedido.';
COMMENT ON COLUMN pedidos.cliente_id 	IS 'Número de identificação do cliente. Chave estrangeira da tabela clientes.';
COMMENT ON COLUMN pedidos.status     	IS 'Define o status do pedido. Valores válidos: CANCELADO, COMPLETO, ABERTO, PAGO, REEMBOLSADO e ENVIADO';
COMMENT ON COLUMN pedidos.loja_id    	IS 'Número de identificação da loja. Chave estrangeira da tabela lojas.';

-- Adicionar as check constraints da tabela pedidos.
ALTER TABLE    pedidos
ADD CONSTRAINT pedido_id_posivivo
CHECK (
    pedido_id > 0
);

ALTER TABLE    pedidos
ADD CONSTRAINT pedidos_cliente_id_positivo
CHECK (
    cliente_id > 0
);

ALTER TABLE    pedidos
ADD CONSTRAINT pedidos_loja_id_positivo
CHECK (
    loja_id > 0
);

ALTER TABLE    pedidos
ADD CONSTRAINT status_pedido
CHECK (
    status IN ('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO')
);

-- Criar a tabela pedidos_itens.
CREATE TABLE pedidos_itens (
                produto_id 		NUMERIC(38)   NOT NULL,
                pedido_id 		NUMERIC(38)   NOT NULL,
                numero_da_linha NUMERIC(38)   NOT NULL,
                preco_unitario  NUMERIC(10,2) NOT NULL,
                quantidade 		NUMERIC(38)   NOT NULL,
                envio_id 		NUMERIC(38),
                CONSTRAINT pk_pedidos_itens PRIMARY KEY (produto_id, pedido_id)
);

-- Adicionar comentarios para a tabela pedidos_itens e suas colunas.
COMMENT ON TABLE  pedidos_itens					IS 'Armazena informações sobre os itens individuais incluídos em cada pedido, como o produto associado, quantidade, preço unitário e outras informações relevantes para rastrear os detalhes do pedido.';
COMMENT ON COLUMN pedidos_itens.produto_id 	   	IS 'Número de identificação do produto. Parte da chave primária da tabela pedido_itens. Chave estrangeira da tabela produtos.';
COMMENT ON COLUMN pedidos_itens.pedido_id 	   	IS 'Número de identificação do pedido. Parte da chave primária da tabela pedido_itens. Chave estrangeira da tabela pedidos.';
COMMENT ON COLUMN pedidos_itens.preco_unitario  IS 'Preço por unidade do respectivo produto.';
COMMENT ON COLUMN pedidos_itens.quantidade 	   	IS 'Número de produtos requisitados por pedido.';
COMMENT ON COLUMN pedidos_itens.envio_id 	  	IS 'Número de identificação do envio. Chave estrangeira da tabela envios.';

-- Adicionar as check constraints da tabela pedidos_itens.
ALTER TABLE    pedidos_itens
ADD CONSTRAINT pedidos_itens_produto_id_positivo
CHECK (
    produto_id > 0
);

ALTER TABLE    pedidos_itens
ADD CONSTRAINT pedidos_itens_pedido_id_posivivo
CHECK (
    pedido_id > 0
);

ALTER TABLE    pedidos_itens
ADD CONSTRAINT pedidos_itens_envio_id_posivivo
CHECK (
    envio_id > 0
);

ALTER TABLE    pedidos_itens
ADD CONSTRAINT pedidos_itens_preco_positivo_ou_0
CHECK (
    preco_unitario >= 0
);

ALTER TABLE    pedidos_itens
ADD CONSTRAINT pedidos_itens_quantidade_positiva_ou_0
CHECK (
    quantidade >= 0
);

-- Criar as relações entre as tabelas.
ALTER TABLE    pedidos 
ADD CONSTRAINT lojas_pedidos_fk
FOREIGN KEY    (loja_id)
REFERENCES     lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE    estoques 
ADD CONSTRAINT lojas_estoques_fk
FOREIGN KEY    (loja_id)
REFERENCES     lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE    envios 
ADD CONSTRAINT lojas_envios_fk
FOREIGN KEY    (loja_id)
REFERENCES     lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE    pedidos_itens 
ADD CONSTRAINT produtos_pedidos_itens_fk
FOREIGN KEY    (produto_id)
REFERENCES     produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE    estoques 
ADD CONSTRAINT produtos_estoques_fk
FOREIGN KEY    (produto_id)
REFERENCES     produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE    pedidos 
ADD CONSTRAINT clientes_pedidos_fk
FOREIGN KEY    (cliente_id)
REFERENCES     clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE    envios 
ADD CONSTRAINT clientes_envios_fk
FOREIGN KEY    (cliente_id)
REFERENCES     clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE    pedidos_itens 
ADD CONSTRAINT envios_pedidos_itens_fk
FOREIGN KEY    (envio_id)
REFERENCES     envios (envio_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE    pedidos_itens 
ADD CONSTRAINT pedidos_pedidos_itens_fk
FOREIGN KEY    (pedido_id)
REFERENCES     pedidos (pedido_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;