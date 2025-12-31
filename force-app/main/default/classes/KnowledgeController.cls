public without sharing class KnowledgeController {

    // Method to get the list of published articles of general
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getKnowledgeArticles() {
        return [
            SELECT Id, Title, ArticleTotalViewCount, CreatedDate, LastModifiedDate, Summary, Article_Body__c
            FROM Knowledge__kav
            WHERE Id IN (
                SELECT EntityId FROM TopicAssignment 
                WHERE TopicId IN ('0TO1C000000LzspWAC', '0TOcW0000001FpqWAE', '0TOcW0000001IEDWA2')
            )
            AND PublishStatus = 'Online'
            AND Language = 'en_US'
        ];
    }

    // Method to get the list of published articles of website
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getKnowledgeWebsiteArticles() {
        return [
            SELECT Id, Title, ArticleTotalViewCount, CreatedDate, LastModifiedDate, Summary, Article_Body__c
            FROM Knowledge__kav 
            WHERE Id IN (
                SELECT EntityId FROM TopicAssignment 
                WHERE TopicId IN ('0TOcW0000001FppWAE', '0TOcW0000001ICbWAM', '0TO1C000000LzsVWAS')
            ) 
            AND PublishStatus = 'Online' 
            AND Language = 'en_US'
        ];
    }

    // Method to get the list of published articles of Coverage and Claims
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getKnowledgeCoverage_and_ClaimsArticles() {
        return [
            SELECT Id, Title, ArticleTotalViewCount, CreatedDate, LastModifiedDate, Summary, Article_Body__c 
            FROM Knowledge__kav 
            WHERE Id IN (
                SELECT EntityId FROM TopicAssignment 
                WHERE TopicId IN ('0TO1C000000LzsQWAS', '0TOcW0000001FprWAE', '0TOcW0000001IFpWAM')
            ) 
            AND PublishStatus = 'Online' 
            AND Language = 'en_US'
        ];
    }

    // Method to get one article by ID
    // @AuraEnabled(cacheable=true)
    // public static Knowledge__kav getArticle(String articleId) {
    //     if (String.isBlank(articleId)) {
    //         return null;
    //     }

    //     try {
    //         return [
    //             SELECT Id, Title, ArticleTotalViewCount, CreatedDate, LastModifiedDate, Summary, Article_Body__c
    //             FROM Knowledge__kav
    //             WHERE Id = :articleId
    //             LIMIT 1
    //         ];
    //     } catch (Exception e) {
    //         System.debug('Error fetching article: ' + e.getMessage());
    //         return null;
    //     }
    // }
    @AuraEnabled(cacheable=true)
public static Knowledge__kav getArticle(String articleId) {
    if (String.isBlank(articleId)) {
        return null;
    }

    try {
        Id fullId = Id.valueOf(articleId); // convierte a ID válido de 18 caracteres

        return [
            SELECT Id, Title, ArticleTotalViewCount, CreatedDate, LastModifiedDate, Summary, Article_Body__c
            FROM Knowledge__kav
            WHERE Id = :fullId
            LIMIT 1
        ];
    } catch (Exception e) {
        System.debug('Error fetching article: ' + e.getMessage());
        return null;
    }
}

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> searchKnowledgeArticles(String searchText) {
        List<Id> topicIds = new List<Id>{
            '0TO1C000000LzspWAC', '0TOcW0000001FpqWAE', '0TOcW0000001IEDWA2', // General
            '0TOcW0000001FppWAE', '0TOcW0000001ICbWAM', '0TO1C000000LzsVWAS', // Website
            '0TO1C000000LzsQWAS', '0TOcW0000001FprWAE', '0TOcW0000001IFpWAM'  // Coverage & Claims
        };

        // Normalizar el texto de búsqueda (quitar espacios extra y convertir a minúsculas)
        searchText = searchText != null ? searchText.trim().toLowerCase() : '';

        // Consulta base
        String query = 'SELECT Id, Title, ArticleTotalViewCount, CreatedDate, LastModifiedDate, Summary, Article_Body__c ' +
                    'FROM Knowledge__kav WHERE Id IN (SELECT EntityId FROM TopicAssignment WHERE TopicId IN :topicIds) ' +
                    'AND PublishStatus = \'Online\' AND Language = \'en_US\'';

        // Aplicar búsqueda solo si hay texto ingresado
        if (!String.isBlank(searchText)) {
            query += ' AND Title LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
        }

        // Ejecutar la consulta
        return Database.query(query);
    }

}