from flask import Blueprint, render_template, request, redirect, current_app, flash, make_response, jsonify
from flask_login import login_required, current_user
from app.models.cliente import Cliente
from app.models.peca import Peca
from app.models.servico import Servico
from app.models.ordem_servico import OrdemServico
from app.models.ordem_servico_servico import OrdemServicoServico
from app.models.ordem_servico_peca import OrdemServicoPeca
from app.models.metodo_pagamento import MetodoPagamento
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from io import BytesIO
import os
from datetime import datetime
from weasyprint import HTML
import calendar

ordem_bp = Blueprint('ordem', __name__)

@ordem_bp.route('/dashboard')
@login_required
def dashboard_principal():
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)

    # Buscar totais
    cursor.execute("SELECT COUNT(*) AS total FROM cliente")
    clientes = cursor.fetchone()['total']

    cursor.execute("SELECT COUNT(*) AS total FROM peca")
    pecas = cursor.fetchone()['total']

    cursor.execute("SELECT COUNT(*) AS total FROM servico")
    servicos = cursor.fetchone()['total']

    cursor.execute("SELECT COUNT(*) AS total FROM ordem_servico WHERE status = 'aberta'")
    total_abertas = cursor.fetchone()['total']

    cursor.execute("SELECT COUNT(*) AS total FROM ordem_servico WHERE status = 'fechada'")
    total_fechadas = cursor.fetchone()['total']

    # Montar dicionário para o gráfico
    ordens = {
        'aberta': total_abertas,
        'fechada': total_fechadas
    }

    # Se quiser incluir usuários por tipo
    cursor.execute("""
        SELECT tipo, COUNT(*) AS total
        FROM usuario
        GROUP BY tipo
    """)
    usuarios_raw = cursor.fetchall()
    usuarios = {u['tipo']: u['total'] for u in usuarios_raw}

    return render_template(
        'dashboard.html',
        clientes=clientes,
        pecas=pecas,
        servicos=servicos,
        ordens=ordens,
        usuarios=usuarios,
        usuario=session['usuario']
    )



@ordem_bp.route('/ordens')
@login_required
def listar_ordens():
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)

    # Filtros
    status = request.args.get('status')
    prioridade = request.args.get('prioridade')
    cliente = request.args.get('cliente')

    # Paginação
    pagina = int(request.args.get('pagina', 1))
    por_pagina = 10
    offset = (pagina - 1) * por_pagina

    # Monta cláusulas de filtro
    filtros = []
    valores = []

    if status:
        filtros.append("os.status = %s")
        valores.append(status)
    if prioridade:
        filtros.append("os.prioridade = %s")
        valores.append(prioridade)
    if cliente:
        filtros.append("c.nome LIKE %s")
        valores.append(f"%{cliente}%")

    where_clause = " AND ".join(filtros)
    if where_clause:
        where_clause = "WHERE " + where_clause

    # Consulta principal com limite
    cursor.execute(f"""
        SELECT os.*, c.nome AS cliente_nome, mp.descricao AS metodo_pagamento_descricao
        FROM ordem_servico os
        JOIN cliente c ON os.cliente_id = c.id
        LEFT JOIN metodo_pagamento mp ON os.metodo_pagamento_id = mp.id
        {where_clause}
        ORDER BY os.data_abertura DESC
        LIMIT %s OFFSET %s
    """, valores + [por_pagina, offset])
    ordens = cursor.fetchall()

    # Total de registros para paginação
    cursor.execute(f"""
        SELECT COUNT(*) AS total
        FROM ordem_servico os
        JOIN cliente c ON os.cliente_id = c.id
        {where_clause}
    """, valores)
    total = cursor.fetchone()['total']
    total_paginas = (total + por_pagina - 1) // por_pagina

    cursor.close()
    return render_template('ordens/listar.html', ordens=ordens, total_paginas=total_paginas, pagina=pagina)
    

@ordem_bp.route('/ordens/nova', methods=['GET', 'POST'])
@login_required
def nova_ordem():
    db = current_app.config['db']
    clientes = Cliente.listar(db)
    metodos = MetodoPagamento.listar(db)

    if request.method == 'POST':
        cliente_id = request.form['cliente_id']
        usuario_id = current_user.id
        status = request.form.get('status', 'aberta')
        data_fechamento = None
        titulo = request.form['titulo']
        descricao_entrada = request.form['descricao_entrada']
        prioridade = request.form.get('prioridade', 'media')
        observacoes = request.form.get('observacoes')
        #Se metodo_pagamento_id não foi enviado ou está vazio, definir como 4
        metodo_pagamento_id = request.form.get('metodo_pagamento_id')
        if not metodo_pagamento_id:
            metodo_pagamento_id = 4
        
        ordem_id = OrdemServico.inserir(
            db, cliente_id, usuario_id, status, data_fechamento, titulo, descricao_entrada, prioridade,
            0.00, 0.00, observacoes, metodo_pagamento_id
        )
        return redirect(f'/ordens/editar/{ordem_id}')

    return render_template('ordens/nova.html', clientes=clientes, metodos=metodos)


