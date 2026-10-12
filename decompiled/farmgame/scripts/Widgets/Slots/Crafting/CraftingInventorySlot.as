package Widgets.Slots.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CraftingInventorySlot extends ZwSlotFrame
   {
      
      private const HOME_FARM:String = "farm";
      
      private const EOS_PLAYERLOVE_2018:String = "fv_playerlove_2018";
      
      protected var m_data:MarketInventoryItem = null;
      
      protected var m_Item:FarmItem = null;
      
      protected var m_UseButton:FarmAnimatedTextButton;
      
      protected var m_ShareButton:FarmAnimatedTextButton;
      
      protected var m_MakeButton:FarmAnimatedTextButton;
      
      protected var m_CropTypeText:ZwTextField;
      
      protected var m_AmountTypeText:ZwTextField;
      
      protected var m_worldName:ZwTextField;
      
      protected var m_FarmIcon:FarmIcon;
      
      protected var m_OnUseCallback:Function;
      
      protected var m_ShareCallBack:Function;
      
      protected var m_MakeCallBack:Function;
      
      public function CraftingInventorySlot(element:DisplayObject, useCallBack:Function = null, shareCallBack:Function = null, makeCallBack:Function = null)
      {
         this.m_OnUseCallback = useCallBack;
         this.m_ShareCallBack = shareCallBack;
         this.m_MakeCallBack = makeCallBack;
         super(element);
         this.m_CropTypeText = new ZwTextField(m_element.cropType_tf);
         this.addWidget(this.m_CropTypeText);
         this.m_AmountTypeText = new ZwTextField(m_element.amount_tf);
         this.addWidget(this.m_AmountTypeText);
         if(m_element.theme_tf)
         {
            this.m_worldName = new ZwTextField(m_element.theme_tf);
            this.m_worldName.visible = false;
         }
         if(m_element.use_bt)
         {
            if(this.m_OnUseCallback != null)
            {
               this.m_UseButton = new FarmAnimatedTextButton(m_element.use_bt,ZLocUtils.t("Crafting","SiloInventoryDialog_UseButton"),this.onUseClick);
               this.addWidget(this.m_UseButton);
            }
            else
            {
               m_element.use_bt.visible = false;
            }
         }
         if(m_element.share_bt)
         {
            if(this.m_ShareCallBack != null)
            {
               this.m_ShareButton = new FarmAnimatedTextButton(m_element.share_bt,ZLocUtils.t("Crafting","SiloInventoryDialog_ShareButton"),this.onShareClick);
               this.addWidget(this.m_ShareButton);
            }
            else
            {
               m_element.share_bt.visible = false;
            }
         }
         if(m_element.makeSlop_bt)
         {
            if(this.m_MakeCallBack != null)
            {
               this.m_MakeButton = new FarmAnimatedTextButton(m_element.makeSlop_bt,ZLocUtils.t("Crafting","SiloInventoryDialog_MakeButton"),this.onMakeClick);
               this.addWidget(this.m_MakeButton);
            }
            else
            {
               m_element.makeSlop_bt.visible = false;
            }
         }
         this.m_FarmIcon = new FarmIcon(m_element.Icon_mc);
         this.m_FarmIcon.setIconSize(50,50);
         this.addWidget(this.m_FarmIcon);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.refresh(data);
      }
      
      public function refresh(data:Object) : void
      {
         this.m_data = data as MarketInventoryItem;
         this.m_Item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.itemCode);
         var worldname:String = null;
         var cropItem:FarmItem = null;
         if(this.m_Item != null)
         {
            this.m_CropTypeText.text = this.m_Item.friendlyTitle;
            this.m_AmountTypeText.text = "x" + String(this.m_data.quantity);
            this.m_FarmIcon.loadIcon(this.m_Item.icon);
            if(Global.eosManager.getEosVariant(this.EOS_PLAYERLOVE_2018) >= 1)
            {
               if(this.m_Item.crop)
               {
                  cropItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_Item.crop);
               }
               if(Boolean(this.m_Item.worldRestrictions) && this.m_Item.worldRestrictions.length > 0)
               {
                  worldname = this.m_Item.worldRestrictions[0].toString();
               }
               else if(Boolean(cropItem) && Boolean(cropItem.worldRestrictions) && cropItem.worldRestrictions.length > 0)
               {
                  worldname = cropItem.worldRestrictions[0].toString();
               }
               if(Boolean(worldname) && worldname != this.HOME_FARM)
               {
                  this.m_worldName.text = Global.worldManager.getWorldFriendlyName(worldname);
                  this.m_worldName.visible = true;
               }
               if(worldname == null)
               {
                  this.m_worldName.text = "";
                  this.m_worldName.visible = true;
               }
            }
            if(this.m_MakeButton != null)
            {
               if(this.m_data.quantity > 0)
               {
                  this.m_MakeButton.visible = true;
               }
               else
               {
                  this.m_MakeButton.visible = false;
               }
            }
            if(null == this.m_Item.crop || "" == this.m_Item.crop)
            {
               this.m_UseButton.visible = false;
            }
            else
            {
               this.m_UseButton.visible = true;
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_UseButton = null;
         this.m_ShareButton = null;
         this.m_MakeButton = null;
         this.m_CropTypeText = null;
         this.m_AmountTypeText = null;
         this.m_FarmIcon = null;
         this.m_data = null;
         this.m_Item = null;
      }
      
      private function onUseClick(evt:MouseEvent) : void
      {
         if(this.m_OnUseCallback != null)
         {
            this.m_OnUseCallback(this.m_data.itemCode);
         }
      }
      
      private function onShareClick(evt:MouseEvent) : void
      {
         if(this.m_ShareCallBack != null)
         {
            this.m_ShareCallBack(this.m_Item,this.m_data);
         }
      }
      
      private function onMakeClick(evt:MouseEvent) : void
      {
         if(this.m_MakeCallBack != null)
         {
            this.m_MakeCallBack(this,this.m_Item,this.m_data);
         }
      }
      
      override public function clearView() : void
      {
      }
   }
}

