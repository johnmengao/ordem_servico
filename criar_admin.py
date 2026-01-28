from werkzeug.security import generate_password_hash
import mysql.connector
from config import DB_CONFIG

# Dados do usuário admin
nome = "Administrador"
email = "admin@teste.com"
senha_plana = "senha123"
tipo = "admin"

# Gerar hash da senha
senha_hash = generate_password_hash(senha_plana)

# Conectar ao banco
conn = mysql.connector.connect(**DB_CONFIG)
cursor = conn.cursor()

# Verifica se o admin já existe
cursor.execute("SELECT id FROM usuario WHERE email = %s", (email,))
existe = cursor.fetchone()

if existe:
    print("⚠️ Usuário admin já existe.")
else:
    # Inserir usuário
    cursor.execute("""
        INSERT INTO usuario (nome, email, senha, tipo)
        VALUES (%s, %s, %s, %s)
    """, (nome, email, senha_hash, tipo))
    conn.commit()
    print("✅ Usuário admin criado com sucesso!")

cursor.close()
conn.close()


