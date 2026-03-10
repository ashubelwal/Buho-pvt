public without sharing class Mex_ShowSelectedQuotePdf {
  public string quoteId;
  public List<Map<String, Object>> coveredBenefits { get; set; }
  public Quote__c quoteDetail { get; set; }
  public string startTime { get; set; }
  public string endTime { get; set; }
  public string name { get; set; }
  public Boolean isBuho { get; set; }

  public Mex_ShowSelectedQuotePdf() {
    quoteId = ApexPages.currentPage().getParameters().get('Id');

    quoteDetail = [
      SELECT
        Id,
        Name,
        Start_Date_for_Coverage__c,
        End_Date_for_Coverage__c,
        Start_Time__c,
        Term_Days__c,
        Policy_Type_picklist__c,
        Quote_Value__c,
        Third_Party_Bodily_Injury__c,
        End_Time__c,
        Vehicle_Type__c,
        Property_Damage_Liability__c,
        Lead__r.LeadSource,
        Liability__c,
        Territory__c,
        Medical__c,
        Coverage__c,
        Medical_Coverage__c,
        Underwriter__c,
        QuotePdfJson__c,
        Lead__r.Name,
        Contact__c,
        Contact__r.Name,
        Contact__r.Agency__c,
        Contact__r.Agency__r.Name,
        Lead__c,
        Lead__r.Agency__r.Name
      FROM Quote__c
      WHERE Id = :quoteId
      LIMIT 1
    ];
    Apexpages.currentPage()
      .getHeaders()
      .put(
        'content-disposition',
        'inline; filename=Mexinsurance-' + quoteDetail.Underwriter__c + '-Quote.pdf'
      );
    if (
      (String.isNotBlank(quoteDetail.Lead__r.LeadSource) &&
      quoteDetail.Lead__r.LeadSource.contains('Buho')) ||
      (quoteDetail.Contact__c != null &&
      String.isNotBlank(quoteDetail.Contact__r.Agency__r.Name) &&
      quoteDetail.Contact__r.Agency__r.Name.contains('Buho')) ||
      (quoteDetail.Lead__c != null &&
      String.isNotBlank(quoteDetail.Lead__r.Agency__r.Name) &&
      quoteDetail.Lead__r.Agency__r.Name.contains('Buho'))
    ) {
      isBuho = true;
    } else {
      isBuho = false;
    }

    if (quoteDetail.Lead__r.Name == null || quoteDetail.Lead__r.Name == '') {
      name = quoteDetail.Contact__r.Name;
    } else {
      name = quoteDetail.Lead__r.Name;
    }

    System.debug('QuoteList--->?///////-->' + quoteDetail.Lead__r.Name);
    coveredBenefits = new List<Map<String, Object>>();

    if (String.isNotBlank(quoteDetail.QuotePdfJson__c)) {
      Map<String, Object> allData = (Map<String, Object>) JSON.deserializeUntyped(
        quoteDetail.QuotePdfJson__c
      );
      String uw = quoteDetail.Underwriter__c; // "Chubb", "Mapfre", "Qualitas"
      if (allData.containsKey(uw)) {
        Map<String, Object> underwriterMap = (Map<String, Object>) allData.get(uw);
        for (String covName : underwriterMap.keySet()) {
          Map<String, Object> covDetail = (Map<String, Object>) underwriterMap.get(covName);

          //coveredBenefits.add(row);
          system.debug('Title :: ' + covName);
          system.debug('is title in the map :: ' + covDetail.containsKey('Title'));
          //stem.debug(' Is the tile coderdd :: '+ String.valueOf(covDetail.get('Title')).startsWith('Covered'));

          if (
            covDetail.containsKey('Title') &&
            !String.valueOf(covDetail.get('Title')).contains('Not Covered') &&
            !String.valueOf(covDetail.get('Title')).contains('Not Included')
          ) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('Coverage', covName);
            // row.put('Order', covDetail.get('Order'));
            row.put('Title', covDetail.get('Title'));
            row.put('Description', covDetail.get('Description'));
            row.put('Image', covDetail.get('Image'));
            coveredBenefits.add(row);
          } else if (!covDetail.containsKey('Title')) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('Coverage', covName);
            // row.put('Order', covDetail.get('Order'));
            row.put('Title', '');
            row.put('Description', covDetail.get('Description'));
            row.put('Image', covDetail.get('Image'));
            coveredBenefits.add(row);
          }

          //system.debug(' this is the current value :: '+ row);
        }
      }
    }
    system.debug('coveredBenefits:: ' + coveredBenefits);
    if (quoteDetail.Start_Time__c != null) {
      Integer strtHour = quoteDetail.Start_Time__c.hour();
      Integer strtmin = quoteDetail.Start_Time__c.minute();

      string strHour = strtHour.format();
      string shift = ' AM';
      if (strtHour > 12) {
        shift = ' PM';
      } else {
        strHour = '0' + strtHour.format();
      }

      startTime = strHour + ':' + string.valueOf(strtmin) + shift;
    }
    if (quoteDetail.End_Time__c != null) {
      Integer endHour = quoteDetail.Start_Time__c.hour();
      Integer endmin = quoteDetail.Start_Time__c.minute();

      string strHour = endHour.format();
      string shift = ' AM';
      if (endHour > 12) {
        shift = ' PM';
      } else {
        strHour = '0' + endHour.format();
      }

      endTime = strHour + ':' + string.valueOf(endmin) + shift;
      // endTime = string.valueOf(quoteDetail.End_Time__c);
    }
    // }
  }
}
