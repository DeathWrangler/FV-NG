package Widgets.Frames.SlotMachine
{
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public class SlotMachineTokenCountFrame extends ZwFrame
   {
      
      private var m_building:FeatureBuilding;
      
      private var m_tokenCountTextField:ZwTextField;
      
      private var m_cachedTokenCount:Number = 0;
      
      public function SlotMachineTokenCountFrame(element:DisplayObject, building:FeatureBuilding)
      {
         super(element);
         this.m_building = building;
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_PennyCountLabel")));
         this.m_tokenCountTextField = addWidget(new ZwTextField(m_element.generic2_tf)) as ZwTextField;
         this.m_cachedTokenCount = this.m_building.slotmachine.tokenCount;
         this.update(true);
      }
      
      public function update(force:Boolean = false) : void
      {
         if(force || this.m_cachedTokenCount != this.m_building.slotmachine.tokenCount)
         {
            this.m_tokenCountTextField.text = ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_PennyCountText",{"quantity":this.m_building.slotmachine.tokenCount});
            if(this.m_cachedTokenCount < this.m_building.slotmachine.tokenCount)
            {
               this.m_building.slotmachine.addDisplayPennyStatusText(this.m_building.slotmachine.tokenCount - this.m_cachedTokenCount);
            }
            this.m_cachedTokenCount = this.m_building.slotmachine.tokenCount;
         }
      }
   }
}

