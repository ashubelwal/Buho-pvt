// public with sharing class AnnualRenewalReportController {

//     public class RenewalRow implements Comparable {
//         @AuraEnabled public Integer month;
//         @AuraEnabled public Integer targetRenewal = 0;
//         @AuraEnabled public Integer renewed = 0;

//         @AuraEnabled
//         public Decimal getRenewedPct() {
//             if (targetRenewal == 0) return 0;
//             Decimal pct = (Decimal.valueOf(renewed) / targetRenewal) * 100;
//             return pct > 100 ? 100 : pct;
//         }

//         // Implementa Comparable para ordenar por mes
//         public Integer compareTo(Object obj) {
//             RenewalRow other = (RenewalRow) obj;
//             if (this.month == null) return -1;
//             if (other.month == null) return 1;
//             if (this.month < other.month) return -1;
//             if (this.month > other.month) return 1;
//             return 0;
//         }
//     }

//     @AuraEnabled(cacheable=true)
//     public static List<RenewalRow> getAnnualRenewalReportPartial() {
//         Map<Integer, RenewalRow> dataByMonth = new Map<Integer, RenewalRow>();

//         Date start2025 = Date.newInstance(2025, 1, 1);
//         Date end2025 = Date.newInstance(2025, 12, 31);

//         Date start2026 = Date.newInstance(2026, 1, 1);
//         Date end2026 = Date.newInstance(2026, 12, 31);

//         // 1) Target Renewal: pólizas con End_Date__c dentro 2025 y Term = 'Annual'
//         List<AggregateResult> targetResults = [
//             SELECT CALENDAR_MONTH(End_Date__c) month, COUNT(Id) cnt
//             FROM Policy__c
//             WHERE End_Date__c >= :start2025 AND End_Date__c <= :end2025
//               AND Term__c = 'Annual'
//             GROUP BY CALENDAR_MONTH(End_Date__c)
//         ];

//         for (AggregateResult ar : targetResults) {
//             Integer monthNum = (Integer)ar.get('month');
//             Integer count = (Integer)ar.get('cnt');

//             if (!dataByMonth.containsKey(monthNum)) {
//                 dataByMonth.put(monthNum, new RenewalRow());
//                 dataByMonth.get(monthNum).month = monthNum;
//             }
//             dataByMonth.get(monthNum).targetRenewal = count;
//         }

//         // 2) Renewed: vehículos con pólizas expirando 2026 + vehicle_coverage_status__c = 'insured-renew-annual'
//         // y póliza relacionada con Term = 'Annual'
//         // Aquí agrupamos por el mes de Policy.CreatedDate en lugar de Policy_Expiration__c de vehículo

//         List<Vehicle__c> vehicles = [
//             SELECT Id, Policy_Expiration__c, vehicle_coverage_status__c, Policy__c,
//                 Policy__r.CreatedDate
//             FROM Vehicle__c
//             WHERE Policy_Expiration__c >= :start2026 AND Policy_Expiration__c <= :end2026
//               AND vehicle_coverage_status__c = 'insured-renew-annual'
//               AND Policy__c != null
//         ];

//         // Filtramos las policies anuales
//         Set<Id> policyIds = new Set<Id>();
//         for (Vehicle__c v : vehicles) {
//             policyIds.add(v.Policy__c);
//         }

//         Map<Id, Date> policyCreatedDates = new Map<Id, Date>();
//         for (Policy__c p : [
//             SELECT Id, CreatedDate, Term__c
//             FROM Policy__c
//             WHERE Id IN :policyIds AND Term__c = 'Annual'
//         ]) {
//             policyCreatedDates.put(p.Id, p.CreatedDate.date()); // solo la fecha, sin tiempo
//         }

//         Map<Integer, Integer> renewedByMonth = new Map<Integer, Integer>();
//         for (Vehicle__c v : vehicles) {
//             if (policyCreatedDates.containsKey(v.Policy__c)) {
//                 Date createdDate = policyCreatedDates.get(v.Policy__c);
//                 Integer monthNum = createdDate.month();
//                 if (!renewedByMonth.containsKey(monthNum)) {
//                     renewedByMonth.put(monthNum, 0);
//                 }
//                 renewedByMonth.put(monthNum, renewedByMonth.get(monthNum) + 1);
//             }
//         }

//         for (Integer m : renewedByMonth.keySet()) {
//             if (!dataByMonth.containsKey(m)) {
//                 dataByMonth.put(m, new RenewalRow());
//                 dataByMonth.get(m).month = m;
//             }
//             dataByMonth.get(m).renewed = renewedByMonth.get(m);
//         }

