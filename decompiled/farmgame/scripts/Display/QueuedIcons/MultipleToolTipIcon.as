package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.util.FarmGameUtil;
   import Managers.LimitedQuantityBundleManager;
   
   public class MultipleToolTipIcon extends FeatureQueuedIcon
   {
      
      public static const FEATURE_EXTRA_DAYS:int = 2;
      
      public static const FEATURE_START_FLAG:String = "_featureStart";
      
      public function MultipleToolTipIcon(xml:XML)
      {
         super(xml);
      }
      
      override public function init() : void
      {
         super.init();
         this.registerFeatureVisible();
         this.setToolTip();
      }
      
      public function registerFeatureVisible() : void
      {
         var startDate:Number = NaN;
         var featureName:String = null;
         var keyFeatureStart:String = extraData.featureName + FEATURE_START_FLAG;
         var featureLastShown:Number = Global.player.getFeatureLastShown(keyFeatureStart);
         if(featureLastShown == 0)
         {
            startDate = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            featureName = extraData.featureName;
            if(featureName.indexOf("limitedQuantityBundles") >= 0 && Global.flashHotParams.hasOwnProperty(LimitedQuantityBundleManager.ZRUNTIME_KEY_START))
            {
               startDate = FarmGameUtil.synchronizedDateToNumber(Global.flashHotParams[LimitedQuantityBundleManager.ZRUNTIME_KEY_START].toString()) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            }
            Global.player.setFeatureLastShown(keyFeatureStart,startDate,false);
         }
      }
      
      public function setToolTip() : void
      {
         var endDateNumber:Number = NaN;
         var timeLeftText:String = null;
         var trimmedText:String = null;
         if(!this.isFeaturePlayable() || this.isFeatureTimeGated())
         {
            endDateNumber = Global.player.getFeatureLastShown(extraData.featureName + FEATURE_START_FLAG) + FEATURE_EXTRA_DAYS * FarmGameUtil.NUM_SECS_IN_DAY;
            if(extraData.endDate)
            {
               endDateNumber = FarmGameUtil.synchronizedDateToNumber(extraData.endDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            }
            timeLeftText = FarmGameUtil.getTimeLeftText(endDateNumber);
            if(timeLeftText != "" && m_currentArrowType != ArrowType.ARROWNEW)
            {
               trimmedText = timeLeftText.replace("minute","min").replace("second","sec");
               m_arrowText = trimmedText;
               attachArrow(ArrowType.ARROWEXPIRY);
            }
         }
      }
      
      override protected function canShowArrow() : Boolean
      {
         var result:Boolean = true;
         if(this.isFeaturePlayable())
         {
            result = super.canShowArrow();
         }
         return result;
      }
      
      private function isFeaturePlayable() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(extraData.endDate,FEATURE_EXTRA_DAYS);
      }
      
      private function isFeatureTimeGated() : Boolean
      {
         var result:Boolean = false;
         if(this.visibilityPrereqs)
         {
            result = this.visibilityPrereqs.hasOwnProperty(PrerequisiteConstants.PREREQUISITE_FEATURE_FREQUENCY);
         }
         return result;
      }
   }
}

