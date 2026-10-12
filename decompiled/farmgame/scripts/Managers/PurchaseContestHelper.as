package Managers
{
   import Classes.Constants.Experiments;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TransactionWithCallBack;
   import Widgets.Windows.GenericOnboardingWindow;
   import Widgets.Windows.PurchaseContestToasterWindow;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class PurchaseContestHelper
   {
      
      private static var s_timer:Timer;
      
      private static const FEATURE_NAME:String = "purchase_contest";
      
      private static const FEATURE_FREQUENCY_FLAG:String = "purchaseContestWinnerSeen";
      
      private static const MAX_WAIT_TIME:int = 180;
      
      public function PurchaseContestHelper()
      {
         super();
      }
      
      public static function checkForWin(optionValue:Object) : void
      {
         var rawXML:XML = null;
         var uiObject:Object = null;
         var popup:GenericOnboardingWindow = null;
         var timestamp:String = String(optionValue);
         if(Global.player.getSeenSessionFlag(FEATURE_NAME + timestamp) == false)
         {
            Global.player.setSeenSessionFlag(FEATURE_NAME + timestamp);
            rawXML = Global.farmGameSettingsManager.getFeatureXML(FEATURE_NAME);
            UserRewardUtil.grantUserRewardsFromXml(rawXML.rewards[0]);
            uiObject = {
               "dialog":"assets/dialogs/FV_share_1000Customer.swf",
               "text":"Dialogs:PurchaseContestRewardBody",
               "buttonText":"Dialogs:Share"
            };
            popup = new GenericOnboardingWindow(uiObject,onShareClick);
            UI.displayPopup(popup,false);
         }
      }
      
      public static function showLatestWinner() : void
      {
         var rndTimeout:int = Math.random() * MAX_WAIT_TIME * FarmGameUtil.NUM_MSECS_IN_SECOND;
         s_timer = new Timer(rndTimeout);
         s_timer.addEventListener(TimerEvent.TIMER,onShowWinnerTimeOut);
         s_timer.start();
      }
      
      public static function inExperiment() : Boolean
      {
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_1000_FREE_CUSTOMER);
         return variant == 2 || variant == 4;
      }
      
      private static function onShowWinnerTimeOut(event:TimerEvent) : void
      {
         s_timer.removeEventListener(TimerEvent.TIMER,onShowWinnerTimeOut);
         s_timer = null;
         TransactionManager.addTransaction(new TGenericTransaction("PurchaseContestService","getWinner",onGetWinnerCallback));
      }
      
      private static function onGetWinnerCallback(result:Object) : void
      {
         var imageUrl:String = null;
         if(Boolean(result) && Boolean(result.hasOwnProperty("name")) && result.name != "")
         {
            imageUrl = result["pic_square"];
            ToasterManager.getInstance().add(new PurchaseContestToasterWindow(result.name,imageUrl,new Point(0,0),onFlyoutClick));
            FarmStatsManager.sample(100,"1000FreeCustomer","flyCount","seen");
            Global.player.setFeatureLastShown(FEATURE_FREQUENCY_FLAG,GlobalEngine.serverTime,true);
         }
      }
      
      private static function onFlyoutClick() : void
      {
         var uiObject:Object = {
            "dialog":"assets/dialogs/FV_motd_1000Customer.swf",
            "text":"Dialogs:PurchaseContestFeatureBody",
            "buttonText":"Dialogs:PurchaseContestFeatureButtonText"
         };
         var popup:GenericOnboardingWindow = new GenericOnboardingWindow(uiObject);
         FarmStatsManager.sample(100,"1000FreeCustomer","flyCount","click");
         UI.displayPopup(popup);
      }
      
      private static function onShareClick() : void
      {
         FarmStatsManager.count("1000FreeCustomer","dialog","accept");
         TransactionManager.addTransaction(new TransactionWithCallBack("PurchaseContestService.publishFeed",onPublishFeedCallback));
      }
      
      private static function onPublishFeedCallback(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData);
         }
      }
   }
}

