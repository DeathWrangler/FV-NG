package GameMode
{
   import Classes.Growable.GrowableContest;
   import Classes.Growable.IGrowableResource;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.GrowableContestManager;
   import Transactions.TGrowableContestAcceptInvite;
   import flash.events.MouseEvent;
   
   public class GMGrowableContestPlaceInvited extends GMObjectMove
   {
      
      private var m_growable:IGrowableResource = null;
      
      private var m_storageKey:String;
      
      public function GMGrowableContestPlaceInvited(growable:IGrowableResource)
      {
         this.m_growable = growable;
         this.m_storageKey = growable.growableMapResource.persistentDataKey;
         GrowableContestManager.instance.beginPlacing(this.m_storageKey);
         super(null,null,true,false);
      }
      
      override public function disableMode() : void
      {
         if(!m_objectPlacedSuccess)
         {
            GrowableContestManager.instance.donePlacing(this.m_storageKey);
         }
         super.disableMode();
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         if(!m_selectedObject)
         {
            this.m_growable.growableMapResource.setOuter(Global.world);
            this.m_growable.growableMapResource.setPosition(0,0);
            m_selectedObject = this.m_growable.growableMapResource;
         }
         return super.onMouseMove(event);
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var growableResource:IGrowableResource = null;
         var contest:GrowableContest = null;
         var result:Boolean = super.onMouseUp(event);
         if(m_objectPlacedSuccess)
         {
            if(Global.world.checkNumObjectLimit())
            {
               if(!m_selectedObject.isToolGenerated && m_selectedObject is IGrowableResource)
               {
                  growableResource = m_selectedObject as IGrowableResource;
                  TransactionManager.addTransaction(new TGrowableContestAcceptInvite(growableResource));
                  contest = GrowableContestManager.instance.getContestForInstance(growableResource);
                  if(contest != null)
                  {
                     contest.onParticipantFinishPlace(growableResource);
                  }
               }
               Global.world.addGameMode(new GMDefault());
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_Full"));
               Global.world.addGameMode(this);
            }
         }
         return result;
      }
      
      override protected function canMultiPlace() : Boolean
      {
         return false;
      }
   }
}

