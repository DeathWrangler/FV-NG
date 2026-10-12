package Widgets.Slots.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class VisitingMarketStallSlot extends ZwSlotFrame
   {
      
      protected var m_data:MarketInventoryItem = null;
      
      protected var m_Item:FarmItem = null;
      
      protected var m_CropName:ZwTextField;
      
      protected var m_CropIcon:FarmIcon;
      
      protected var m_GetCropButton:FarmAnimatedTextButton;
      
      protected var m_BuyButton:FarmAnimatedTextButton;
      
      protected var m_Amount:ZwTextField;
      
      protected var m_SiloAmount:ZwTextField;
      
      protected var m_TakeItemCallback:Function;
      
      protected var m_BuyItemCallback:Function;
      
      protected var m_OwnerUid:String;
      
      protected var m_mode:String;
      
      public function VisitingMarketStallSlot(element:DisplayObject, takeItemCallback:Function, buyItemCallback:Function, uid:String)
      {
         super(element);
         this.m_TakeItemCallback = takeItemCallback;
         this.m_BuyItemCallback = buyItemCallback;
         this.m_CropName = new ZwTextField(m_element.cropType_tf,"");
         this.m_OwnerUid = uid;
         addWidget(this.m_CropName);
         this.m_CropIcon = new FarmIcon(m_element.bushelIcon_mc);
         this.m_CropIcon.setIconSize(90,90);
         addWidget(this.m_CropIcon);
         this.m_GetCropButton = new FarmAnimatedTextButton(m_element.take_bt,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_TakeOne"),this.onTakeOneClick);
         this.m_GetCropButton.enabled = false;
         addWidget(this.m_GetCropButton);
         this.m_BuyButton = new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_Buy"),this.onBuyClick);
         this.m_BuyButton.enabled = false;
         addWidget(this.m_BuyButton);
         this.m_Amount = new ZwTextField(m_element.amount_mc.amount_tf);
         addWidget(this.m_Amount,true);
         this.m_SiloAmount = new ZwTextField(m_element.siloAmount_tf,"");
         addWidget(this.m_SiloAmount);
         addWidget(new ZwWidget(m_element.level_mc),true);
         addWidget(new ZwTextField(m_element.level_mc.level_tf),true);
      }
      
      private function onTakeOneClick(evt:MouseEvent) : void
      {
         if(this.m_GetCropButton.enabled && this.m_data != null)
         {
            this.m_GetCropButton.enabled = false;
            if(this.m_TakeItemCallback != null)
            {
               this.m_TakeItemCallback(this.m_data.itemCode);
            }
         }
      }
      
      private function onBuyClick(evt:MouseEvent) : void
      {
         if(this.m_BuyButton.enabled && this.m_data != null)
         {
            this.m_BuyButton.enabled = false;
            if(this.m_BuyItemCallback != null)
            {
               this.m_BuyItemCallback(this.m_data);
            }
         }
         if(Global.worldManager.isVisiting())
         {
            FarmStatsManager.count("crafting_cottage","shop","from_your_farm",this.m_Item.name);
         }
         else
         {
            FarmStatsManager.count("crafting_cottage","shop","from_my_farm",this.m_Item.name);
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as MarketInventoryItem;
         this.m_Item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.itemCode);
         this.m_CropIcon.loadIcon(this.m_Item.icon);
         if(this.m_data.price > 0)
         {
            this.renderPurchasePresentation();
         }
         else
         {
            this.renderFreePresentation();
         }
         if(this.m_mode == "bushels")
         {
            this.m_CropName.text = this.m_Item.friendlyTitle;
            m_element.level_mc.visible = false;
            this.m_Amount.visible = false;
         }
         else
         {
            this.m_CropName.text = ZLocUtils.tk_pk_asTitle("Items:" + this.m_Item.name + "_friendlyName");
            (getWidget(m_element.level_mc.level_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingCottages_Level2",{"quantity":this.m_data.level});
            m_element.level_mc.visible = true;
            this.m_Amount.visible = true;
            this.m_Amount.text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_Amount",{"quantity":this.m_data.quantity});
         }
      }
      
      private function renderFreePresentation() : void
      {
         this.m_BuyButton.visible = false;
         this.m_GetCropButton.visible = true;
         this.m_GetCropButton.enabled = CraftingManager.getInstance().canPurchaseFromUser(this.m_OwnerUid);
         this.m_SiloAmount.text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_SiloInventory",{"quantity":CraftingManager.getInstance().getBushelQuantityInInventory(this.m_data.itemCode)});
      }
      
      private function renderPurchasePresentation() : void
      {
         this.m_GetCropButton.visible = false;
         this.m_BuyButton.visible = true;
         this.m_BuyButton.enabled = CraftingManager.getInstance().canPurchaseCraftingGoodFromUser(this.m_OwnerUid) && Global.player.canBuy(this.m_data.price,false);
         this.m_BuyButton.text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_Buy");
         this.m_SiloAmount.text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_Price",{"quantity":Utilities.formatNumber(this.m_data.price)});
      }
      
      override public function release() : void
      {
         super.release();
         this.m_CropName = null;
         this.m_CropIcon = null;
         this.m_GetCropButton = null;
         this.m_Amount = null;
         this.m_SiloAmount = null;
         this.m_Item = null;
         this.m_data = null;
      }
      
      override public function clearView() : void
      {
      }
      
      public function set mode(modeIn:String) : void
      {
         this.m_mode = modeIn;
      }
      
      public function setButtonEnable(bool:Boolean) : void
      {
         this.m_BuyButton.enabled = bool;
         this.m_GetCropButton.enabled = bool;
      }
   }
}

