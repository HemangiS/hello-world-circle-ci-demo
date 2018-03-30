var express = require('express');
var router = express.Router();
var data = require('../data/info.json');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/info', function(req, res, next) {
  res.render('table', { title: 'Info', data: data });
});

module.exports = router;
