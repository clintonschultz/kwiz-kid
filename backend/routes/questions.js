const express = require('express');
const router = express.Router();
const QuestionService = require('../services/QuestionService');
const ContentValidator = require('../middleware/ContentValidator');
const AuthMiddleware = require('../middleware/AuthMiddleware');

// Get questions for app consumption
router.get('/', async (req, res) => {
  try {
    const { 
      category, 
      difficulty, 
      ageMin, 
      ageMax, 
      limit = 10,
      includeImages = false 
    } = req.query;

    const questions = await QuestionService.getQuestions({
      category,
      difficulty,
      ageRange: ageMin && ageMax ? { min: parseInt(ageMin), max: parseInt(ageMax) } : null,
      includeImages: includeImages === 'true',
      limit: parseInt(limit)
    });

    res.json({
      success: true,
      data: questions,
      count: questions.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching questions:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch questions',
      message: error.message
    });
  }
});

// Get question statistics
router.get('/stats', async (req, res) => {
  try {
    const stats = await QuestionService.getQuestionStats();
    res.json({
      success: true,
      data: stats,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching question stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch question statistics',
      message: error.message
    });
  }
});

// Generate new questions (admin only)
router.post('/generate', AuthMiddleware.requireAdmin, ContentValidator.validateGenerationRequest, async (req, res) => {
  try {
    const { 
      category, 
      difficulty, 
      ageRange, 
      count = 10,
      useAI = true,
      reviewRequired = true 
    } = req.body;

    const result = await QuestionService.generateQuestions({
      category,
      difficulty,
      ageRange,
      count: parseInt(count),
      useAI,
      reviewRequired
    });

    res.json({
      success: true,
      data: result,
      message: `Generated ${result.questions.length} questions`,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error generating questions:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to generate questions',
      message: error.message
    });
  }
});

// Update question (admin only)
router.put('/:id', AuthMiddleware.requireAdmin, ContentValidator.validateQuestionUpdate, async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const question = await QuestionService.updateQuestion(id, updates);

    res.json({
      success: true,
      data: question,
      message: 'Question updated successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error updating question:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update question',
      message: error.message
    });
  }
});

// Delete question (admin only)
router.delete('/:id', AuthMiddleware.requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { permanent = false } = req.query;

    await QuestionService.deleteQuestion(id, permanent === 'true');

    res.json({
      success: true,
      message: permanent === 'true' ? 'Question permanently deleted' : 'Question deactivated',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error deleting question:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete question',
      message: error.message
    });
  }
});

module.exports = router;


