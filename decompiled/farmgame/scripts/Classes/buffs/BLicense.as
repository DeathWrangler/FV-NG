package Classes.buffs
{
   import Managers.LicenseManager;
   
   public class BLicense extends BBushel
   {
      
      public function BLicense(itemName:String)
      {
         super(itemName);
      }
      
      override public function apply(isNew:Boolean = false) : void
      {
         var buffStats:Object = null;
         if(isNew)
         {
            buffStats = Global.player.buffs[m_itemName];
            LicenseManager.getInstance().addLicense(buffStats.crop,buffStats.time + getExpiresTTL());
         }
      }
      
      override public function unapply() : void
      {
         var buffStats:Object = Global.player.buffs[m_itemName];
         LicenseManager.getInstance().deleteLicense(buffStats.crop);
      }
   }
}

