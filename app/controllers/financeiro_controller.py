from flask import Blueprint, render_template, request, redirect, current_app
from flask_login import login_required
from datetime import datetime
financeiro_bp = Blueprint('financeiro', __name__)
'''
@financeiro_bp.route('/financeiro/nova', methods=['GET', 'POST'])
@login_required
def nova_movimentacao():
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)

    if request.method == 'POST':
        tipo = request.form['tipo']
        origem = request.form['origem']
        descricao = request.form['descricao']
        valor = request.form['valor']
        metodo_pagamento_id = request.form['metodo_pagamento_id']

        cursor.execute("""
            INSERT INTO movimentacao_financeira (tipo, origem, descricao, valor, metodo_pagamento_id)
            VALUES (%s, %s, %s, %s, %s)
        """, (tipo, origem, descricao, valor, metodo_pagamento_id))
        db.commit()
        return redirect('/dashboard')

    cursor.execute("SELECT id, descricao FROM metodo_pagamento")
    metodos = cursor.fetchall()
    return render_template('financeiro/nova_movimentacao.html', metodos=metodos)
'''


@financeiro_bp.route('/financeiro/painel')
@login_required
def painel_financeiro():
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)

    # Filtros de data
    data_inicio = request.args.get('data_inicio')
    data_fim = request.args.get('data_fim')

    filtro_sql = ""
    params = []

    if data_inicio and data_fim:
        filtro_sql = "WHERE data_movimento BETWEEN %s AND %s"
        params = [data_inicio, data_fim]

    # Fluxo diário
    cursor.execute(f"""
        SELECT DATE(data_movimento) AS data, SUM(valor_consolidado) AS saldo
        FROM vw_fluxo_caixa_consolidado
        {filtro_sql}
        GROUP BY DATE(data_movimento)
        ORDER BY data DESC
    """, params)
    fluxo_diario = cursor.fetchall()

    # Resumo por tipo
    cursor.execute(f"""
        SELECT tipo, SUM(valor_consolidado) AS total
        FROM vw_fluxo_caixa_consolidado
        {filtro_sql}
        GROUP BY tipo
    """, params)
    resumo_tipo = cursor.fetchall()

    # Por forma de pagamento
    cursor.execute(f"""
        SELECT metodo_pagamento, SUM(valor_consolidado) AS total
        FROM vw_fluxo_caixa_consolidado
        {filtro_sql}
        GROUP BY metodo_pagamento
    """, params)
    por_pagamento = cursor.fetchall()

    return render_template('financeiro/painel.html',
                           fluxo_diario=fluxo_diario,
                           resumo_tipo=resumo_tipo,
                           por_pagamento=por_pagamento,
                           data_inicio=data_inicio,
                           data_fim=data_fim)