@ordem_bp.route('/ordens/editar/<int:id>', methods=['GET', 'POST'])
@login_required
def editar_ordem(id):
    db = current_app.config['db']
    ordem = OrdemServico.buscar_por_id(db, id)

    if request.method == 'POST':
        status = request.form.get('status')
        descricao_saida = request.form.get('descricao_saida')
        observacoes = request.form.get('observacoes')

        try:
            OrdemServico.atualizar(db, id, status, descricao_saida, observacoes)
            flash('Ordem atualizada com sucesso!', 'success')
            return redirect(f'/ordens/editar/{id}')
        except Exception as e:
            flash(f'Erro ao atualizar ordem: {str(e)}', 'danger')
            return redirect(f'/ordens/editar/{id}')

    servicos = OrdemServicoServico.vw_listar_por_ordem_servico(db, id)
    pecas = OrdemServicoPeca.vw_listar_por_ordem_peca(db, id)
    totais = OrdemServico.calcular_total(db, id)  

    return render_template('ordens/editar.html',
                           ordem=ordem,
                           servicos=servicos,
                           pecas=pecas,
                           totais=totais)


@ordem_bp.route('/ordens/ver/<int:id>')
@login_required
def ver_ordem(id):
    db = current_app.config['db']
    ordem = OrdemServico.buscar_por_id(db, id)
    cliente = Cliente.buscar_por_id(db, ordem['cliente_id'])
    servicos = OrdemServicoServico.vw_listar_por_ordem_servico(db, id)
    pecas = OrdemServicoPeca.vw_listar_por_ordem_peca(db, id)
    totais = OrdemServico.calcular_total(db, id)
    metodo_pagamento = MetodoPagamento.buscar_por_id(db, ordem['metodo_pagamento_id'])

    return render_template('ordens/ver.html', ordem=ordem, cliente=cliente,
                       servicos=servicos, pecas=pecas, totais=totais, metodo_pagamento=metodo_pagamento)


@ordem_bp.route('/ordens/orcamento/<int:id>')
@login_required
def gerar_orcamento(id):
    db = current_app.config['db']
    ordem = OrdemServico.buscar_por_id(db, id)
    cliente = Cliente.buscar_por_id(db, ordem['cliente_id'])
    servicos = OrdemServicoServico.vw_listar_por_ordem_servico(db, id)
    pecas = OrdemServicoPeca.vw_listar_por_ordem_peca(db, id)
    totais = OrdemServico.calcular_total(db, id)  # ✅ ESSENCIAL
    metodo_pagamento = MetodoPagamento.buscar_por_id(db, ordem['metodo_pagamento_id'])

    return render_template('ordens/orcamento.html',
                           ordem=ordem,
                           cliente=cliente,
                           servicos=servicos,
                           pecas=pecas,
                           totais=totais,
                           metodo_pagamento=metodo_pagamento)

@ordem_bp.route('/ordens/fechar/<int:ordem_id>')
def fechar_ordem(ordem_id):
    OrdemServico.fechar(ordem_id)
    return redirect('/ordens')


#####  adicionar serviço à ordem  #####
@ordem_bp.route('/ordens/adicionar_servico/<int:ordem_id>', methods=['GET', 'POST'])
@login_required
def adicionar_servico(ordem_id):
    db = current_app.config['db']
    servicos_disponiveis = Servico.listar(db)
    ordem_servicos = OrdemServicoServico.vw_listar_por_ordem_servico(db, ordem_id)

    if request.method == 'POST':
        servico_id = int(request.form['servico_id'])
        quantidade = int(request.form['quantidade'])
        preco_unitario = float(request.form['preco_unitario'])
        desconto = float(request.form['desconto'])

        OrdemServicoServico.adicionar(db, ordem_id, servico_id, quantidade, preco_unitario, desconto)
        return redirect(f'/ordens/editar/{ordem_id}')

    return render_template('ordens/adicionar_servico.html', ordem_id=ordem_id, servicos=servicos_disponiveis)


