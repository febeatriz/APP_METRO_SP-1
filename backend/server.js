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

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '9534',
    database: 'metro_sp',
});

db.connect((err) => {
    if (err) {
        console.error('Erro ao conectar ao banco de dados:', err);
        return;
    }
    console.log('Conectado ao banco de dados MySQL');
});

// Middleware para CORS
app.use(cors({
    origin: '*', 
}));

app.use(bodyParser.json());

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadsPath);
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`); 
    }
});
const upload = multer({ storage: storage });

app.get('/qr-code/:patrimonio', (req, res) => {
    const patrimonio = req.params.patrimonio;
    const qrCodePath = path.join(__dirname, 'uploads', 'qrcodes', `${patrimonio}.png`);
    if (fs.existsSync(qrCodePath)) {
        res.sendFile(qrCodePath);
    } else {
        res.status(404).json({ success: false, message: 'QR Code não encontrado' });
    }
});

const uploadsPath = path.join(__dirname, 'uploads', 'qrcodes');
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/uploads/qrcodes', express.static(uploadsPath));

const gerarSalvarQRCode = async (data, nomeArquivo) => {
    try {
        const caminhoImagem = path.join(uploadsPath, `${nomeArquivo}.png`);

        if (!fs.existsSync(path.dirname(caminhoImagem))) {
            fs.mkdirSync(path.dirname(caminhoImagem), { recursive: true });
        }

        await QRCode.toFile(caminhoImagem, data);
        return `http://localhost:3001/uploads/qrcodes/${nomeArquivo}.png`;
    } catch (err) {
        console.error('Erro ao gerar o QR code:', err);
        throw err;
    }
};

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
        linha_id,
        id_localizacao,
        observacoes
    } = req.body;

    const extintor = {
        patrimonio,
        tipo_id,
        capacidade,
        codigo_fabricante,
        data_fabricacao,
        data_validade,
        ultima_recarga,
        proxima_inspecao,
        status,
        linha_id,
        id_localizacao,
        observacoes,
    };

    const data = JSON.stringify(extintor);

    try {
        // Gera o QR code e salva
        const qrCodeUrl = await gerarSalvarQRCode(data, patrimonio);

        // Query para inserir no banco de dados
        const query = `
            INSERT INTO Extintores 
            (Patrimonio, Tipo_ID, Capacidade, Codigo_Fabricante, Data_Fabricacao, Data_Validade, Ultima_Recarga, Proxima_Inspecao, status_id, Linha_ID, ID_Localizacao, QR_Code, Observacoes) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

        db.query(query, [
            patrimonio, tipo_id, capacidade, codigo_fabricante, data_fabricacao, data_validade, ultima_recarga, proxima_inspecao, status, linha_id, id_localizacao, qrCodeUrl, observacoes
        ], (err, result) => {

            if (err) {
                console.error('Erro ao inserir no banco de dados:', err);
                return res.status(500).json({ success: false, message: 'Erro ao registrar o extintor no banco de dados.' });
            }
            res.json({ success: true, qrCodeUrl });
        });

    } catch (err) {
        res.status(500).json({ success: false, error: 'Erro ao gerar o QR code.' });
    }
});

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

app.post('/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Campos obrigatórios faltando' });
    }

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

app.get('/status', (req, res) => {
    const query = 'SELECT id, nome FROM Status_Extintor';

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao consultar status:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar status' });
        }

        res.json({ success: true, data: results });
    });
});

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

app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
