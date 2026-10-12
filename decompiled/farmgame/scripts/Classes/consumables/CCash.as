package Classes.consumables
{
   import Classes.Consumable;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Utilities;
   import Managers.FarmGameSettingsManager;
   
   public class CCash extends Consumable
   {
      
      private const ONE_TIME_USE_FLAG_PREFIX:String = "consumeLimitHit_";
      
      public function CCash(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         var status:String = null;
         var cash:int = getItem().cash;
         if(cash > 0)
         {
            Global.player.cash += cash;
            status = ZLocUtils.t("FarmGame","Status_AddCash",{"cashNum":Utilities.formatNumber(cash)});
            Global.player.avatar.displayStatus(status);
         }
      }
      
      override public function canUse() : Boolean
      {
         var oneTimeUseFlagName:String = null;
         var canUse:Boolean = true;
         if(this.isOneTimeUse())
         {
            oneTimeUseFlagName = this.ONE_TIME_USE_FLAG_PREFIX + getItem().code;
            if(Global.player.getSeenFlag(oneTimeUseFlagName) || Global.player.getSeenSessionFlag(oneTimeUseFlagName))
            {
               canUse = false;
            }
            else
            {
               Global.player.setSeenSessionFlag(oneTimeUseFlagName);
            }
         }
         return canUse;
      }
      
      override public function onFailedPerform() : void
      {
         var msg:String = ZLocUtils.t("Dialogs","Consumable_Cash_OneTimeUse_Fail");
         UI.displayMessage(msg);
      }
      
      private function isOneTimeUse() : Boolean
      {
         var oneTimeUse:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            oneTimeUse = getItem().getStringFromDataSource("oneTimeUse");
         }
         else
         {
            oneTimeUse = getItem().xml.attribute("oneTimeUse");
         }
         return Boolean(oneTimeUse) && oneTimeUse == "true";
      }
   }
}

