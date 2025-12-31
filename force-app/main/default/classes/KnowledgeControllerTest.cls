@isTest(seeAllData=true)
public class KnowledgeControllerTest {

    // Prueba para el método getKnowledgeArticles
    static testMethod void testGetKnowledgeArticles() {
        List<Knowledge__kav> articles = KnowledgeController.getKnowledgeArticles();
        System.assertNotEquals(null, articles, 'La lista de artículos no debe ser nula');
    }
    
    // Prueba para el método getKnowledgeWebsiteArticles
    static testMethod void testGetKnowledgeWebsiteArticles() {
        List<Knowledge__kav> articles = KnowledgeController.getKnowledgeWebsiteArticles();
        System.assertNotEquals(null, articles, 'La lista de artículos de website no debe ser nula');
    }
    
    // Prueba para el método getKnowledgeCoverage_and_ClaimsArticles
    static testMethod void testGetKnowledgeCoverage_and_ClaimsArticles() {
        List<Knowledge__kav> articles = KnowledgeController.getKnowledgeCoverage_and_ClaimsArticles();
        System.assertNotEquals(null, articles, 'La lista de artículos de Coverage and Claims no debe ser nula');
    }
    
    // Prueba para el método getArticle con valor en blanco
    static testMethod void testGetArticleBlank() {
        Knowledge__kav article = KnowledgeController.getArticle('');
        System.assertEquals(null, article, 'Si se pasa cadena vacía se debe retornar null');
    }
    
    // Prueba para el método getArticle con un ID inválido
    static testMethod void testGetArticleInvalidId() {
        Knowledge__kav article = KnowledgeController.getArticle('IDInvalido');
        System.assertEquals(null, article, 'Si se pasa un ID inválido se debe retornar null');
    }
    
    // Prueba para el método getArticle con un ID válido
    static testMethod void testGetArticleValidId() {
        List<Knowledge__kav> articles = KnowledgeController.getKnowledgeArticles();
        if (!articles.isEmpty()) {
            String validId = articles[0].Id;
            Knowledge__kav article = KnowledgeController.getArticle(validId);
            System.assertNotEquals(null, article, 'Con un ID válido se debe retornar un artículo');
        } else {
            System.debug('No existen artículos de conocimiento para probar el método getArticle con ID válido.');
        }
    }

    // 🔹 Prueba para el método searchKnowledgeArticles
    static testMethod void testSearchKnowledgeArticles() {
        // Buscar artículos con un texto aleatorio
        List<Knowledge__kav> results = KnowledgeController.searchKnowledgeArticles('Test');
        System.assertNotEquals(null, results, 'La lista de artículos de búsqueda no debe ser nula');
        
        // También probamos con una búsqueda vacía, que debería devolver artículos igualmente
        List<Knowledge__kav> allResults = KnowledgeController.searchKnowledgeArticles('');
        System.assertNotEquals(null, allResults, 'La búsqueda sin texto también debe devolver artículos');
    }
}