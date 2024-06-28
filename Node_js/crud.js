const express=require('express');
const router=express.Router();
const moment = require('moment');
var db=require('./db.js');

router.route('/login').post((req,res)=>{

    var eamil=req.body.email;
    var password=req.body.password;

    var sql="SELECT * FROM user WHERE email=? AND password=?";

    if(eamil != "" && password !=""){
        db.query(sql,[eamil,password],function(err,data,fields){
            if(err){
                res.send(JSON.stringify({success:false,message:err}));

            }else{
                if(data.length > 0)
                {
                    res.send(JSON.stringify({success:true,user:data}));
                }else{
                    res.send(JSON.stringify({success:false,message:'Empty Data'}));
                }
            }
        });
    }else{
        res.send(JSON.stringify({success:false,message:'Email and password required!'}));
    }

});

router.route('/niveau').get((req, res) => {

    const sql = "SELECT * FROM niveau";

    db.query(sql, (err, result) => {
      if (err) {
        console.error("Error getting user cards:", err);
        return res.status(500).json({ error: 'Error getting user cards' });
      }

      res.json(result);
    });
});

router.post('/addNiveau', (req, res) => {
    var NomNiveau = req.body.NomNiveau;
    var listEtd = req.body.listEtd;


    // Add your logic to insert a new card into the 'cards' table with the user_id as a foreign key
    const sql = 'INSERT INTO niveau (nom,listestudent) VALUES (?,?)';
    db.query(sql, [NomNiveau, listEtd], (err, result) => {
      if (err) {
        console.error(err);
        res.status(500).json({ message: 'Error adding card' });
        return;
      }

      res.status(201).json({ message: 'niveau added successfully', cardId: result.insertId });
    });
  });

router.delete('/niveau/:niveauId', (req, res) => {

    const niveauId = req.params.niveauId;

    // Delete the card with the given cardId for the user with the given userId
    const sql = 'DELETE FROM niveau WHERE id = ?';

    db.query(sql, [niveauId], (err, result) => {
      if (err) {
        console.error("Error deleting niveau:", err);
        return res.status(500).json({ error: 'Error deleting niveau' });
      }

      if (result.affectedRows > 0) {
        res.json({ success: true, message: 'niveau deleted successfully' });
      } else {
        res.status(404).json({ error: 'niveau not found' });
      }
    });
  });

router.put('/niveau/:niveauId/update',async (req, res) => {
    const niveauId = req.params.niveauId;
    var newNom = req.body.newNom;
    var newListStd = req.body.newListStd;

    // Check if NomNiveau and listEtd are not empty
    /*if (!newNom || !newListStd) {
        return res.status(400).json({ error: 'newNom and newListStd are required' });
    }*/

    const sql = 'UPDATE niveau SET nom = ?, listestudent = ? WHERE id = ?';

    db.query(sql, [newNom, newListStd, niveauId], (err,data,fields) => {
      if (err) {
        console.error("Error updating card name:", err);
        return res.status(500).json({ error: 'Error updating card name' });
      }

      res.status(201).json({ success: true, message: 'Card name updated successfully' });
    });
  });


router.get('/niveaux', async (req, res) => {
    const sql = 'SELECT nom FROM niveau'; // Sélectionnez tous les niveaux de la table 'niveau'

    db.query(sql, (err, data, fields) => {
        if (err) {
            console.error("Error fetching niveaux:", err);
            return res.status(500).json({ error: 'Error fetching niveaux' });
        }

        res.status(200).json({ niveaux: data }); // Renvoie les niveaux récupérés au format JSON
    });
});


// recuperation des modules :

router.get('/modules/:niveauId', (req, res) => {
    const niveauId = req.params.niveauId;

    // Query the database to retrieve modules for the given niveauId
    const sql = 'SELECT * FROM module WHERE id_niveau = ?';

    db.query(sql, [niveauId], (err, result) => {
        if (err) {
            console.error("Error fetching modules:", err);
            return res.status(500).json({ error: 'Error fetching modules' });
        }

        // Check if modules are found
        if (result.length > 0) {
            res.json(result); // Return the modules found
        } else {
            res.status(404).json({ error: 'Modules not found' });
        }
    });
});