//         // Asegurar fila para cada mes
//         for (Integer m = 1; m <= 12; m++) {
//             if (!dataByMonth.containsKey(m)) {
//                 RenewalRow r = new RenewalRow();
//                 r.month = m;
//                 dataByMonth.put(m, r);
//             }
//         }

//         List<RenewalRow> result = new List<RenewalRow>(dataByMonth.values());
//         result.sort();

//         return result;
//     }
// }

// HARDCODED DATES ---------------------------------------------------------
// public with sharing class AnnualRenewalReportController {

//     public class RenewalRow implements Comparable {
//         @AuraEnabled public Integer month;
//         @AuraEnabled public Integer targetRenewal = 0;
//         @AuraEnabled public Integer renewed = 0;
//         @AuraEnabled public Integer ineligible = 0;
//         @AuraEnabled public Integer pending = 0;

//         @AuraEnabled
//         public Decimal getRenewedPct() {
//             if (targetRenewal == 0) return 0;
//             Decimal pct = (Decimal.valueOf(renewed) / targetRenewal) * 100;
//             return pct > 100 ? 100 : pct;
//         }
//         @AuraEnabled
//         public Decimal getIneligiblePct() {
//             if (targetRenewal == 0) return 0;
//             Decimal pct = (Decimal.valueOf(ineligible) / targetRenewal) * 100;
//             return pct > 100 ? 100 : pct;
//         }
//         @AuraEnabled
//         public Decimal getPendingPct() {
//             if (targetRenewal == 0) return 0;
//             Decimal pct = (Decimal.valueOf(pending) / targetRenewal) * 100;
//             return pct > 100 ? 100 : pct;
//         }

//         // Implementa Comparable para ordenar por mes
//         public Integer compareTo(Object obj) {
//             RenewalRow other = (RenewalRow) obj;
//             if (this.month == null) return -1;
//             if (other.month == null) return 1;
//             if (this.month < other.month) return -1;
//             if (this.month > other.month) return 1;
//             return 0;
//         }
//     }

//     @AuraEnabled(cacheable=true)
//     public static List<RenewalRow> getAnnualRenewalReportPartial() {
//         Map<Integer, RenewalRow> dataByMonth = new Map<Integer, RenewalRow>();

//         Date start2025 = Date.newInstance(2025, 1, 1);
//         Date end2025 = Date.newInstance(2025, 12, 31);

//         Date start2026 = Date.newInstance(2026, 1, 1);
//         Date end2026 = Date.newInstance(2026, 12, 31);

//         // 1) Target Renewal: pólizas con End_Date__c dentro 2025 y Term = 'Annual'
//         List<AggregateResult> targetResults = [
//             SELECT CALENDAR_MONTH(End_Date__c) month, COUNT(Id) cnt
//             FROM Policy__c
//             WHERE End_Date__c >= :start2025 AND End_Date__c <= :end2025
//               AND Term__c = 'Annual'
//             GROUP BY CALENDAR_MONTH(End_Date__c)
//         ];
//         for (AggregateResult ar : targetResults) {
//             Integer monthNum = (Integer)ar.get('month');
//             Integer count = (Integer)ar.get('cnt');
//             if (!dataByMonth.containsKey(monthNum)) {
//                 dataByMonth.put(monthNum, new RenewalRow());
//                 dataByMonth.get(monthNum).month = monthNum;
//             }
//             dataByMonth.get(monthNum).targetRenewal = count;
//         }

