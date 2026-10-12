package Widgets.Windows.Subscriptions
{
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Frames.Subscriptions.SubscriptionSlotContainer;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class SubscriptionsMainWindow extends FarmWindow
   {
      
      public static const SUBSCRIPTION_ACTIVE:String = "SUBSCRIPTION_ACTIVE";
      
      public static const SUBSCRIPTION_TRIAL:String = "SUBSCRIPTION_TRIAL";
      
      public static const SUBSCRIPTION_PENDING_CANCEL:String = "SUBSCRIPTION_PENDING_CANCEL";
      
      public static const SUBSCRIPTION_CANCELED:String = "SUBSCRIPTION_CANCELED";
      
      public static const SUBSCRIPTION_REINSTATE:String = "SUBSCRIPTION_REINSTATE";
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_Subscriptions.swf";
      
      public static const DEFAULT_SUBSCRIPTION_CODE:String = "sub:1";
      
      public static const STATS_COUNTER:String = "subs_coins_cash";
      
      public static const STATS_KINGDOM:String = "dialog_subscriber";
      
      private var m_subscriptionsFrame:SubscriptionSlotContainer;
      
      public function SubscriptionsMainWindow()
      {
         super(ASSET_PATH);
      }
      
      public static function getSubscriptionData() : Array
      {
         var keyValue:String = null;
         var result:Array = new Array();
         var subscriptionData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS,DEFAULT_SUBSCRIPTION_CODE);
         if(subscriptionData == null)
         {
            subscriptionData = SubscriptionsMainWindow.generateSubscriptionData(DEFAULT_SUBSCRIPTION_CODE);
         }
         for(keyValue in subscriptionData)
         {
            result.push(subscriptionData[keyValue]);
         }
         result.sortOn(["amount"]);
         return result;
      }
      
      public static function generateSubscriptionData(itemCode:String) : Object
      {
         var packagesXML:XMLList = null;
         var packagesLength:int = 0;
         var packagesArray:Array = null;
         var i:int = 0;
         var packageData:XML = null;
         var amount:String = null;
         var packageObj:Object = null;
         var result:Object = null;
         var subscriptionXML:XML = Global.farmGameSettingsManager.getSubscriptionByItemCode(itemCode);
         if(subscriptionXML != null)
         {
            packagesXML = subscriptionXML["package"];
            packagesLength = packagesXML.length();
            packagesArray = new Array();
            for(i = 0; i < packagesLength; i++)
            {
               packageData = packagesXML[i];
               amount = String(packageData["amount"]);
               packageObj = {
                  "amount":amount,
                  "tradingCost":Number(packageData["tradingCost"]),
                  "currency":String(packageData["currency"]),
                  "tradingLimit":Number(packageData["tradingLimit"]),
                  "alreadyTraded":0
               };
               packagesArray[amount] = packageObj;
            }
            result = packagesArray;
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS,DEFAULT_SUBSCRIPTION_CODE,packagesArray);
         }
         else
         {
            ErrorManager.addError("Error generating the subscription plan - not a valid item code");
         }
         return result;
      }
      
      public static function isSubscriber() : Boolean
      {
         var result:Boolean = false;
         var subscriptionStatus:String = Global.player.subscriptionStatus;
         if(subscriptionStatus != null && subscriptionStatus != "" && (subscriptionStatus == SUBSCRIPTION_ACTIVE || subscriptionStatus == SUBSCRIPTION_PENDING_CANCEL || subscriptionStatus == SUBSCRIPTION_REINSTATE))
         {
            result = true;
         }
         return result;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,"view");
         this.m_subscriptionsFrame = new SubscriptionSlotContainer(m_window.slotFrame_mc,this);
         addWidget(this.m_subscriptionsFrame);
         addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.howDoesThisWorkClick,true));
         this.m_subscriptionsFrame.items = SubscriptionsMainWindow.getSubscriptionData();
      }
      
      public function updateTradingStatus() : void
      {
         this.m_subscriptionsFrame.items = SubscriptionsMainWindow.getSubscriptionData();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,"what_is_this");
         UI.displayPopup(new SubscriptionsTutorialWindow(),false,"SubscriptionsTutorial",true);
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,"close");
         super.onClose(event);
      }
   }
}

