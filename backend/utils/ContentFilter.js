class ContentFilter {
  /**
   * Filter content for child safety
   */
  static async filterForChildren(question, age) {
    const filteredQuestion = { ...question };

    // Age-appropriate language adjustment
    filteredQuestion.text = this.adjustLanguageForAge(question.text, age);
    filteredQuestion.explanation = this.adjustLanguageForAge(question.explanation, age);

    // Content safety checks
    if (!this.isContentSafe(question.text) || !this.isContentSafe(question.explanation)) {
      throw new Error('Content failed safety checks');
    }

    return filteredQuestion;
  }

  /**
   * Adjust language complexity for age
   */
  static adjustLanguageForAge(text, age) {
    if (age < 8) {
      // Simplify for younger children
      return text
        .replace(/\butilize\b/g, 'use')
        .replace(/\bdemonstrate\b/g, 'show')
        .replace(/\bconsequently\b/g, 'so')
        .replace(/\bhowever\b/g, 'but')
        .replace(/\btherefore\b/g, 'so');
    } else if (age < 12) {
      // Moderate complexity
      return text
        .replace(/\butilize\b/g, 'use')
        .replace(/\bdemonstrate\b/g, 'show');
    }
    
    // Keep original for older children
    return text;
  }

  /**
   * Check if content is safe for children
   */
  static isContentSafe(text) {
    const inappropriateWords = [
      'violence', 'weapon', 'danger', 'scary', 'frightening',
      'inappropriate', 'adult', 'mature', 'explicit',
      'death', 'kill', 'murder', 'suicide', 'self-harm'
    ];

    const lowerText = text.toLowerCase();
    
    for (const word of inappropriateWords) {
      if (lowerText.includes(word)) {
        return false;
      }
    }

    return true;
  }

  /**
   * Validate question structure
   */
  static validateQuestionStructure(question) {
    const errors = [];

    if (!question.text || question.text.trim().length === 0) {
      errors.push('Question text is required');
    }

    if (!question.options || !Array.isArray(question.options) || question.options.length !== 4) {
      errors.push('Question must have exactly 4 options');
    }

    if (typeof question.correctAnswer !== 'number' || 
        question.correctAnswer < 0 || 
        question.correctAnswer > 3) {
      errors.push('Correct answer must be a number between 0 and 3');
    }

    if (!question.explanation || question.explanation.trim().length === 0) {
      errors.push('Explanation is required');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  /**
   * Sanitize HTML content
   */
  static sanitizeHTML(html) {
    // Remove potentially dangerous HTML tags
    return html
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
      .replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '')
      .replace(/<object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object>/gi, '')
      .replace(/<embed\b[^<]*(?:(?!<\/embed>)<[^<]*)*<\/embed>/gi, '');
  }

  /**
   * Check for duplicate content
   */
  static async checkForDuplicates(question, existingQuestions) {
    const questionText = question.text.toLowerCase().trim();
    
    for (const existing of existingQuestions) {
      const existingText = existing.text.toLowerCase().trim();
      
      // Check for exact matches
      if (questionText === existingText) {
        return { isDuplicate: true, reason: 'Exact text match' };
      }
      
      // Check for high similarity (simple implementation)
      const similarity = this.calculateSimilarity(questionText, existingText);
      if (similarity > 0.8) {
        return { isDuplicate: true, reason: `High similarity (${Math.round(similarity * 100)}%)` };
      }
    }
    
    return { isDuplicate: false };
  }

  /**
   * Calculate text similarity (simple Jaccard similarity)
   */
  static calculateSimilarity(text1, text2) {
    const words1 = new Set(text1.split(/\s+/));
    const words2 = new Set(text2.split(/\s+/));
    
    const intersection = new Set([...words1].filter(x => words2.has(x)));
    const union = new Set([...words1, ...words2]);
    
    return intersection.size / union.size;
  }
}

module.exports = ContentFilter;


