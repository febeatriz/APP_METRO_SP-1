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

const atualizarStatusExtintor = async (idExtintor) => {
    try {
        // Recupera o extintor com base no ID
        const query = 'SELECT * FROM Extintores WHERE Patrimonio = ?';
        db.query(query, [idExtintor], (err, results) => {
            if (err) {
                console.error('Erro ao buscar extintor:', err);
                return;
            }

            const extintor = results[0];
            if (!extintor) {
                console.log('Extintor não encontrado');
                return;
            }

            let novoStatus;
            const dataAtual = new Date();

            // Verifica se o extintor está vencido
            if (new Date(extintor.Data_Validade) < dataAtual) {
                novoStatus = 'Vencido';
            }
            // Verifica se o extintor foi violado
            else if (extintor.Status === 'violado') {
                novoStatus = 'Violado';
            }
            // Caso contrário, considera o status como Ativo
            else {
                novoStatus = 'Ativo';
            }

            // Recupera o id do status a partir do nome
            const queryStatus = 'SELECT id FROM Status_Extintor WHERE nome = ?';
            db.query(queryStatus, [novoStatus], (err, statusResult) => {
                if (err) {
                    console.error('Erro ao buscar status:', err);
                    return;
                }

                if (statusResult.length === 0) {
                    console.log('Status não encontrado');
                    return;
                }

                const statusId = statusResult[0].id;

                // Atualiza o status do extintor no banco
                const updateQuery = 'UPDATE Extintores SET status_id = ? WHERE Patrimonio = ?';
                db.query(updateQuery, [statusId, idExtintor], (err, updateResult) => {
                    if (err) {
                        console.error('Erro ao atualizar o status do extintor:', err);
                        return;
                    }
                    console.log('Status do extintor atualizado para:', novoStatus);
                });
            });
        });
    } catch (err) {
        console.error('Erro ao atualizar o status:', err);
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

    try {
        // Gera o QR code e salva
        const qrCodeUrl = await gerarSalvarQRCode(JSON.stringify(extintor), patrimonio);

        // Insere o extintor no banco de dados
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

            // Após inserir, atualiza o status do extintor
            atualizarStatusExtintor(patrimonio);

            res.json({ success: true, qrCodeUrl });
        });

    } catch (err) {
        res.status(500).json({ success: false, error: 'Erro ao gerar o QR code.' });
    }
});

app.get('/extintores', (req, res) => {
    const query = 'SELECT Patrimonio, Tipo_ID FROM Extintores';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao buscar extintores: ' + err.stack);
            return res.status(500).json({ success: false, message: 'Erro ao buscar extintores' });
        }

        console.log('Resultados encontrados:', results); // Adicione esse log para verificar o retorno

        res.status(200).json({ success: true, extintores: results });
    });
});

// app.post('/salvar_manutencao', (req, res) => {
//     const {
//         patrimonio,          // Usando Patrimonio
//         descricao,
//         responsavel,
//         observacoes,
//         data_manutencao,
//         ultima_recarga,
//         proxima_inspecao,
//         data_vencimento
//     } = req.body;

//     // Verificação para garantir que todos os campos obrigatórios estão presentes
//     if (
//         !patrimonio ||
//         !descricao ||
//         !responsavel ||
//         !data_manutencao ||
//         !ultima_recarga ||
//         !proxima_inspecao ||
//         !data_vencimento
//     ) {
//         return res.status(400).json({ success: false, message: 'Todos os campos são obrigatórios' });
//     }

//     // 1. Inserir a manutenção no histórico de manutenção
//     const queryManutencao = `
//         INSERT INTO Historico_Manutencao (ID_Extintor, Data_Manutencao, Descricao, Responsavel_Manutencao, Observacoes)
//         VALUES (?, ?, ?, ?, ?)
//     `;

//     // Executar a consulta para salvar a manutenção
//     db.query(queryManutencao, [
//         patrimonio,                // Referência ao campo Patrimonio como ID_Extintor
//         data_manutencao,
//         descricao,
//         responsavel,
//         observacoes || '',  // Observações podem ser nulas
//     ], (err, result) => {
//         if (err) {
//             console.error('Erro ao salvar manutenção: ' + err.stack);
//             return res.status(500).json({ success: false, message: 'Erro ao salvar manutenção' });
//         }

//         // 2. Agora, atualizamos os dados na tabela Extintores com as novas informações
//         const queryExtintores = `
//             UPDATE Extintores
//             SET Ultima_Recarga = ?, Proxima_Inspecao = ?, Data_Validade = ?
//             WHERE Patrimonio = ?
//         `;

