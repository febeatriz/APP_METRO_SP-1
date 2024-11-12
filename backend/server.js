const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const QRCode = require('qrcode');
const app = express();
const PORT = 3001;

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadsPath); // Salva na pasta de uploads definida
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`); // Define o nome do arquivo
    }
});
const upload = multer({ storage: storage });

// Configuração do banco de dados
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '9534',
    database: 'metro_sp', 
});

// Conectar ao banco de dados
db.connect((err) => {
    if (err) {
        console.error('Erro ao conectar ao banco de dados:', err);
        return;
    }
    console.log('Conectado ao banco de dados MySQL');
});

// Middleware para CORS
app.use(cors({
    origin: '*',  // Permite todas as origens
}));

// Middleware para análise do corpo da requisição
app.use(bodyParser.json());

// Rota para upload da foto de perfil
app.post('/upload', upload.single('image'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ success: false, message: 'Nenhuma imagem enviada' });
    }

    const usuarioId = req.body.usuario_id; // ID do usuário passado no campo "usuario_id"
    if (!usuarioId) {
        return res.status(400).json({ success: false, message: 'Usuário não especificado' });
    }

    const imagem = req.file.buffer; // O conteúdo da imagem que foi enviado

    // Atualizando o banco de dados com a imagem
    const query = 'UPDATE usuarios SET foto_perfil = ? WHERE id = ?';
    db.query(query, [imagem, usuarioId], (err, result) => {
        if (err) {
            console.error('Erro ao salvar a imagem no banco de dados:', err);
            return res.status(500).json({ success: false, message: 'Erro ao salvar a imagem' });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Usuário não encontrado' });
        }

        res.json({ success: true, message: 'Imagem salva com sucesso' });
    });
});

// Rota de login
app.post('/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Campos obrigatórios faltando' });
    }

    // Consulta ao banco de dados para verificar se o usuário existe, incluindo o nome do cargo
    const query = `
        SELECT usuarios.id, usuarios.nome, cargos.nome AS cargo
        FROM usuarios
        JOIN cargos ON usuarios.cargo_id = cargos.id
        WHERE usuarios.email = ? AND usuarios.senha = ?`;

    db.query(query, [email, password], (err, results) => {
        if (err) {
            console.error('Erro ao consultar o banco de dados:', err);
            return res.status(500).json({ success: false, message: 'Erro no servidor' });
        }

        if (results.length === 0) {
            return res.status(401).json({ success: false, message: 'Email ou senha incorretos' });
        }

        // Retornar o nome do usuário e cargo
        const usuario = results[0];
        return res.json({ success: true, nome: usuario.nome, cargo: usuario.cargo });
    });
});

// Rota para buscar informações do usuário
app.get('/usuario', (req, res) => {
    const email = req.query.email;

    if (!email) {
        return res.status(400).json({ success: false, message: 'Email é obrigatório' });
    }

    console.log(`Procurando usuário com email: ${email}`);  // Log para depuração

    const query = `
        SELECT usuarios.id, usuarios.nome, usuarios.matricula, cargos.nome AS cargo
        FROM usuarios
        JOIN cargos ON usuarios.cargo_id = cargos.id
        WHERE usuarios.email = ?`;

    db.query(query, [email], (err, results) => {
        if (err) {
            console.error('Erro ao consultar o banco de dados:', err);
            return res.status(500).json({ success: false, message: 'Erro no servidor' });
        }

        if (results.length === 0) {
            console.log('Usuário não encontrado');  // Log para depuração
            return res.status(404).json({ success: false, message: 'Usuário não encontrado' });
        }

        const usuario = results[0];
        console.log('Usuário encontrado:', usuario);  // Log para depuração

        res.json({
            success: true,
            nome: usuario.nome,
            matricula: usuario.matricula,
            cargo: usuario.cargo,
            id: usuario.id,
        });
    });
});

// Rota para buscar tipos de extintores
app.get('/tipos-extintores', (req, res) => {
    const query = 'SELECT id, tipo AS nome FROM Tipos_Extintores';

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao consultar tipos de extintores:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar tipos de extintores' });
        }

        res.json({ success: true, data: results });
    });
});

// Rota para buscar localizações
app.get('/localizacoes', (req, res) => {
    const query = 'SELECT ID_Localizacao AS id, Area AS nome FROM Localizacoes';

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao consultar localizações:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar localizações' });
        }

        res.json({ success: true, data: results });
    });
});


// Função para gerar e salvar o QR code como imagem
const gerarSalvarQRCode = async (data, nomeArquivo) => {
    try {
        // Define o caminho do arquivo onde a imagem será salva
        const caminhoImagem = path.join(__dirname, 'uploads', 'qrcodes', `${nomeArquivo}.png`);

        // Verifica se a pasta existe, caso contrário cria a pasta
        const pastaImagem = path.dirname(caminhoImagem);
        if (!fs.existsSync(pastaImagem)) {
            fs.mkdirSync(pastaImagem, { recursive: true });
        }

        // Gera o QR code e salva a imagem
        await QRCode.toFile(caminhoImagem, data);

        return `http://192.168.0.6:3001/uploads/qrcodes/${nomeArquivo}.png`;
    } catch (err) {
        console.error('Erro ao gerar o QR code:', err);
        throw err;
    }
};

