public class JSON2GetYearsApex {

	public class Years {
		public String min_year;
		public String max_year;
	}

	public Years Years;

	
	public static JSON2GetYearsApex parse(String json) {
		return (JSON2GetYearsApex) System.JSON.deserialize(json, JSON2GetYearsApex.class);
	}
}