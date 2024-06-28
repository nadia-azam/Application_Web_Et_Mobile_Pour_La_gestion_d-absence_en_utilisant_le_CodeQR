const express=require('express');
const router=express.Router();
var db=require('./db.js');




// Route pour recevoir les données scannées KHDAM M3A LI KHDAM F BLOCNOTES
router.post('/scanner', (req, res) => {
  const { scannedCode, userId } = req.body;

  // Décomposer le code QR scanné en ses différentes parties
  const [idModule, idNiveau, salle, date] = scannedCode.split('|');

  // Récupérer l'id du codeqr correspondant au code scanné
  const query = 'SELECT id FROM codeqr WHERE id_module = ? AND id_niveau = ? AND salle = ? AND date = ?';
  db.query(query, [idModule, idNiveau, salle, date], (err, results) => {
    if (err) {
      console.error('Erreur lors de la requête SELECT:', err);
      return res.status(500).send('Erreur du serveur');
    }

    if (results.length > 0) {
      const codeqrId = results[0].id;

      // Vérifier si l'entrée existe déjà dans la table scanner
      const checkQuery = 'SELECT * FROM scanner WHERE id_student = ? AND id_codeqr = ?';
      db.query(checkQuery, [userId, codeqrId], (err, checkResults) => {
        if (err) {
          console.error('Erreur lors de la requête de vérification:', err);
          return res.status(500).send('Erreur du serveur');
        }

        if (checkResults.length > 0) {
          console.log('L\'entrée existe déjà.');
          return res.status(409).send('Duplication détectée'); // 409 Conflict
        } else {
          // Insérer les données dans la table scanner
          const insertQuery = 'INSERT INTO scanner (id_student, id_codeqr, statut, date) VALUES (?, ?, ?, NOW())';
          db.query(insertQuery, [userId, codeqrId, 'present(e)'], (err, insertResults) => {
            if (err) {
              console.error('Erreur lors de l\'insertion:', err);
              return res.status(500).send('Erreur du serveur');
            }

            res.sendStatus(200);
          });
        }
      });
    } else {
      res.sendStatus(404); // Code QR non trouvé dans la base de données
    }
  });
});



module.exports = router;