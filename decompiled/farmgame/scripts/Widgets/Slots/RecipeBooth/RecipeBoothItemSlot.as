package Widgets.Slots.RecipeBooth
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Managers.RecipeBoothManager;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Tooltips.WidgetTooltip;
   import Widgets.Windows.RecipeBooth.RecipeBoothWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   public final class RecipeBoothItemSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_itemName:String;
      
      private var m_previewFrame:ObjectPreviewFrame;
      
      private var m_checkWidget:ZwWidget;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_hitWidget:ZwWidget;
      
      private var m_actionTooltip:WidgetTooltip;
      
      private var m_actionTooltipFrame:RecipeBoothItemSlotTooltipFrame;
      
      public function RecipeBoothItemSlot(element:DisplayObject)
      {
         super(element);
         this.m_checkWidget = addWidget(new ZwWidget(m_element.checked_mc)) as ZwWidget;
         this.m_nameTextField = addWidget(new ZwTextField(m_element.itemname_tf," ")) as ZwTextField;
         if(m_element.hit_bt)
         {
            this.m_hitWidget = addWidget(new ZwWidget(m_element.hit_bt)) as ZwWidget;
            (this.m_hitWidget.element as SimpleButton).useHandCursor = false;
         }
         this.m_actionTooltipFrame = new RecipeBoothItemSlotTooltipFrame(m_element.tooltip_mc,this.onBuyButtonClick) as RecipeBoothItemSlotTooltipFrame;
         this.m_actionTooltip = new WidgetTooltip(this.m_actionTooltipFrame);
         this.m_actionTooltip.fixed = true;
         this.m_actionTooltip.interactive = true;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_itemName = data as String;
         this.refresh();
      }
      
      override public function release() : void
      {
         this.m_previewFrame = null;
         this.m_checkWidget = null;
         this.m_nameTextField = null;
         super.release();
      }
      
      private function refresh() : void
      {
         var item:FarmItem = null;
         var parentWindow:RecipeBoothWindow = null;
         var itemWon:int = 0;
         if(this.m_itemName)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
            if(item)
            {
               if(item.displayLoader.canUseAnimation)
               {
                  item.displayLoader.useAnimation = true;
               }
               if(this.m_previewFrame != null)
               {
                  removeWidget(this.m_previewFrame);
               }
               this.m_previewFrame = addWidget(new ObjectPreviewFrame(m_element.item_mc,item,null,null,[ICON_SIZE])) as ObjectPreviewFrame;
               (this.m_previewFrame.element as MovieClip).mouseEnabled = false;
               this.m_previewFrame.visible = true;
               this.m_nameTextField.text = item.friendlyTitle;
               this.m_nameTextField.visible = true;
               parentWindow = getAncestorByClassType(RecipeBoothWindow) as RecipeBoothWindow;
               itemWon = RecipeBoothManager.getBatchItemWonCount(parentWindow.featureName,parentWindow.batchName,this.m_itemName);
               this.m_checkWidget.visible = itemWon > 0;
               if(item.buyableWithCash())
               {
                  this.m_actionTooltipFrame.populate(this.m_itemName);
                  if(tooltip != this.m_actionTooltip)
                  {
                     attachTooltip(this.m_actionTooltip);
                     this.m_hitWidget.visible = true;
                  }
               }
               else if(tooltip == this.m_actionTooltip)
               {
                  detachTooltip();
               }
            }
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var parentWindow:RecipeBoothWindow = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(item)
         {
            Global.player.buyFarmItem(item,Currency.CASH,1,true,true,true,null,true);
            parentWindow = getAncestorByClassType(RecipeBoothWindow) as RecipeBoothWindow;
            FarmStatsManager.count(parentWindow.featureName,"buy_item",this.m_itemName);
         }
      }
   }
}

