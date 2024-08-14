/*
    Nome da Procedure: Sp_GerarRanking
    Descrição: Esta procedure calcula a média dos alunos para determinar o ganho de bolsa mérito de 70%, 
               50% ou 30%, com base nos alunos de um determinado ano e tipo de média (Media1 ou MediaFinal). 
               A porcentagem da bolsa é dividida igualmente entre alunos que empataram no ranking. Em seguida, 
               faz o insert dos resultados na tabela 'Ranking'.

    Parâmetros:
        @Ano    - INT: Define o ano para o qual a pontuação será calculada. Valores possíveis: 2023, 2024.
        @Media  - VARCHAR(50): Define o tipo de média a ser utilizada nos cálculos. 
                  Valores possíveis: 'Media1' para o ano de 2023 e 'MediaFinal' para o ano de 2024.

    Exemplo de uso:
        EXEC Sp_GerarRanking @Ano = 2023, @Media = 'MediaFinal';
        EXEC Sp_GerarRanking @Ano = 2024, @Media = 'Media1'; 

    Observações:
        - A procedure deve ser executada com os parâmetros corretos, pois as combinações de ano e tipo de média
          são importantes para garantir que os cálculos sejam feitos corretamente.
        - As notas entre 77,75 e 79,99 são arredondadas para 80 na coluna 'MediaAcessoAlura'.
*/

CREATE PROCEDURE Sp_GerarRanking
    @Ano INT,  -- Parâmetro que representa o ano (2023 ou 2024)
    @Media NVARCHAR(50)  -- Parâmetro que representa o tipo de média (Media1 ou MediaFinal)
