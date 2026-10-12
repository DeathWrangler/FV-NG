package Widgets.Frames.Party
{
   import Classes.FeatureDataObjects.PartyDataObject;
   import Managers.FarmGameSettingsManager;
   import Managers.PartyManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Windows.Party.BuildingPartyWindow;
   import flash.display.DisplayObject;
   
   public class PartyProgressFrame extends ZwFrame
   {
      
      protected var m_parentWindow:BuildingPartyWindow;
      
      public function PartyProgressFrame(element:DisplayObject, parentWindow:BuildingPartyWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         this.buildProgressFrame();
      }
      
      override public function release() : void
      {
         this.m_parentWindow = null;
         super.release();
      }
      
      protected function buildProgressFrame() : void
      {
         var collectedSlots:Array = null;
         var uncollectedSlots:Array = null;
         var goal:int = 0;
         var prog:int = 0;
         var rewardXML:XML = null;
         var rewardName:String = null;
         var i:int = 0;
         var element:Object = this.element;
         var danceFloorFrame:PartyDanceFloorFrame = this.addWidget(new PartyDanceFloorFrame(element.avatarFrame_mc)) as PartyDanceFloorFrame;
         var partyObject:PartyDataObject = PartyManager.getInstance().getPartyObjectByCode(this.m_parentWindow.partyCode);
         if(partyObject)
         {
            collectedSlots = new Array();
            uncollectedSlots = new Array();
            goal = 0;
            prog = partyObject.friendSet.value;
            for(i = 0; i < partyObject.goal.getNumberOfGoalLevels(); i++)
            {
               goal = partyObject.goal.getRequirementByLevel(i + 1);
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  rewardName = partyObject.goal.getRewardNameForLevel(i + 1);
               }
               else
               {
                  rewardXML = partyObject.goal.getRewardForLevel(i + 1);
                  rewardName = rewardXML.@name;
               }
               if(!partyObject.friendSet.initialized || prog < goal)
               {
                  uncollectedSlots.push(addWidget(new PartyUncollectedItemFrame(element["uncollectedSlot_" + i.toString() + "_mc"],rewardName,this.m_parentWindow,goal,prog)) as PartyUncollectedItemFrame);
               }
               else
               {
                  collectedSlots.push(addWidget(new PartyCollectedItemFrame(element["collectedSlot_" + i.toString() + "_mc"],rewardName,goal)) as PartyCollectedItemFrame);
               }
            }
         }
      }
   }
}

