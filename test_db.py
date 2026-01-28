import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="sua_senha_do_banco",
    database="ordem_servico"
)

print("Conexão bem-sucedida!" if conn.is_connected() else "Falha na conexão.")
conn.close()

