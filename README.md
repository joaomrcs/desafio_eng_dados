# 📋 Projeto de Análise de Dados e Dashboard

## 📝 Descrição do Projeto

### Arquivo: `procedure_ranking.sql`

Este projeto desenvolve uma procedure no SQL Server para calcular as médias semestrais dos alunos e determinar o ganho de bolsa mérito. Além disso, realiza o arredondamento das médias para liberar o acesso à plataforma Alura e insere os resultados na tabela `Ranking`.

#### 🔍 Principais Características:

- **Parâmetros:**
  - `@Ano`: Define o ano para o cálculo.
  - `@Media`: Especifica o tipo de média a ser utilizada.
    - `'MediaFinal'`: Para 2023.
    - `'Media1'`: Para 2024.

- **Cálculo:**
  - Considera as notas dos alunos.
  - Aplica regras para distribuição de bolsas, incluindo a divisão de porcentagens entre alunos empatados.
  - Arredonda as notas para liberar o acesso à Alura.

---

## 📊 Descrição do Dashboard Streamlit

Complementando a procedure, foi desenvolvido um dashboard utilizando a biblioteca Streamlit via Python para oferecer uma visualização mais intuitiva e interativa dos dados. Este dashboard foi projetado para auxiliar o departamento financeiro na tomada de decisões de forma rápida e eficiente.

### 🎯 Características do Dashboard:

- **Interface intuitiva:** 
  - Design clean e fácil de navegar, permitindo que os usuários encontrem as informações desejadas rapidamente.
  
- **Métricas relevantes:** 
  - Apresenta indicadores-chave de desempenho (KPIs) personalizados para as necessidades do time financeiro.
  
- **Potencial de evolução:** 
  - Arquitetura modular e escalável, facilitando a adição de novas funcionalidades e fontes de dados no futuro.

### 🌐 Acesse o Dashboard Online

O dashboard também está disponível online. Você pode acessá-lo através do link abaixo:

[**Acessar o Dashboard**](https://dashboard-desafio.streamlit.app/)

### 🚀 Como Rodar o Dashboard Localmente

Para rodar o dashboard em sua máquina local, siga os passos abaixo:

1. **Abra o terminal.**

2. **Instale a biblioteca Streamlit.**
      pip install streamlit 

3. **Navegue até o diretório onde o arquivo `app_web.py` está localizado.**

4. **Execute o comando:**
      streamlit run app_web.py

Isso iniciará um servidor local, e o dashboard estará acessível via navegador no endereço [http://localhost:8501](http://localhost:8501)

---

### 🚀 Conclusão

A combinação da procedure com o dashboard oferece uma solução completa para a análise de dados e a tomada de decisões. Ao centralizar as informações mais relevantes em uma interface visualmente atraente e interativa, o dashboard agiliza o acesso à informação e permite uma melhor compreensão dos resultados.
