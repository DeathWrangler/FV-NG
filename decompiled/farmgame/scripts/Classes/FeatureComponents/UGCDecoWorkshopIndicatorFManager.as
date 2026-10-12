package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Managers.UGCDecoManager;
   import Transactions.TGenericTransaction;
   
   public class UGCDecoWorkshopIndicatorFManager extends ArrowIndicatorFManager
   {
      
      private static const INDICATOR_X_OFFSET:Number = 50;
      
      private static const INDICATOR_Y_OFFSET:Number = 0;
      
      private static const SENTARROWSELECTION:String = "sentUGCDecoArrowSelection";
      
      private static const SENTARROWSHOWN:String = "sentUGCDecoArrowShown";
      
      public function UGCDecoWorkshopIndicatorFManager(owner:FeatureBuilding)
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
         if(!Global.player.getSeenSessionFlag(SENTARROWSELECTION))
         {
            TransactionManager.addTransaction(new TGenericTransaction(UGCDecoManager.UGCDECOSERVICE,UGCDecoManager.ARROWSELECTION));
            Global.player.setSeenSessionFlag(SENTARROWSELECTION);
         }
         m_owner.displayStorageDialog();
      }
      
      override public function get lookInsideOnClick() : Boolean
      {
         return true;
      }
      
      override public function show(state:String = "default") : void
      {
         var stateData:Object = null;
         if(Global.player.postInitFinished)
         {
            stateData = UGCDecoManager.instance.getArrowStateData();
            if(stateData)
            {
               this.setState(state,stateData);
               super.show(state);
               if(!Global.player.getSeenSessionFlag(SENTARROWSHOWN))
               {
                  TransactionManager.addTransaction(new TGenericTransaction(UGCDecoManager.UGCDECOSERVICE,UGCDecoManager.ARROWSHOWN));
                  Global.player.setSeenSessionFlag(SENTARROWSHOWN);
               }
            }
         }
         else
         {
            m_delayedShowState = state;
            if(!m_isDelayedShow)
            {
               m_isDelayedShow = true;
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.onDelayedShow,false,0,true);
            }
         }
      }
      
      override protected function onDelayedShow(event:FarmGameWorldEvent) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.onDelayedShow);
         super.onDelayedShow(event);
      }
      
      override public function hide() : void
      {
         if(m_isDelayedShow)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.onDelayedShow);
            m_isDelayedShow = false;
         }
         else
         {
            super.hide();
         }
      }
   }
}

