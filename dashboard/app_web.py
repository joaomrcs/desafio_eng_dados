import streamlit as st
import pandas as pd
from PIL import Image

# Carregar arquivo xlsx
df = pd.read_excel("results.xlsx")

# Personalização de alguns traços da dash
st.set_page_config(page_title='FIAP', page_icon='🎒')
image = Image.open('fiap_icon.jpg')
st.sidebar.image(image, width=120)

# Alterar os tipos das colunas
df['RM'] = df['RM'].astype(str)
df['Ano'] = df['Ano'].astype(str)

# Título central
st.write('# Central de bolsas acadêmicas')

# Filtros laterais
st.sidebar.header("Filtros")
ano = st.sidebar.selectbox("Ano", df['Ano'].unique())
semestre = st.sidebar.selectbox("Semestre", df['Semestre'].unique())
turma = st.sidebar.multiselect("Turma", df['Turma'].unique())
rm = st.sidebar.text_input("Digite o RM:")

# Aplicar os filtros selecionados
df_filtrado = df[(df['Ano'] == ano) & (df['Semestre'] == semestre)]

# Se uma turma específica foi selecionada, filtrar pelo nome da turma
if turma:
    df_filtrado = df_filtrado[df_filtrado['Turma'].isin(turma)]

# Filtrar o DataFrame com base no RM digitado
if rm:
    df_filtrado = df_filtrado[df_filtrado['RM'].astype(str) == rm] 

# Métricas
col1, col2, col3, col4 = st.columns(4)
with col1:
    total_bolsas = len(df['RM'])
    st.metric(label="# Alunos c/bolsa mérito", value=total_bolsas)

with col2:
    total_bolsas_alura = df[df['MediaAcessoAlura'] > 80]
    total_alunos_acima_80 = len(total_bolsas_alura)
    st.metric(label="# Alunos c/acesso alura", value=total_alunos_acima_80)

with col3:
    total_bolsas = df['Turma'].nunique()
    st.metric(label="# Quantidade de turmas", value=total_bolsas)

with col4:
    nota_media = df['MediaBolsaMerito'].mean()
    nota_media_formatada = f"{nota_media:.1f}"
    st.metric(label="Nota média", value=nota_media_formatada)

# Exibir tabela central
st.header("Contemplados")
st.dataframe(df_filtrado)