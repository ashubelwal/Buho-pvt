({
	doInit : function(component, event, helper) {
        
        console.log('---initilizeData----');
        var quoteRecord = component.get("v.quoteRecord");
        var liabilitylist = [
            100000, 200000, 300000, 500000, 1000000
        ];
        component.set("v.liabilitylist", liabilitylist);

        var medicallist = [ '$2,000/$10,000', '$3,000/$15,000', '$4,000/$20,000', '$5,000/$25,000', '$10,000/$50,000', '$15,000/$75,000', '$20,000/$100,000'];
        component.set("v.medicallist", medicallist);

        var additional_towunit_Index = component.get("v.additional_towunit_Index");

        var additional_towunit = component.get("v.additional_towunit");
        if( additional_towunit && additional_towunit != null  ){

            var primaryquoteRecord = component.get("v.primaryquoteRecord");
            var title= 'You indicated your '+additional_towunit.Towed_Unit_Type__c+' was street legal.  Once it is removed from the '+primaryquoteRecord.Vehicle_Make__c+' '+primaryquoteRecord.Vehicle_Model__c+' it will need it’s own Mexico insurance policy.  Purchasing both at the same time qualifies you for multiple vehicle discount.'; //+additional_towunit.Towed_Unit_Type__c;

            component.set('v.title', title);
            /*var daysTootip = 'The number of days this vehicle will need its own insurance once it is removed from the '+primaryquoteRecord.Vehicle_Model__c+' '+primaryquoteRecord.Vehicle_Make__c+'.  Another way to put it, how many days removed from the '+additional_towunit.Make__c+' '+additional_towunit.Model__c+'.';*/

            var daysTootip = 'The number of days this vehicle will need its own insurance once it is removed from the '+primaryquoteRecord.Vehicle_Model__c+'.';//  Another way to put it, how many days removed from the '+primaryquoteRecord.Vehicle_Make__c+' '+additional_towunit.Model__c+'.';

            component.set("v.daysTootip", daysTootip);

            /*var daysIntowTootip = 'Number of days vehicle will be covered under the '+additional_towunit.Make__c+' '+additional_towunit.Model__c+' policy as a towed unit';*/

            var daysIntowTootip = 'Number of days vehicle will be covered under the '+primaryquoteRecord.Vehicle_Make__c+' '+primaryquoteRecord.Vehicle_Model__c+' policy as a towed unit';
            component.set("v.daysIntowTootip", daysIntowTootip);
            //component.set("v.countVehicle", parseInt('2'));

            if( additional_towunit.Towed_Unit_Type__c 
                    && ( additional_towunit.Towed_Unit_Type__c == 'Motorcycle'
                    || additional_towunit.Towed_Unit_Type__c == 'ATV' ) ){
                
                component.set('v.isMedicalPayment', false);
                component.set("v.qualitasMedical", null);
                component.set("v.chubbMedical", null);
                component.set("v.mapfreMedical", null);
            }

            
            console.log('-additional_towunit.Towed_Unit_Type__c---'+additional_towunit.Towed_Unit_Type__c);
            if( additional_towunit.Towed_Unit_Type__c != undefined ){
                if( additional_towunit.Towed_Unit_Type__c == 'Motorcycle' || additional_towunit.Towed_Unit_Type__c == 'ATV'){
                    component.set('v.policyType', 'Motorcycle/Street Legal ATV');
                }else if( additional_towunit.Towed_Unit_Type__c == 'Camper' ){
                    component.set('v.policyType', 'RV');
                }else if( additional_towunit.Towed_Unit_Type__c == 'Towed Automobile' ){
                    component.set('v.policyType', 'Automobile');
                }else {
                    component.set('v.policyType', null);
                }
            }

            var mapfreLiablityOnly = component.get("v.mapfreLiablityOnly");
            var policyType = component.get("v.policyType")
            console.log('--policyType---'+policyType);
            if( (mapfreLiablityOnly == undefined || mapfreLiablityOnly == 'Max') 
                && ( policyType == 'Motorcycle/Street Legal ATV' || policyType == 'RV' )){
                component.set("v.mapfreLiablityOnly", "Complete");
            }else if( policyType == 'Automobile' ){
                component.set("v.mapfreLiablityOnly", "Max");
            }

            if( additional_towunit.quoteRecord && additional_towunit.quoteRecord != null  ){
                var quoteRecord = additional_towunit.quoteRecord;
                quoteRecord['Policy_Type_picklist__c'] = component.get("v.policyType");
                component.set("v.quoteRecord", quoteRecord );
            }
        }else{
            component.set("v.daysTootip", "");
            component.set("v.daysIntowTootip", "");
            var policyType = component.get("v.policyType");
            if( policyType != null && ( policyType == 'Motorcycle/Street Legal ATV' || policyType == 'RV' ) ){
                var mapfreLiablityOnly = component.get("v.mapfreLiablityOnly");
                if( mapfreLiablityOnly == undefined || mapfreLiablityOnly == 'Max'){
                    component.set("v.mapfreLiablityOnly", "Complete");
                }
            }else if( policyType == 'Automobile' ){
                component.set("v.mapfreLiablityOnly", "Max");
            }
            //component.set("v.countVehicle", parseInt('1'));
        }
        var liabiltyOnly = component.get("v.liabiltyOnly");
       console.log("Ca Liality Only --- ", liabiltyOnly);
        if( liabiltyOnly != null && liabiltyOnly == true ){
            component.set("v.qualitasLiablityOnly", true);
            component.set("v.chubbLiablityOnly", true);
            component.set("v.mapfreLiablityOnly", 'Liability');
        }
        helper.initilizeData(component, event, helper);
	},

    onGroup : function(component, event, helper) {
        var value = event.getSource().get('v.label');
        if( value == 'Liability Only'){
            component.set('v.mapfreLiablityOnly', 'Liability');
        }else if( value == 'Full Coverage' ){
            component.set('v.mapfreLiablityOnly', 'Complete');
        }else if( value == 'Max Coverage' ){
            component.set('v.mapfreLiablityOnly', 'Max');
        }else if( value == 'Liability + Theft' ){
            component.set('v.mapfreLiablityOnly', 'LiabilityTheft');
        }else if( value == 'Complete Coverage' ){
            component.set('v.mapfreLiablityOnly', 'Complete');
        }
        helper.calculateCoverageDetail( component, event, helper );
        helper.getquickQuoteData( component, event, helper );
    },

    onNextClick : function(component, event, helper) {
        try{
        let name = event.target.name;;
        var quoteRecord = component.get("v.quoteRecord");
        var qualitasLiablityOnly = component.get("v.qualitasLiablityOnly");
        var chubbLiablityOnly = component.get("v.chubbLiablityOnly");
        var mapfreLiablityOnly = component.get("v.mapfreLiablityOnly");
        var coverageMap = component.get("v.coverageMap");
        var policyType = component.get("v.policyType");
        let communityUser = component.get("v.communityUser");
        var Difference_In_Days;
        var Difference_In_Time

        var liability;
        if( name != null && name == 'mapfreRate'){
            quoteRecord['Underwriter__c'] = 'Mapfre';

            if( component.get("v.mapfreMedical") && component.get("v.mapfreMedical") != null ){
                quoteRecord['Medical__c'] = component.get("v.mapfreMedical").replaceAll('$','');
            }

            liability = component.get("v.mapfreLiability");
            var mapfreRateValue = 0;
            if( component.get("v.mapfreRateValue") != undefined ){
                mapfreRateValue = component.get("v.mapfreRateValue");
            }
            var mapfreBroker_Policy_Fee = 0;
            if( component.get("v.mapfreBroker_Policy_Fee") != undefined ){
                mapfreBroker_Policy_Fee = component.get("v.mapfreBroker_Policy_Fee");
            }
            
            let mapfreIVATaxVal = 0;
            if (component.get("v.mapfre_iva") != undefined) {
                mapfreIVATaxVal = component.get("v.mapfre_iva");
            }

			quoteRecord['Net_Premium__c'] = ((mapfreRateValue - mapfreBroker_Policy_Fee) - mapfreIVATaxVal);
            quoteRecord['Quote_Value__c'] = mapfreRateValue;

            quoteRecord['Coverage__c'] = mapfreLiablityOnly;
            quoteRecord['I_V_A_Mex_Tax__c'] = component.get("v.mapfre_iva");
            quoteRecord['Broker_Policy_Fee__c'] = component.get("v.mapfreBroker_Policy_Fee");

            if( coverageMap != undefined && coverageMap.Mapfre != undefined && mapfreLiablityOnly != undefined && mapfreLiablityOnly != 'Liability' ){
                if( policyType == 'Automobile'  ){
                    quoteRecord['Vehicle_Deductible_Collision__c'] = String(component.get("v.auto_mapfre_collision_deductible"));
                    quoteRecord['Vehicle_Deductible_Comprehensive__c'] = String(component.get("v.auto_mapfre_theft_Total"));
                }else if( policyType == 'RV' ){
                    quoteRecord['Vehicle_Deductible_Collision__c'] = String(component.get("v.rv_collision_deductible"));
                    quoteRecord['Vehicle_Deductible_Comprehensive__c'] = String(component.get("v.rv_theft_Total"));
                }else if( policyType == 'Motorcycle/Street Legal ATV' ){
                    quoteRecord['Vehicle_Deductible_Collision__c'] = String(component.get("v.moto_map_collision_deductible"));
                    quoteRecord['Vehicle_Deductible_Comprehensive__c'] = String(component.get("v.moto_map_theft_Total"));
                }else{
                    quoteRecord['Vehicle_Deductible_Collision__c'] = String(coverageMap.Mapfre.Collision_Deductible__c);
                    quoteRecord['Vehicle_Deductible_Comprehensive__c'] = String(coverageMap.Mapfre.Total_Theft_Deductible__c);
                }
            }

            console.log('---mapfreBroker_Policy_Fee-'+component.get("v.mapfreBroker_Policy_Fee"));
            console.log('---mapfreRateValue 172-'+component.get("v.mapfreRateValue"));

            let finalValueMapfre = component.get("v.mapfreRateValue");

            component.set("v.Final_total_Premium", finalValueMapfre);

        }else if( name != null && name == 'qualitasRate' ){
            if( component.get("v.qualitasMedical") && component.get("v.qualitasMedical") != null ){
                quoteRecord['Medical__c'] = component.get("v.qualitasMedical").replaceAll('$','');
            }
            liability = component.get("v.qualitasLiability");
            quoteRecord['Underwriter__c'] = 'Qualitas';

            if( qualitasLiablityOnly ){
                quoteRecord['Coverage__c'] = 'Liability';
            }else{
                quoteRecord['Coverage__c'] = 'Complete';
            }

            var qualitasRateValue = 0;
            if( component.get("v.qualitasRateValue") != undefined){
                qualitasRateValue = component.get("v.qualitasRateValue");
            }
            var qualitas_Surcharge = 0;
            if( component.get("v.qualitas_Surcharge") != undefined ){
                qualitas_Surcharge = component.get("v.qualitas_Surcharge");
            }
            var qualitasBroker_Policy_Fee = 0;
            if( component.get("v.qualitasBroker_Policy_Fee") != undefined ){
                qualitasBroker_Policy_Fee = component.get("v.qualitasBroker_Policy_Fee");
            }

            var qualitas_Iva = 0;
            if( component.get("v.qualitas_Iva") != undefined && component.get("v.qualitas_Iva") != null  ){
                qualitas_Iva = component.get("v.qualitas_Iva");
            }

            quoteRecord['Net_Premium__c'] = qualitasRateValue - (  qualitasBroker_Policy_Fee + qualitas_Iva );
            quoteRecord['Quote_Value__c'] = qualitasRateValue;

            quoteRecord['I_V_A_Mex_Tax__c'] = component.get("v.qualitas_Iva"); 
            quoteRecord['Surcharge__c'] = component.get("v.qualitas_Surcharge");
            quoteRecord['Broker_Policy_Fee__c'] = component.get("v.qualitasBroker_Policy_Fee");
            
            if( coverageMap != undefined && coverageMap.Qualitas != undefined && qualitasLiablityOnly != undefined && !qualitasLiablityOnly ){
                if( policyType == 'Automobile' ){
                    quoteRecord['Vehicle_Deductible_Collision__c'] = String(component.get("v.auto_collision_deductible"));
                    quoteRecord['Vehicle_Deductible_Comprehensive__c'] = String(component.get("v.auto_theft_Total"));
                }else if( policyType == 'RV' ){
                    quoteRecord['Vehicle_Deductible_Collision__c'] = String(component.get("v.rv_collision_deductible"));
                    quoteRecord['Vehicle_Deductible_Comprehensive__c'] = String(component.get("v.rv_theft_Total"));
                }else if( policyType == 'Motorcycle/Street Legal ATV' ){
                    quoteRecord['Vehicle_Deductible_Collision__c'] = String(component.get("v.moto_qual_collision_deductible"));
                    quoteRecord['Vehicle_Deductible_Comprehensive__c'] = String(component.get("v.moto_qual_theft_Total"));
                }else{
                    quoteRecord['Vehicle_Deductible_Collision__c'] = String(coverageMap.Qualitas.Collision_Deductible__c);
                    quoteRecord['Vehicle_Deductible_Comprehensive__c'] = String(coverageMap.Qualitas.Total_Theft_Deductible__c);
                }
            }

            console.log('---qualitasRateValue 228-'+component.get("v.qualitasRateValue"));
            let finalValueQualitas = component.get("v.qualitasRateValue");

            component.set("v.Final_total_Premium", finalValueQualitas);

        }else if( name != null && name == 'chubbRate' ){
            quoteRecord['Underwriter__c'] = 'Chubb';
            if( component.get("v.chubbMedical") && component.get("v.chubbMedical") != null ){
                quoteRecord['Medical__c'] = component.get("v.chubbMedical").replaceAll('$','');
            }
            liability = component.get("v.chubbLiability");
            
            
            if( chubbLiablityOnly ){
                quoteRecord['Coverage__c'] = 'Liability';
            }else{
                quoteRecord['Coverage__c'] = 'Complete';
            }
            var chubbRateValue = 0;
            if( component.get("v.chubbRateValue") != undefined ){
                chubbRateValue = component.get("v.chubbRateValue");
            }
            var chubbBroker_Policy_Fee = 0;
            if( component.get("v.chubbBroker_Policy_Fee") != undefined ){
                chubbBroker_Policy_Fee = component.get("v.chubbBroker_Policy_Fee");
            }
            var chub_SurCharge = 0;
            if( component.get("v.chub_SurCharge") != undefined ){
                chub_SurCharge = component.get("v.chub_SurCharge");
            }
            
            quoteRecord['Net_Premium__c'] = chubbRateValue - ( chubbBroker_Policy_Fee );
            quoteRecord['Quote_Value__c'] = chubbRateValue;
            
            quoteRecord['I_V_A_Mex_Tax__c'] = null;
            quoteRecord['Broker_Policy_Fee__c'] = component.get("v.chubbBroker_Policy_Fee");
            quoteRecord['Surcharge__c'] = component.get("v.chub_SurCharge");
            quoteRecord['Physical_Damage__c'] = component.get("v.physicalDamagePayment");
            quoteRecord['Liability_Payment__c'] = component.get("v.LiabilityPayment");
            quoteRecord['Medical_Payment__c'] = component.get("v.medicalPayment");
            quoteRecord['Platinum_Endorsment__c'] = component.get("v.platinumEndorsementPayment");
            quoteRecord['Total_Theft_Payment__c'] = component.get("v.totalTheftPayment");
            
            if( coverageMap != undefined && coverageMap.Chubb != undefined && chubbLiablityOnly != undefined && !chubbLiablityOnly ){
                quoteRecord['Vehicle_Deductible_Collision__c'] = String(coverageMap.Chubb.Collision_Deductible__c);
                quoteRecord['Vehicle_Deductible_Comprehensive__c'] = String(coverageMap.Chubb.Total_Theft_Deductible__c);
            }
            
            //console.log('---chubbBroker_Policy_Fee-'+component.get("v.chubbBroker_Policy_Fee"));
            console.log('---chubbRateValue 269-'+component.get("v.chubbRateValue"));
            let finalValueChubb = component.get("v.chubbRateValue");
            
            component.set("v.Final_total_Premium", finalValueChubb);
        }
            if( liability && liability != null){
                if( liability == '100000'){
                    quoteRecord['Liability__c'] = '100,000';
                }else if( liability == '200000' ){
                    quoteRecord['Liability__c'] = '200,000';
                }else if( liability == '300000' ){
                    quoteRecord['Liability__c'] = '300,000';
                }else if( liability == '500000' ){
                    quoteRecord['Liability__c'] = '500,000';
                }else if( liability == '1000000' ){
                    //quoteRecord['Liability__c'] = '500,000';
                } 
            }
            
            component.set("v.quoteRecord", quoteRecord);
            
            var quoteRecord = component.get("v.quoteRecord");
            let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
            startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
            
            let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']); 
            endDayForCoverage = new Date (endDayForCoverage.getUTCFullYear(), endDayForCoverage.getUTCMonth(), endDayForCoverage.getUTCDate());
            
            Difference_In_Time = endDayForCoverage.getTime() - startDayForCoverage.getTime();
            Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            console.log('Difference_In_Days ',Difference_In_Days);
            if( Difference_In_Days != null && Difference_In_Days > 365 ){
                helper.showToast('Total days cannot equal more than 365', 'error');
                return ;
            }
            
            if (Difference_In_Days != null && Difference_In_Days == 0) {
                helper.showToast('Total days cannot be less than 1', 'error');
                return;
            }
            
            var additional_towunit = component.get("v.additional_towunit");
            var allValid = helper.validateInputFields(component, event, helper);
            if( allValid ){
                var renewPolicy = component.get("v.renewPolicy");
                if( renewPolicy != undefined && renewPolicy == true ){
                    if( additional_towunit && additional_towunit != null  ){
                        console.log("Ca log Line number 311----->"+ JSON.stringify(additional_towunit, null, 4));
                        helper.updateQuoteForTowUnitHelper(component, event, helper);
                    }else{
                        helper.updateQuoteHelper(component, event, helper);
                    }
                    $A.enqueueAction(component.get("v.onNextClick"));
                    return;
                }
                
                if (!communityUser) {
                    let selectedProduct = {};
                    selectedProduct.item_name = "Automobile";
                    selectedProduct.item_id = quoteRecord.Policy_Type_picklist__c.toLowerCase() == "automobile" ? "0121C00000102F1QAI-" + quoteRecord.Underwriter__c : quoteRecord.Policy_Type_picklist__c.toLowerCase() == "rv" ? "0121C00000102F6QAI-" + quoteRecord.Underwriter__c : "0121C00000102F4QAI-" + quoteRecord.Underwriter__c;
                    selectedProduct.price = quoteRecord.Quote_Value__c;
                    selectedProduct.item_brand = "MexInsurance";
                    selectedProduct.item_category = quoteRecord.Vehicle_Type__c;
                    selectedProduct.item_category2 = Difference_In_Days > 0 && Difference_In_Days <= 30 ? "Daily" : Difference_In_Days > 30 && Difference_In_Days <= 180 ? "Semi-Annual(Half a Year)" : "Annual(One Year)";
                    selectedProduct.item_category3 = quoteRecord.Territory_Coverage__c;
                    selectedProduct.item_category4 = quoteRecord.Underwriter__c;
                    selectedProduct.item_variant = quoteRecord.Coverage__c;
                    selectedProduct.item_list_name = quoteRecord.Policy_Type_picklist__c + " Quote Page";
                    selectedProduct.quantity = 1;
                    selectedProduct.index = quoteRecord.Underwriter__c.toLowerCase() == "qualitas" ? 1 : quoteRecord.Underwriter__c.toLowerCase() == "chubb" ? 2 : 3;
                    
                    console.log("Selected Product Item ---> ", JSON.stringify(selectedProduct, null, 4));
                    
                    window.dataLayer.push({ ecommerce: undefined });
                    window.dataLayer.push({
                        event: "select_item",
                        ecommerce: {
                            items: [selectedProduct]
                        }
                    });

                    // Lead create for new user
                    helper.saveQuoteHelper(component, event, helper, name);
                    if( additional_towunit && additional_towunit != null  ){
                        helper.updateQuoteForTowUnitHelper(component, event, helper);
                    }else{
                        helper.updateQuoteHelper(component, event, helper);
                    }
                }else{
                    if( additional_towunit && additional_towunit != null  ){
                        helper.updateQuoteForTowUnitHelper(component, event, helper);
                    }else{
                        helper.updateQuoteHelper(component, event, helper);
                    }
                }
            }
        }catch( ex ){
            console.log('---ex--', ex);
        } 
        
    },

    updatePhoneValue : function(component, event, helper) {
        var value = event.getParam("value");
        if( value && value.length > 0 ){
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            value = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        }
        component.set("v.phoneNumber", value);
    },
    
    saveQuote : function(component, event, helper) {
        var quoteRecord = component.get("v.quoteRecord");
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
        startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());

        let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']); 
        endDayForCoverage = new Date (endDayForCoverage.getUTCFullYear(), endDayForCoverage.getUTCMonth(), endDayForCoverage.getUTCDate());

        var Difference_In_Time = endDayForCoverage.getTime() - startDayForCoverage.getTime();
        var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
        if( Difference_In_Days != null && Difference_In_Days > 365 ){
            helper.showToast('Total days cannot equal more than 365', 'error');
            return ;
        }
        
        if (Difference_In_Days != null && Difference_In_Days == 0) {
            helper.showToast('Total days cannot be less than 1', 'error');
            return;
        }
        
        var allValid = helper.validateInputFields(component, event, helper);
        if( allValid ){
            helper.checkalreadyExistUser( component, event, helper );
            //helper.saveQuoteHelper(component, event, helper);
        } 
    },
    
    highlightView : function (component, event, helper) {
        component.set("v.highlightView", true);
        component.set("v.normalView", false);
    },
    
    normalView : function (component, event, helper) {
        component.set("v.normalView", true);
        component.set("v.highlightView", false);
    },
    
    updateLiability : function (component, event, helper) {
        var name = event.target.name;
        var type = event.target.dataset.type;

        var liabilitylist = component.get("v.liabilitylist");
        var length = (liabilitylist.length - 1);
        var liablity = '';
        if( name && name == 'qualitasLiability'){
            liablity = component.get("v.qualitasLiability");
        }else if( name && name == 'chubbLiability'){
            liablity = component.get("v.chubbLiability");
        }else if( name && name == 'mapfreLiability'){
            liablity = component.get("v.mapfreLiability");
        }
        
        
        var updatelibality;
        if( type && type == 'high' ){
            var index = liabilitylist.indexOf(parseInt(liablity));
            if( length != index ){
                updatelibality = liabilitylist[index+1];
            }
        }else if( type && type == 'low' ){
            var index = liabilitylist.indexOf(parseInt(liablity));
            if( index != 0 ){
                updatelibality = liabilitylist[index-1] ;
            }
        }
        if( name && name == 'mapfreLiability' && (updatelibality == '1000000')){
            updatelibality = null;
        }

        if( name && name == 'qualitasLiability' && updatelibality && updatelibality != null ){
            component.set("v.qualitasLiability", updatelibality );
        }else if( name && name == 'chubbLiability' && updatelibality && updatelibality != null ){
            component.set("v.chubbLiability", updatelibality );
        }else if( name && name == 'mapfreLiability' && updatelibality && updatelibality != null ){
            component.set("v.mapfreLiability", updatelibality );
        }

        if( updatelibality && updatelibality != null ){
            helper.getquickQuoteData( component, event, helper );
        }
    },

    updateMedical: function (component, event, helper) {
        var name = event.target.name;
        var type = event.target.dataset.type;
        var medicallist = component.get("v.medicallist");
        var length = (medicallist.length - 1);

        var medical = '';
        if( name && name == 'qualitasMedical'){
            medical = component.get("v.qualitasMedical");
        }else if( name && name == 'chubbMedical'){
            medical = component.get("v.chubbMedical");
        }else if( name && name == 'mapfreMedical'){
            medical = component.get("v.mapfreMedical");
        }

        var index = medicallist.indexOf(medical);
        var updateMedical;
        if( type && type == 'high' ){
            if( length != index ){
                updateMedical = medicallist[index+1];
            }
        }else if( type && type == 'low' ){
            if( index != 0 ){
                updateMedical = medicallist[index-1];
            }
        }

        if( name && name == 'mapfreMedical' && (updateMedical == '$20,000/$100,000' || updateMedical == '$15,000/$75,000')){
            updateMedical = null;
        }

        if( name && name == 'qualitasMedical' && updateMedical && updateMedical != null ){
            component.set("v.qualitasMedical", updateMedical );
        }else if( name && name == 'mapfreMedical' && updateMedical && updateMedical != null ){
            component.set("v.mapfreMedical", updateMedical );
        }else if( name && name == 'chubbMedical' && updateMedical && updateMedical != null ){
            component.set("v.chubbMedical", updateMedical );
        }

        if( updateMedical && updateMedical != null ){
            helper.getquickQuoteData( component, event, helper );
        }
    },

    fetchRateData :function (component, event, helper) {
        var quoteRecord = component.get("v.quoteRecord");
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
        startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());

        let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']); 
        endDayForCoverage = new Date (endDayForCoverage.getUTCFullYear(), endDayForCoverage.getUTCMonth(), endDayForCoverage.getUTCDate());

        if( startDayForCoverage != undefined ){
            var  endMinDate = startDayForCoverage;
            endMinDate = endMinDate.setDate(endMinDate.getDate() + 1);
            component.set("v.endMinDate", $A.localizationService.formatDate(endMinDate, "YYYY-MM-DD"));
        }
        
        var Difference_In_Time = endDayForCoverage.getTime() - startDayForCoverage.getTime();
        var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
        if( Difference_In_Days != null && Difference_In_Days > 365 ){
            helper.showToast('Total days cannot equal more than 365', 'error');
            return ;
        }
        
        if (Difference_In_Days != null && Difference_In_Days == 0) {
            helper.showToast('Total days cannot be less than 1', 'error');
            return;
        }

        helper.getquickQuoteData( component, event, helper );
    },
    
    openModel : function(component, event, helper) {
        var communityUser = component.get("v.communityUser");
        if( !communityUser ){
            console.log('--communityUser open popup----');
            component.set("v.saveQuotePop", true);
        }else{
            helper.showToast( 'Quote Saved!', 'success');
        }
	},
    
    openPurchaseModal: function (c, e, h) {
        let communityUser = c.get("v.communityUser");
        let name = e.target.name;
        c.set("v.clickedItemValue", name);
        console.log("Name ----> ", name);
        if (!communityUser) {
            c.set("v.purchaseQuotePop", true);
        }
    },
	
    closeModel : function (component, event, helper) {
        component.set("v.saveQuotePop", false);
    },
    
    closePurchaseModel: function (c, e, h) {
        c.set("v.purchaseQuotePop", false);
    },

    updateLibilityValue : function (component, event, helper) {
        helper.calculateRate( component, event, helper );
        helper.calculateCoverageDetail( component, event, helper );
    }
})