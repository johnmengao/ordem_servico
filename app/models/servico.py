class Servico:
    @staticmethod
    def buscar_por_id(db, id):
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM servico WHERE id = %s", (id,))
        return cursor.fetchone()

    @staticmethod
    def listar(db):
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM servico")
        return cursor.fetchall()

    @staticmethod
    def inserir(db, nome, preco_padrao):
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO servico (nome, preco_padrao)
            VALUES (%s, %s)
        """, (nome, preco_padrao))
        db.commit()

    @staticmethod
    def atualizar(db, id, nome, preco_padrao):
        cursor = db.cursor()
        cursor.execute("""
            UPDATE servico
            SET nome = %s,
                preco_padrao = %s
            WHERE id = %s
        """, (nome, preco_padrao, id))
        db.commit()

    @staticmethod
    def excluir(db, id):
        cursor = db.cursor()
        cursor.execute("DELETE FROM servico WHERE id = %s", (id,))
        db.commit()
