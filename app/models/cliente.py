class Cliente:
    @staticmethod
    def buscar_por_id(db, id):
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM cliente WHERE id = %s", (id,))
        return cursor.fetchone()
    
    @staticmethod
    def listar(db):
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM cliente")
        return cursor.fetchall()

    @staticmethod
    def inserir(db, nome, telefone, email, cpf_cnpj, endereco, observacoes):
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO cliente (nome, telefone, email, cpf_cnpj, endereco, observacoes)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (nome, telefone, email, cpf_cnpj, endereco, observacoes))
        db.commit()

    @staticmethod
    def atualizar(db, id, nome, telefone, email, cpf_cnpj, endereco, observacoes):
        cursor = db.cursor()
        cursor.execute("""
            UPDATE cliente
            SET nome = %s, telefone = %s, email = %s,
                cpf_cnpj = %s, endereco = %s, observacoes = %s
            WHERE id = %s
        """, (nome, telefone, email, cpf_cnpj, endereco, observacoes, id))
        db.commit()

    @staticmethod
    def excluir(db, id):
        cursor = db.cursor()
        cursor.execute("DELETE FROM cliente WHERE id = %s", (id,))
        db.commit()
