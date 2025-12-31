public class JSON2MakesApex {
 /*public List<Makes> Makes;
	public class Makes {
		public String make_id;
		public String make_display;
		public String make_is_common;
		public String make_country;
	}*/

    public Integer Count;
    public String Message;
    public String SearchCriteria;
    public List<Result> Results;
    
    public class Result {
        public Integer MakeId;
        public String MakeName;
        public Integer VehicleTypeId;
        public String VehicleTypeName;
    }
	
	public static JSON2MakesApex parse(String json) {
		return (JSON2MakesApex) System.JSON.deserialize(json, JSON2MakesApex.class);
	}
}