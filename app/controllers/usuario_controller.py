from flask import Blueprint, render_template, request, redirect, current_app, flash, url_for
from flask_login import login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from app.models.usuario import Usuario

usuario_bp = Blueprint('usuario', __name__)

@usuario_bp.route('/usuarios')
@login_required
def listar_usuarios():
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)

    # Filtros
    tipo = request.args.get('tipo')
    status = request.args.get('status')
    nome = request.args.get('nome')

    pagina = int(request.args.get('pagina', 1))
    por_pagina = 10
    offset = (pagina - 1) * por_pagina

    filtros = []
    valores = []

    if tipo:
        filtros.append("tipo = %s")
        valores.append(tipo)
    if status:
        filtros.append("ativo = %s")
        valores.append(1 if status == 'ativo' else 0)
    if nome:
        filtros.append("nome LIKE %s")
        valores.append(f"%{nome}%")

    where_clause = " AND ".join(filtros)
    if where_clause:
        where_clause = "WHERE " + where_clause

    # Consulta paginada
    cursor.execute(f"""
        SELECT * FROM usuario
        {where_clause}
        ORDER BY nome ASC
        LIMIT %s OFFSET %s
    """, valores + [por_pagina, offset])
    usuarios = cursor.fetchall()

    # Total para paginação
    cursor.execute(f"SELECT COUNT(*) AS total FROM usuario {where_clause}", valores)
    total = cursor.fetchone()['total']
    total_paginas = (total + por_pagina - 1) // por_pagina

    cursor.close()
    return render_template('usuarios/listar.html', usuarios=usuarios, pagina=pagina, total_paginas=total_paginas)




@usuario_bp.route('/usuarios/novo', methods=['GET', 'POST'])
@login_required
def novo_usuario():
    if current_user.tipo != 'admin':
        return redirect('/dashboard')

    db = current_app.config['db']  # ✅ acessa o banco de dados

    if request.method == 'POST':
        nome = request.form['nome']
        email = request.form['email']
        senha = generate_password_hash(request.form['senha'])  # ✅ criptografa a senha
        tipo = request.form['tipo']

        Usuario.inserir(db, nome, email, senha, tipo)  # ✅ insere no banco
        return redirect('/usuarios')

    return render_template('usuarios/novo.html')

@usuario_bp.route('/usuarios/editar/<int:id>', methods=['GET', 'POST'])
@login_required
def editar_usuario(id):
    if current_user.tipo != 'admin':
        return redirect('/dashboard')

    db = current_app.config['db']
    usuario = Usuario.buscar_por_id(db, id)

    if request.method == 'POST':
        nome = request.form['nome']
        email = request.form['email']
        tipo = request.form['tipo']
        ativo = request.form.get('ativo') == 'on'

        Usuario.atualizar(db, id, nome, email, tipo, ativo)
        return redirect('/usuarios')

    return render_template('usuarios/editar.html', usuario=usuario)

@usuario_bp.route('/usuarios/reset_senha/<int:id>', methods=['POST'])
@login_required
def reset_senha(id):
    if current_user.tipo != 'admin':
        return redirect('/dashboard')

    db = current_app.config['db']
    nova_senha = request.form['nova_senha']
    confirmar_senha = request.form['confirmar_senha']

    if nova_senha != confirmar_senha:
        flash("As senhas não coincidem. Tente novamente.", "danger")
        return redirect(url_for('usuario.editar_usuario', id=id))

    Usuario.atualizar_senha(db, id, nova_senha)
    flash("Senha redefinida com sucesso!", "success")
    return redirect(url_for('usuario.editar_usuario', id=id))



@usuario_bp.route('/usuarios/excluir/<int:id>', methods=['POST'])
@login_required
def excluir_usuario(id):
    if current_user.tipo != 'admin':
        return redirect('/dashboard')

    db = current_app.config['db']
    Usuario.excluir(db, id)
    return redirect('/usuarios')


