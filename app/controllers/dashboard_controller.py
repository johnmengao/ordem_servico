from flask import render_template, request, current_app, jsonify, flash, redirect, url_for
from flask_login import login_required, current_user
from app.models.cliente import Cliente
from app.models.peca import Peca
from app.models.servico import Servico
from app.models.usuario import Usuario
from flask import Blueprint
import calendar
import os

dashboard_bp = Blueprint('dashboard', __name__)

@dashboard_bp.route('/dashboard')
@login_required
def dashboard():
    db = current_app.config['db']
    de = request.args.get('de')
    ate = request.args.get('ate')

    filtro = ""
    params = []
    if de and ate:
        filtro = "WHERE data_abertura BETWEEN %s AND %s"
        params = [de, ate]

    cursor = db.cursor(dictionary=True)
    cursor.execute(f"SELECT status, COUNT(*) as total FROM ordem_servico {filtro} GROUP BY status", params)
    ordens = {row['status']: row['total'] for row in cursor.fetchall()}

    cursor.execute("SELECT SUM(valor) AS total_dia FROM movimentacao_financeira WHERE DATE(data_movimento) = CURDATE()")
    total_dia = cursor.fetchone()['total_dia'] or 0.00

    cursor.execute("SELECT SUM(valor) AS total_mes FROM movimentacao_financeira WHERE MONTH(data_movimento) = MONTH(CURDATE()) AND YEAR(data_movimento) = YEAR(CURDATE())")
    total_mes = cursor.fetchone()['total_mes'] or 0.00

    cursor.execute("SELECT SUM(valor) AS total_ano FROM movimentacao_financeira WHERE YEAR(data_movimento) = YEAR(CURDATE())")
    total_ano = cursor.fetchone()['total_ano'] or 0.00

    cursor.execute("SELECT mp.descricao, SUM(mf.valor) AS total FROM movimentacao_financeira mf JOIN metodo_pagamento mp ON mf.metodo_pagamento_id = mp.id WHERE mf.tipo = 'entrada' GROUP BY mp.descricao")
    resultados = cursor.fetchall()
    labels = [row['descricao'] for row in resultados]
    valores = [float(row['total']) for row in resultados]

    clientes = len(Cliente.listar(db))
    pecas = len(Peca.listar(db))
    servicos = len(Servico.listar(db))
    usuarios = Usuario.contagem_por_tipo(db) if current_user.tipo == 'admin' else None

    cursor.close()
    return render_template('dashboard/dashboard.html', usuario=current_user, ordens=ordens, clientes=clientes, pecas=pecas, servicos=servicos, usuarios=usuarios, total_dia=total_dia, total_mes=total_mes, total_ano=total_ano, labels=labels, valores=valores)

@dashboard_bp.route('/dashboard/evolucao')
@login_required
def evolucao_ordens():
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT MONTH(data_abertura) AS mes,
               SUM(CASE WHEN status IN ('aberta', 'aguardando_pecas') THEN 1 ELSE 0 END) AS abertas,
               SUM(CASE WHEN status IN ('concluida', 'fechada') THEN 1 ELSE 0 END) AS fechadas
        FROM ordem_servico
        WHERE data_abertura IS NOT NULL
        GROUP BY MONTH(data_abertura)
        ORDER BY mes
    """)
    resultados = cursor.fetchall()
    cursor.close()

    dados = {}
    for linha in resultados:
        nome_mes = calendar.month_abbr[int(linha['mes'])].capitalize()
        dados[nome_mes] = {
            'aberta': int(linha['abertas'] or 0),
            'fechada': int(linha['fechadas'] or 0)
        }

    return jsonify(dados)

@dashboard_bp.route('/dashboard/logo', methods=['POST'])
@login_required
def upload_logo():
    if 'logo' not in request.files:
        flash('Nenhum arquivo enviado!', 'danger')
        return redirect(url_for('dashboard.dashboard'))

    file = request.files['logo']
    if file.filename == '':
        flash('Arquivo inválido!', 'danger')
        return redirect(url_for('dashboard.dashboard'))

    # Caminho fixo para sobrescrever a logo
    caminho_logo = os.path.join(current_app.root_path, 'static', 'img', 'logo_empresa.png')
    file.save(caminho_logo)

    flash('Logo atualizada com sucesso!', 'success')
    return redirect(url_for('dashboard.dashboard'))