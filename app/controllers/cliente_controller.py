from flask import Blueprint, render_template, request, redirect, current_app
from flask_login import login_required, current_user
from app.models.cliente import Cliente

cliente_bp = Blueprint('cliente', __name__)

@cliente_bp.route('/clientes')
@login_required
def listar_clientes():
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)

    pagina = int(request.args.get('pagina', 1))
    por_pagina = 10
    offset = (pagina - 1) * por_pagina

    # Consulta paginada
    cursor.execute("""
        SELECT * FROM cliente
        ORDER BY nome ASC
        LIMIT %s OFFSET %s
    """, (por_pagina, offset))
    clientes = cursor.fetchall()

    # Total de registros
    cursor.execute("SELECT COUNT(*) AS total FROM cliente")
    total = cursor.fetchone()['total']
    total_paginas = (total + por_pagina - 1) // por_pagina

    cursor.close()
    return render_template('clientes/listar.html', clientes=clientes, pagina=pagina, total_paginas=total_paginas)

@cliente_bp.route('/clientes/novo', methods=['GET', 'POST'])
@login_required
def novo_cliente():
    db = current_app.config['db']
    if request.method == 'POST':
        nome = request.form['nome']
        telefone = request.form['telefone']
        email = request.form['email']
        cpf_cnpj = request.form['cpf_cnpj']
        endereco = request.form['endereco']
        observacoes = request.form['observacoes']
        Cliente.inserir(db, nome, telefone, email, cpf_cnpj, endereco, observacoes)
        return redirect('/clientes')
    return render_template('clientes/novo.html')

@cliente_bp.route('/clientes/editar/<int:id>', methods=['GET', 'POST'])
@login_required
def editar_cliente(id):
    db = current_app.config['db']
    cliente = Cliente.buscar_por_id(db, id)
    if request.method == 'POST':
        nome = request.form['nome']
        telefone = request.form['telefone']
        email = request.form['email']
        cpf_cnpj = request.form['cpf_cnpj']
        endereco = request.form['endereco']
        observacoes = request.form['observacoes']
        Cliente.atualizar(db, id, nome, telefone, email, cpf_cnpj, endereco, observacoes)
        return redirect('/clientes')
    return render_template('clientes/editar.html', cliente=cliente)