// ajout des modules :
router.post('/ajoutModule', (req, res) => {
    var nomModule = req.body.nomModule;
    var emailProf = req.body.emailProf;
    var salle = req.body.salle ;
   var description = req.body.description ;
    var niveauId = req.body.niveauId;

      // Add your logic to insert a new card into the 'cards' table with the user_id as a foreign key
    const sql = 'INSERT INTO module (nom  , salle , description , email_prof , id_niveau ) VALUES (?,? , ? , ? , ? )';
    db.query(sql, [nomModule,salle,description , emailProf , niveauId ], (err, result) => {
      if (err) {
        console.error(err);
        res.status(500).json({ message: 'Error adding module' });
        return;
      }

      res.status(201).json({ message: 'module added successfully', cardId: result.insertId });
    });
  });



// Définissez la route pour récupérer les adresses e-mail des professeurs et les afficher en drop dow lors de l ajout de module
router.get('/getEmailsProfessors', async (req, res) => {
  try {
    // Récupérez tous les professeurs depuis la base de données
    const professors = await db.query('SELECT email FROM prof'); // Assurez-vous d'attendre la réponse de la requête

    // Vérifiez si des professeurs ont été trouvés
    if (!professors || professors.length === 0) {
      return res.status(404).json({ error: 'Professors emails not found' });
    }

    // Extrayez les adresses e-mail des professeurs
    const professorsEmails = professors.map(professor => professor.email);

    // Renvoyez les adresses e-mail sous forme de réponse JSON
    res.status(200).json(professorsEmails);
  } catch (error) {
    console.error('Error fetching professors emails:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});



 // Suppression d'un module
 router.delete('/deleteModule/:niveauId/:moduleName', (req, res) => {
        const niveauId = req.params.niveauId;
         const moduleName = req.params.moduleName;
       const query = `DELETE FROM module WHERE id_niveau = ? AND nom = ?`;
       db.query(query, [niveauId, moduleName], (err, result) => {
         if (err) {
           console.error('Erreur lors de la suppression du module :', err);
           res.status(500).send('Erreur lors de la suppression du module.');
           return;
         }
         console.log('Module supprimé avec succès');
         res.status(200).send('Module supprimé avec succès.');
       });
 });

 // Route pour récupérer le nom complet du professeur à partir de son email et l afficher dans detail module
 router.get('/professor/:emailProf', (req, res) => {
    const email = req.params.emailProf;
    const query = `SELECT CONCAT(nom, ' ', prenom) AS fullName FROM prof WHERE email = ?`;
    db.query(query, [email], (error, results) => {
      if (error) {
        res.status(500).json({ error: error.message });
      } else if (results.length > 0) {
        res.json({ fullName: results[0].fullName });
      } else {
        res.status(404).json({ error: 'Professor not found' });
      }
    });
  });


 router.put('/updateModule/:moduleName', (req, res) => {
  const moduleName = req.params.moduleName;
  const { newSalle, newEmailProf, newDescription } = req.body;

  const query = `
    UPDATE module
    SET salle = ?, email_prof = ?, description = ?
    WHERE nom = ?
  `;

  db.query(query, [newSalle, newEmailProf, newDescription, moduleName], (error, results) => {
    if (error) {
      res.status(500).json({ error: error.message });
    } else {
      // Vérifier si la mise à jour a affecté des lignes dans la base de données
      if (results.affectedRows > 0) {
        res.status(200).json({ message: 'Module updated successfully' });
      } else {
        res.status(404).json({ error: 'Module not found' });
      }
    }
  });
});



// partie de profff

router.route('/cards/:userEmail').get((req, res) => {
  const userEmail = req.params.userEmail;

  const sql = "SELECT * FROM module WHERE email_prof = ?";

  db.query(sql, [userEmail], (err, result) => {
    if (err) {
      console.error("Error getting user cards:", err);
      return res.status(500).json({ error: 'Error getting user cards' });
    }

    res.json(result);
  });
});







//partie:prof


 // Ajout d'un professeur
 router.post('/addProfessor', (req, res) => {
     const { nom, prenom, email, password } = req.body;
     const role = 'prof';

     const userSql = 'INSERT INTO user (nom, prenom, email, password, role) VALUES (?, ?, ?, ?, ?)';
     db.query(userSql, [nom, prenom, email, password, role], (err, userResult) => {
         if (err) {
             console.error(err);
             res.status(500).send('Erreur lors de l\'ajout du professeur');
         } else {
             const userId = userResult.insertId;
             const profSql = 'INSERT INTO prof (id, nom, prenom, email, password) VALUES (?, ?, ?, ?, ?)';
             db.query(profSql, [userId, nom, prenom, email, password], (err, profResult) => {
                 if (err) {
                     console.error(err);
                     res.status(500).send('Erreur lors de l\'ajout du professeur');
                 } else {
                     res.status(200).send('Professeur ajouté avec succès');
                 }
             });
         }
     });
 });


 // Récupération de tous les professeurs
 router.get('/professors', (req, res) => {
     const sql = 'SELECT * FROM prof';
     db.query(sql, (err, result) => {
         if (err) {
             console.error(err);
             res.status(500).send('Erreur lors de la récupération des professeurs');
         } else {
             res.status(200).json(result);
         }
     });
 });



 // Récupération d'un professeur par son ID
 router.get('/professor/:id', (req, res) => {
   const id = req.params.id;
   const sql = 'SELECT * FROM prof WHERE id = ?';
   db.query(sql, [id], (err, result) => {
       if (err) {
           console.error(err);
           res.status(500).send('Erreur lors de la récupération du professeur');
       } else {
           res.status(200).json(result[0]);
       }
   });
 });


 // Mise à jour d'un professeur
 router.put('/updateProfessor/:id', (req, res) => {
     const id = req.params.id;
     const { nom, prenom, email } = req.body;

     // Récupération de l'ancien mot de passe
     const getPasswordSql = 'SELECT password FROM user WHERE id = ?';
     db.query(getPasswordSql, [id], (err, getPasswordResult) => {
         if (err) {
             console.error(err);
             res.status(500).send('Erreur lors de la récupération du mot de passe');
             return;
         }

         // Ancien mot de passe
         const oldPassword = getPasswordResult[0].password;

         // Mise à jour du professeur
         const updateProfSql = 'UPDATE prof SET nom = ?, prenom = ?, email = ? WHERE id = ?';
         db.query(updateProfSql, [nom, prenom, email, id], (err, result) => {
             if (err) {
                 console.error(err);
                 res.status(500).send('Erreur lors de la mise à jour du professeur');
             } else {
                 // Mise à jour de l'utilisateur avec l'ancien mot de passe
                 const updateUserSql = 'UPDATE user SET nom = ?, prenom = ?, email = ?, password = ? WHERE id = ?';
                 db.query(updateUserSql, [nom, prenom, email, oldPassword, id], (err, userResult) => {
                     if (err) {
                         console.error(err);
                         res.status(500).send('Erreur lors de la mise à jour de l\'utilisateur');
                     } else {
                         res.status(200).send('Professeur mis à jour avec succès');
                     }
                 });
             }
         });
     });
 });


 // Suppression d'un professeur
 router.delete('/deleteProfessor/:id', (req, res) => {
     const id = req.params.id;
     const sql = 'DELETE FROM prof WHERE id = ?';
     db.query(sql, [id], (err, result) => {
         if (err) {
             console.error(err);
             res.status(500).send('Erreur lors de la suppression du professeur');
         } else {
             const userSql = 'DELETE FROM user WHERE id = ?';
             db.query(userSql, [id], (err, userResult) => {
                 if (err) {
                     console.error(err);
                     res.status(500).send('Erreur lors de la suppression de l\'utilisateur');
                 } else {
                     res.status(200).send('Professeur supprimé avec succès');
                 }
             });
         }
     });
 });




 // recuperer les modules pour les afficher dans student
router.get('/level/:id', (req, res) => {
  const studentId = req.params.id;
  const query = `SELECT niveau FROM student WHERE id = ${studentId}`;

  db.query(query, (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération du niveau :', err);
      res.status(500).json({ error: 'Erreur lors de la récupération du niveau' });
      return;
    }
    if (results.length === 0) {
      res.status(404).json({ error: 'Étudiant non trouvé' });
      return;
    }

    const niveauEtudiant = results[0].niveau;

    const moduleQuery = `
      SELECT module.*, prof.nom AS nom_prof, prof.prenom AS prenom_prof
      FROM module
      JOIN prof ON module.email_prof = prof.email
      WHERE module.id_niveau IN (SELECT id FROM niveau WHERE nom = ?)
    `;
    db.query(moduleQuery, [niveauEtudiant], (moduleErr, moduleResults) => {
      if (moduleErr) {
        console.error('Erreur lors de la récupération des modules :', moduleErr);
        res.status(500).json({ error: 'Erreur lors de la récupération des modules' });
        return;
      }

      const data = {
        niveau: niveauEtudiant,
        modules: moduleResults
      };

      res.json(data);
    });
  });
});



// fetch modules by names
router.get('/modules', (req, res) => {
  const moduleName = req.query.name;
  console.log(moduleName);
  const query = `SELECT * FROM module WHERE nom = ?`;

  db.query(query, moduleName, (error, results, fields) => {
    if (error) {
      console.error(error);
      res.status(500).send('Erreur lors de la récupération des modules');
      return;
    }

    res.json(results);
  });
});

// Endpoint pour récupérer les niveaux par liste d'identifiants de modules
router.get('/niveaux', (req, res) => {
  const moduleName = req.query.name;

  // Vérifiez si le paramètre est passé correctement
  if (!moduleName) {
    return res.status(400).send('Le nom du module est requis');
  }

  const getNiveauxQuery = `
    SELECT n.nom
        FROM niveau n
        WHERE n.id IN (
          SELECT m.id_niveau
          FROM module m
          WHERE m.nom = $moduleName
        )
  `;

  db.query(getNiveauxQuery, (error, niveauResults) => {
    if (error) {
      console.error('Erreur de requête:', error);
      return res.status(500).send('Erreur lors de la récupération des noms des niveaux');
    }

    if (niveauResults.length === 0) {
      return res.status(404).send('Aucun niveau trouvé pour le module spécifié');
    }

    // Extraire les noms des niveaux des résultats et formater la réponse
    const niveauNoms = niveauResults.map(row => row.nom);

    console.log('Niveaux trouvés:', niveauNoms);
    res.json({ niveaux: niveauNoms });
  });
});



// enregistrer dans la table codeqr les informations de code
// Route pour enregistrer les données du QR code



// Endpoint to get niveau ID by name
router.get('/niveauId/:nom', (req, res) => {
  const nomNiveau = req.params.nom;
  const sql = 'SELECT id FROM niveau WHERE nom = ?';

  db.query(sql, [nomNiveau], (err, data, fields) => {
    if (err) {
      console.error("Erreur lors de la récupération de l'ID du niveau :", err);
      return res.status(500).json({ error: 'Erreur lors de la récupération de l\'ID du niveau' });
    }

    if (data.length > 0) {
      res.status(200).json({ id: data[0].id });
    } else {
      res.status(404).json({ error: 'Niveau non trouvé' });
    }
  });
});

// Endpoint to get professor ID by email
router.get('/professeurByEmail/:email', (req, res) => {
  const emailProf = req.params.email;
  const sql = 'SELECT id FROM prof WHERE email = ?';

  db.query(sql, [emailProf], (err, data, fields) => {
    if (err) {
      console.error("Erreur lors de la récupération de l'ID du professeur :", err);
      return res.status(500).json({ error: 'Erreur lors de la récupération de l\'ID du professeur' });
    }

    if (data.length > 0) {
      res.status(200).json({ id: data[0].id });
    } else {
      res.status(404).json({ error: 'Professeur non trouvé' });
    }
  });
});

// Endpoint to get module ID by name
router.get('/moduleId/:nom', (req, res) => {
  const nomModule = req.params.nom;
  const sql = 'SELECT id FROM module WHERE nom = ?';

  db.query(sql, [nomModule], (err, data, fields) => {
    if (err) {
      console.error("Erreur lors de la récupération de l'ID du module :", err);
      return res.status(500).json({ error: 'Erreur lors de la récupération de l\'ID du module' });
    }

    if (data.length > 0) {
      res.status(200).json({ id: data[0].id });
    } else {
      res.status(404).json({ error: 'Module non trouvé' });
    }
  });
});





// Route POST pour enregistrer les données du code QR







router.post('/saveCodeQr', async (req, res) => {
  try {
    // Extraire les données du corps de la requête
    moduleId = req.body.moduleId;
        niveauId = req.body.niveauId;
        salle = req.body.salle;
        datetime = req.body.datetime;
        profId = req.body.profId;

    // Analyser la date avec Moment.js
    const parsedDate = moment(datetime, 'YYYY/MM/DD HH:mm');

    // Vérifier si la date est valide
    if (!parsedDate.isValid()) {
      console.error('Invalid date format:', datetime);
      res.status(400).send('Invalid date format');
      return;
    }

    // Extraire les composantes de la date
    const year = parsedDate.year();
    const month = parsedDate.month() + 1; // Moment.js indexe les mois à partir de 0
    const day = parsedDate.date();
    const hour = parsedDate.hour();
    const minute = parsedDate.minute();

    // Construire la date au format requis pour la base de données
    const formattedDate = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')} ${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}:00`;

    // Requête SQL pour insérer les données dans la table 'codeqr'
    const sql = `INSERT INTO codeqr (id_prof, id_module, date, id_niveau, salle)
                 VALUES (?, ?, ?, ?, ?)`;

    // Exécution de la requête SQL avec la date formatée
    db.query(sql, [profId, moduleId, formattedDate, niveauId, salle], (err, result) => {
      if (err) {
        console.error('Error inserting QRCode data:', err);
        res.status(500).send('Failed to save QRCode data');
        return;
      }
      console.log('QRCode data saved successfully');
      res.status(200).send('QR Code data saved successfully');
    });
  } catch (error) {
    console.error('Error saving QRCode data:', error);
    res.status(500).send('Internal server error');
  }
});





// Endpoint to save scan data
router.post('/saveScan', (req, res) => {
  const { studentId, qrCodeId } = req.body;
  const query = 'INSERT INTO scanner (studentId, qrCodeId) VALUES (?, ?)';
  connection.query(query, [studentId, qrCodeId], (error, results, fields) => {
    if (error) {
      console.error('Error saving scan data:', error);
      res.status(500).json({ success: false, message: 'Failed to save scan data' });
      return;
    }
    res.status(200).json({ success: true, message: 'Scan data saved successfully' });
  });
});



// rapport de jour

  // Fonction pour récupérer les données des étudiants
router.get('/stud', async (req, res) => {
  const { niveau, module, date } = req.query;

  const query = `
    SELECT e.nom AS Lname, e.prenom AS Fname,
           COALESCE(
             (SELECT 'present(e)' FROM scanner s
              JOIN codeqr c ON s.id_codeqr = c.id
              WHERE s.id_student = e.id
              AND s.date BETWEEN ? AND DATE_ADD(?, INTERVAL 5 MINUTE)
              AND c.id_niveau = n.id AND c.id_module = m.id),
             'absent(e)'
           ) AS status
    FROM student e
    CROSS JOIN (SELECT id, nom FROM niveau WHERE nom = ?) n
    CROSS JOIN (SELECT id FROM module WHERE nom = ?) m
    WHERE e.niveau = n.nom
  `;

  db.query(query, [date, date, niveau, module], (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des données des étudiants:', err);
      res.status(500).json({ message: 'Erreur serveur' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.status(404).json({ message: 'Aucun résultat trouvé' });
      }
    }
  });
});


//niveau de mod
router.get('/niveauxp/:profEmail', (req, res) => {
         const profEmail = req.params.profEmail;
         console.log('Requête reçue pour profEmail:', profEmail);

         const query = `
           SELECT DISTINCT n.nom
           FROM niveau n
           INNER JOIN module m ON n.id = m.id_niveau
           WHERE m.email_prof = ?
         `;

         db.query(query, [profEmail], (err, results) => {
           if (err) {
             console.error('Erreur lors de la récupération des niveaux du professeur : ', err);
             res.status(500).json({ message: 'Erreur lors de la récupération des niveaux du professeur', error: err.message });
           } else {
             console.log('Résultats de la requête SQL:', results);
             const response = {
               niveaux: results.map(result => {
                 if (typeof result.nom === 'string') {
                   return result.nom;
                 } else {
                   console.error('Le champ nom n\'est pas une chaîne de caractères:', result.nom);
                   // Traitez le cas où le champ nom n'est pas une chaîne de caractères
                   return null; // ou une valeur par défaut appropriée
                 }
               })
             };
             res.json(response);
           }
         });
       });

//module de prof
router.get('/modulep/:profEmail', (req, res) => {
                  const profEmail = req.params.profEmail;
                  console.log('Requête reçue pour profEmail:', profEmail);

                  const query = `
                    SELECT DISTINCT m.nom
                    FROM module m
                    WHERE m.email_prof = ?
                  `;

                  db.query(query, [profEmail], (err, results) => {
                    if (err) {
                      console.error('Erreur lors de la récupération des modules du professeur : ', err);
                      res.status(500).json({ message: 'Erreur lors de la récupération des modules du professeur', error: err.message });
                    } else {
                      console.log('Résultats de la requête SQL:', results);
                      const response = {
                        modules: results.map(result => {
                          if (typeof result.nom === 'string') {
                            return result.nom;
                          } else {
                            console.error('Le champ nom n\'est pas une chaîne de caractères:', result.nom);
                            // Traitez le cas où le champ nom n'est pas une chaîne de caractères
                            return null; // ou une valeur par défaut appropriée
                          }
                        })
                      };
                      res.json(response);
                    }
                  });
                });



// rapport semestriell
router.get('/report/:niveauName/:moduleName', (req, res) => {
    const { niveauName, moduleName } = req.params;

    // Requête pour obtenir l'ID du niveau à partir du nom
    const getNiveauIdQuery = `
        SELECT id FROM niveau WHERE nom = ?;
    `;

    // Requête pour obtenir l'ID du module à partir du nom
    const getModuleIdQuery = `
        SELECT id FROM module WHERE nom = ?;
    `;

    db.query(getNiveauIdQuery, [niveauName], (err, niveauResult) => {
        if (err) {
            console.error('Error fetching niveau ID:', err);
            return res.status(500).json({ error: err.message });
        }

        const niveauId = niveauResult[0]?.id;
        if (!niveauId) {
            return res.status(404).json({ error: 'Niveau not found' });
        }

        db.query(getModuleIdQuery, [moduleName], (err, moduleResult) => {
            if (err) {
                console.error('Error fetching module ID:', err);
                return res.status(500).json({ error: err.message });
            }

            const moduleId = moduleResult[0]?.id;
            if (!moduleId) {
                return res.status(404).json({ error: 'Module not found' });
            }

            const query = `
                SELECT s.id as student_id, s.nom as student_nom, s.prenom as student_prenom,
                       m.nom as module_nom,
                       COUNT(DISTINCT c.date) as total_classes,
                       COUNT(DISTINCT CASE WHEN sc.statut = 'present(e)' THEN sc.date END) as present_classes,
                       (COUNT(DISTINCT CASE WHEN sc.statut = 'present(e)' THEN sc.date END) / COUNT(DISTINCT c.date)) * 100 as presence_percentage
                FROM student s
                JOIN niveau n ON s.niveau = n.nom
                JOIN module m ON m.id_niveau = n.id
                JOIN codeqr c ON c.id_niveau = n.id AND c.id_module = m.id
                LEFT JOIN scanner sc ON sc.id_codeqr = c.id AND sc.id_student = s.id
                WHERE n.id = ? AND m.id = ?
                GROUP BY s.id, s.nom, s.prenom, m.nom;
            `;

            db.query(query, [niveauId, moduleId], (err, results) => {
                if (err) {
                    console.error('Error executing query:', err);
                    return res.status(500).json({ error: err.message });
                }

                const report = results.map(row => ({
                    student_id: row.student_id,
                    student_nom: row.student_nom,
                    student_prenom: row.student_prenom,
                    module_nom: row.module_nom,
                    total_classes: row.total_classes,
                    present_classes: row.present_classes,
                    presence_percentage: row.presence_percentage || 0
                }));

                res.json({ niveauName, moduleName, report });
            });
        });
    });
});




// changer le password dans le premier login :
router.post('/updatepassword', async (req, res) => {
  const { userId, newPassword } = req.body;

  if (!userId || !newPassword) {
    return res.status(400).json({ success: false, message: 'Missing userId or newPassword' });
  }

  try {

      //const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password in 'user' table
    const updateQueryUser = `
      UPDATE user
      SET password = ?,first_login = false
      WHERE id = ?;
    `;
    const updateValuesUser = [newPassword, userId];

    db.query(updateQueryUser, updateValuesUser, (err, results) => {
      if (err) {
        console.error('Error executing query:', err);
        return res.status(500).json({ error: err.message });
      }

      // Check the role of the user
      const roleQuery = `
        SELECT role
        FROM user
        WHERE id = ?;
      `;
      const roleValues = [userId];

      db.query(roleQuery, roleValues, (err, roleResult) => {
        if (err) {
          console.error('Erreur lors de la recherche de l\'ID du user : ', err);
          return res.status(500).json({ message: 'Erreur lors de la recherche de l\'ID du user' });
        }

        if (!roleResult || roleResult.length === 0) {
          return res.status(404).json({ success: false, message: 'User not found' });
        }

        const userRole = roleResult[0].role;
        console.log(userRole);

        // Update password in corresponding table based on user role
        let updateQuery = '';
        const updateValues = [newPassword, userId]; // Common update values

        switch (userRole) {
          case 'prof':
            updateQuery = `
              UPDATE prof
              SET password = ?
              WHERE id = ?;
            `;
            break;
          case 'student':
            updateQuery = `
              UPDATE student
              SET password = ?
              WHERE id = ?;
            `;
            break;
          case 'admin':
            updateQuery = `
              UPDATE admin
              SET password = ?
              WHERE id = ?;
            `;
            break;
          default:
            return res.status(403).json({ success: false, message: 'Unsupported user role' });
        }

        // Perform the update query
        if (updateQuery !== '') {
          db.query(updateQuery, updateValues, (err, results) => {
            if (err) {
              console.error('Error executing query:', err);
              return res.status(500).json({ error: err.message });
            }

            // Select updated user information from the 'user' table
            const selectQuery = `
              SELECT id, email, nom, role
              FROM user
              WHERE id = ?;
            `;
            const selectValues = [userId];

            db.query(selectQuery, selectValues, (err, result) => {
              if (err) {
                console.error('Error executing query:', err);
                return res.status(500).json({ error: err.message });
              }

              if (!result || result.length === 0) {
                return res.status(404).json({ success: false, message: 'User not found' });
              }

              res.json({ success: true, user: result[0] });
            });
          });
        }
      });
    });
  } catch (error) {
    console.error('Error in updatePassword:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});



// ajouter professeur par liste excel
router.post('/liste_professeurs', (req, res) => {
  // Récupérer les données des professeurs à partir du corps de la requête
  const professorsData = req.body;

  // Requête SQL pour insérer les professeurs dans la table
  const query = 'INSERT INTO prof (nom, prenom, email, password) VALUES ?';

  // Exécution de la requête SQL avec les données des professeurs
  db.query(query, [professorsData.map(professor => [professor.nom, professor.prenom, professor.email, professor.password])], (error, results) => {
    if (error) {
      console.error('Erreur lors de l\'ajout des professeurs à la base de données :', error);
      res.status(500).json({ message: 'Erreur lors de l\'ajout des professeurs à la base de données' });
      return;
    }

    console.log('Professeurs ajoutés avec succès à la base de données');
    res.status(200).json({ message: 'Professeurs ajoutés avec succès à la base de données' });
  });
});


































module.exports =router;