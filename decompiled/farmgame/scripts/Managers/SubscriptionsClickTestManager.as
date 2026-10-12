package Managers
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Widgets.Windows.Subscriptions.SubscriptionsClickTestPopUp;
   import Widgets.Windows.Subscriptions.SubscriptionsClickThankYou;
   import flash.events.EventDispatcher;
   
   public class SubscriptionsClickTestManager extends EventDispatcher
   {
      
      public function SubscriptionsClickTestManager()
      {
         super();
      }
      
      public static function displaySubscriptionPlanDescPopUp(variant:int, secondPopUpGeneric:String, isSubscriber:Boolean) : void
      {
         var secondPopUp:String = "assets/dialogs/" + secondPopUpGeneric;
         secondPopUp += isSubscriber ? "0" + variant + "b.swf" : "0" + variant + "a.swf";
         UI.displayPopup(new SubscriptionsClickTestPopUp(secondPopUp,subscriptionPlanDescCloseCallBack(variant,isSubscriber)),false,"",false,true);
         UI.stopPopups(true);
      }
      
      public static function subscriptionPlanDescCloseCallBack(variant:int, isSubscriber:Boolean) : Function
      {
         var f:Function = function(clickedOk:Boolean):void
         {
            StatsManager.count("SubscriptionsClickTest",clickedOk ? "ok" : "no","variant:" + variant,isSubscriber ? "Subscriber" : "NonSubscriber");
            SubscriptionsClickThankYou.display(subscriptionClickThankYouCloseCallBack);
         };
         return f;
      }
      
      public static function subscriptionClickThankYouCloseCallBack() : void
      {
         UI.stopPopups(false);
      }
   }
}

