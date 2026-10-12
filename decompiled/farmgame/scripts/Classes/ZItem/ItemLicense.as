package Classes.ZItem
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   
   public class ItemLicense
   {
      
      private static const UNSET:int = -1;
      
      private static const FALSE:int = 0;
      
      private static const TRUE:int = 1;
      
      private var m_type:String;
      
      private var m_code:String;
      
      private var m_duration:int;
      
      private var m_prereqs:Array;
      
      private var m_startDate:Number;
      
      private var m_endDate:Number;
      
      private var m_unlocks:Array;
      
      private var m_hasBuyableUnlock:int;
      
      private var m_buyableUnlock:LicenseUnlock;
      
      public function ItemLicense(itemLicenseXML:XML)
      {
         var unlockXML:XML = null;
         super();
         this.m_type = itemLicenseXML.@type;
         this.m_code = itemLicenseXML.@code;
         if(itemLicenseXML.hasOwnProperty("duration"))
         {
            this.m_duration = int(itemLicenseXML.duration);
         }
         if(itemLicenseXML.hasOwnProperty("startDate"))
         {
            this.m_startDate = FarmGameUtil.synchronizedDateToNumber(itemLicenseXML.startDate);
         }
         if(itemLicenseXML.hasOwnProperty("endDate"))
         {
            this.m_endDate = FarmGameUtil.synchronizedDateToNumber(itemLicenseXML.endDate);
         }
         if(itemLicenseXML.hasOwnProperty("prereqs"))
         {
            this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(itemLicenseXML.prereqs.prereq);
         }
         this.m_unlocks = [];
         var unlockXMLList:XMLList = itemLicenseXML.unlock;
         if(unlockXMLList)
         {
            for each(unlockXML in unlockXMLList)
            {
               this.m_unlocks.push(new LicenseUnlock(unlockXML));
            }
         }
         this.m_hasBuyableUnlock = UNSET;
         this.m_buyableUnlock = null;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get code() : String
      {
         return this.m_code;
      }
      
      public function get duration() : int
      {
         return this.m_duration;
      }
      
      public function get startDate() : Number
      {
         return this.m_startDate;
      }
      
      public function get endDate() : Number
      {
         return this.m_endDate;
      }
      
      public function get prereqs() : Array
      {
         return this.m_prereqs;
      }
      
      public function get unlocks() : Array
      {
         return this.m_unlocks;
      }
      
      public function get buyableUnlock() : LicenseUnlock
      {
         if(this.m_hasBuyableUnlock == UNSET)
         {
            this.setBuyableUnlock();
         }
         return this.m_buyableUnlock;
      }
      
      public function get hasBuyableUnlock() : Boolean
      {
         if(this.m_hasBuyableUnlock == UNSET)
         {
            this.setBuyableUnlock();
         }
         return this.m_hasBuyableUnlock == TRUE;
      }
      
      private function setBuyableUnlock() : void
      {
         var unlock:LicenseUnlock = null;
         this.m_hasBuyableUnlock = FALSE;
         for each(unlock in this.unlocks)
         {
            if(unlock.buyable)
            {
               this.m_hasBuyableUnlock = TRUE;
               this.m_buyableUnlock = unlock;
               break;
            }
         }
      }
   }
}

