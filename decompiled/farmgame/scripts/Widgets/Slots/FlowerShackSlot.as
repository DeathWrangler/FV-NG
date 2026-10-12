package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Managers.FlowerShackManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class FlowerShackSlot extends ZwSlotFrame
   {
      
      private static const BLOSSOM_MC:String = "blossom_mc";
      
      private static const BOUQUET_MC:String = "bouquet_mc";
      
      private static const BUY_BTN:String = "buy_bt";
      
      private static const BLOSSOM_ICON_MC:String = "icon_1_mc";
      
      private static const BOQUET_ICON_MC:String = "icon_2_mc";
      
      private static const ITEM_TXT:String = "subtitle1_tf";
      
      private static const BLOSSOM_SUFFIX:String = "blossom";
      
      private static const BOQUET_SUFFIX:String = "bouquet";
      
      private static const BLOSSOM_BUY_BTN:String = "buy_1_btn";
      
      private static const BOQUET_BUY_BTN:String = "buy_2_btn";
      
      private var m_owner:DisplayObject;
      
      private var m_data:Object;
      
      private var m_blossomMc:ZwWidget;
      
      private var m_boquetMc:ZwWidget;
      
      private var m_blossomIconMc:FarmIcon;
      
      private var m_boquetIconMc:FarmIcon;
      
      private var m_buyBtn:FarmAnimatedTextButton;
      
      private var m_titleTxt:ZwTextField;
      
      private var m_featureName:String;
      
      private var m_blossomBuyBtn:FarmAnimatedCashButton;
      
      private var m_boquetBuyBtn:FarmAnimatedTextButton;
      
      public function FlowerShackSlot(element:DisplayObject, owner:DisplayObject, featureName:String)
      {
         this.m_owner = owner;
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty(ITEM_TXT))
         {
            addWidget(this.m_titleTxt = new ZwTextField(m_element[ITEM_TXT],"Flower Name"),true);
         }
         if(m_element.hasOwnProperty(BLOSSOM_MC))
         {
            this.m_blossomMc = addWidget(new ZwWidget(m_element[BLOSSOM_MC]),true) as ZwWidget;
            if(this.m_blossomMc.element[BLOSSOM_ICON_MC])
            {
               addWidget(this.m_blossomIconMc = new FarmIcon(this.m_blossomMc.element[BLOSSOM_ICON_MC]));
            }
         }
         if(m_element.hasOwnProperty(BOUQUET_MC))
         {
            this.m_boquetMc = addWidget(new ZwWidget(m_element[BOUQUET_MC]),true) as ZwWidget;
            if(this.m_boquetMc.element[BOQUET_ICON_MC])
            {
               addWidget(this.m_boquetIconMc = new FarmIcon(this.m_boquetMc.element[BOQUET_ICON_MC]));
            }
         }
         if(m_element.hasOwnProperty(BLOSSOM_BUY_BTN))
         {
            this.m_blossomBuyBtn = new FarmAnimatedCashButton(m_element[BLOSSOM_BUY_BTN],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_buy_btn_txt"),"0",this.onBlossomBuyClick);
         }
         if(m_element.hasOwnProperty(BOQUET_BUY_BTN))
         {
            addWidget(this.m_boquetBuyBtn = new FarmAnimatedTextButton(m_element[BOQUET_BUY_BTN],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,FlowerShackManager.FEATURE_NAME + "_slot_buy_btn_txt"),this.onBoquetBuyClick),true);
         }
      }
      
      private function onBlossomBuyClick(e:Event) : void
      {
         var itemName:String = this.m_data["blossom"];
         this.onBuyClick(itemName);
      }
      
      private function onBoquetBuyClick(e:Event) : void
      {
         var itemName:String = this.m_data["bouquet"];
         this.onBuyClick(itemName);
      }
      
      private function onBuyClick(itemName:String) : void
      {
         var canBuy:Boolean = false;
         var currencyName:String = null;
         var bought:Boolean = false;
         var item:FarmItem = null;
         if(itemName.length)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         }
         if(item)
         {
            canBuy = FlowerShackManager.getInstance(this.m_featureName).canBuyItem(item);
            if(canBuy)
            {
               currencyName = FlowerShackManager.getInstance(this.m_featureName).currencyName;
               bought = Global.player.buyFarmItem(item,currencyName,1,false);
               if(bought)
               {
                  FlowerShackManager.getInstance(this.m_featureName).closeWindow();
               }
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         var blossomItem:FarmItem = null;
         var canBuyBlossom:Boolean = false;
         var blossomBuyCost:TextField = null;
         var boquetItem:FarmItem = null;
         var canBuyBoquet:Boolean = false;
         var boquetBuyCost:TextField = null;
         super.populate(data);
         this.m_data = data;
         if(this.m_blossomBuyBtn)
         {
            this.m_blossomBuyBtn.visible = true;
            this.m_blossomBuyBtn.enabled = false;
         }
         if(this.m_boquetBuyBtn)
         {
            this.m_boquetBuyBtn.visible = true;
            this.m_boquetBuyBtn.enabled = false;
         }
         var blossomName:String = "";
         var bouquetName:String = "";
         if(this.m_data.hasOwnProperty("blossom"))
         {
            blossomName = this.m_data["blossom"];
         }
         if(this.m_data.hasOwnProperty("bouquet"))
         {
            bouquetName = this.m_data["bouquet"];
         }
         if(blossomName != "")
         {
            this.setTitle(blossomName);
            blossomItem = Global.farmGameSettingsManager.getFarmItemByName(blossomName);
            canBuyBlossom = FlowerShackManager.getInstance(this.m_featureName).canBuyItem(blossomItem);
            if(canBuyBlossom)
            {
               if(this.m_blossomBuyBtn)
               {
                  this.m_blossomBuyBtn.enabled = true;
               }
            }
            if(Boolean(blossomItem && blossomItem.iconUrl) && Boolean(this.m_blossomIconMc) && Boolean(this.m_blossomMc))
            {
               this.m_blossomIconMc.loadIcon(blossomItem.iconUrl,this.onBlossomIconLoaded);
               this.m_blossomIconMc.setIconSize(50,50);
               this.m_blossomIconMc.setSmoothing(true);
               this.m_blossomIconMc.visible = true;
               this.m_blossomMc.visible = true;
            }
            if(Boolean(this.m_blossomBuyBtn) && this.m_blossomBuyBtn.element.hasOwnProperty("amount_tf"))
            {
               blossomBuyCost = this.m_blossomBuyBtn.element["amount_tf"];
               blossomBuyCost.text = blossomItem.cost.toString();
            }
         }
         if(bouquetName != "")
         {
            boquetItem = Global.farmGameSettingsManager.getFarmItemByName(bouquetName);
            canBuyBoquet = FlowerShackManager.getInstance(this.m_featureName).canBuyItem(boquetItem);
            if(canBuyBoquet)
            {
               if(this.m_boquetBuyBtn)
               {
                  this.m_boquetBuyBtn.enabled = true;
               }
            }
            if(Boolean(boquetItem && boquetItem.iconUrl) && Boolean(this.m_boquetIconMc) && Boolean(this.m_boquetMc))
            {
               this.m_boquetIconMc.loadIcon(boquetItem.iconUrl,this.onBoquetIconLoaded);
               this.m_boquetIconMc.setIconSize(50,50);
               this.m_boquetIconMc.setSmoothing(true);
               this.m_boquetIconMc.visible = true;
               this.m_boquetMc.visible = true;
            }
            if(Boolean(this.m_boquetBuyBtn) && this.m_boquetBuyBtn.element.hasOwnProperty("amount_tf"))
            {
               boquetBuyCost = this.m_boquetBuyBtn.element["amount_tf"];
               boquetBuyCost.text = boquetItem.cost.toString();
            }
         }
      }
      
      private function setTitle(itemName:String) : void
      {
         var croppedText:String = null;
         var lowerCaseText:String = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(item)
         {
            if(this.m_titleTxt)
            {
               croppedText = item.friendlyTitle;
               lowerCaseText = croppedText.toLocaleLowerCase();
               if(lowerCaseText.indexOf(BLOSSOM_SUFFIX) != -1)
               {
                  croppedText = croppedText.slice(0,lowerCaseText.indexOf(BLOSSOM_SUFFIX));
               }
               else if(lowerCaseText.indexOf(BOQUET_SUFFIX) != -1)
               {
                  croppedText = croppedText.slice(0,lowerCaseText.indexOf(BOQUET_SUFFIX));
               }
               this.m_titleTxt.text = croppedText;
               this.m_titleTxt.visible = true;
            }
         }
      }
      
      private function onBlossomIconLoaded() : void
      {
         this.m_blossomIconMc.visible = true;
         this.m_blossomIconMc.setIconSize(50,50);
         this.m_blossomIconMc.setSmoothing(true);
         this.m_blossomIconMc.x = -this.m_blossomIconMc.width / 2;
         this.m_blossomIconMc.y = -this.m_blossomIconMc.height / 2;
      }
      
      private function onBoquetIconLoaded() : void
      {
         this.m_boquetIconMc.visible = true;
         this.m_boquetIconMc.setIconSize(50,50);
         this.m_boquetIconMc.setSmoothing(true);
         this.m_boquetIconMc.x = -this.m_boquetIconMc.width / 2;
         this.m_boquetIconMc.y = -this.m_boquetIconMc.height / 2;
      }
      
      override public function release() : void
      {
         this.m_buyBtn = null;
         this.m_blossomMc = null;
         this.m_blossomIconMc = null;
         super.release();
      }
   }
}

