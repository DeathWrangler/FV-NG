package Transactions
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Managers.LicenseManager;
   
   public class TAcquireLicense extends TFarmTransaction
   {
      
      protected var m_item:FarmItem;
      
      protected var m_licenseCode:String;
      
      protected var m_callback:Function;
      
      public function TAcquireLicense(item:XML, licenseCode:String, callback:Function = null, itemName:String = null)
      {
         super();
         if(itemName)
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         }
         else
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(item.@name);
         }
         this.m_licenseCode = licenseCode;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("LicenseService.acquireLicense",this.m_item.code,this.m_licenseCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && Boolean(result.timeExpires))
         {
            FarmStatsManager.count("License","Acquire_success",this.m_item.name,this.m_licenseCode);
            LicenseManager.getInstance().addLicense(this.m_item.code,result.timeExpires);
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
         else
         {
            FarmStatsManager.count("License","Acquire_fail",this.m_item.name,this.m_licenseCode);
         }
      }
   }
}

