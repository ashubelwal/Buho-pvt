import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getArticle from '@salesforce/apex/KnowledgeController.getArticle';

export default class KnowledgeDetails extends LightningElement {
    @track article;
    articleId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.articleId = currentPageReference.state.articleId;
        }
    }

    @wire(getArticle, { articleId: '$articleId' })
    wiredArticle({ error, data }) {
        if (data) {
            this.article = data;
            this.renderArticleBody();
        } else if (error) {
            console.error('Error loading article:', error);
        }
    }

    renderedCallback() {
        this.renderArticleBody();
    }

    renderArticleBody() {
        if (this.article && this.article.Article_Body__c) {
            const articleContainer = this.template.querySelector('.article-body');
            if (articleContainer) {
                articleContainer.innerHTML = this.article.Article_Body__c;

                // Mejorar enlaces
                this.fixLinks(articleContainer);
            }
        }
    }

    fixLinks(container) {
        const links = container.querySelectorAll('a');
        links.forEach(link => {
            link.setAttribute('target', '_blank');  // Forzar apertura en nueva pestaña
            link.setAttribute('rel', 'noopener noreferrer'); // Seguridad adicional
        });
    }
}