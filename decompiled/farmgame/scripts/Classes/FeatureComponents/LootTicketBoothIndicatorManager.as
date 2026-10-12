package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.LootTicketBoothStageConfig;
   import Events.FarmGameWorldEvent;
   import Managers.LootTicketBoothManager;
   
   public class LootTicketBoothIndicatorManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      protected static const ARROW_HORIZONTAL_OFFSET:Number = 10;
      
      protected static const ARROW_VERTICAL_OFFSET:Number = -60;
      
      private static const IDLE_OVERLAY_INDEX:uint = 0;
      
      private static const READY_OVERLAY_INDEX:uint = 1;
      
      public function LootTicketBoothIndicatorManager(owner:FeatureBuilding)
      {
         m_owner = owner;
         m_lookInsideOnClick = true;
         super(owner);
      }
      
      override public function canDisplay() : Boolean
      {
         var lastStageUnlocked:LootTicketBoothStageConfig = null;
         var ticketItemName:String = null;
         var ticketItemNeeded:int = 0;
         var ticketItemOwned:int = 0;
         var result:Boolean = false;
         if(!Global.player.getSeenSessionFlag(this.sessionFlag))
         {
            lastStageUnlocked = LootTicketBoothManager.getLastStageUnlocked(m_owner.getItemName());
            if(lastStageUnlocked)
            {
               ticketItemName = lastStageUnlocked.ticketItemName;
               ticketItemNeeded = lastStageUnlocked.ticketItemNeeded as int;
               ticketItemOwned = Global.player.getGiftCountForItem(ticketItemName);
               if(ticketItemOwned >= ticketItemNeeded)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      override protected function drawIndicator(state:String = "default", visible:Boolean = true) : void
      {
         var overlayOverride:int = 0;
         super.drawIndicator(state,visible);
         if(this.canDisplay())
         {
            overlayOverride = int(READY_OVERLAY_INDEX);
            if(m_owner.getCurrentSuffix() != overlayOverride)
            {
               m_owner.setOverlayOverride(overlayOverride + 1,true);
            }
         }
      }
      
      override public function removeIndicator() : Boolean
      {
         var overlayOverride:int = 0;
         var shouldRedraw:Boolean = super.removeIndicator();
         if(shouldRedraw)
         {
            overlayOverride = int(IDLE_OVERLAY_INDEX);
            if(m_owner.getCurrentSuffix() != overlayOverride)
            {
               m_owner.setOverlayOverride(overlayOverride + 1,true);
            }
         }
         return shouldRedraw;
      }
      
      override public function show(state:String = "default") : void
      {
         if(Global.player.postInitFinished)
         {
            super.show(state);
         }
         else
         {
            this.handleDelayedShow(state);
         }
      }
      
      override public function hide() : void
      {
         Global.player.setSeenSessionFlag(this.sessionFlag,true);
         super.hide();
      }
      
      override protected function handleDelayedShow(state:String = "default") : void
      {
         m_delayedShowState = state;
         if(!m_isDelayedShow)
         {
            m_isDelayedShow = true;
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.onDelayedShow,false,0,true);
         }
      }
      
      override protected function onDelayedShow(event:FarmGameWorldEvent) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.onDelayedShow);
         m_isDelayedShow = false;
         this.show(m_delayedShowState);
      }
      
      override protected function getHorizontalOffset() : Number
      {
         return ARROW_HORIZONTAL_OFFSET;
      }
      
      override protected function getVerticalOffset() : Number
      {
         return ARROW_VERTICAL_OFFSET;
      }
      
      private function get sessionFlag() : String
      {
         return m_owner.getItemName() + "_ReadyIndicator";
      }
   }
}

