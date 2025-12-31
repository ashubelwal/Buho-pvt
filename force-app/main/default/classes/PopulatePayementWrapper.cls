public class PopulatePayementWrapper {
   		public qualitasData qualitasData{get;set;}
		public MapfreData MapfreData{get;set;}
		public ChubbData ChubbData{get;set;}
		public Integer days{get;set;}
	public class travelAssistance{
		public Decimal Daily{get;set;}
		public Decimal Days180{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Days90{get;set;}
	}
	
	public class TotalTheft{
		public Decimal Days180{get;set;}
		public Decimal Days90{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Semi_annual{get;set;}
	}
	public class TotalPremiumLiabilityOnly{
		public Decimal Annual{get;set;}
		public Decimal Semi_annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class TotalCompleteCoverage{
		public Decimal Annual{get;set;}
		public Decimal Semi_annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class TheftDeductible{
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Semi_annual{get;set;}
	}
	public class qualitasData{
		public businessSurcharge businessSurcharge{get;set;}
		public brokerFee brokerFee{get;set;}
		public CompleteCoverageLimited CompleteCoverageLimited{get;set;}
		public ageSurcharge ageSurcharge{get;set;}
		public CompleteCoveragePremium CompleteCoveragePremium{get;set;}
		public Liability Liability{get;set;}
		public LiabilityOnlyLimitedTerritory LiabilityOnlyLimitedTerritory{get;set;}
		public LegalandRoadside LegalandRoadside{get;set;}
		public LiabilityOnlyPremium LiabilityOnlyPremium{get;set;}
		public IVALimitedCoverage IVALimitedCoverage{get;set;}
		public Medical Medical{get;set;}
		public IVALiabilityOnly IVALiabilityOnly{get;set;}
		public PhysicalDamage PhysicalDamage{get;set;}
		public IVACompleteCoverage IVACompleteCoverage{get;set;}
		public Boolean showQualitas{get;set;}
		public DamageDeductible DamageDeductible{get;set;}
		public TheftDeductible TheftDeductible{get;set;}
		public TotalTheft TotalTheft{get;set;}
		public Decimal totalvalue{get;set;}
		public TotalPremiumLiabilityOnly TotalPremiumLiabilityOnly{get;set;}
		//public decimal TowedUnitPhysicalDamage{get;set;}
        public TowedUnitPhysicalDamage TowedUnitPhysicalDamage{get;set;}
		public TotalCompleteCoverage TotalCompleteCoverage{get;set;}
		public TowedUnitTotalTheft TowedUnitTotalTheft{get;set;}
	}
    
    
    public class TowedUnitPhysicalDamage{
		public Decimal Daily{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Semi_annual{get;set;}
	}
    
	public class PlatinumEndorsementLiabilityOnly{
		public Decimal Semi_annual{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class PlatinumEndorsementCompleteCoverage{
		public Decimal Semi_annual{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class physicalDamages{
		public Decimal Days90{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Days180{get;set;}
	}
	public class PhysicalDamage{
		public Decimal Semi_annual{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class medicalPayments{
		public Decimal Daily{get;set;}
		public Decimal Days180{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Days90{get;set;}
	}
	public class Medical{
		public Decimal Daily{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Semi_annual{get;set;}
	}
	public class MaxCoverageTotal{
		public Decimal Days90{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Days180{get;set;}
	}
	public class MapfreData{
		public totalTheft totalTheft{get;set;}
		public liabilityOnlyTotal liabilityOnlyTotal{get;set;}
		public limitedCoverageTotal limitedCoverageTotal{get;set;}
		public liability liability{get;set;}
		public MaxCoverageTotal MaxCoverageTotal{get;set;}
		public legalAssist legalAssist{get;set;}
		public medicalPayments medicalPayments{get;set;}
		public IVAliabilityOnlyTotal IVAliabilityOnlyTotal{get;set;}
		public physicalDamages physicalDamages{get;set;}
		public IVAFullCoverage IVAFullCoverage{get;set;}
		public Boolean showMapfre{get;set;}
		public fullCoverageTotal fullCoverageTotal{get;set;}
		public Decimal totalvalue{get;set;}
		public deductiblesTotalTheft deductiblesTotalTheft{get;set;}
		public TowedUnitPhysicalDamage TowedUnitPhysicalDamage{get;set;}
		public deductiblesPhysicalDamages deductiblesPhysicalDamages{get;set;}
		public TowedUnitTotalTheft TowedUnitTotalTheft{get;set;}
		public brokerFee brokerFee{get;set;}
		public travelAssistance travelAssistance{get;set;}
	}
	public class limitedCoverageTotal{
		public Decimal Daily{get;set;}
		public Decimal Days180{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Days90{get;set;}
	}
	public class liabilityOnlyTotal{
		public Decimal Daily{get;set;}
		public Decimal Days90{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Days180{get;set;}
	}
	public class LiabilityOnlyPremium{
		public Decimal Semi_annual{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class LiabilityOnlyLimitedTerritory{
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Semi_annual{get;set;}
	}
	
	public class Liability{
		public Decimal Days90{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Days180{get;set;}
		public Decimal Semi_annual{get;set;}
	}
	public class legalAssist{
		public Decimal Days90{get;set;}
		public Decimal Days180{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Annual{get;set;}
	}
	public class LegalandRoadside{
		public Decimal Semi_annual{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class IVALimitedCoverage{
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Semi_annual{get;set;}
	}
	public class IVAliabilityOnlyTotal{
		public Decimal Days180{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Days90{get;set;}
	}
	public class IVALiabilityOnly{
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Semi_annual{get;set;}
	}
	public class IVAFullCoverage{
		public Decimal Daily{get;set;}
		public Decimal Days90{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Days180{get;set;}
	}
	public class IVACompleteCoverage{
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Semi_annual{get;set;}
	}
	public class fullCoverageTotal{
		public Decimal Days180{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Days90{get;set;}
	}
	public class deductiblesTotalTheft{
		public Decimal Days90{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Days180{get;set;}
	}
	public class deductiblesPhysicalDamages{
		public Decimal Days180{get;set;}
		public Decimal Days90{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class DamageDeductible{
		public Decimal Semi_annual{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class CompleteCoveragePremium{
		public Decimal Annual{get;set;}
		public Decimal Semi_annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class CompleteCoverageLimited{
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Semi_annual{get;set;}
	}
	public class ChubbData{
		public TotalCompleteCoverage TotalCompleteCoverage{get;set;}
		public PhysicalDamage PhysicalDamage{get;set;}
		public PlatinumEndorsementCompleteCoverage PlatinumEndorsementCompleteCoverage{get;set;}
		public Medical Medical{get;set;}
		public PlatinumEndorsementLiabilityOnly PlatinumEndorsementLiabilityOnly{get;set;}
		public LiabilityOnlyPremium LiabilityOnlyPremium{get;set;}
		public Boolean showChubb{get;set;}
		public Liability Liability{get;set;}
		public TotalPremiumLiabilityOnly TotalPremiumLiabilityOnly{get;set;}
		public LegalandRoadside LegalandRoadside{get;set;}
		public TotalTheft TotalTheft{get;set;}
		public DamageDeductible DamageDeductible{get;set;}
		public TowedUnitPhysicalDamage TowedUnitPhysicalDamage{get;set;}
		public CompleteCoveragePremium CompleteCoveragePremium{get;set;}
		public TowedUnitTotalTheft TowedUnitTotalTheft{get;set;}
		public brokerFee brokerFee{get;set;}
		public BajaSonaraDiscountComplete BajaSonaraDiscountComplete{get;set;}
		public BajaSonaraDiscountLiabilityOnly BajaSonaraDiscountLiabilityOnly{get;set;}
	}
    public class TowedUnitTotalTheft{
        public Decimal Daily{get;set;}
    }
    
	public class businessSurcharge{
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Semi_annual{get;set;}
	}
	public class brokerFee{
		public Integer Days90{get;set;}
		public Integer Semi_annual{get;set;}
		public Integer Annual{get;set;}
		public Integer Daily{get;set;}
		public Integer Days180{get;set;}
		
	}
	public class BajaSonaraDiscountLiabilityOnly{
		public Decimal Semi_annual{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class BajaSonaraDiscountComplete{
		public Decimal Semi_annual{get;set;}
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
	}
	public class ageSurcharge{
		public Decimal Annual{get;set;}
		public Decimal Daily{get;set;}
		public Decimal Semi_annual{get;set;}
	}
}