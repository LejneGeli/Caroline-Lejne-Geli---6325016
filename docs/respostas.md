## 1. SGBD Relacional vs NoSQL

Um SGBD relacional como o PostgreSQL é mais adequado para esse cenário porque garante as propriedades ACID (Atomicidade, Consistência, Isolamento e Durabilidade).

No contexto de um sistema acadêmico, é essencial garantir a integridade dos dados. Por exemplo, uma matrícula não pode existir sem um aluno, e uma nota não pode ficar inconsistente. O modelo relacional permite isso através de chaves primárias (PK), chaves estrangeiras (FK) e restrições.

Além disso, o PostgreSQL garante que todas as operações ocorram de forma segura, evitando problemas como dados duplicados, inconsistentes ou incompletos. Já um banco NoSQL é mais flexível, porém não garante o mesmo nível de integridade, o que pode ser um risco para esse tipo de sistema.

## 2. Uso de Schemas

O uso de schemas permite organizar melhor o banco de dados, separando responsabilidades.

No projeto, foram criados dois schemas:

academico: responsável pelos dados principais do sistema
seguranca: responsável pelos dados sensíveis, como e-mail

Essa separação melhora a organização, facilita manutenção e aumenta a segurança. Por exemplo, é possível controlar permissões e impedir que determinados usuários tenham acesso a informações sensíveis.

Se todas as tabelas estivessem no schema public, o banco ficaria desorganizado e mais difícil de controlar em um ambiente profissional.

## 3. Modelo Lógico

O modelo foi estruturado separando as entidades principais do sistema:

Aluno
Docente
Disciplina
Turma
Matrícula em disciplina
Operador pedagógico
Ciclo letivo
Usuário (dados sensíveis)

Cada tabela representa uma entidade específica, evitando mistura de informações.

A tabela turma centraliza a relação entre disciplina, docente e ciclo.
A tabela matricula_disciplina representa o vínculo do aluno com a turma, incluindo a nota.

## 4. Aplicação das Formas Normais
 1FN (Primeira Forma Normal)

A 1FN foi aplicada garantindo que todos os campos sejam atômicos, ou seja, sem valores múltiplos em uma mesma coluna.

Exemplo:

Cada aluno possui uma única matrícula (PK)
Não existem listas dentro de colunas

## 2FN (Segunda Forma Normal)

A 2FN foi aplicada separando dados que não dependem totalmente da chave primária.

Exemplo:

Nome do docente foi separado da tabela de turma
Dados do aluno foram isolados na tabela aluno
Disciplina possui sua própria tabela

Isso evita repetição de dados e dependências parciais.

## 3FN (Terceira Forma Normal)

A 3FN foi aplicada removendo dependências transitivas.

Exemplo:

O ciclo letivo foi separado em sua própria tabela
A turma referencia o ciclo, ao invés de armazenar diretamente
Dados sensíveis (como e-mail) foram separados no schema seguranca

Isso evita redundância e melhora a consistência dos dados.

## 5. Concorrência (ACID e Locks)

Quando dois operadores tentam alterar a mesma nota ao mesmo tempo, o banco de dados precisa garantir que o dado final não fique inconsistente.

O PostgreSQL resolve isso utilizando o conceito de isolamento (ACID) e locks (bloqueios).

Quando uma transação começa a modificar um dado, o banco bloqueia aquele registro temporariamente. Isso impede que outra transação altere o mesmo dado ao mesmo tempo.

Assim, uma operação só é concluída quando a outra termina, garantindo que o valor final seja consistente.

Isso evita problemas como:

perda de dados
sobrescrita incorreta
inconsistência no banco

## Observação

As justificativas de normalização (1FN, 2FN, 3FN) também foram aplicadas diretamente no script SQL, através de comentários explicando cada decisão tomada durante a modelagem.

## Diagrama Entidade-Relacionamento (DER)

O diagrama abaixo representa o modelo relacional do sistema acadêmico, já normalizado até a 3FN:

![DER](/docs/DER-ProvaBD.png)

O DER demonstra as seguintes relações principais:

- Um aluno pode estar matriculado em várias turmas
- Cada turma pertence a uma disciplina, docente e ciclo letivo
- A tabela matricula_disciplina representa o relacionamento entre aluno e turma
- O operador pedagógico registra as ações acadêmicas

A modelagem evita redundância e segue as regras da 3ª Forma Normal (3FN).