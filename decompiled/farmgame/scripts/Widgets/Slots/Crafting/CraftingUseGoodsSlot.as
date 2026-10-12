package Widgets.Slots.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.storage.CraftedItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CraftingUseGoodsSlot extends ZwSlotFrame
   {
      
      private var m_clickCallback:Function = null;
      
      private var m_item:FarmItem = null;
      
      private var m_data:CraftedItem = null;
      
      private var m_toolTip:FarmTextTooltip = null;
      
      public function CraftingUseGoodsSlot(element:DisplayObject, clickCallback:Function)
      {
         this.m_clickCallback = clickCallback;
         super(element);
         addWidget(new ZwTextField(m_element.generic_tf));
         addWidget(new ZwTextField(m_element.level_tf));
         addWidget(new ZwTextField(m_element.amount_tf));
         addWidget(new FarmIcon(m_element.icon_mc));
         (getWidget(m_element.icon_mc) as FarmIcon).setIconSize(50,50);
         addWidget(new FarmAnimatedTextButton(m_element.use_bt,ZLocUtils.t("Crafting","CraftingUseGoods_Use"),this.onUseClick));
         this.m_toolTip = new FarmTextTooltip();
         this.attachTooltip(this.m_toolTip);
      }
      
      private function onUseClick(evt:MouseEvent) : void
      {
         if(this.m_clickCallback != null)
         {
            this.m_clickCallback(this.m_data);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var recipeItem:RecipeItem = null;
         var fuel:Number = NaN;
         var rewardItem:FarmItem = null;
         var rewardQty:Number = NaN;
         this.m_data = data as CraftedItem;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.itemCode);
         if(this.m_data)
         {
            recipeItem = Global.craftConfigSettings.getRecipeByProductItemCode(this.m_data.itemCode);
            fuel = recipeItem ? Global.craftConfigSettings.getFuelRewardForGood(this.m_data.level,recipeItem) : 0;
            if(Boolean(recipeItem) && Boolean(recipeItem.onUseItemCode))
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(recipeItem.onUseItemCode);
               rewardQty = recipeItem.onUseQuantity;
               this.m_toolTip.setText(ZLocUtils.t("Crafting","CraftingGetGoods_ToolTipB",{
                  "item":ZLocUtils.tk_pk(this.m_item.friendlyName),
                  "quantity":fuel,
                  "rewardQuantity":rewardQty,
                  "rewardItem":ZLocUtils.tk_pk(rewardItem.friendlyName,"",rewardQty)
               }));
            }
            else
            {
               this.m_toolTip.setText(ZLocUtils.t("Crafting","CraftingGetGoods_ToolTip",{
                  "item":ZLocUtils.tk_pk(this.m_item.friendlyName),
                  "quantity":fuel
               }));
            }
            (getWidget(m_element.generic_tf) as ZwTextField).text = this.m_item.friendlyTitle;
            (getWidget(m_element.level_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingUseGoods_Level2",{"levelNum":this.m_data.level});
            (getWidget(m_element.amount_tf) as ZwTextField).text = this.m_data.quantity.toString();
            (getWidget(m_element.icon_mc) as FarmIcon).loadIcon(this.m_item.icon);
            (getWidget(m_element.generic_tf) as ZwTextField).visible = true;
            (getWidget(m_element.level_tf) as ZwTextField).visible = true;
            (getWidget(m_element.amount_tf) as ZwTextField).visible = true;
            (getWidget(m_element.icon_mc) as FarmIcon).visible = true;
            (getWidget(m_element.use_bt) as FarmAnimatedTextButton).visible = true;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_clickCallback = null;
         this.m_item = null;
         this.m_data = null;
         this.m_toolTip = null;
      }
      
      public function setEnabled(enable:Boolean) : void
      {
         (getWidget(m_element.use_bt) as FarmAnimatedTextButton).enabled = enable;
      }
   }
}

