class MetodoPagamento:
    @staticmethod
    def listar(db):
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM metodo_pagamento ORDER BY descricao")
        return cursor.fetchall()

    @staticmethod
    def buscar_por_id(db, id):
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM metodo_pagamento WHERE id = %s", (id,))
        return cursor.fetchone()
 