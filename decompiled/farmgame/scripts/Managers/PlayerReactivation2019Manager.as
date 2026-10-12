package Managers
{
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.PlayerReactivation2019Window;
   
   public class PlayerReactivation2019Manager
   {
      
      public static const SERVICE_NAME:String = "PlayerReactivation2019Service";
      
      public static const ASSET_PATH:String = "assets/dialogs/PayerReactivation/FV_motd_payerreactivation_2019.swf";
      
      public function PlayerReactivation2019Manager()
      {
         super();
      }
      
      public static function isEligibleForPlayerReactivation2019() : Boolean
      {
         var fo:Object = null;
         var isEligible:Boolean = false;
         if(getTimeLeftForEventEnd() > 0)
         {
            fo = FeatureOptionsManager.getInstance().getFeatureOption("PlayerReactivation2019","PlayerReactivation2019");
            if(Boolean(fo) || Global.eosManager.getEosVariant("fv_payerreactivation_2019") == 2)
            {
               if(!fo)
               {
                  isEligible = true;
               }
               else if(fo.hasOwnProperty("dayCount") && fo["dayCount"] < 4)
               {
                  if(fo.hasOwnProperty("ts") && GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND > fo["ts"] + 86400)
                  {
                     isEligible = true;
                  }
               }
            }
         }
         return isEligible;
      }
      
      public static function grantReward() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantReward",onGrantReward,["PlayerReactivation2019"]),true);
      }
      
      public static function onGrantReward(result:Object) : void
      {
         var rewardIndex:int = 0;
         if(Boolean(result) && result.hasOwnProperty("rewardIndex"))
         {
            rewardIndex = int(result["rewardIndex"]);
            Global.player.addGift("consume_unwither","0",2);
            Global.player.addGift("consume_instagrow","0",3);
            Global.player.addGift("consume_turbo_charger","0",5);
            Global.player.cash += rewardIndex + 1;
            UI.displayPopup(new PlayerReactivation2019Window(ASSET_PATH,rewardIndex),false);
         }
      }
      
      public static function getTimeLeftForEventEnd() : Number
      {
         var dayExpiredTime:Number = FarmGameUtil.synchronizedDateTimeToNumber("8/28/2019/") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
   }
}