//         // 2) Renewed: vehículos con pólizas expirando 2026, vehicle_coverage_status__c = 'insured-renew-annual'
//         // y póliza Term = 'Annual', agrupados por mes de Policy.CreatedDate
//         List<Vehicle__c> vehicles = [
//             SELECT Id, Policy_Expiration__c, vehicle_coverage_status__c, Policy__c,
//                 Policy__r.CreatedDate
//             FROM Vehicle__c
//             WHERE Policy_Expiration__c >= :start2026 AND Policy_Expiration__c <= :end2026
//               AND vehicle_coverage_status__c = 'insured-renew-annual'
//               AND Policy__c != null
//         ];
//         Set<Id> policyIds = new Set<Id>();
//         for (Vehicle__c v : vehicles) {
//             policyIds.add(v.Policy__c);
//         }
//         Map<Id, Date> policyCreatedDates = new Map<Id, Date>();
//         for (Policy__c p : [
//             SELECT Id, CreatedDate, Term__c
//             FROM Policy__c
//             WHERE Id IN :policyIds AND Term__c = 'Annual'
//         ]) {
//             policyCreatedDates.put(p.Id, p.CreatedDate.date());
//         }
//         Map<Integer, Integer> renewedByMonth = new Map<Integer, Integer>();
//         for (Vehicle__c v : vehicles) {
//             if (policyCreatedDates.containsKey(v.Policy__c)) {
//                 Integer monthNum = policyCreatedDates.get(v.Policy__c).month();
//                 Integer currentCount = 0;
//                 if (renewedByMonth.containsKey(monthNum)) {
//                     currentCount = renewedByMonth.get(monthNum);
//                 }
//                 renewedByMonth.put(monthNum, currentCount + 1);
//             }
//         }
//         for (Integer m : renewedByMonth.keySet()) {
//             if (!dataByMonth.containsKey(m)) {
//                 dataByMonth.put(m, new RenewalRow());
//                 dataByMonth.get(m).month = m;
//             }
//             dataByMonth.get(m).renewed = renewedByMonth.get(m);
//         }

//         // 3) Ineligible: vehículos sin seguro (vehicle_coverage_status__c = 'uninsured') con ciertas razones,
//         // pólizas que expiran en 2025, Term = Annual, agrupados por Policy_Expiration__c.month()
//         List<AggregateResult> ineligibleResults = [
//             SELECT CALENDAR_MONTH(Policy_Expiration__c) month, COUNT(Id) cnt
//             FROM Vehicle__c
//             WHERE Policy_Expiration__c >= :start2025 AND Policy_Expiration__c <= :end2025
//               AND vehicle_coverage_status__c = 'uninsured'
//               AND Uninsured_Reason__c IN ('Transferred Ownership', 'Destroyed', 'Stolen', 'No Longer in Mexico')
//               AND Policy__r.Term__c = 'Annual'
//             GROUP BY CALENDAR_MONTH(Policy_Expiration__c)
//         ];
//         for (AggregateResult ar : ineligibleResults) {
//             Integer monthNum = (Integer)ar.get('month');
//             Integer count = (Integer)ar.get('cnt');
//             if (!dataByMonth.containsKey(monthNum)) {
//                 dataByMonth.put(monthNum, new RenewalRow());
//                 dataByMonth.get(monthNum).month = monthNum;
//             }
//             dataByMonth.get(monthNum).ineligible = count;
//         }

//         // 4) Pending: vehículos sin seguro con ciertas otras razones,
//         // pólizas que expiran en 2025, Term = Annual, agrupados por Policy_Expiration__c.month()
//         List<AggregateResult> pendingResults = [
//             SELECT CALENDAR_MONTH(Policy_Expiration__c) month, COUNT(Id) cnt
//             FROM Vehicle__c
//             WHERE Policy_Expiration__c >= :start2025 AND Policy_Expiration__c <= :end2025
//               AND vehicle_coverage_status__c = 'uninsured'
//               AND Uninsured_Reason__c IN ('Will Renew Later', 'Unknown')
//               AND Policy__r.Term__c = 'Annual'
//             GROUP BY CALENDAR_MONTH(Policy_Expiration__c)
//         ];
//         for (AggregateResult ar : pendingResults) {
//             Integer monthNum = (Integer)ar.get('month');
//             Integer count = (Integer)ar.get('cnt');
//             if (!dataByMonth.containsKey(monthNum)) {
//                 dataByMonth.put(monthNum, new RenewalRow());
//                 dataByMonth.get(monthNum).month = monthNum;
//             }
//             dataByMonth.get(monthNum).pending = count;
//         }

//         // Asegurar fila para cada mes
//         for (Integer m = 1; m <= 12; m++) {
//             if (!dataByMonth.containsKey(m)) {
//                 RenewalRow r = new RenewalRow();
//                 r.month = m;
//                 dataByMonth.put(m, r);
//             }
//         }

//         List<RenewalRow> result = new List<RenewalRow>(dataByMonth.values());
//         result.sort();

//         return result;
//     }
// }
// HARDCODED DATES ---------------------------------------------------------

