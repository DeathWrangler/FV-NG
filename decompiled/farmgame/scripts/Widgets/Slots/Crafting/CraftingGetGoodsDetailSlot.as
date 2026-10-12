package Widgets.Slots.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CraftingGetGoodsDetailSlot extends ZwSlotFrame
   {
      
      public var marketInventoryItem:MarketInventoryItem = null;
      
      private var m_callback:Function = null;
      
      private var m_item:FarmItem = null;
      
      private var m_toolTip:FarmTextTooltip;
      
      public function CraftingGetGoodsDetailSlot(element:DisplayObject, callback:Function)
      {
         super(element);
         this.m_callback = callback;
         addWidget(new ZwWidget(m_element.friendEmpty_mc));
         addWidget(new ZwWidget(m_element.friendFull_mc));
         addWidget(new ZwWidget(m_element.friendFull_mc.coin_mc));
         addWidget(new ZwTextField(m_element.friendFull_mc.cost_tf));
         addWidget(new ZwTextField(m_element.friendFull_mc.level_tf));
         addWidget(new FarmAnimatedTextButton(m_element.friendFull_mc.take_bt,ZLocUtils.t("Crafting","CraftingGetGoods_Take"),this.onTake));
         addWidget(new FarmIcon(m_element.friendFull_mc.icon_mc));
         (getWidget(m_element.friendFull_mc.icon_mc) as FarmIcon).setIconSize(50,50);
         this.m_toolTip = new FarmTextTooltip();
         (getWidget(m_element.friendFull_mc) as ZwWidget).attachTooltip(this.m_toolTip);
      }
      
      override public function populate(data:Object) : void
      {
         var recipeItem:RecipeItem = null;
         var fuel:Number = NaN;
         this.marketInventoryItem = data as MarketInventoryItem;
         if(this.marketInventoryItem)
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.marketInventoryItem.itemCode);
            if(this.m_item)
            {
               recipeItem = Global.craftConfigSettings.getRecipeByProductItemCode(this.marketInventoryItem.itemCode);
               fuel = Global.craftConfigSettings.getFuelRewardForGood(this.marketInventoryItem.level,recipeItem);
               this.m_toolTip.setText(ZLocUtils.t("Crafting","CraftingGetGoods_ToolTip",{
                  "item":ZLocUtils.tk_pk(this.m_item.friendlyName),
                  "quantity":fuel
               }));
               (getWidget(m_element.friendFull_mc.cost_tf) as ZwTextField).text = this.marketInventoryItem.price.toString();
               (getWidget(m_element.friendFull_mc.level_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingGetGoods_Level2",{"levelNum":this.marketInventoryItem.level});
               (getWidget(m_element.friendFull_mc.icon_mc) as FarmIcon).loadIcon(this.m_item.icon);
               (getWidget(m_element.friendFull_mc) as ZwWidget).visible = true;
               (getWidget(m_element.friendFull_mc.coin_mc) as ZwWidget).visible = true;
               (getWidget(m_element.friendFull_mc.cost_tf) as ZwTextField).visible = true;
               (getWidget(m_element.friendFull_mc.level_tf) as ZwTextField).visible = true;
               (getWidget(m_element.friendFull_mc.take_bt) as FarmAnimatedTextButton).visible = true;
               (getWidget(m_element.friendFull_mc.icon_mc) as FarmIcon).visible = true;
            }
         }
         else
         {
            (getWidget(m_element.friendEmpty_mc) as ZwWidget).visible = true;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.marketInventoryItem = null;
         this.m_item = null;
         this.m_callback = null;
      }
      
      private function onTake(event:MouseEvent) : void
      {
         this.m_toolTip.setText("");
         if(this.m_callback != null)
         {
            this.m_callback(this);
         }
      }
   }
}

