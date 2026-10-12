package Widgets.Frames.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FeatureCrafting.FeatureCraftingExpansionSlot;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingStorageWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingExpansionSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private static const DOUBLE_CLICK_DELAY:int = 500;
      
      private var m_lastClickTime:int;
      
      private var m_parentWindow:FeatureCraftingStorageWindow;
      
      private var m_completeButton:FarmAnimatedCashButton;
      
      private var m_expandButton:FarmAnimatedTextButton;
      
      private var m_location:String = "";
      
      public function FeatureCraftingExpansionSlotContainerFrame(element:DisplayObject, location:String = "")
      {
         this.m_location = location;
         super(element);
         this.m_completeButton = addWidget(new FarmAnimatedCashButton(m_element.finish_bt,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StorageWindow_CompleteNowButton"),"00",this.onCompleteButtonClick)) as FarmAnimatedCashButton;
         this.m_expandButton = addWidget(new FarmAnimatedTextButton(m_element.upgrade_bt,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StorageWindow_ExpandButton"),this.onExpandButtonClick)) as FarmAnimatedTextButton;
         addWidget(new ZwTextField(m_element.getParts_tf,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StorageWindow_ExpandPartsMessage")));
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FeatureCraftingExpansionSlot(slotElement,this.m_location);
      }
      
      override public function release() : void
      {
         this.m_parentWindow = null;
         this.m_completeButton = null;
         this.m_expandButton = null;
         super.release();
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function refresh() : void
      {
         var cost:int = 0;
         super.refresh();
         if(m_slotData)
         {
            if(this.parentWindow.inventory.canExpandNow())
            {
               this.m_expandButton.visible = true;
               this.m_completeButton.visible = false;
            }
            else
            {
               cost = this.parentWindow.inventory.completeNowCost();
               if(cost > 0)
               {
                  this.m_completeButton.setAmountText(String(cost));
                  this.m_completeButton.visible = true;
                  this.m_expandButton.visible = false;
               }
            }
         }
         else
         {
            this.m_completeButton.visible = false;
            this.m_expandButton.visible = false;
         }
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         this.refresh();
      }
      
      public function get parentWindow() : FeatureCraftingStorageWindow
      {
         if(!this.m_parentWindow)
         {
            this.m_parentWindow = getAncestorByClassType(FeatureCraftingStorageWindow) as FeatureCraftingStorageWindow;
         }
         return this.m_parentWindow;
      }
      
      private function onCompleteButtonClick(event:MouseEvent) : void
      {
         this.m_completeButton.enabled = false;
         var cost:int = this.parentWindow.inventory.completeNowCost();
         var message:String = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StorageExpansion_UnlockButton_Confirmation",{"cost":cost});
         UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onUnlockMessageClose,"FeatureCraftingUnlockStorage",true);
      }
      
      private function onUnlockMessageClose(event:GenericPopupEvent) : void
      {
         this.m_completeButton.enabled = true;
         if(event.button == GenericPopup.OK)
         {
            if(this.m_completeButton.enabled && GlobalEngine.currentTime >= this.m_lastClickTime + DOUBLE_CLICK_DELAY)
            {
               this.m_lastClickTime = GlobalEngine.currentTime;
               this.parentWindow.inventory.completeNow();
               if(this.parentWindow.inventory.hasReachedMaxInventory())
               {
                  this.parentWindow.refresh();
               }
               else
               {
                  this.parentWindow.refreshCount();
               }
               this.refresh();
            }
         }
      }
      
      private function onExpandButtonClick(event:MouseEvent) : void
      {
         if(this.m_expandButton.enabled)
         {
            this.parentWindow.inventory.expandInventory();
            if(this.parentWindow.inventory.hasReachedMaxInventory())
            {
               this.parentWindow.refresh();
            }
            else
            {
               this.parentWindow.refreshCount();
            }
            this.refresh();
         }
      }
   }
}

