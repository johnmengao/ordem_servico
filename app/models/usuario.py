from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash


class Usuario:

    @staticmethod
    def autenticar(db, email, senha):
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM usuario WHERE email = %s AND ativo = TRUE", (email,))
        usuario = cursor.fetchone()

        if usuario and check_password_hash(usuario['senha'], senha):
            return usuario
        return None

    @staticmethod
    def listar(db):
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM usuario")
        return cursor.fetchall()

    @staticmethod
    def inserir(db, nome, email, senha, tipo):
        senha_hash = generate_password_hash(senha)
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO usuario (nome, email, senha, tipo, ativo)
            VALUES (%s, %s, %s, %s, TRUE)
        """, (nome, email, senha_hash, tipo))
        db.commit()


    @staticmethod
    def buscar_por_id(db, id):
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM usuario WHERE id = %s", (id,))
        return cursor.fetchone()

    @staticmethod
    def atualizar(db, id, nome, email, tipo, ativo, senha=None):
        cursor = db.cursor()
        if senha:
            senha_hash = generate_password_hash(senha)
            cursor.execute("""
                UPDATE usuario
                SET nome = %s, email = %s, tipo = %s, ativo = %s, senha = %s
                WHERE id = %s
            """, (nome, email, tipo, ativo, senha_hash, id))
        else:
            cursor.execute("""
                UPDATE usuario
                SET nome = %s, email = %s, tipo = %s, ativo = %s
                WHERE id = %s
            """, (nome, email, tipo, ativo, id))
        db.commit()


    @staticmethod
    def excluir(db, id):
        cursor = db.cursor()
        cursor.execute("DELETE FROM usuario WHERE id = %s", (id,))
        db.commit()

    @staticmethod
    def contagem_por_tipo(db):
        cursor = db.cursor(dictionary=True)
        cursor.execute("""
            SELECT tipo, COUNT(*) as total
            FROM usuario
            GROUP BY tipo
        """)
        resultados = cursor.fetchall()
        return {r['tipo']: r['total'] for r in resultados}
