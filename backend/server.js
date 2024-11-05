const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors'); // Importar o cors

const app = express();
const PORT = 3001;

// Middleware para parsear JSON
app.use(bodyParser.json());

// Middleware CORS para permitir requisições de outros domínios
app.use(cors());

// Configuração do banco de dados
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '9534',
    database: 'metro_ext',
});

// Conectar ao banco de dados
db.connect((err) => {
    if (err) {
        console.error('Erro ao conectar ao banco de dados:', err);
        return;
    }
    console.log('Conectado ao banco de dados MySQL');
});

// Rota de login
app.post('/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Campos obrigatórios faltando' });
    }

    // Consulta ao banco de dados para verificar se o usuário existe
    const query = 'SELECT * FROM usuarios WHERE email = ? AND senha = ?';
    db.query(query, [email, password], (err, results) => {
        if (err) {
            console.error('Erro ao consultar o banco de dados:', err);
            return res.status(500).json({ success: false, message: 'Erro ao consultar o banco de dados' });
        }

        if (results.length > 0) {
            return res.status(200).json({ success: true, message: 'Login bem-sucedido' });
        } else {
            return res.status(401).json({ success: false, message: 'Credenciais inválidas' });
        }
    });
});

// Iniciar o servidor
app.listen(PORT, () => {
    console.log(`Servidor rodando em http://localhost:${PORT}`);
});
