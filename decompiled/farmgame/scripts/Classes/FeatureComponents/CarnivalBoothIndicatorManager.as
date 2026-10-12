package Classes.FeatureComponents
{
   import Classes.Constants.Experiments;
   import Classes.FeatureBuilding;
   import Classes.util.FarmGameUtil;
   
   public class CarnivalBoothIndicatorManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      public static const CARNIVAL_BOOTH_INDICATOR_DATE_RUNTIME_PARAM:String = "CARNIVAL_BOOTH_INDICATOR_DATE";
      
      public static const CARNIVAL_BOOTH_INDICATOR_FF:String = "CarnivalBoothIndicatorClicked";
      
      private static const CARNIVAL_BOOTH_BACKOFF:String = "carnival_booth_backoff";
      
      public function CarnivalBoothIndicatorManager(owner:FeatureBuilding)
      {
         m_owner = owner;
         m_lookInsideOnClick = true;
         super(owner);
      }
      
      override public function canDisplay() : Boolean
      {
         var indicatorTriggerDate:String = null;
         var indicatorTriggerTimestamp:Number = NaN;
         var now:Number = NaN;
         var lastClickedDate:Number = NaN;
         var result:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CARNIVAL_BOOTH_ARROW) >= 2)
         {
            if(Global.player.canShowFeatureWithBackoff(CARNIVAL_BOOTH_BACKOFF))
            {
               result = true;
            }
         }
         else
         {
            indicatorTriggerDate = Global.flashHotParams[CARNIVAL_BOOTH_INDICATOR_DATE_RUNTIME_PARAM];
            indicatorTriggerTimestamp = FarmGameUtil.synchronizedDateTimeToNumber(indicatorTriggerDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            now = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            lastClickedDate = Global.player.getFeatureLastShown(CARNIVAL_BOOTH_INDICATOR_FF);
            if(now >= indicatorTriggerTimestamp && lastClickedDate < indicatorTriggerTimestamp)
            {
               result = true;
            }
         }
         return result;
      }
      
      override public function show(state:String = "default") : void
      {
         if(Global.player.isDataLoaded)
         {
            super.show(state);
         }
         else
         {
            handleDelayedShow(state);
         }
      }
      
      override public function onClick() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CARNIVAL_BOOTH_ARROW) >= 2)
         {
            Global.player.incrementBackoffInterval(CARNIVAL_BOOTH_BACKOFF);
         }
         else
         {
            Global.player.setFeatureLastShown(CARNIVAL_BOOTH_INDICATOR_FF,GlobalEngine.serverTime,true);
         }
         super.onClick();
      }
   }
}

