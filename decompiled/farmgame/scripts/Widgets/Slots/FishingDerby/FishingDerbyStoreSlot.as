package Widgets.Slots.FishingDerby
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.FishingDerbyManager;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import gs.TweenLite;
   
   public class FishingDerbyStoreSlot extends ZwSlotFrame
   {
      
      private var m_itemName:ZwTextField;
      
      private var m_emptyText:ZwTextField;
      
      private var m_itemIcon:FarmIcon;
      
      private var m_buyCashFrame:ZwFrame;
      
      private var m_cashAmount:ZwTextField;
      
      private var m_counter:ZwTextField;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_farmItem:FarmItem;
      
      private var m_farmItemType:String;
      
      private const BAIT_TYPE:String = "bait";
      
      private const ROD_TYPE:String = "rod";
      
      private const BUFF_TYPE:String = "buff";
      
      private var m_questionMark:FarmButton;
      
      public function FishingDerbyStoreSlot(element:DisplayObject)
      {
         super(element);
         addWidget(this.m_itemName = new ZwTextField(m_element.title_tf));
         addWidget(this.m_itemIcon = new FarmIcon(m_element.icon_mc));
         addWidget(this.m_counter = new ZwTextField(m_element.counter_tf));
         addWidget(this.m_buyCashFrame = new ZwFrame(m_element.buyCash_mc));
         this.m_buyCashFrame.addWidget(this.m_cashAmount = new ZwTextField(m_element.buyCash_mc.cost_tf));
         addWidget(this.m_buyButton = new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t_pk("Dialogs","BuyPlain"),this.onBuyItem));
         if(m_element.hasOwnProperty("question_bt"))
         {
            addWidget(this.m_questionMark = new FarmButton(m_element.question_bt));
         }
         addWidget(new ZwBaseWidget(m_element.checkmark_mc),false);
      }
      
      override public function populate(data:Object) : void
      {
         var description:String = null;
         this.m_farmItem = Global.farmGameSettingsManager.getFarmItemByName(data.name as String);
         this.m_farmItemType = data.type as String;
         if(this.m_farmItem != null)
         {
            this.m_itemName.text = ZLocUtils.tk_pk_asTitle(this.m_farmItem.friendlyName);
            this.m_itemIcon.setSmoothing(true);
            this.m_itemIcon.loadIcon(this.m_farmItem.icon);
            this.m_cashAmount.text = this.m_farmItem.cash.toString();
            if(this.m_farmItem.count > 0)
            {
               this.m_counter.text = this.m_farmItem.count.toString();
               this.m_counter.visible = true;
            }
            this.m_itemName.visible = true;
            this.m_itemIcon.visible = true;
            this.m_buyCashFrame.visible = true;
            this.m_buyButton.visible = true;
            description = ZLocUtils.t_pk("Items",this.m_farmItem.name + "_message_tooltip");
            if(description != null)
            {
               if(this.m_questionMark)
               {
                  this.m_questionMark.visible = true;
                  this.m_questionMark.detachTooltip();
                  this.m_questionMark.attachTooltip(new FarmTextTooltip(description));
               }
            }
         }
      }
      
      private function onBuyItem(event:Event) : void
      {
         var mr:MapResource = null;
         if(this.m_farmItem != null)
         {
            mr = new MapResource(this.m_farmItem.name);
            if(Global.player.canBuyCash(this.m_farmItem.cash))
            {
               FarmStatsManager.count("fv_cash_buy",this.m_farmItem.type,this.m_farmItem.name,this.m_farmItem.cash.toString());
               this.m_buyButton.enabled = false;
               switch(this.m_farmItemType)
               {
                  case this.BAIT_TYPE:
                     this.buyBait();
                     break;
                  case this.ROD_TYPE:
                     this.buyRod();
                     break;
                  case this.BUFF_TYPE:
                     this.buyBuff();
               }
            }
         }
      }
      
      private function buyRod() : void
      {
         if(this.m_farmItem.cash >= 10)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","Fishing_BuyItemPrompt",{
               "cashQuantity":this.m_farmItem.cash,
               "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)
            }),GenericPopup.TYPE_ACCEPTCANCEL,function(event:GenericPopupEvent):void
            {
               if(event.button == GenericPopup.YES)
               {
                  FishingDerbyManager.instance.equipRod(m_farmItem.name);
                  fadeCheckMark();
               }
            },"",true);
         }
         else
         {
            FishingDerbyManager.instance.equipRod(this.m_farmItem.name);
            this.fadeCheckMark();
         }
         this.m_buyButton.enabled = true;
      }
      
      private function fadeCheckMark() : void
      {
         if(m_element["checkmark_mc"])
         {
            (m_element.checkmark_mc as MovieClip).visible = true;
            (m_element.checkmark_mc as MovieClip).alpha = 1;
            TweenLite.to(m_element.checkmark_mc,1.5,{"alpha":0});
         }
      }
      
      private function buyBuff() : void
      {
         if(this.m_farmItem.cash >= 10)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","Fishing_BuyItemPrompt",{
               "cashQuantity":this.m_farmItem.cash,
               "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)
            }),GenericPopup.TYPE_ACCEPTCANCEL,function(event:GenericPopupEvent):void
            {
               if(event.button == GenericPopup.YES)
               {
                  FishingDerbyManager.instance.equipBuff(m_farmItem.name);
                  fadeCheckMark();
               }
            },"",true);
         }
         else
         {
            FishingDerbyManager.instance.equipBuff(this.m_farmItem.name);
            this.fadeCheckMark();
         }
         this.m_buyButton.enabled = true;
      }
      
      private function buyBait() : void
      {
         if(this.m_farmItem.cash >= 10)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","Fishing_BuyItemPrompt",{
               "cashQuantity":this.m_farmItem.cash,
               "item":ZLocUtils.tk_pk_asTitlePlural(this.m_farmItem.friendlyName)
            }),GenericPopup.TYPE_ACCEPTCANCEL,function(event:GenericPopupEvent):void
            {
               if(event.button == GenericPopup.YES)
               {
                  buyConsumable();
                  fadeCheckMark();
               }
            },"",true);
         }
         else
         {
            this.buyConsumable();
            this.fadeCheckMark();
         }
         this.m_buyButton.enabled = true;
      }
      
      private function buyConsumable() : void
      {
         TransactionManager.addTransaction(new TBuyItemPutGiftbox(this.m_farmItem,Currency.CASH,1,false,true,function(result:Object):void
         {
            var giftName:* = undefined;
            var giftCount:* = undefined;
            var i:* = undefined;
            if(result)
            {
               giftName = FeatureConfigManager.getFeatureConfiguration(FishingDerbyManager.FEATURE_NAME).getStringConstant(m_farmItem.name);
               giftCount = Global.player.getGiftCountForItem(giftName);
               m_farmItem = Global.farmGameSettingsManager.getFarmItemByName(giftName);
               for(i = 0; i < giftCount; i++)
               {
                  m_farmItem.onUse(0,{
                     "isGift":false,
                     "allowReshopping":false
                  });
                  Global.player.removeGift(null,m_farmItem.name);
               }
               if(m_buyButton.element != null)
               {
                  m_buyButton.enabled = true;
               }
            }
         },true));
      }
   }
}

