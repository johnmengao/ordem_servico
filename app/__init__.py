from flask import Flask
from flask_login import LoginManager
from flask_mail import Mail
import mysql.connector
from config import DB_CONFIG, MAIL_CONFIG

# 1. Cria o app primeiro
app = Flask(__name__)
app.secret_key = 'sua_chave_secreta'

# 2. Configura o banco
db = mysql.connector.connect(**DB_CONFIG)
app.config['db'] = db

# 3. Configura o e-mail
for key, value in MAIL_CONFIG.items():
    app.config[key] = value
mail = Mail(app)

# 4. Configura login
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# 5. Carregador de usuário
from app.models.user_session import UserSession
from app.models.usuario import Usuario

#from app.controllers.ordem_controller import dashboard_bp

@login_manager.user_loader
def load_user(user_id):
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM usuario WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    if user:
        return UserSession(user['id'], user['nome'], user['tipo'])
    return None

# 6. Registra blueprints
from app.controllers.usuario_controller import usuario_bp
from app.controllers.auth_controller import auth_bp
from app.controllers.dashboard_controller import dashboard_bp
from app.controllers.relatorio_controller import relatorio_bp
from app.controllers.cliente_controller import cliente_bp
from app.controllers.peca_controller import peca_bp
from app.controllers.servico_controller import servico_bp
from app.controllers.ordem_controller import ordem_bp
from app.controllers.financeiro_controller import financeiro_bp

app.register_blueprint(usuario_bp)
app.register_blueprint(auth_bp)
app.register_blueprint(dashboard_bp)
app.register_blueprint(relatorio_bp)
app.register_blueprint(cliente_bp)
app.register_blueprint(peca_bp)
app.register_blueprint(servico_bp)
app.register_blueprint(ordem_bp)
app.register_blueprint(financeiro_bp)
#app.register_blueprint(dashboard_bp)

