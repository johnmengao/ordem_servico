from flask import Blueprint, render_template, request, redirect, current_app
from flask_login import login_required, current_user
from app.models.servico import Servico

servico_bp = Blueprint('servico', __name__)

@servico_bp.route('/servicos')
@login_required
def listar_servicos():
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)

    pagina = int(request.args.get('pagina', 1))
    por_pagina = 10
    offset = (pagina - 1) * por_pagina

    # Consulta paginada
    cursor.execute("""
        SELECT * FROM servico
        ORDER BY nome ASC
        LIMIT %s OFFSET %s
    """, (por_pagina, offset))
    servicos = cursor.fetchall()

    # Total de registros
    cursor.execute("SELECT COUNT(*) AS total FROM servico")
    total = cursor.fetchone()['total']
    total_paginas = (total + por_pagina - 1) // por_pagina

    cursor.close()
    return render_template('servicos/listar.html', servicos=servicos, pagina=pagina, total_paginas=total_paginas)

@servico_bp.route('/servicos/novo', methods=['GET', 'POST'])
@login_required
def novo_servico():
    db = current_app.config['db']
    if request.method == 'POST':
        nome = request.form.get('nome')
        preco_padrao = request.form.get('preco_padrao', type=float)

        if nome and preco_padrao is not None:
            Servico.inserir(db, nome, preco_padrao)
            return redirect('/servicos')
        else:
            flash('Preencha todos os campos corretamente.')
            return redirect('/servicos/novo')

    return render_template('servicos/novo.html')


@servico_bp.route('/servicos/editar/<int:id>', methods=['GET', 'POST'])
@login_required
def editar_servico(id):
    db = current_app.config['db']
    servico = Servico.buscar_por_id(db, id)
    if request.method == 'POST':
        nome = request.form['nome']
        preco_padrao = request.form['preco_padrao']
        Servico.atualizar(db, id, nome, preco_padrao)
        return redirect('/servicos')
    return render_template('servicos/editar.html', servico=servico)


@servico_bp.route('/servicos/excluir/<int:id>', methods=['POST'])
@login_required
def excluir_servico(id):
    db = current_app.config['db']
    Servico.excluir(db, id)
    return redirect('/servicos')

