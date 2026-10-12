package Widgets.Frames
{
   import Classes.IsraelInnovationCommunityGoalTask;
   import Managers.IsraelInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.IsraelInnovationCommunityGoalSlot;
   import Widgets.Windows.IsraelInnovationCommunityGoalWindow;
   import flash.display.DisplayObject;
   
   public class IsraelInnovationCommunityGoalFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:IsraelInnovationCommunityGoalWindow;
      
      private var m_task:IsraelInnovationCommunityGoalTask;
      
      private var m_taskList:Array;
      
      public var m_communityScore:int;
      
      private var m_featureName:String;
      
      private const PREFIX:String = "buyCountSlot";
      
      public function IsraelInnovationCommunityGoalFrame(element:DisplayObject, window:IsraelInnovationCommunityGoalWindow, featureName:String, taskList:Array)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         this.m_taskList = taskList;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new IsraelInnovationCommunityGoalSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      private function get manager() : IsraelInnovationManager
      {
         return IsraelInnovationManager.getInstance(this.m_featureName);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         for(var i:int = 0; i < 2; i++)
         {
            if(this.m_taskList.length >= i + 1)
            {
               m_slotData.push({
                  "slotNumber":i,
                  "taskName":this.m_taskList[i].name,
                  "communityGoal":this.m_taskList[i].communityGoal,
                  "playerGoal":this.m_taskList[i].playerGoal,
                  "rewardName":this.m_taskList[i].rewards.@name,
                  "rewardQuantity":this.m_taskList[i].rewards.@qty,
                  "playerProg":this.manager.getCommGoalPlayerCountForTask(this.m_taskList[i].name),
                  "communityProg":this.m_window.m_communityScore[i]
               });
            }
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