//         // Atualizar as informações do extintor
//         db.query(queryExtintores, [
//             ultima_recarga,
//             proxima_inspecao,
//             data_vencimento,
//             patrimonio    // Usando Patrimonio aqui para atualizar o extintor correto
//         ], (err2, result2) => {
//             if (err2) {
//                 print('Resposta do servidor: $responseData'); // Log da resposta completa
//                 console.error('Erro ao atualizar extintores: ' + err2.stack);
//                 return res.status(500).json({ success: false, message: 'Erro ao atualizar extintores' });
//             }

//             // Se a manutenção e a atualização foram bem-sucedidas
//             res.status(200).json({ success: true, message: 'Manutenção salva e dados atualizados com sucesso!' });
//         });
//     });
// });
app.post('/salvar_manutencao', (req, res) => {
    const {
        patrimonio,          // Usando Patrimonio
        descricao,
        responsavel,
        observacoes,
        data_manutencao,
        ultima_recarga,
        proxima_inspecao,
        data_vencimento,
        revisar_status // Novo campo para revisão de status
    } = req.body;

    // Verificação para garantir que todos os campos obrigatórios estão presentes
    if (
        !patrimonio ||
        !descricao ||
        !responsavel ||
        !data_manutencao ||
        !ultima_recarga ||
        !proxima_inspecao ||
        !data_vencimento
    ) {
        return res.status(400).json({ success: false, message: 'Todos os campos são obrigatórios' });
    }

    // 1. Inserir a manutenção no histórico de manutenção
    const queryManutencao = `
        INSERT INTO Historico_Manutencao (ID_Extintor, Data_Manutencao, Descricao, Responsavel_Manutencao, Observacoes)
        VALUES (?, ?, ?, ?, ?)
    `;

    // Executar a consulta para salvar a manutenção
    db.query(queryManutencao, [
        patrimonio,                // Referência ao campo Patrimonio como ID_Extintor
        data_manutencao,
        descricao,
        responsavel,
        observacoes || '',  // Observações podem ser nulas
    ], (err, result) => {
        if (err) {
            console.error('Erro ao salvar manutenção: ' + err.stack);
            return res.status(500).json({ success: false, message: 'Erro ao salvar manutenção' });
        }

        // 2. Agora, atualizamos os dados na tabela Extintores com as novas informações
        const queryExtintores = `
            UPDATE Extintores
            SET Ultima_Recarga = ?, Proxima_Inspecao = ?, Data_Validade = ?
            WHERE Patrimonio = ?
        `;

        // Atualizar as informações do extintor
        db.query(queryExtintores, [
            ultima_recarga,
            proxima_inspecao,
            data_vencimento,
            patrimonio    // Usando Patrimonio aqui para atualizar o extintor correto
        ], (err2, result2) => {
            if (err2) {
                console.error('Erro ao atualizar extintores: ' + err2.stack);
                return res.status(500).json({ success: false, message: 'Erro ao atualizar extintores' });
            }

            // 3. Atualizar o status do extintor, se necessário
            if (revisar_status) {
                // Certifique-se de que o status "Ativo" existe na tabela Status_Extintor
                const queryStatus = `
                    SELECT id FROM Status_Extintor WHERE nome = 'Ativo'
                `;

                // Obter o ID do status 'Ativo'
                db.query(queryStatus, [], (err3, result3) => {
                    if (err3) {
                        console.error('Erro ao buscar status: ' + err3.stack);
                        return res.status(500).json({ success: false, message: 'Erro ao buscar status' });
                    }

                    if (result3.length > 0) {
                        const status_id = result3[0].id;

                        // Atualizar o status do extintor com o ID correto
                        const queryUpdateStatus = `
                            UPDATE Extintores
                            SET status_id = ?
                            WHERE Patrimonio = ?
                        `;

                        // Atualiza o status do extintor para 'Ativo'
                        db.query(queryUpdateStatus, [status_id, patrimonio], (err4, result4) => {
                            if (err4) {
                                console.error('Erro ao atualizar status do extintor: ' + err4.stack);
                                return res.status(500).json({ success: false, message: 'Erro ao atualizar status' });
                            }

                            // Se a manutenção, atualização do extintor e status forem bem-sucedidos
                            res.status(200).json({ success: true, message: 'Manutenção salva, dados atualizados e status alterado com sucesso!' });
                        });
                    } else {
                        // Se o status 'Ativo' não foi encontrado
                        console.error('Status "Ativo" não encontrado na tabela Status_Extintor');
                        return res.status(500).json({ success: false, message: 'Status "Ativo" não encontrado' });
                    }
                });
            } else {
                // Se não for necessário revisar o status, apenas finalize a operação
                res.status(200).json({ success: true, message: 'Manutenção salva e dados atualizados com sucesso!' });
            }
        });
    });
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
