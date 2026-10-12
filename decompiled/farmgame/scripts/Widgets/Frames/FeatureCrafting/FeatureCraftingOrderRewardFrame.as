package Widgets.Frames.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingOrderBoard;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingContentsWindow;
   import flash.display.DisplayObject;
   
   public class FeatureCraftingOrderRewardFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 40;
      
      private var m_headerTextField:ZwTextField;
      
      private var m_infoTextField:ZwTextField;
      
      private var m_rewardSlots:FeatureCraftingRewardSlotContainerFrame;
      
      public function FeatureCraftingOrderRewardFrame(element:DisplayObject)
      {
         super(element);
         this.m_headerTextField = addWidget(new ZwTextField(m_element.header_tf,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"OrderBoard_Title"))) as ZwTextField;
         this.m_infoTextField = addWidget(new ZwTextField(m_element.subheader_tf,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"OrderBoard_Rewards"))) as ZwTextField;
         this.m_rewardSlots = addWidget(new FeatureCraftingRewardSlotContainerFrame(m_element.rewards_mc)) as FeatureCraftingRewardSlotContainerFrame;
      }
      
      override public function release() : void
      {
         this.m_headerTextField = null;
         this.m_infoTextField = null;
         this.m_rewardSlots = null;
         super.release();
      }
      
      public function refresh() : void
      {
         var parentWindow:FeatureCraftingContentsWindow = null;
         var system:FeatureCraftingSystem = null;
         var orderBoard:FeatureCraftingOrderBoard = null;
         if(m_element)
         {
            parentWindow = getAncestorByClassType(FeatureCraftingContentsWindow) as FeatureCraftingContentsWindow;
            if(parentWindow)
            {
               system = parentWindow.system;
               if(system)
               {
                  this.m_rewardSlots.system = system;
                  orderBoard = system.getOrderBoard();
                  if(orderBoard)
                  {
                     this.m_rewardSlots.items = orderBoard.rewards;
                  }
               }
            }
         }
      }
   }
}

