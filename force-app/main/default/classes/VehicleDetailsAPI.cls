/**
 * VehicleDetailsAPI Apex class provides functionalities for fetching car details such as years, makes, and models from external APIs or internal configurations.
 * This class includes authentication, API callout handling, and fallback mechanisms for data retrieval.
 *
 * Features:
 * - Fetch car years range from configuration.
 * - Retrieve car makes and models using external API or predefined endpoints.
 * - Custom error handling with CustomErrorExceptionHandlerException for better debugging and fault tolerance.
 * - Modular design for future scalability and maintainability
 */
public with sharing class VehicleDetailsAPI {
    
    /**
     * Wrapper class for Make API response.
     */
    public class CarAPIMake {
        public List<MakeData> data;
    }
    
    /**
     * Data structure for each make.
     */
    public class MakeData {
        public String name;
    }
    
    /**
     * Wrapper class for API Authentication.
     */
    public class CarAPIAuthWrap {
        public String api_token;
        public String api_secret;
        
        /**
         * Constructor to initialize authentication details from configuration.
         */
        public CarAPIAuthWrap() {
            try {
                this.api_token = CarApi_Config__c.getOrgDefaults().Client_Token__c;
                this.api_secret = CarApi_Config__c.getOrgDefaults().Client_Secret__c;
            } catch (Exception e) {
                throw new CustomErrorExceptionHandlerException('Error initializing CarAPIAuthWrap: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Fetches a list of car years from the current year to a configured minimum year.
     * @return List of years in key-value format.
     */
    @AuraEnabled
    public static List<Object> getYears() {
        try {
            Integer minYear = Integer.valueOf(Label.URL_To_Get_Years);
            Integer maxYear = System.today().year();
            
            List<Object> yearsList = new List<Object>();
            for (Integer i = maxYear + 1; i >= minYear; i--) {
                yearsList.add(new Map<String, Object>{ 'label' => String.valueOf(i), 'value' => String.valueOf(i) });
            }
            return yearsList;
        } catch (Exception e) {
            throw new CustomErrorExceptionHandlerException('Error fetching years: ' + e.getMessage());
        }
    }
    
    /**
     * Fetches the authentication token from the Car API.
     * @return JWT token as a String.
     */
    public static String fetchCarAPIAuthToken() {
        try {
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('https://carapi.app/api/auth/login');
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(120000);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('accept', 'text/plain');
            httpRequest.setBody(JSON.serialize(new CarAPIAuthWrap()));
            
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            String jwtToken = httpResponse.getBody();
            return String.isNotBlank(jwtToken) ? jwtToken : null;
        } catch (Exception e) {
            throw new CustomErrorExceptionHandlerException('Error fetching Car API Auth Token: ' + e.getMessage());
        }
    }
    
    /**
     * Fetches car makes from the Car API for a given year.
     * @param year The year for which car makes are to be fetched.
     * @return List of car makes in key-value format.
     */
    public static List<Object> getMakesFromCarAPI(String year) {
        try {
            List<Object> makesList = new List<Object>();
            
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('https://carapi.app/api/makes?year=' + year);
            httpRequest.setMethod('GET');
            httpRequest.setTimeout(120000);
            httpRequest.setHeader('accept', 'application/json');
            
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            
            String makeResponse = httpResponse.getBody();
            if (String.isNotBlank(makeResponse)) {
                CarAPIMake makes = (CarAPIMake) JSON.deserialize(makeResponse, CarAPIMake.class);
                for (MakeData data : makes?.data) {
                    makesList.add(new Map<String, String>{ 'label' => data.name, 'value' => data.name });
                }
            }
            return makesList;
        } catch (Exception e) {
            throw new CustomErrorExceptionHandlerException('Error fetching car makes from Car API: ' + e.getMessage()+e.getStackTraceString());
        }
    }
    
    /**
     * Fetches car models for a given year and make.
     * @param year The year of the car.
     * @param make The make of the car.
     * @return List of car models in key-value format.
     */
    @AuraEnabled
    public static List<Object> fetchModelsFromCarAPI(String year, String make) {
        System.debug('@@@year=>'+year+' @@make=>'+make);
        try {
            List<Object> modelList = new List<Object>();
            Integer yearInteger= Integer.valueOf(year);
            System.debug('@@@year=>'+yearInteger+' @@make=>'+make);
            String jwtToken = fetchCarAPIAuthToken();
            if (String.isNotBlank(jwtToken)) {
                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setEndpoint('https://carapi.app/api/models?year=' + String.valueOf(yearInteger) + '&make=' + make);
                httpRequest.setMethod('GET');
                httpRequest.setTimeout(120000);
                httpRequest.setHeader('accept', 'application/json');
                httpRequest.setHeader('Authorization', 'Bearer ' + jwtToken);
                
                Http http = new Http();
                HttpResponse httpResponse = http.send(httpRequest);
                String response = httpResponse.getBody();
                System.debug('response@@@'+response);
                if (String.isNotBlank(response)) {
                    CarAPIMake models = (CarAPIMake) JSON.deserialize(response, CarAPIMake.class);
                    for (MakeData model : models?.data) {
                        modelList.add(new Map<String, Object>{ 'label' => model.name, 'value' => model.name });
                    }
                }
            }
            return modelList;
        } catch (Exception e) {
            throw new CustomErrorExceptionHandlerException('Error fetching car models: ' + e.getMessage()+e.getStackTraceString());
        }
    }
}