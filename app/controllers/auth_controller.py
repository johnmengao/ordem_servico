from flask import render_template, request, redirect, current_app, url_for, flash
from flask_login import login_user, logout_user, login_required
from flask_mail import Message
from werkzeug.security import generate_password_hash
from app.models.usuario import Usuario
from app.models.user_session import UserSession
from app import mail
import uuid
from flask import Blueprint

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/')
def index():
    return redirect('/login')

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        senha = request.form['senha']
        db = current_app.config['db']
        user = Usuario.autenticar(db, email, senha)
        if user:
            login_user(UserSession(user['id'], user['nome'], user['tipo']))
            return redirect('/dashboard')
        return render_template('auth/login.html', erro='Credenciais inválidas')
    return render_template('auth/login.html')

@auth_bp.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect('/')

@auth_bp.route('/recuperar_senha', methods=['GET', 'POST'])
def recuperar_senha():
    if request.method == 'POST':
        email = request.form.get('email')
        db = current_app.config['db']
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT id FROM usuario WHERE email = %s", (email,))
        usuario = cursor.fetchone()

        if usuario:
            token = str(uuid.uuid4())
            cursor.execute("INSERT INTO recuperacao_senha (usuario_id, token) VALUES (%s, %s)", (usuario['id'], token))
            db.commit()
            link = url_for('auth.redefinir_senha', token=token, _external=True)
            msg = Message("Recuperação de Senha", sender=current_app.config['MAIL_USERNAME'], recipients=[email], body=f"Olá! Clique no link para redefinir sua senha:\n{link}")
            mail.send(msg)
            return render_template('auth/recuperar_senha.html', mensagem="Um e-mail foi enviado com instruções.")
        else:
            return render_template('auth/recuperar_senha.html', erro="Email não encontrado.")
    return render_template('auth/recuperar_senha.html')

@auth_bp.route('/redefinir_senha/<token>', methods=['GET', 'POST'])
def redefinir_senha(token):
    db = current_app.config['db']
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT usuario_id FROM recuperacao_senha WHERE token = %s AND valido_ate >= NOW()", (token,))
    registro = cursor.fetchone()

    if not registro:
        return "Token inválido ou expirado."

    if request.method == 'POST':
        nova_senha = request.form.get('senha')
        senha_hash = generate_password_hash(nova_senha)
        cursor.execute("UPDATE usuario SET senha = %s WHERE id = %s", (senha_hash, registro['usuario_id']))
        cursor.execute("DELETE FROM recuperacao_senha WHERE token = %s", (token,))
        db.commit()
        flash('Senha redefinida com sucesso!', 'success')
        return render_template('auth/login.html')

    return render_template('auth/redefinir_senha.html')
