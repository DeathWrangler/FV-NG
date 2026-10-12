package Classes.util
{
   import Display.UI;
   import Managers.AOEManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Windows.GenericOnboardingWindow;
   
   public class OnboardingUtil
   {
      
      private static const FRAME_COMPLETE_AWARD_FLAG:String = "_FrameCompleteAward";
      
      private static const FRAME_COMPLETE_TOKEN:String = "frame_complete_award";
      
      public function OnboardingUtil()
      {
         super();
      }
      
      public static function conditionallyAwardOnboardingItem(featureKey:String) : void
      {
         var xml:XMLList = null;
         var rewardItem:String = null;
         var rewardDays:Number = NaN;
         var endDate:Date = null;
         var hasAwarded:Boolean = false;
         var bInTimeRange:Boolean = false;
         var rawXml:XML = Global.farmGameSettingsManager.getFeatureXML(featureKey);
         if(Boolean(rawXml) && Boolean(rawXml.hasOwnProperty("onboard")) && rawXml.hasOwnProperty("@born"))
         {
            xml = rawXml.onboard;
            rewardItem = xml["rewardItem"];
            rewardDays = Number(xml["rewardDays"]);
            endDate = new Date(String(rawXml.@born));
            endDate.setDate(endDate.getDate() + rewardDays);
            hasAwarded = Global.player.getSeenFlag(featureKey + FRAME_COMPLETE_AWARD_FLAG);
            bInTimeRange = FarmGameUtil.checkEndDateGate(endDate.getMonth() + 1 + "/" + endDate.getDate() + "/" + endDate.getFullYear());
            if(rewardItem != "" && bInTimeRange && !hasAwarded)
            {
               Global.player.setSeenFlag(featureKey + FRAME_COMPLETE_AWARD_FLAG,false,true);
               Global.player.addGift(rewardItem);
               FeatureOptionsManager.getInstance().setFeatureOption(featureKey,FRAME_COMPLETE_TOKEN,{"rewardItem":rewardItem});
            }
         }
      }
      
      public static function conditionallySurfaceOnboardingAward(featureKey:String, uiObject:Object) : void
      {
         var onboardingAwardItem:String = null;
         var displayPopup:GenericOnboardingWindow = null;
         onboardingAwardItem = "";
         var obj:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureKey,FRAME_COMPLETE_TOKEN);
         if(obj != null && obj.hasOwnProperty("rewardItem"))
         {
            onboardingAwardItem = obj.rewardItem;
         }
         if(onboardingAwardItem != "")
         {
            displayPopup = new GenericOnboardingWindow(uiObject,function():void
            {
               Global.world.enterForcePlaceMode(onboardingAwardItem,true);
               FarmStatsManager.count(AOEManager.STATS_COUNTER_NAME,featureKey,"free_one_placed","after_frame_complete");
            });
            UI.displayPopup(displayPopup,false);
            FeatureOptionsManager.getInstance().setFeatureOption(featureKey,FRAME_COMPLETE_TOKEN,null);
         }
      }
      
      public static function hasOnboardingAward(featureKey:String) : Boolean
      {
         var result:Boolean = false;
         var obj:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureKey,FRAME_COMPLETE_TOKEN);
         if(obj != null && obj.hasOwnProperty("rewardItem") && obj.rewardItem != "")
         {
            result = true;
         }
         return result;
      }
   }
}

