CREATE DATABASE db_exercicio_udf
GO
USE db_exercicio_udf
GO
CREATE TABLE funcionario(
	codigo INT,
	nome VARCHAR(100),
	salario DECIMAL(5,2),
	PRIMARY KEY(codigo)
)
GO
CREATE TABLE dependente(
	codigo_dependente INT,
	codigo_funcionario INT,
	nome_dependente VARCHAR(100),
	salario_dependente DECIMAL(5,2),
	PRIMARY KEY(codigo_dependente),
	FOREIGN KEY(codigo_funcionario) REFERENCES funcionario(codigo)
)

DECLARE @codigo INT, @nome_func VARCHAR(100), @salario_func DECIMAL(7,2)
DECLARE @nome_depend VARCHAR(100), @salario_depend DECIMAL(7,2), @codigo_depend INT,
@num INT
SET @codigo = 1

WHILE(@codigo < 12)
BEGIN
	SET @nome_func = 'Funcionario ' + CAST(@codigo AS VARCHAR(03))
	SET @salario_func =	(RAND()  * 1000)


	INSERT INTO funcionario VALUES (@codigo, @nome_func, @salario_func)

	SET @num = 1
	WHILE(@num < 3) BEGIN
		SET @nome_depend = 'Dependente ' + CAST(@codigo AS VARCHAR(03))
		SET @salario_depend = (RAND()  * 1000)
		SET @codigo_depend = @codigo + (@num * 10)
		INSERT INTO dependente VALUES (@codigo_depend, @codigo, @nome_depend, @salario_depend)
		SET @num = @num + 1
	END
	SET @codigo = @codigo + 1
END


SELECT funcionario.nome AS 'Nome do Funcionario', nome_dependente, salario_dependente, salario FROM funcionario, dependente
WHERE funcionario.codigo = dependente.codigo_funcionario


CREATE FUNCTION fn_relacao()
RETURNS @relacao TABLE(
	nome_funcionario VARCHAR(100),
	nome_dependente VARCHAR(100),
	salario_funcionario DECIMAL(7,2),
	salario_dependente DECIMAL(7,2)
	)
AS
	BEGIN
		INSERT INTO @relacao 
		SELECT funcionario.nome , nome_dependente, salario, salario_dependente FROM funcionario, dependente
		WHERE funcionario.codigo = dependente.codigo_funcionario 
		RETURN
	END

SELECT * FROM dbo.fn_relacao()

ALTER FUNCTION fn_soma_salario(@codigo INT)
RETURNS DECIMAL(7,2) BEGIN
	DECLARE @soma_salario DECIMAL(7,2)
	DECLARE @salario_func DECIMAL(7,2)

	SELECT @soma_salario = SUM(salario_dependente) FROM fn_relacao() WHERE nome_funcionario LIKE '% ' + CAST(@codigo AS VARCHAR(03))+ '%'  GROUP BY nome_funcionario
	SET @salario_func = (SELECT salario_funcionario FROM fn_relacao() WHERE nome_funcionario LIKE '% ' + CAST(3 AS VARCHAR(03))+ '%' GROUP BY salario_funcionario)
	SET @soma_salario = @soma_salario + @salario_func

	RETURN @soma_salario
	END

SELECT dbo.fn_soma_salario(1)

