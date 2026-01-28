from flask_login import UserMixin

class UserSession(UserMixin):
    def __init__(self, id, nome, tipo):
        self.id = id
        self.nome = nome
        self.tipo = tipo
