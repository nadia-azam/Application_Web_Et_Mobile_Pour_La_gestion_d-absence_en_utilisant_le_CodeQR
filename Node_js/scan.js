const express=require('express');
const router=express.Router();
var db=require('./db.js');


// Créer la table si elle n'existe pas
const createTableQuery = `
CREATE TABLE IF NOT EXISTS scans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  studentId VARCHAR(255) NOT NULL,
  qrCodeId VARCHAR(255) NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
`;

db.query(createTableQuery, (err, result) => {
  if (err) {
    throw err;
  }
  console.log('Table "scans" créée ou déjà existante');
});

// Route pour enregistrer un scan de QR Code
router.post('/api/scan', (req, res) => {
  const { studentId, qrCodeId } = req.body;
  const query = 'INSERT INTO scans (studentId, qrCodeId) VALUES (?, ?)';
  db.query(query, [studentId, qrCodeId], (err, result) => {
    if (err) {
      res.status(500).send('Erreur lors de l\'enregistrement du scan');
      return;
    }
    res.sendStatus(200);
  });
});

// Route pour récupérer tous les scans
router.get('/api/scans', (req, res) => {
  const query = 'SELECT * FROM scans';
  db.query(query, (err, results) => {
    if (err) {
      res.status(500).send('Erreur lors de la récupération des scans');
      return;
    }
    res.json(results);
  });
});