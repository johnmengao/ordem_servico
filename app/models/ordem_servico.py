from flask_login import login_required, current_user

class OrdemServico:
    @staticmethod
    def inserir(db, cliente_id, usuario_id, status, data_fechamento, titulo, descricao_entrada, 
        prioridade, desconto_peca, valor_servico, observacoes, metodo_pagamento_id):
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO ordem_servico (
                cliente_id, usuario_id, status, data_fechamento, titulo, descricao_entrada, prioridade, 
                desconto_peca, valor_servico, observacoes, metodo_pagamento_id
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            cliente_id, usuario_id, status, data_fechamento, titulo, descricao_entrada, prioridade, 
                desconto_peca, valor_servico, observacoes, metodo_pagamento_id
        ))
        db.commit()
        return cursor.lastrowid


    @staticmethod
    def buscar_por_id(db, id):
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM ordem_servico WHERE id = %s", (id,))
        return cursor.fetchone()

    @staticmethod
    def listar_todas(db):
        cursor = db.cursor(dictionary=True)
        cursor.execute("""
            SELECT os.*, c.nome AS cliente_nome, u.nome AS tecnico_nome
            FROM ordem_servico os
            JOIN cliente c ON c.id = os.cliente_id
            JOIN usuario u ON u.id = os.usuario_id
            ORDER BY os.data_abertura DESC
        """)
        return cursor.fetchall()

    @staticmethod
    def atualizar(db, ordem_id, status, descricao_saida, observacoes):
        cursor = db.cursor()
        cursor.execute("""
            UPDATE ordem_servico
            SET status = %s, descricao_saida = %s, observacoes = %s
            WHERE id = %s
        """, (status, descricao_saida, observacoes, ordem_id))
        db.commit()




##### cálculo automático do total da ordem de serviço, somando os valores dos serviços e peças com seus respectivos descontos. #####

    @staticmethod
    def calcular_total(db, ordem_id):
        cursor = db.cursor(dictionary=True)
        cursor.execute("""
            SELECT 
                total_servicos,
                total_pecas,
                total_geral
            FROM vw_ordem_servico_total
            WHERE ordem_id = %s
        """, (ordem_id,))
        
        resultado = cursor.fetchone()
        
        if resultado:
            return {
                'total_servicos': float(resultado['total_servicos']),
                'total_pecas': float(resultado['total_pecas']),
                'total_geral': float(resultado['total_geral'])
            }
        else:
            return {
                'total_servicos': 0.0,
                'total_pecas': 0.0,
                'total_geral': 0.0
            }


    @staticmethod
    def fechar(ordem_id):
        cursor = db.cursor()
        cursor.execute("""
            UPDATE ordem_servico SET status = 'fechada', data_fechamento = NOW()
            WHERE id = %s
        """, (ordem_id,))
        db.commit()

    @staticmethod
    def contagem_status():
        cursor = db.cursor(dictionary=True)
        cursor.execute("""
            SELECT status, COUNT(*) as total
            FROM ordem_servico
            GROUP BY status
        """)
        return {row['status']: row['total'] for row in cursor.fetchall()}

    @staticmethod
    def finalizar(db, ordem_id):
        cursor = db.cursor()
        cursor.execute("""
            UPDATE ordem_servico
            SET status = 'concluida', data_fechamento = CURDATE()
            WHERE id = %s
        """, (ordem_id,))
        db.commit()
