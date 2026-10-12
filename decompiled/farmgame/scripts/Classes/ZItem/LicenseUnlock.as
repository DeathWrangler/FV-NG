package Classes.ZItem
{
   public class LicenseUnlock
   {
      
      private static const BUYABLE_LICENSES:Array = ["CashLicense","DonationLicense","BerryLicense"];
      
      private var m_className:String;
      
      private var m_requirement:int;
      
      private var m_donation:Boolean;
      
      public function LicenseUnlock(unlockXML:XML)
      {
         super();
         if(unlockXML.hasOwnProperty("@className"))
         {
            this.m_className = unlockXML.@className;
         }
         if(unlockXML.hasOwnProperty("@requirement"))
         {
            this.m_requirement = int(unlockXML.@requirement);
         }
         if(unlockXML.hasOwnProperty("@donation"))
         {
            this.m_donation = unlockXML.@donation == "true";
         }
         else
         {
            this.m_donation = false;
         }
      }
      
      public function get className() : String
      {
         return this.m_className;
      }
      
      public function get requirement() : int
      {
         return this.m_requirement;
      }
      
      public function get buyable() : Boolean
      {
         return Boolean(this.m_className) && (BUYABLE_LICENSES.indexOf(this.m_className) != -1 || this.m_donation);
      }
   }
}

