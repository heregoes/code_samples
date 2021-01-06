const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth');

// bookmark Model
const Bookmark = require('../../models/Bookmark');

// @route   GET api/bookmarks
// @desc    Get All bookmarks
// @access  Public
router.get('/:userId', (req, res) => {
  Bookmark.find({ user : req.params.userId })
    .sort({ date: -1 })
    .then(bookmarks => {
      res.json(bookmarks)})
    .catch(err => res.json({
      success: false, 
      message: `Error: ${err} unable to find bookmarks`
    }));
});

// @route   POST api/bookmarks
// @desc    Create An bookmark
// @access  Private
router.post('/', auth, (req, res) => {
  const newBookmark = new Bookmark({
    article_name: req.body.article_name,
    article_link: req.body.article_link,
    article_image: req.body.article_image,
    article_description: req.body.article_description,
    article_source: req.body.article_source,
    article_date: req.body.article_date,
    user: req.body.user
  });
  newBookmark.save()
    .then(article => res.json(article))
    .catch(err => res.json({
      success: false,
      message: `Error: ${err}.. Unable to Save`}));
});

// @route   DELETE api/bookmarks/:id
// @desc    Delete A bookmark
// @access  Private
router.delete('/:id', (req, res) => {
    Bookmark.findById(req.params.id)
    .then(article => article.remove().then(() => res.json({ id: article._id ,success: true })))
    .catch(err => res.status(404).json({ success: false }));
});

module.exports = router;