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
   import Widgets.Windows.FeatureCrafting.FeatureCraftingContentsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingIngredientSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      protected var m_parentWindow:FeatureCraftingContentsWindow;
      
      protected var m_data:FeatureCraftingRequiredGood;
      
      private var m_icon:FarmIcon;
      
      private var m_checkWidget:ZwWidget;
      
      private var m_countTextField:ZwTextField;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      public function FeatureCraftingIngredientSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_icon.attachTooltip(new FarmTextTooltip(""));
         this.m_checkWidget = addWidget(new ZwWidget(m_element.checkMark_mc)) as ZwWidget;
         this.m_countTextField = addWidget(new ZwTextField(m_element.generic_tf," ")) as ZwTextField;
         this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,"BUY","00",this.onBuyButtonClick)) as FarmAnimatedCashButton;
      }
      
      override public function release() : void
      {
         if(Boolean(this.m_data.system.currentNPCWindow) && this.m_data.system.currentNPCWindow.hasSingleRecipeWindow)
         {
            (this.m_icon.element as MovieClip).removeEventListener(MouseEvent.CLICK,this.onIconClick);
            (this.m_icon.element as MovieClip).removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            (this.m_icon.element as MovieClip).removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         }
         this.m_parentWindow = null;
         this.m_icon = null;
         this.m_checkWidget = null;
         this.m_countTextField = null;
         this.m_buyButton = null;
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
            (this.m_icon.tooltip as FarmTextTooltip).setText(this.m_data.good.friendlyTitle);
            if(Boolean(this.m_data.system.currentNPCWindow) && this.m_data.system.currentNPCWindow.hasSingleRecipeWindow)
            {
               (this.m_icon.element as MovieClip).addEventListener(MouseEvent.CLICK,this.onIconClick);
               (this.m_icon.element as MovieClip).addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
               (this.m_icon.element as MovieClip).addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
               (this.m_icon.element as MovieClip).buttonMode = true;
            }
            this.refresh();
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
      
      public function refresh() : void
      {
         var numOwned:int = 0;
         var numRequired:int = 0;
         var parentSlot:FeatureCraftingRecipeSlot = null;
         if(this.m_data)
         {
            numOwned = this.m_data.good.inventoryCount;
            numRequired = this.m_data.numRequired;
            this.m_countTextField.text = numOwned + "/" + numRequired;
            this.m_countTextField.visible = true;
            if(numOwned >= numRequired)
            {
               this.m_checkWidget.visible = true;
               this.m_buyButton.visible = false;
            }
            else
            {
               parentSlot = getAncestorByClassType(FeatureCraftingRecipeSlot) as FeatureCraftingRecipeSlot;
               if(parentSlot.data.unlocked)
               {
                  this.m_buyButton.visible = true;
                  this.m_buyButton.setAmountText(this.m_data.good.costToBuy().toString());
               }
               else
               {
                  this.m_buyButton.visible = false;
               }
               this.m_checkWidget.visible = false;
            }
         }
      }
      
      public function hasEnough() : Boolean
      {
         var result:Boolean = false;
         var numOwned:int = 0;
         var numRequired:int = 0;
         if(this.m_data)
         {
            numOwned = this.m_data.good.inventoryCount;
            numRequired = this.m_data.numRequired;
            result = numOwned >= numRequired;
         }
         return result;
      }
      
      private function onIconClick(event:MouseEvent) : void
      {
         var recipe:FeatureCraftingRecipe = null;
         var station:FeatureCraftingStation = this.m_data.system.getStationThatMakesRecipe(this.m_data.good.name);
         if(Boolean(station) && !station.autoStart)
         {
            if(Boolean(this.m_data.system.currentNPCWindow) && this.m_data.system.currentNPCWindow.hasSingleRecipeWindow)
            {
               recipe = this.m_data.system.getRecipe(this.m_data.good.name);
               this.m_data.system.currentNPCWindow.updateSingleRecipeWindow(recipe,station);
            }
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var text:String = null;
         var parentSlot:FeatureCraftingRecipeSlot = null;
         if(this.m_buyButton.enabled)
         {
            if(this.m_data)
            {
               if(this.m_data.good.costToBuy() >= 10)
               {
                  text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"FeatureCraftingGood_purchase_Confirmation",{
                     "cost":this.m_data.good.costToBuy(),
                     "goodName":this.m_data.good.friendlyTitle
                  });
                  UI.displayMessage(text,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyMessageClose,"FeatureCraftingUnlockStorage",true);
               }
               else
               {
                  this.m_data.good.buyGood(1,"recipe");
                  parentSlot = getAncestorByClassType(FeatureCraftingRecipeSlot) as FeatureCraftingRecipeSlot;
                  parentSlot.refresh();
                  if(Boolean(this.m_data.system.currentNPCWindow) && Boolean(this.m_data.system.currentNPCWindow.hasSingleRecipeWindow) && this.m_data.system.currentNPCWindow.isSingleRecipeWindowOpen)
                  {
                     this.m_data.system.currentNPCWindow.singleRecipeWindow.refresh();
                  }
               }
            }
         }
      }
      
      private function onBuyMessageClose(event:GenericPopupEvent) : void
      {
         var parentSlot:FeatureCraftingRecipeSlot = null;
         if(event.button == GenericPopup.OK)
         {
            this.m_data.good.buyGood(1,"recipe");
            parentSlot = getAncestorByClassType(FeatureCraftingRecipeSlot) as FeatureCraftingRecipeSlot;
            parentSlot.refresh();
            if(Boolean(this.m_data.system.currentNPCWindow) && Boolean(this.m_data.system.currentNPCWindow.hasSingleRecipeWindow) && this.m_data.system.currentNPCWindow.isSingleRecipeWindowOpen)
            {
               this.m_data.system.currentNPCWindow.singleRecipeWindow.refresh();
            }
         }
      }
   }
}

