package Widgets.Frames
{
   import Managers.OrderBoard.BobBerryManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.BobsBerryQuestLevelSlot;
   import Widgets.Windows.BobBerryFarmWindow;
   import flash.display.DisplayObject;
   
   public class BobsBerryQuestLevelContainterFrame extends FarmSlotContainerFrame
   {
      
      private var m_owner:BobBerryFarmWindow;
      
      private var m_featureName:String;
      
      public function BobsBerryQuestLevelContainterFrame(element:DisplayObject, owner:BobBerryFarmWindow, featureName:String)
      {
         this.m_owner = owner;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BobsBerryQuestLevelSlot(slotElement,this.m_owner,this.m_featureName);
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         this.refresh();
      }
      
      override public function release() : void
      {
         this.m_owner = null;
         super.release();
      }
      
      override protected function setupData() : void
      {
         var rewards:Object = null;
         var questLevels:Array = [];
         var i:int = 0;
         while(i < BobBerryFarmWindow.NUM_OF_SLOTS)
         {
            rewards = BobBerryManager.getInstance(this.m_featureName).getAllDifficultyRewardsData();
            switch(i)
            {
               case 0:
                  questLevels.push({
                     "questLevelSlotNumber":i,
                     "levelType":"easy",
                     "rewardcount_tf":"x" + rewards["easy"][0].value
                  });
                  break;
               case 1:
                  questLevels.push({
                     "questLevelSlotNumber":i,
                     "levelType":"medium",
                     "rewardcount_tf":"x" + rewards["medium"][0].value
                  });
                  break;
               case 2:
                  questLevels.push({
                     "questLevelSlotNumber":i,
                     "levelType":"hard",
                     "rewardcount_tf":"x" + rewards["hard"][0].value
                  });
            }
            i++;
         }
         m_slotData = questLevels;
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

