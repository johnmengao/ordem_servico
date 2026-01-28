class OrdemServicoPeca:
    @staticmethod
    def adicionar(db, ordem_id, peca_id, quantidade, preco_unitario, desconto):
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO ordem_servico_peca (ordem_id, peca_id, quantidade, preco_unitario, desconto)
            VALUES (%s, %s, %s, %s, %s)
        """, (ordem_id, peca_id, quantidade, preco_unitario, desconto))
        db.commit()

    @staticmethod
    def vw_listar_por_ordem_peca(db, ordem_id):
        cursor = db.cursor(dictionary=True)
        cursor.execute("""
            SELECT * FROM vw_ordem_servico_peca
            WHERE ordem_id = %s
        """, (ordem_id,))
        return cursor.fetchall()


    @staticmethod
    def remover(db, id):
        cursor = db.cursor()
        cursor.execute("DELETE FROM ordem_servico_peca WHERE id = %s", (id,))
        db.commit()