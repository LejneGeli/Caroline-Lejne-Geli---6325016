-- =====================================================
-- PROVA PRÁTICA - SIGAEDU
-- =====================================================

-- Este script contém:
-- - criação do banco lógico
-- - aplicação das formas normais (1FN, 2FN, 3FN)
-- - justificativas diretamente nos comentários

-- =====================================================
-- SCHEMAS
-- =====================================================

-- Separação por responsabilidade (organização + segurança)
-- academico → dados do sistema
-- seguranca → dados sensíveis (ex: email)

CREATE SCHEMA academico;
CREATE SCHEMA seguranca;

-- =====================================================
-- TABELA: aluno
-- =====================================================

CREATE TABLE academico.aluno (
    matricula BIGINT PRIMARY KEY, 
    -- PK escolhida pois é única para cada aluno e não se repete (1FN aplicada aqui)

    nome VARCHAR(150) NOT NULL, 
    -- depende apenas do aluno → separado (2FN)

    data_ingresso DATE NOT NULL,
    -- pertence ao aluno → mantido aqui (2FN)

    ativo BOOLEAN DEFAULT TRUE
    -- controle lógico (boa prática, evita delete físico)
);

-- =====================================================
-- TABELA: docente
-- =====================================================

CREATE TABLE academico.docente (
    id_docente SERIAL PRIMARY KEY,
    -- PK criada pois o nome não é confiável como identificador único

    nome VARCHAR(150) NOT NULL,
    -- depende apenas do docente → separado (2FN)

    ativo BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- TABELA: disciplina
-- =====================================================

CREATE TABLE academico.disciplina (
    cod_disciplina VARCHAR(20) PRIMARY KEY,
    -- PK escolhida pois representa o código único da disciplina

    nome VARCHAR(150) NOT NULL,
    -- depende apenas da disciplina → separado (2FN)

    carga_h INTEGER NOT NULL CHECK (carga_h > 0),
    -- carga horária não pode ser zero nem negativa

    ativo BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- TABELA: operador_pedagogico
-- =====================================================

CREATE TABLE academico.operador_pedagogico (
    matricula_operador VARCHAR(20) PRIMARY KEY,
    -- identificador único do operador

    ativo BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- TABELA: ciclo_letivo
-- =====================================================

CREATE TABLE academico.ciclo_letivo (
    id_ciclo SERIAL PRIMARY KEY,
    -- criado para evitar depender de texto como chave

    codigo VARCHAR(10) NOT NULL UNIQUE,
    -- ex: 2026/1 → mantido como identificador lógico

    ativo BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- TABELA: turma
-- =====================================================

CREATE TABLE academico.turma (
    id_turma SERIAL PRIMARY KEY,
    -- PK criada para identificar cada oferta de disciplina

    cod_disciplina VARCHAR(20) NOT NULL,
    -- FK para disciplina

    id_docente INTEGER NOT NULL,
    -- FK para docente

    id_ciclo INTEGER NOT NULL,
    -- FK para ciclo letivo

    ativo BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_turma_disciplina
        FOREIGN KEY (cod_disciplina)
        REFERENCES academico.disciplina (cod_disciplina),
    -- ligação correta com disciplina (evita repetição de nome)

    CONSTRAINT fk_turma_docente
        FOREIGN KEY (id_docente)
        REFERENCES academico.docente (id_docente),
    -- docente não fica repetido na planilha → 2FN aplicada

    CONSTRAINT fk_turma_ciclo
        FOREIGN KEY (id_ciclo)
        REFERENCES academico.ciclo_letivo (id_ciclo),
    -- ciclo separado corretamente → evita dependência indireta (3FN)

    CONSTRAINT uq_turma UNIQUE (cod_disciplina, id_docente, id_ciclo)
    -- impede duplicação da mesma turma
);
-- =====================================================
-- TABELA: matricula_disciplina
-- =====================================================

CREATE TABLE academico.matricula_disciplina (
    id_matricula_disciplina SERIAL PRIMARY KEY,
    -- PK criada para identificar cada vínculo do aluno com uma turma

    matricula BIGINT NOT NULL,
    -- FK para aluno

    id_turma INTEGER NOT NULL,
    -- FK para turma

    matricula_operador VARCHAR(20) NOT NULL,
    -- FK para operador que registrou ou acompanhou o lançamento

    nota_final NUMERIC(4,2) NOT NULL CHECK (nota_final >= 0 AND nota_final <= 10),
-- a nota foi limitada entre 0 e 10 para garantir valor válido

    ativo BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_md_aluno
        FOREIGN KEY (matricula)
        REFERENCES academico.aluno (matricula),
    -- o aluno foi separado em sua própria tabela (2FN)

    CONSTRAINT fk_md_turma
        FOREIGN KEY (id_turma)
        REFERENCES academico.turma (id_turma),
    -- a turma centraliza disciplina + docente + ciclo (3FN)

    CONSTRAINT fk_md_operador
        FOREIGN KEY (matricula_operador)
        REFERENCES academico.operador_pedagogico (matricula_operador),
    -- operador fica separado para evitar repetição desnecessária

    CONSTRAINT uq_md UNIQUE (matricula, id_turma)
    -- impede que o mesmo aluno seja matriculado duas vezes na mesma turma
);
-- =====================================================
-- TABELA: usuario_aluno
-- =====================================================

CREATE TABLE seguranca.usuario_aluno (
    id_usuario SERIAL PRIMARY KEY,
    -- PK técnica criada para identificar cada registro de acesso/contato

    matricula BIGINT NOT NULL UNIQUE,
    -- cada aluno deve ter apenas um cadastro de usuário nesta tabela

    email VARCHAR(150) NOT NULL UNIQUE,
    -- email foi separado por ser dado sensível e não precisar ficar nas tabelas acadêmicas

    endereco VARCHAR(150) NOT NULL,
    -- endereço também pertence ao aluno, não à nota, nem à turma

    ativo BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_usuario_aluno
        FOREIGN KEY (matricula)
        REFERENCES academico.aluno (matricula)
    -- ligação com aluno sem repetir nome, nota ou disciplina
);
-- =====================================================
-- DADOS - INSERTS INICIAIS
-- =====================================================

-- =========================
-- ALUNOS
-- =========================

INSERT INTO academico.aluno (matricula, nome, data_ingresso) VALUES
(2026001, 'Ana Beatriz Lima', '2026-01-20'),
(2026002, 'Bruno Henrique Souza', '2026-01-21'),
(2026003, 'Camila Ferreira', '2026-01-22'),
(2026004, 'Diego Martins', '2026-01-23');

-- =========================
-- USUÁRIOS (dados sensíveis)
-- =========================

INSERT INTO seguranca.usuario_aluno (matricula, email, endereco) VALUES
(2026001, 'ana@email.com', 'Atibaia/SP'),
(2026002, 'bruno@email.com', 'Bragança/SP'),
(2026003, 'camila@email.com', 'Jundiaí/SP'),
(2026004, 'diego@email.com', 'Campinas/SP');

-- =========================
-- DOCENTES
-- =========================

INSERT INTO academico.docente (nome) VALUES
('Prof. Carlos Mendes'),
('Profa. Juliana Castro');

-- =========================
-- DISCIPLINAS
-- =========================

INSERT INTO academico.disciplina (cod_disciplina, nome, carga_h) VALUES
('ADS101', 'Banco de Dados', 80),
('ADS102', 'Engenharia de Software', 80);

-- =========================
-- OPERADORES
-- =========================

INSERT INTO academico.operador_pedagogico (matricula_operador) VALUES
('OP9001'),
('OP9002');

-- =========================
-- CICLOS
-- =========================

INSERT INTO academico.ciclo_letivo (codigo) VALUES
('2026/1');

-- =========================
-- TURMAS
-- =========================

INSERT INTO academico.turma (cod_disciplina, id_docente, id_ciclo)
SELECT 'ADS101', d.id_docente, c.id_ciclo
FROM academico.docente d, academico.ciclo_letivo c
WHERE d.nome = 'Prof. Carlos Mendes' AND c.codigo = '2026/1';

INSERT INTO academico.turma (cod_disciplina, id_docente, id_ciclo)
SELECT 'ADS102', d.id_docente, c.id_ciclo
FROM academico.docente d, academico.ciclo_letivo c
WHERE d.nome = 'Profa. Juliana Castro' AND c.codigo = '2026/1';

-- usamos SELECT para buscar os IDs automaticamente
-- evita erro de "chutar" id_docente ou id_ciclo
-- boa prática: nunca depender de valores fixos

-- =========================
-- MATRÍCULAS EM DISCIPLINA
-- =========================

INSERT INTO academico.matricula_disciplina (matricula, id_turma, matricula_operador, nota_final)
SELECT 2026001, t.id_turma, 'OP9001', 9.1
FROM academico.turma t
JOIN academico.ciclo_letivo c ON c.id_ciclo = t.id_ciclo
WHERE t.cod_disciplina = 'ADS101' AND c.codigo = '2026/1';

INSERT INTO academico.matricula_disciplina (matricula, id_turma, matricula_operador, nota_final)
SELECT 2026002, t.id_turma, 'OP9002', 7.5
FROM academico.turma t
JOIN academico.ciclo_letivo c ON c.id_ciclo = t.id_ciclo
WHERE t.cod_disciplina = 'ADS102' AND c.codigo = '2026/1';

SELECT 
    a.nome AS aluno,
    d.nome AS disciplina,
    c.codigo AS ciclo
FROM academico.matricula_disciplina md
JOIN academico.aluno a ON a.matricula = md.matricula
JOIN academico.turma t ON t.id_turma = md.id_turma
JOIN academico.disciplina d ON d.cod_disciplina = t.cod_disciplina
JOIN academico.ciclo_letivo c ON c.id_ciclo = t.id_ciclo
WHERE c.codigo = '2026/1';

SELECT 
    d.nome AS disciplina,
    AVG(md.nota_final) AS media
FROM academico.matricula_disciplina md
JOIN academico.turma t ON t.id_turma = md.id_turma
JOIN academico.disciplina d ON d.cod_disciplina = t.cod_disciplina
GROUP BY d.nome
HAVING AVG(md.nota_final) < 6;

SELECT 
    doc.nome AS docente,
    d.nome AS disciplina
FROM academico.docente doc
LEFT JOIN academico.turma t ON t.id_docente = doc.id_docente
LEFT JOIN academico.disciplina d ON d.cod_disciplina = t.cod_disciplina;

SELECT 
    a.nome,
    md.nota_final
FROM academico.matricula_disciplina md
JOIN academico.aluno a ON a.matricula = md.matricula
JOIN academico.turma t ON t.id_turma = md.id_turma
JOIN academico.disciplina d ON d.cod_disciplina = t.cod_disciplina
WHERE d.nome = 'Banco de Dados'
AND md.nota_final = (
    SELECT MAX(md2.nota_final)
    FROM academico.matricula_disciplina md2
    JOIN academico.turma t2 ON t2.id_turma = md2.id_turma
    JOIN academico.disciplina d2 ON d2.cod_disciplina = t2.cod_disciplina
    WHERE d2.nome = 'Banco de Dados'
);  

-- =====================================================
-- ROLES (DCL)
-- =====================================================

DROP ROLE IF EXISTS professor_role;
DROP ROLE IF EXISTS coordenador_role;

-- Professor: só pode atualizar nota
CREATE ROLE professor_role;

GRANT USAGE ON SCHEMA academico TO professor_role;
GRANT UPDATE (nota_final)
ON academico.matricula_disciplina
TO professor_role;

-- Coordenador: acesso total
CREATE ROLE coordenador_role;

GRANT USAGE ON SCHEMA academico, seguranca TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA seguranca TO coordenador_role;

-- impedir professor de ver email
REVOKE SELECT (email)
ON seguranca.usuario_aluno
FROM professor_role;