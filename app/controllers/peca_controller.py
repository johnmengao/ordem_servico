from flask import Blueprint, render_template, request, redirect, current_app
from flask_login import login_required, current_user
from app.models.peca import Peca

peca_bp = Blueprint('peca', __name__)

@peca_bp.route('/pecas')
@login_required
def listar_pecas():
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)

    pagina = int(request.args.get('pagina', 1))
    por_pagina = 10
    offset = (pagina - 1) * por_pagina

    # Consulta paginada
    cursor.execute("""
        SELECT * FROM peca
        ORDER BY nome ASC
        LIMIT %s OFFSET %s
    """, (por_pagina, offset))
    pecas = cursor.fetchall()

    # Total de registros
    cursor.execute("SELECT COUNT(*) AS total FROM peca")
    total = cursor.fetchone()['total']
    total_paginas = (total + por_pagina - 1) // por_pagina

    cursor.close()
    return render_template('pecas/listar.html', pecas=pecas, pagina=pagina, total_paginas=total_paginas)

@peca_bp.route('/pecas/nova', methods=['GET', 'POST'])
@login_required
def nova_peca():
    db = current_app.config['db']
    if request.method == 'POST':
        nome = request.form['nome']
        preco_padrao = request.form['preco_padrao']
        Peca.inserir(db, nome, preco_padrao)
        return redirect('/pecas')
    return render_template('pecas/nova.html')

@peca_bp.route('/pecas/editar/<int:id>', methods=['GET', 'POST'])
@login_required
def editar_peca(id):
    db = current_app.config['db']
    peca = Peca.buscar_por_id(db, id)
    if request.method == 'POST':
        nome = request.form['nome']
        preco_padrao = request.form['preco_padrao']
        Peca.atualizar(db, id, nome, preco_padrao)
        return redirect('/pecas')
    return render_template('pecas/editar.html', peca=peca)


@peca_bp.route('/pecas/excluir/<int:id>', methods=['POST'])
@login_required
def excluir_peca(id):
    db = current_app.config['db']
    Peca.excluir(db, id)
    return redirect('/pecas')