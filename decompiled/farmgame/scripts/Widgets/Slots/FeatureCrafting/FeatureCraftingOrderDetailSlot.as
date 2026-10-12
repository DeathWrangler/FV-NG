package Widgets.Slots.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingRecipe;
   import Classes.FeatureCrafting.FeatureCraftingRequiredGood;
   import Classes.FeatureCrafting.FeatureCraftingStation;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingRecipesWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingOrderDetailSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_data:FeatureCraftingRequiredGood;
      
      private var m_icon:FarmIcon;
      
      private var m_checkWidget:ZwWidget;
      
      private var m_countTextField:ZwTextField;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      public function FeatureCraftingOrderDetailSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.clearScale();
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_icon.attachTooltip(new FarmTextTooltip(""));
         (this.m_icon.element as MovieClip).addEventListener(MouseEvent.CLICK,this.onIconClick);
         this.m_checkWidget = addWidget(new ZwWidget(m_element.check_mc)) as ZwWidget;
         this.m_countTextField = addWidget(new ZwTextField(m_element.count_tf," ")) as ZwTextField;
         this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_mc,"BUY","00",this.onBuyButtonClick)) as FarmAnimatedCashButton;
      }
      
      override public function release() : void
      {
         (this.m_icon.element as MovieClip).removeEventListener(MouseEvent.CLICK,this.onIconClick);
         (this.m_icon.element as MovieClip).removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         (this.m_icon.element as MovieClip).removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         this.m_icon = null;
         this.m_checkWidget = null;
         this.m_countTextField = null;
         this.m_buyButton = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var station:FeatureCraftingStation = null;
         var tooltipText:String = null;
         super.populate(data);
         this.m_data = data as FeatureCraftingRequiredGood;
         if(this.m_data)
         {
            this.m_icon.loadIcon(this.m_data.good.iconUrl());
            this.m_icon.visible = true;
            station = this.m_data.system.getStationThatMakesRecipe(this.m_data.good.name);
            tooltipText = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"GoodTooltip",{
               "goodName":this.m_data.good.friendlyTitle,
               "stationName":station.friendlyTitle
            });
            (this.m_icon.tooltip as FarmTextTooltip).setText(tooltipText);
            (this.m_icon.element as MovieClip).buttonMode = !this.m_data.hasEnough && !station.autoStart;
            (this.m_icon.element as MovieClip).addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            (this.m_icon.element as MovieClip).addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
            this.m_countTextField.text = this.m_data.good.inventoryCount + "/" + this.m_data.numRequired;
            this.m_countTextField.visible = true;
            if(this.m_data.hasEnough)
            {
               this.m_checkWidget.visible = true;
               this.m_buyButton.visible = false;
            }
            else
            {
               this.m_buyButton.visible = true;
               this.m_buyButton.setAmountText(this.m_data.good.costToBuy().toString());
               this.m_checkWidget.visible = false;
            }
            (this.m_icon.element as MovieClip).buttonMode = !this.m_data.hasEnough && !station.autoStart;
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var cost:int = 0;
         var message:String = null;
         if(this.m_data.good.costToBuy() >= 10)
         {
            cost = this.m_data.good.costToBuy();
            message = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"FeatureCraftingGood_purchase_Confirmation",{
               "cost":cost,
               "goodName":this.m_data.good.friendlyTitle
            });
            UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onUnlockMessageClose,"FeatureCraftingUnlockStorage",true);
         }
         else
         {
            this.processBuyGood();
         }
      }
      
      private function onUnlockMessageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            this.processBuyGood();
         }
      }
      
      private function processBuyGood() : void
      {
         if(this.m_buyButton.enabled)
         {
            if(this.m_data)
            {
               this.m_data.good.buyGood(1,"order");
            }
         }
      }
      
      private function onIconClick(event:MouseEvent) : void
      {
         var recipe:FeatureCraftingRecipe = null;
         var messageText:String = null;
         var station:FeatureCraftingStation = this.m_data.system.getStationThatMakesRecipe(this.m_data.good.name);
         if(Boolean(station) && !station.autoStart)
         {
            if(this.m_data.system.currentNPCWindow.hasSingleRecipeWindow)
            {
               recipe = this.m_data.system.getRecipe(this.m_data.good.name);
               this.m_data.system.currentNPCWindow.updateSingleRecipeWindow(recipe,station);
            }
            else if(!this.m_data.hasEnough)
            {
               if(!station.active)
               {
                  FeatureCraftingRecipesWindow.display(station,this.refreshContentWindow);
               }
               else
               {
                  messageText = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StationBusyMessage",{"stationName":station.friendlyTitle});
                  UI.displayMessage(messageText,GenericPopup.TYPE_OK,null,"StationBusyMessage",true);
               }
            }
         }
      }
      
      private function refreshContentWindow(result:Boolean) : void
      {
         if(this.m_data.system.currentContentsWindow)
         {
            this.m_data.system.currentContentsWindow.refresh();
         }
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         var station:FeatureCraftingStation = this.m_data.system.getStationThatMakesRecipe(this.m_data.good.name);
         var stationSlot:FeatureCraftingStationSlot = null;
         if(!station.autoStart)
         {
            stationSlot = this.m_data.system.currentContentsWindow.recipeStationSlots.getSlotIdByStation(station);
         }
         else
         {
            stationSlot = this.m_data.system.currentContentsWindow.ingredientStationSlots.getSlotIdByStation(station);
         }
         if(Boolean(station) && Boolean(stationSlot))
         {
            stationSlot.toggleTooltip(true);
         }
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
         this.m_data.system.currentContentsWindow.ingredientStationSlots.hideAllTooltips();
         this.m_data.system.currentContentsWindow.recipeStationSlots.hideAllTooltips();
      }
   }
}

