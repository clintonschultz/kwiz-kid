// KwizKid Content Management System
class ContentManager {
    constructor() {
        this.apiBase = 'https://your-api-domain.com/api';
        this.currentPage = 1;
        this.pageSize = 10;
        this.questions = [];
        this.filters = {};
        
        this.init();
    }
    
    async init() {
        await this.loadStats();
        await this.loadQuestions();
        this.setupEventListeners();
    }
    
    setupEventListeners() {
        // Generation modal
        document.getElementById('generate-questions-btn').addEventListener('click', () => {
            this.showGenerationModal();
        });
        
        document.getElementById('cancel-generation').addEventListener('click', () => {
            this.hideGenerationModal();
        });
        
        document.getElementById('generation-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleGeneration();
        });
        
        // Filters
        ['category-filter', 'difficulty-filter', 'status-filter', 'age-filter'].forEach(id => {
            document.getElementById(id).addEventListener('change', () => {
                this.applyFilters();
            });
        });
        
        // Pagination
        document.getElementById('prev-page').addEventListener('click', () => {
            if (this.currentPage > 1) {
                this.currentPage--;
                this.loadQuestions();
            }
        });
        
        document.getElementById('next-page').addEventListener('click', () => {
            this.currentPage++;
            this.loadQuestions();
        });
    }
    
    async loadStats() {
        try {
            const response = await fetch(`${this.apiBase}/questions/stats`);
            const data = await response.json();
            
            if (data.success) {
                document.getElementById('total-questions').textContent = data.data.total;
                document.getElementById('approved-questions').textContent = data.data.approved;
                document.getElementById('pending-questions').textContent = data.data.pendingReview;
                document.getElementById('total-categories').textContent = Object.keys(data.data.byCategory).length;
            }
        } catch (error) {
            console.error('Error loading stats:', error);
            this.showNotification('Failed to load statistics', 'error');
        }
    }
    
    async loadQuestions() {
        try {
            const params = new URLSearchParams({
                page: this.currentPage,
                limit: this.pageSize,
                ...this.filters
            });
            
            const response = await fetch(`${this.apiBase}/questions?${params}`);
            const data = await response.json();
            
            if (data.success) {
                this.questions = data.data;
                this.renderQuestions();
                this.updatePagination(data.count);
            }
        } catch (error) {
            console.error('Error loading questions:', error);
            this.showNotification('Failed to load questions', 'error');
        }
    }
    
    renderQuestions() {
        const tbody = document.getElementById('questions-table-body');
        tbody.innerHTML = '';
        
        this.questions.forEach(question => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm font-medium text-gray-900 max-w-xs truncate">
                        ${question.text}
                    </div>
                    <div class="text-sm text-gray-500">
                        ${question.options.map((opt, i) => `${String.fromCharCode(65 + i)}. ${opt}`).join(', ')}
                    </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                        ${question.category}
                    </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                        question.difficulty === 'easy' ? 'bg-green-100 text-green-800' :
                        question.difficulty === 'medium' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-red-100 text-red-800'
                    }">
                        ${question.difficulty}
                    </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    ${question.ageMin}-${question.ageMax}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                        question.status === 'approved' ? 'bg-green-100 text-green-800' :
                        question.status === 'pending_review' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-red-100 text-red-800'
                    }">
                        ${question.status.replace('_', ' ')}
                    </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button onclick="contentManager.viewQuestion('${question.id}')" class="text-blue-600 hover:text-blue-900 mr-3">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button onclick="contentManager.editQuestion('${question.id}')" class="text-indigo-600 hover:text-indigo-900 mr-3">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button onclick="contentManager.deleteQuestion('${question.id}')" class="text-red-600 hover:text-red-900">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            `;
            tbody.appendChild(row);
        });
    }
    
    updatePagination(totalCount) {
        const start = (this.currentPage - 1) * this.pageSize + 1;
        const end = Math.min(this.currentPage * this.pageSize, totalCount);
        
        document.getElementById('showing-start').textContent = start;
        document.getElementById('showing-end').textContent = end;
        document.getElementById('total-count').textContent = totalCount;
        
        document.getElementById('prev-page').disabled = this.currentPage === 1;
        document.getElementById('next-page').disabled = end >= totalCount;
    }
    
    applyFilters() {
        this.filters = {
            category: document.getElementById('category-filter').value,
            difficulty: document.getElementById('difficulty-filter').value,
            status: document.getElementById('status-filter').value,
            ageRange: document.getElementById('age-filter').value
        };
        
        // Remove empty filters
        Object.keys(this.filters).forEach(key => {
            if (!this.filters[key]) {
                delete this.filters[key];
            }
        });
        
        this.currentPage = 1;
        this.loadQuestions();
    }
    
    showGenerationModal() {
        document.getElementById('generation-modal').classList.remove('hidden');
    }
    
    hideGenerationModal() {
        document.getElementById('generation-modal').classList.add('hidden');
    }
    
    async handleGeneration() {
        const formData = {
            category: document.getElementById('gen-category').value,
            difficulty: document.getElementById('gen-difficulty').value,
            ageRange: this.parseAgeRange(document.getElementById('gen-age-range').value),
            count: parseInt(document.getElementById('gen-count').value),
            useAI: document.getElementById('gen-use-ai').checked,
            reviewRequired: document.getElementById('gen-review-required').checked
        };
        
        try {
            this.showNotification('Generating questions...', 'info');
            
            const response = await fetch(`${this.apiBase}/questions/generate`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.getAuthToken()}`
                },
                body: JSON.stringify(formData)
            });
            
            const data = await response.json();
            
            if (data.success) {
                this.showNotification(`Generated ${data.data.questions.length} questions successfully!`, 'success');
                this.hideGenerationModal();
                this.loadStats();
                this.loadQuestions();
            } else {
                this.showNotification(data.error || 'Generation failed', 'error');
            }
        } catch (error) {
            console.error('Error generating questions:', error);
            this.showNotification('Failed to generate questions', 'error');
        }
    }
    
    parseAgeRange(ageRangeStr) {
        const [min, max] = ageRangeStr.split('-').map(Number);
        return { min, max };
    }
    
    async viewQuestion(id) {
        // Implementation for viewing question details
        console.log('View question:', id);
    }
    
    async editQuestion(id) {
        // Implementation for editing question
        console.log('Edit question:', id);
    }
    
    async deleteQuestion(id) {
        if (confirm('Are you sure you want to delete this question?')) {
            try {
                const response = await fetch(`${this.apiBase}/questions/${id}`, {
                    method: 'DELETE',
                    headers: {
                        'Authorization': `Bearer ${this.getAuthToken()}`
                    }
                });
                
                const data = await response.json();
                
                if (data.success) {
                    this.showNotification('Question deleted successfully', 'success');
                    this.loadQuestions();
                } else {
                    this.showNotification(data.error || 'Delete failed', 'error');
                }
            } catch (error) {
                console.error('Error deleting question:', error);
                this.showNotification('Failed to delete question', 'error');
            }
        }
    }
    
    getAuthToken() {
        // In a real implementation, this would get the token from localStorage or a secure store
        return 'your-auth-token-here';
    }
    
    showNotification(message, type = 'info') {
        // Simple notification system
        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 p-4 rounded-md shadow-lg z-50 ${
            type === 'success' ? 'bg-green-500 text-white' :
            type === 'error' ? 'bg-red-500 text-white' :
            type === 'warning' ? 'bg-yellow-500 text-white' :
            'bg-blue-500 text-white'
        }`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }
}

// Initialize the content manager when the page loads
let contentManager;
document.addEventListener('DOMContentLoaded', () => {
    contentManager = new ContentManager();
});