##### adicionar peças à ordem #####
@ordem_bp.route('/ordens/adicionar_peca/<int:ordem_id>', methods=['GET', 'POST'])
@login_required
def adicionar_peca(ordem_id):
    db = current_app.config['db']
    pecas_disponiveis = Peca.listar(db)
    ordem_pecas = OrdemServicoPeca.vw_listar_por_ordem_peca(db, ordem_id)

    if request.method == 'POST':
        peca_id = int(request.form['peca_id'])
        quantidade = int(request.form['quantidade'])
        preco_unitario = float(request.form['preco_unitario'])
        desconto = float(request.form['desconto'])

        OrdemServicoPeca.adicionar(db, ordem_id, peca_id, quantidade, preco_unitario, desconto)
        return redirect(f'/ordens/editar/{ordem_id}')

    return render_template('ordens/adicionar_peca.html', ordem_id=ordem_id, pecas=pecas_disponiveis)


##### Exportar para pdf #####
@ordem_bp.route('/ordens/pdf/<int:id>')
@login_required
def gerar_pdf_ordem(id):
    db = current_app.config['db']
    ordem = OrdemServico.buscar_por_id(db, id)
    cliente = Cliente.buscar_por_id(db, ordem['cliente_id'])
    servicos = OrdemServicoServico.vw_listar_por_ordem_servico(db, id)
    pecas = OrdemServicoPeca.vw_listar_por_ordem_peca(db, id)
    totais = OrdemServico.calcular_total(db, id)

    buffer = BytesIO()
    pdf = canvas.Canvas(buffer, pagesize=A4)
    width, height = A4
    y = height - 50

    def linha(texto, tamanho=10, deslocamento=15):
        nonlocal y
        pdf.setFont("Helvetica", tamanho)
        pdf.drawString(50, y, texto)
        y -= deslocamento

    # Cabeçalho
    pdf.setFont("Helvetica-Bold", 14)
    pdf.drawString(200, y, "Ordem de Serviço")
    y -= 30

    linha("Empresa: TechService Solutions", 10)
    linha("Endereço: Rua das Inovações, 123 - Teresina, PI")
    linha("Telefone: (86) 99999-0000 | Email: contato@techservice.com.br")
    y -= 10
    pdf.line(50, y, width - 50, y)
    y -= 20

    # Cliente
    linha("Cliente:")
    linha(f"Nome: {cliente['nome']}")
    linha(f"Email: {cliente['email']}")
    linha(f"Telefone: {cliente['telefone']}")
    y -= 10
    pdf.line(50, y, width - 50, y)
    y -= 20

    # Ordem
    linha("Dados da Ordem:")
    linha(f"ID: {ordem['id']}")
    linha(f"Data de Entrada: {ordem['data_abertura']}")
    linha(f"Data de Saída: {ordem['data_fechamento'] or '—'}")
    linha(f"Status: {ordem['status']}")
    linha(f"Prioridade: {ordem['prioridade']}")
    linha(f"Título: {ordem['titulo']}")
    linha(f"Descrição de Entrada: {ordem['descricao_entrada']}")
    linha(f"Descrição de Saída: {ordem['descricao_saida'] or '—'}")
    y -= 10
    pdf.line(50, y, width - 50, y)
    y -= 20

    # Serviços
    linha("Serviços Executados:")
    if servicos:
        for s in servicos:
            total = s['quantidade'] * s['preco_unitario'] * (1 - s['desconto'] / 100)
            linha(f"- {s['nome']} | Qtd: {s['quantidade']} | R$ {s['preco_unitario']:.2f} | Desc: {s['desconto']}% | Total: R$ {total:.2f}")
    else:
        linha("Nenhum serviço registrado.")
    y -= 10

    # Peças
    linha("Peças Utilizadas:")
    if pecas:
        for p in pecas:
            total = p['quantidade'] * p['preco_unitario'] * (1 - p['desconto'] / 100)
            linha(f"- {p['nome']} | Qtd: {p['quantidade']} | R$ {p['preco_unitario']:.2f} | Desc: {p['desconto']}% | Total: R$ {total:.2f}")
    else:
        linha("Nenhuma peça registrada.")
    y -= 10

    # Totais
    linha("Totais:")
    linha(f"Total de Serviços: R$ {totais['total_servicos']:.2f}")
    linha(f"Total de Peças: R$ {totais['total_pecas']:.2f}")
    linha(f"Total Geral: R$ {totais['total_geral']:.2f}")
    y -= 30

    # Assinaturas
    linha("Assinatura do Técnico: ____________________________", 10, 25)
    linha("Assinatura do Cliente: ____________________________", 10, 25)

    pdf.save()
    buffer.seek(0)

    return send_file(buffer, as_attachment=True, download_name=f"ordem_{id}.pdf", mimetype='application/pdf')


