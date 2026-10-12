package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Events.FarmGameWorldEvent;
   import Managers.CaptureFeatureManager;
   
   public class GopherGardenIndicatorFManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      private static const INDICATOR_X_OFFSET:Number = 50;
      
      private static const INDICATOR_Y_OFFSET:Number = 0;
      
      public function GopherGardenIndicatorFManager(owner:FeatureBuilding)
      {
         m_owner = owner;
         super(owner);
      }
      
      override protected function getHorizontalOffset() : Number
      {
         return INDICATOR_X_OFFSET;
      }
      
      override protected function getVerticalOffset() : Number
      {
         return INDICATOR_Y_OFFSET;
      }
      
      override public function onClick() : void
      {
         super.onClick();
         m_owner.displayStorageDialog();
      }
      
      override public function get lookInsideOnClick() : Boolean
      {
         return true;
      }
      
      override public function show(state:String = "default") : void
      {
         if(Global.player.postInitFinished)
         {
            if(CaptureFeatureManager.instance.canAskForTreats(m_owner.featureName,CaptureFeatureManager.SOURCE_UI))
            {
               super.show(state);
            }
         }
         else
         {
            m_delayedShowState = state;
            if(!m_isDelayedShow)
            {
               m_isDelayedShow = true;
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,onDelayedShow,false,0,true);
            }
         }
      }
      
      override public function hide() : void
      {
         if(m_isDelayedShow)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,onDelayedShow);
            m_isDelayedShow = false;
         }
         else
         {
            super.hide();
         }
      }
   }
}

