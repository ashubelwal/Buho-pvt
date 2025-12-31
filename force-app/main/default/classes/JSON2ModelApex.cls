public class JSON2ModelApex {

	/*public List<Models> Models;

	public class Models {
		public String model_name;
		public String model_make_id;
	} */

    public Integer Count;
    public String Message;
    public String SearchCriteria;
    public List<Result> Results;
    
    public class Result {
        public Integer Make_ID;
        public String Make_Name;
        public Integer Model_ID;
        public String Model_Name;
    }
	
	public static JSON2ModelApex parse(String json) {
		return (JSON2ModelApex) System.JSON.deserialize(json, JSON2ModelApex.class);
	}
}