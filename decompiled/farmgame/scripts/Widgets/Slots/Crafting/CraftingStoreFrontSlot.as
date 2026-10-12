package Widgets.Slots.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Classes.crafting.RecipeItem;
   import Classes.crafting.RecipeState;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CraftingStoreFrontSlot extends ZwSlotFrame
   {
      
      protected var m_data:MarketInventoryItem = null;
      
      protected var m_Item:FarmItem = null;
      
      protected var m_SetPriceButton:FarmAnimatedTextButton;
      
      protected var m_CropTypeText:ZwTextField;
      
      protected var m_AmountTypeText:ZwTextField;
      
      protected var m_PriceText:ZwTextField;
      
      protected var m_FarmIcon:FarmIcon;
      
      protected var m_SetPriceCallback:Function;
      
      private var m_itemQuantityToolTip:FarmTextTooltip = null;
      
      public function CraftingStoreFrontSlot(element:DisplayObject, setPriceCallBack:Function)
      {
         super(element);
         this.m_CropTypeText = new ZwTextField(m_element.recipe_tf);
         addWidget(this.m_CropTypeText);
         this.m_AmountTypeText = new ZwTextField(m_element.amount_tf);
         addWidget(this.m_AmountTypeText);
         this.m_PriceText = new ZwTextField(m_element.price_tf);
         addWidget(this.m_PriceText);
         this.m_FarmIcon = new FarmIcon(m_element.Icon_mc);
         this.m_FarmIcon.setIconSize(70,70);
         addWidget(this.m_FarmIcon);
         addWidget(new ZwWidget(m_element.emptyCell_mc),false);
         addWidget(new ZwTextField(m_element.level_tf));
         m_element.Star___Gray_1.visible = true;
         addWidget(new ZwTextField(m_element.emptyCell_mc.generic_tf,ZLocUtils.t("Crafting","StoreFrontDialog_NoGoodsForSale")));
      }
      
      override public function populate(data:Object) : void
      {
         var variant:int = 0;
         var recipeItem:RecipeItem = null;
         var recipeState:RecipeState = null;
         super.populate(data);
         if(data.hasOwnProperty("itemCode"))
         {
            this.m_data = data as MarketInventoryItem;
            this.m_Item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.itemCode);
            if(this.m_Item != null)
            {
               this.m_CropTypeText.text = ZLocUtils.tk_pk_asTitle(this.m_Item.friendlyName);
               variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_WINERY_DISPLAY_TOOLTIP);
               if(variant == Experiments.VARIANT_FLASH_WINERY_DISPLAY_TOOLTIP_ALWAYS || this.m_data.quantity >= 100)
               {
                  if(this.m_itemQuantityToolTip == null)
                  {
                     this.m_itemQuantityToolTip = new FarmTextTooltip();
                  }
                  this.m_itemQuantityToolTip.setText(String(this.m_data.quantity));
                  this.m_AmountTypeText.attachTooltip(this.m_itemQuantityToolTip);
               }
               this.m_AmountTypeText.text = String(this.m_data.quantity);
               if(this.m_data.price >= 0)
               {
                  this.m_PriceText.text = ZLocUtils.t("Crafting","StoreFrontDialog_PriceSet",{"quantity":Utilities.formatNumber(this.m_data.getTaxedPrice())});
               }
               else
               {
                  this.m_PriceText.text = ZLocUtils.t("Crafting","StoreFrontDialog_PriceNotSet");
               }
               this.m_FarmIcon.loadIcon(this.m_Item.icon);
               recipeItem = Global.craftConfigSettings.getRecipeByProductItemCode(this.m_data.itemCode);
               recipeState = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipeItem.id);
               m_element.level_tf.text = ZLocUtils.t("Crafting","CraftingCottages_Level2",{"quantity":recipeState.level});
               this.m_CropTypeText.visible = true;
               this.m_AmountTypeText.visible = true;
               this.m_PriceText.visible = true;
               this.m_FarmIcon.visible = true;
               m_element.Star___Gray_1.visible = true;
               m_element.level_tf.visible = true;
               m_element.emptyCell_mc.visible = false;
            }
            else
            {
               this.populateEmptySlot();
               if(Config.DEBUG_MODE)
               {
                  ErrorManager.addError(data["itemCode"] + " is not in Items.xml");
               }
            }
         }
         else
         {
            this.populateEmptySlot();
         }
      }
      
      private function populateEmptySlot() : void
      {
         this.m_CropTypeText.visible = false;
         this.m_AmountTypeText.visible = false;
         this.m_PriceText.visible = false;
         this.m_FarmIcon.visible = false;
         m_element.Star___Gray_1.visible = false;
         m_element.level_tf.visible = false;
         m_element.emptyCell_mc.visible = true;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_CropTypeText = null;
         this.m_AmountTypeText = null;
         this.m_PriceText = null;
         this.m_FarmIcon = null;
         this.m_data = null;
         this.m_Item = null;
         this.m_itemQuantityToolTip = null;
      }
      
      private function onSetPriceClicked(evt:MouseEvent) : void
      {
         if(this.m_SetPriceCallback != null)
         {
            this.m_SetPriceCallback(this.m_data);
         }
      }
      
      override public function clearView() : void
      {
      }
   }
}