AS
BEGIN
    SET NOCOUNT ON;  -- Evita que o SQL Server retorne mensagens de contagem de linhas afetadas para cada operação

    -- Ativa a inserção manual de valores na coluna de identidade
    SET IDENTITY_INSERT Ranking ON;

    -- Insere os dados na tabela Ranking com base nos cálculos realizados
    INSERT INTO Ranking (
        Codigo,
        RM, 
        Nome, 
        Ano, 
        Semestre, 
        Turma, 
        QtdeDisciplina, 
        MediaBolsaMerito, 
        PosicaoBolsaMerito, 
        PorcentagemBolsaMerito, 
        MediaAcessoAlura
    )
    SELECT 
        ROW_NUMBER() OVER (ORDER BY PontuacaoFinal DESC) AS Codigo,  -- Gera um número sequencial para cada linha, usado como código
        RM, 
        Nome, 
        @Ano AS Ano,  -- Insere o ano passado como parâmetro na tabela Ranking
        Semestre,
        Turma, 
        QtdeDisciplinas AS QtdeDisciplina,
        ROUND(PontuacaoFinal, 3) AS MediaBolsaMerito,  -- Calcula a média da bolsa mérito, arredondada para 3 casas decimais
        RankingBolsa AS PosicaoBolsaMerito,  -- Define a posição no ranking de bolsa mérito
        CASE 
            WHEN PorcentagemBolsaInicial IS NOT NULL THEN 
                ROUND(PorcentagemBolsaInicial / TotalEmpatados, 2)  -- Divide a porcentagem da bolsa inicial entre os alunos empatados
            ELSE NULL
        END AS PorcentagemBolsaMerito,  -- Porcentagem final da bolsa mérito
        CASE 
            WHEN PontuacaoFinal >= 77.75 AND PontuacaoFinal < 80 THEN 80  -- Arredonda pontuação final para 80 se estiver entre 77.75 e 79.99
            ELSE PontuacaoFinal
        END AS MediaAcessoAlura  -- Define a média final para acesso ao Alura
    FROM (
        SELECT 
            *,
            COUNT(*) OVER (PARTITION BY NomeCurso, Semestre, Turma, PorcentagemBolsaInicial) 
            AS TotalEmpatados,  -- Conta quantos alunos estão empatados com a mesma porcentagem de bolsa
            SUM(CASE WHEN PorcentagemBolsaInicial IS NOT NULL THEN 1 ELSE 0 END) 
                OVER (PARTITION BY NomeCurso, Semestre, Turma) AS TotalBeneficiados,  -- Conta o total de alunos que receberam alguma porcentagem de bolsa
            DENSE_RANK() OVER (PARTITION BY NomeCurso, Semestre, Turma 
            ORDER BY PorcentagemBolsaInicial DESC) AS RankingBolsa  -- Define o ranking da bolsa, sem saltar números, para alunos com mesma porcentagem
        FROM (
            SELECT 
                *,
                CASE 
                    WHEN Ranking = 1 THEN 70  -- Define 70% de bolsa 
                    WHEN Ranking = 2 THEN 50  -- Define 50% de bolsa 
                    WHEN Ranking <= 5 THEN 30  -- Define 30% de bolsa
                    ELSE NULL
                END AS PorcentagemBolsaInicial,  -- Inicializa a porcentagem da bolsa com base na posição no ranking
                ROW_NUMBER() OVER (PARTITION BY NomeCurso, Semestre, Turma 
                ORDER BY PontuacaoFinal DESC) AS PosicaoEfetiva  -- Define a posição efetiva do aluno na turma, baseada na pontuação final
            FROM (
                SELECT 
                    n.RM,
                    n.Nome,
                    n.NomeCurso,
                    n.Semestre,
                    n.Turma,
                    -- Calcula a pontuação final baseada na média (Media1 ou MediaFinal) e na carga horária, conforme o ano
                    ROUND(SUM(
                        CASE @Ano 
                            WHEN 2023 THEN n.MediaFinal * n.CH  
                            WHEN 2024 THEN n.Media1 * n.CH  
                        END
                    ) / cht.CH_Total, 3) AS PontuacaoFinal,
                    RANK() OVER (PARTITION BY n.NomeCurso, n.Semestre, n.Turma 
                    ORDER BY SUM(
                        CASE @Ano 
                            WHEN 2023 THEN n.MediaFinal * n.CH
                            WHEN 2024 THEN n.Media1 * n.CH
                        END
                    ) / cht.CH_Total DESC) AS Ranking,  -- Define o ranking baseado na pontuação final
                    d.QtdeDisciplinas  -- Inclui a quantidade de disciplinas cursadas pelo aluno
                FROM Notas n
                JOIN (
                    -- Calcula a carga horária total por aluno
                    SELECT RM, SUM(CH) AS CH_Total
                    FROM Notas
                    WHERE Ano = @Ano AND CodigoDisciplina NOT IN (441, 448, 3528, 2627)
                    GROUP BY RM
                ) cht ON n.RM = cht.RM
                JOIN (
                    -- Calcula a quantidade de disciplinas cursadas por aluno, excluindo algumas específicas
                    SELECT 
                        RM, 
                        COUNT(DISTINCT CodigoDisciplina) AS QtdeDisciplinas
                    FROM Notas
                    WHERE CodigoDisciplina NOT IN (441, 448, 3528, 2627)
                    GROUP BY RM
                ) d ON n.RM = d.RM
                -- Filtra as disciplinas excluídas e agrupa os resultados por aluno, curso, semestre e turma
                WHERE n.CodigoDisciplina NOT IN (441, 448, 3528, 2627)
                GROUP BY n.RM, n.Nome, n.NomeCurso, n.Semestre, n.Turma, cht.CH_Total, d.QtdeDisciplinas
            ) AS Ranking
        ) AS RankingComBolsas
    ) AS BolsasDivididas
    WHERE PorcentagemBolsaInicial IS NOT NULL  -- Exclui alunos que não têm porcentagem de bolsa
    ORDER BY NomeCurso, Semestre, Turma, PontuacaoFinal DESC;  -- Ordena os resultados pelo curso, semestre, turma e pontuação final

    -- Desativa a inserção manual de valores na coluna de identidade
    SET IDENTITY_INSERT Ranking OFF;

END;

-- Executa a procedure
-- @Ano = 2023 ou 2024 | @Media = 'MediaFinal' ou 'Media1'
EXEC Sp_GerarRanking @Ano = 2023, @Media = 'MediaFinal';

-- Visualizar resultado
SELECT * FROM Ranking ORDER BY Ano, Turma, PosicaoBolsaMerito;