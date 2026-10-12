package Widgets.Slots.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingRequiredGood;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class FeatureCraftingGoodSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_data:FeatureCraftingRequiredGood;
      
      private var m_icon:FarmIcon;
      
      public function FeatureCraftingGoodSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.clearScale();
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as FeatureCraftingRequiredGood;
         if(this.m_data)
         {
            this.m_icon.loadIcon(this.m_data.good.iconUrl());
            this.m_icon.visible = true;
         }
      }
   }
}