//DINAMIC DATES ---------------------------------------------------------
public with sharing class AnnualRenewalReportController {

    public class RenewalRow implements Comparable {
        @AuraEnabled public Integer month;
        @AuraEnabled public Integer targetRenewal = 0;
        @AuraEnabled public Integer renewed = 0;
        @AuraEnabled public Integer ineligible = 0;
        @AuraEnabled public Integer pending = 0;
        @AuraEnabled public Integer lost = 0;  // Nueva columna Lost

        @AuraEnabled
        public Decimal getRenewedPct() {
            if (targetRenewal == 0) return 0;
            Decimal pct = (Decimal.valueOf(renewed) / targetRenewal) * 100;
            return pct > 100 ? 100 : pct;
        }
        @AuraEnabled
        public Decimal getIneligiblePct() {
            if (targetRenewal == 0) return 0;
            Decimal pct = (Decimal.valueOf(ineligible) / targetRenewal) * 100;
            return pct > 100 ? 100 : pct;
        }
        @AuraEnabled
        public Decimal getPendingPct() {
            if (targetRenewal == 0) return 0;
            Decimal pct = (Decimal.valueOf(pending) / targetRenewal) * 100;
            return pct > 100 ? 100 : pct;
        }
        @AuraEnabled
        public Decimal getLostPct() {
            if (targetRenewal == 0) return 0;
            Decimal pct = (Decimal.valueOf(lost) / targetRenewal) * 100;
            return pct > 100 ? 100 : pct;
        }

        // Ordenar por mes
        public Integer compareTo(Object obj) {
            RenewalRow other = (RenewalRow) obj;
            if (this.month == null) return -1;
            if (other.month == null) return 1;
            if (this.month < other.month) return -1;
            if (this.month > other.month) return 1;
            return 0;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<RenewalRow> getAnnualRenewalReportPartial() {
        Map<Integer, RenewalRow> dataByMonth = new Map<Integer, RenewalRow>();

        Integer currentYear = Date.today().year();

        Date startCurrentYear = Date.newInstance(currentYear, 1, 1);
        Date endCurrentYear = Date.newInstance(currentYear, 12, 31);

        Date startNextYear = Date.newInstance(currentYear + 1, 1, 1);
        Date endNextYear = Date.newInstance(currentYear + 1, 12, 31);

        // 1) Target Renewal: pólizas con End_Date__c dentro del año actual y Term = 'Annual'
        List<AggregateResult> targetResults = [
            SELECT CALENDAR_MONTH(End_Date__c) month, COUNT(Id) cnt
            FROM Policy__c
            WHERE End_Date__c >= :startCurrentYear AND End_Date__c <= :endCurrentYear
              AND Term__c = 'Annual'
            GROUP BY CALENDAR_MONTH(End_Date__c)
        ];
        for (AggregateResult ar : targetResults) {
            Integer monthNum = (Integer)ar.get('month');
            Integer count = (Integer)ar.get('cnt');
            if (!dataByMonth.containsKey(monthNum)) {
                dataByMonth.put(monthNum, new RenewalRow());
                dataByMonth.get(monthNum).month = monthNum;
            }
            dataByMonth.get(monthNum).targetRenewal = count;
        }

        // 2) Renewed: vehículos con pólizas expirando en el siguiente año, vehicle_coverage_status__c = 'insured-renew-annual'
        // y póliza Term = 'Annual', agrupados por mes de Policy.CreatedDate
        List<Vehicle__c> vehicles = [
            SELECT Id, Policy_Expiration__c, vehicle_coverage_status__c, Policy__c,
                Policy__r.CreatedDate
            FROM Vehicle__c
            WHERE Policy_Expiration__c >= :startNextYear AND Policy_Expiration__c <= :endNextYear
              AND vehicle_coverage_status__c = 'insured-renew-annual'
              AND Policy__c != null
        ];
        Set<Id> policyIds = new Set<Id>();
        for (Vehicle__c v : vehicles) {
            policyIds.add(v.Policy__c);
        }
        Map<Id, Date> policyCreatedDates = new Map<Id, Date>();
        for (Policy__c p : [
            SELECT Id, CreatedDate, Term__c
            FROM Policy__c
            WHERE Id IN :policyIds AND Term__c = 'Annual'
        ]) {
            policyCreatedDates.put(p.Id, p.CreatedDate.date());
        }
        Map<Integer, Integer> renewedByMonth = new Map<Integer, Integer>();
        for (Vehicle__c v : vehicles) {
            if (policyCreatedDates.containsKey(v.Policy__c)) {
                Integer monthNum = policyCreatedDates.get(v.Policy__c).month();
                Integer currentCount = 0;
                if (renewedByMonth.containsKey(monthNum)) {
                    currentCount = renewedByMonth.get(monthNum);
                }
                renewedByMonth.put(monthNum, currentCount + 1);
            }
        }
        for (Integer m : renewedByMonth.keySet()) {
            if (!dataByMonth.containsKey(m)) {
                dataByMonth.put(m, new RenewalRow());
                dataByMonth.get(m).month = m;
            }
            dataByMonth.get(m).renewed = renewedByMonth.get(m);
        }

        // 3) Ineligible: vehículos sin seguro con ciertas razones, pólizas que expiran en el año actual, Term = Annual
        List<AggregateResult> ineligibleResults = [
            SELECT CALENDAR_MONTH(Policy_Expiration__c) month, COUNT(Id) cnt
            FROM Vehicle__c
            WHERE Policy_Expiration__c >= :startCurrentYear AND Policy_Expiration__c <= :endCurrentYear
              AND vehicle_coverage_status__c = 'uninsured'
              AND Uninsured_Reason__c IN ('Transferred Ownership', 'Destroyed', 'Stolen', 'No Longer in Mexico')
              AND Policy__r.Term__c = 'Annual'
            GROUP BY CALENDAR_MONTH(Policy_Expiration__c)
        ];
        for (AggregateResult ar : ineligibleResults) {
            Integer monthNum = (Integer)ar.get('month');
            Integer count = (Integer)ar.get('cnt');
            if (!dataByMonth.containsKey(monthNum)) {
                dataByMonth.put(monthNum, new RenewalRow());
                dataByMonth.get(monthNum).month = monthNum;
            }
            dataByMonth.get(monthNum).ineligible = count;
        }

        // 4) Pending: vehículos sin seguro con otras razones, pólizas que expiran en el año actual, Term = Annual
        List<AggregateResult> pendingResults = [
            SELECT CALENDAR_MONTH(Policy_Expiration__c) month, COUNT(Id) cnt
            FROM Vehicle__c
            WHERE Policy_Expiration__c >= :startCurrentYear AND Policy_Expiration__c <= :endCurrentYear
              AND vehicle_coverage_status__c = 'uninsured'
              AND Uninsured_Reason__c IN ('Will Renew Later', 'Unknown')
              AND Policy__r.Term__c = 'Annual'
            GROUP BY CALENDAR_MONTH(Policy_Expiration__c)
        ];
        for (AggregateResult ar : pendingResults) {
            Integer monthNum = (Integer)ar.get('month');
            Integer count = (Integer)ar.get('cnt');
            if (!dataByMonth.containsKey(monthNum)) {
                dataByMonth.put(monthNum, new RenewalRow());
                dataByMonth.get(monthNum).month = monthNum;
            }
            dataByMonth.get(monthNum).pending = count;
        }

        // 5) Lost: vehículos sin seguro con razones 'Insured Elsewhere' o 'Lost', pólizas expiran en año actual, Term = Annual
        List<AggregateResult> lostResults = [
            SELECT CALENDAR_MONTH(Policy_Expiration__c) month, COUNT(Id) cnt
            FROM Vehicle__c
            WHERE Policy_Expiration__c >= :startCurrentYear AND Policy_Expiration__c <= :endCurrentYear
              AND vehicle_coverage_status__c = 'uninsured'
              AND Uninsured_Reason__c IN ('Insured Elsewhere', 'Lost')
              AND Policy__r.Term__c = 'Annual'
            GROUP BY CALENDAR_MONTH(Policy_Expiration__c)
        ];
        for (AggregateResult ar : lostResults) {
            Integer monthNum = (Integer)ar.get('month');
            Integer count = (Integer)ar.get('cnt');
            if (!dataByMonth.containsKey(monthNum)) {
                dataByMonth.put(monthNum, new RenewalRow());
                dataByMonth.get(monthNum).month = monthNum;
            }
            dataByMonth.get(monthNum).lost = count;
        }

        // Asegurar fila para cada mes
        for (Integer m = 1; m <= 12; m++) {
            if (!dataByMonth.containsKey(m)) {
                RenewalRow r = new RenewalRow();
                r.month = m;
                dataByMonth.put(m, r);
            }
        }

        List<RenewalRow> result = new List<RenewalRow>(dataByMonth.values());
        result.sort();

        // Calcular fila total
        RenewalRow totalRow = new RenewalRow();
        totalRow.month = null; // identificador para fila total

        for (RenewalRow r : result) {
            totalRow.targetRenewal += r.targetRenewal;
            totalRow.renewed += r.renewed;
            totalRow.ineligible += r.ineligible;
            totalRow.pending += r.pending;
            totalRow.lost += r.lost;
        }

        result.add(totalRow);

        return result;
    }
}