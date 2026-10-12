package Widgets.Frames
{
   import Managers.ChoiceDrivenManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.ChoiceDrivenFeatureSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class ChoiceDrivenFeatureSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_window:FarmWindow;
      
      protected var m_featureName:String;
      
      public function ChoiceDrivenFeatureSlotFrame(featureName:String, element:DisplayObject, window:FarmWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ChoiceDrivenFeatureSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      override protected function setupData() : void
      {
         var itemObject:Object = null;
         var activeContender:String = null;
         m_slotData = new Array();
         var count:* = 1;
         var contenderObject:Array = ChoiceDrivenManager.getInstance(this.m_featureName).currentRewardCollection;
         for each(itemObject in contenderObject)
         {
            activeContender = ChoiceDrivenManager.getInstance(this.m_featureName).getActiveContender();
            itemObject.redeemed = ChoiceDrivenManager.getInstance(this.m_featureName).isRewardRedeemed(activeContender,itemObject.name);
            itemObject.roundNumber = count++;
            m_slotData.push(itemObject);
         }
      }
   }
}

