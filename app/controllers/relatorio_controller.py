from flask import request, current_app, Response
from flask_login import login_required
from flask import Blueprint

relatorio_bp = Blueprint('relatorio', __name__)

@relatorio_bp.route('/relatorio')
@login_required
def relatorio():
    db = current_app.config['db']
    de = request.args.get('de')
    ate = request.args.get('ate')

    filtro = ""
    params = []
    if de and ate:
        filtro = "WHERE data_abertura BETWEEN %s AND %s"
        params = [de, ate]

    cursor = db.cursor(dictionary=True)
    cursor.execute(f"""
        SELECT os.id, os.status, os.data_abertura, os.data_fechamento,
               c.nome AS cliente, u.nome AS tecnico
        FROM ordem_servico os
        JOIN cliente c ON os.cliente_id = c.id
        JOIN usuario u ON os.usuario_id = u.id
        {filtro}
    """, params)
    rows = cursor.fetchall()

    def gerar_csv():
        yield "ID,Status,Data Abertura,Data Fechamento,Cliente,Técnico\n"
        for r in rows:
            yield f"{r['id']},{r['status']},{r['data_abertura']},{r['data_fechamento']},{r['cliente']},{r['tecnico']}\n"

    return Response(gerar_csv(), mimetype='text/csv',
                    headers={"Content-Disposition": "attachment;filename=relatorio.csv"})
