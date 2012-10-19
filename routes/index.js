
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Express', technologies: ['Javascript', 'Node', 'Mobile'] });
};
