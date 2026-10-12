package Managers
{
   import Classes.util.FarmGameUtil;
   import flash.utils.Dictionary;
   
   public class LicenseManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static var m_instance:LicenseManager = null;
      
      public var m_licenses:Dictionary = new Dictionary();
      
      public function LicenseManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use LicenseManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : LicenseManager
      {
         if(m_instance == null)
         {
            m_instance = new LicenseManager();
         }
         return m_instance;
      }
      
      public function addLicense(itemCode:String, expirationTime:Number) : void
      {
         this.m_licenses[itemCode] = expirationTime;
      }
      
      public function deleteLicense(key:String) : void
      {
         delete this.m_licenses[key];
      }
      
      public function hasCurrentLicense(code:String) : Boolean
      {
         var licenseHeld:Number = NaN;
         var currentTime:Number = NaN;
         var delta:Number = NaN;
         var result:Boolean = false;
         if(this.m_licenses[code])
         {
            licenseHeld = Number(this.m_licenses[code]);
            currentTime = GlobalEngine.serverTime / 1000;
            delta = licenseHeld - currentTime;
            if(licenseHeld != 0 && delta > -10)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getTimeLeftToExpiration(code:String) : Number
      {
         var result:Number = 0;
         var expirationTime:Number = this.getLicenseExpirationTime(code);
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return expirationTime - currentTime;
      }
      
      public function getLicenseExpirationTime(code:String) : Number
      {
         var expirationTime:Number = 0;
         if(this.m_licenses[code])
         {
            expirationTime = Number(this.m_licenses[code]);
         }
         return expirationTime;
      }
      
      public function resetLicenses() : void
      {
         this.m_licenses = null;
         this.m_licenses = new Dictionary();
      }
   }
}