// Rota para registrar o extintor
app.post('/registrar_extintor', async (req, res) => {
    const {
        patrimonio,
        tipo_id,
        capacidade,
        codigo_fabricante,
        data_fabricacao,
        data_validade,
        ultima_recarga,
        proxima_inspecao,
        status,
        id_localizacao,
        linha_id,
        observacoes,
    } = req.body;

    // Gerar o QR code com base no patrimônio
    const qrData = `Patrimonio: ${patrimonio}`;

    try {
        // Gera o QR code e salva como imagem
        const qrCodeCaminho = await gerarSalvarQRCode(qrData, patrimonio);  // Usando o patrimônio como nome do arquivo

        // Supondo que o servidor esteja configurado para servir arquivos estáticos na pasta 'uploads/qrcodes'
        const qrCodeUrl = `http://192.168.0.6:3001/uploads/qrcodes/${patrimonio}.png`;

        // Consulta SQL para inserir os dados do extintor, incluindo o caminho da imagem do QR code
        const query = `
            INSERT INTO Extintores (Patrimonio, Tipo_ID, Capacidade, Codigo_Fabricante, Data_Fabricacao, Data_Validade, Ultima_Recarga, Proxima_Inspecao, Status, ID_Localizacao, Linha_ID, QR_Code, Observacoes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

        db.query(
            query,
            [
                patrimonio,
                tipo_id,
                capacidade,
                codigo_fabricante,
                data_fabricacao,
                data_validade,
                ultima_recarga,
                proxima_inspecao,
                status,
                id_localizacao,
                linha_id,
                qrCodeUrl,  // Armazenando a URL pública do QR code
                observacoes,
            ],
            (err, result) => {
                if (err) {
                    console.error('Erro ao registrar o extintor:', err);
                    return res.status(500).json({ success: false, message: 'Erro ao registrar o extintor' });
                }

                res.json({
                    success: true,
                    message: 'Extintor registrado com sucesso',
                    extintorId: result.insertId,
                    qrCode: qrCodeUrl,  // Retorna a URL pública do QR code gerado
                });
            }
        );
    } catch (err) {
        console.error('Erro ao gerar o QR code:', err);
        res.status(500).json({ success: false, message: 'Erro ao gerar o QR code' });
    }
});


app.get('/linhas', (req, res) => {
    const query = 'SELECT * FROM Linhas';

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao buscar linhas:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar linhas' });
        }
        res.json({ success: true, data: results });
    });
});


// Iniciar o servidor
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