##### Imprimir ordem #####
@ordem_bp.route('/ordens/relatorio_pdf/<int:ordem_id>')
def imprimir_ordem(ordem_id):
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)

    # Caminho absoluto para o logo
    logo_path = os.path.join(current_app.root_path, 'static', 'img', 'logo_empresa.png')

    # Buscar dados da ordem
    cursor.execute("SELECT * FROM vw_ordem_servico_resumo WHERE ordem_id = %s", (ordem_id,))
    ordem = cursor.fetchone()

    # Buscar serviços
    cursor.execute("""
        SELECT oss.id, s.nome AS servico_nome, oss.quantidade, oss.preco_unitario, oss.desconto
        FROM ordem_servico_servico oss
        JOIN servico s ON s.id = oss.servico_id
        WHERE oss.ordem_id = %s
    """, (ordem_id,))
    servicos = cursor.fetchall()

    # Buscar peças
    cursor.execute("""
        SELECT osp.id, p.nome, osp.quantidade, osp.preco_unitario, osp.desconto
        FROM ordem_servico_peca osp
        JOIN peca p ON p.id = osp.peca_id
        WHERE osp.ordem_id = %s
    """, (ordem_id,))
    pecas = cursor.fetchall()

    # Gerar HTML com dados
    rendered = render_template(
        'ordens/relatorio_pdf.html',
        ordem=ordem,
        servicos=servicos,
        pecas=pecas,
        logo_path=logo_path,
        now=datetime.now()
    )

    # Gerar PDF
    pdf = HTML(string=rendered).write_pdf()

    # Retornar como resposta
    response = make_response(pdf)
    response.headers['Content-Type'] = 'application/pdf'
    response.headers['Content-Disposition'] = f'inline; filename=ordem_{ordem_id}.pdf'
    return response



@ordem_bp.route('/ordens/orcamento/<int:id>')
@login_required
def orcamento(id):
    db = current_app.config['db']
    ordem = OrdemServico.buscar_por_id(db, id)
    cliente = Cliente.buscar_por_id(db, ordem['cliente_id'])
    servicos = OrdemServicoServico.listar_por_ordem(db, id)
    pecas = OrdemServicoPeca.listar_por_ordem(db, id)
    totais = OrdemServico.calcular_total(db, id)
    metodo_pagamento = MetodoPagamento.buscar_por_id(db, ordem['metodo_pagamento_id'])
    
    return render_template('ordens/orcamento.html', ordem=ordem, cliente=cliente,
                           servicos=servicos, pecas=pecas, totais=totais, metodo_pagamento=metodo_pagamento)


##### Remover ######
@ordem_bp.route('/ordens/remover_servico/<int:id>')
@login_required
def remover_servico(id):
    db = current_app.config['db']
    OrdemServicoServico.remover(db, id)
    return redirect(request.referrer)

@ordem_bp.route('/ordens/remover_peca/<int:id>')
@login_required
def remover_peca(id):
    db = current_app.config['db']
    OrdemServicoPeca.remover(db, id)
    return redirect(request.referrer)



##### Finalizar Ordem de Serviço #####
'''
@ordem_bp.route('/ordens/finalizar/<int:id>', methods=['POST'])
@login_required
def finalizar_ordem(id):
    db = current_app.config['db']
    metodo_pagamento_id = request.form['metodo_pagamento_id']

    cursor = db.cursor()
    cursor.execute("""
        UPDATE ordem_servico
        SET status = 'concluida',
            metodo_pagamento_id = %s,
            data_fechamento = NOW()
        WHERE id = %s
    """, (metodo_pagamento_id, id))
    db.commit()
    cursor.close()

    cursor.execute("SELECT total_geral FROM vw_ordem_servico_resumo WHERE id = %s", (id,))
    ordem = cursor.fetchone()

    return redirect('/ordens')

'''

@ordem_bp.route('/ordens/finalizar/<int:id>', methods=['POST'])
@login_required
def finalizar_ordem(id):
    db = current_app.config['db']
    metodo_pagamento_id = request.form['metodo_pagamento_id']
    cursor = db.cursor()

    # Atualiza a ordem
    cursor.execute("""
        UPDATE ordem_servico
        SET status = 'concluida',
            metodo_pagamento_id = %s,
            data_fechamento = NOW()
        WHERE id = %s
    """, (metodo_pagamento_id, id))

    # Busca valor total da ordem pela view
    cursor.execute("SELECT total_geral FROM vw_ordem_servico_resumo WHERE ordem_id = %s", (id,))
    resultado = cursor.fetchone()
    valor_total = resultado[0] if resultado else 0.00

    # Registra movimentação financeira
    cursor.execute("""
        INSERT INTO movimentacao_financeira (tipo, origem, descricao, valor, metodo_pagamento_id)
        VALUES (%s, %s, %s, %s, %s)
    """, (
        'entrada',
        'servico',
        f'Ordem de serviço #{id} concluída',
        valor_total,
        metodo_pagamento_id
    ))

    db.commit()
    cursor.close()
    return redirect('/ordens')


