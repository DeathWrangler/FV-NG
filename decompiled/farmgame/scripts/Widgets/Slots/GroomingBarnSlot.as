package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.RandomItemGrowableBaby;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.GroomingBarnManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.GroomingBarnWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GroomingBarnSlot extends ZwSlotFrame
   {
      
      private static const brushFixedText:String = "/40";
      
      private var m_window:GroomingBarnWindow;
      
      private var m_buyCashButton:FarmAnimatedCashButton = null;
      
      private var m_buyCoinButton:FarmAnimatedCashButton = null;
      
      private var m_growYearlingButton:FarmAnimatedTextButton = null;
      
      private var m_redeemFreeYearling:FarmAnimatedTextButton = null;
      
      private var m_brushCountRequired:ZwTextField;
      
      private var m_horseName:ZwTextField;
      
      private var m_brushImage:ZwBaseWidget;
      
      private var m_data:Object;
      
      public function GroomingBarnSlot(element:DisplayObject, parentWindow:GroomingBarnWindow)
      {
         super(element);
         this.m_window = parentWindow;
         if(m_element.hasOwnProperty("buyCoin_bt"))
         {
            addWidget(this.m_buyCoinButton = new FarmAnimatedCashButton(m_element.buyCoin_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"LightningCollectionsBuyButton"),"",this.onBuyClick),false);
         }
         if(m_element.hasOwnProperty("buyCash_bt"))
         {
            addWidget(this.m_buyCashButton = new FarmAnimatedCashButton(m_element.buyCash_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"LightningCollectionsBuyButton"),"",this.onBuyClick),false);
         }
         if(m_element.hasOwnProperty("redeem_bt"))
         {
            addWidget(this.m_growYearlingButton = new FarmAnimatedTextButton(m_element.redeem_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Bloom_Tutorial_PlaceFeed_Button"),this.onGrowYearlingClick),false);
         }
         if(m_element.hasOwnProperty("recipeName_tf"))
         {
            addWidget(this.m_horseName = new ZwTextField(m_element.recipeName_tf,""));
         }
         if(m_element.hasOwnProperty("firstRedeem_bt"))
         {
            addWidget(this.m_redeemFreeYearling = new FarmAnimatedTextButton(m_element.firstRedeem_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MOTDPizzaShopButtonText"),this.onRedeemFreeClick),false);
         }
         if(m_element.hasOwnProperty("brushcount_tf"))
         {
            addWidget(this.m_brushCountRequired = new ZwTextField(m_element.brushcount_tf,""),false);
         }
         if(m_element.hasOwnProperty("currybrush_mc"))
         {
            addWidget(this.m_brushImage = new ZwBaseWidget(m_element.currybrush_mc),false);
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.m_horseName.visible = true;
         this.m_horseName.text = this.m_data["friendlyName"];
         if(Global.world.getObjectsByName(this.m_data["name"]).length > 0)
         {
            this.m_redeemFreeYearling.visible = false;
            this.m_buyCoinButton.visible = false;
            this.m_buyCashButton.visible = false;
            this.m_growYearlingButton.visible = true;
            this.m_brushImage.visible = true;
            this.m_brushCountRequired.visible = true;
            this.m_brushCountRequired.text = GroomingBarnManager.getInstance().getBrushCountText() + brushFixedText;
         }
         else if(Boolean(this.m_data["free"]) && this.m_data["free"] == true)
         {
            this.m_redeemFreeYearling.visible = true;
            this.m_buyCoinButton.visible = false;
            this.m_buyCashButton.visible = false;
            this.m_growYearlingButton.visible = false;
            this.m_brushImage.visible = false;
            this.m_brushCountRequired.visible = false;
         }
         else
         {
            this.m_redeemFreeYearling.visible = false;
            this.m_growYearlingButton.visible = false;
            this.m_brushImage.visible = false;
            this.m_brushCountRequired.visible = false;
            if(Boolean(this.m_data["currency"]) && this.m_data["currency"] == Currency.COINS)
            {
               this.m_buyCoinButton.visible = true;
               this.m_buyCoinButton.setAmountText(this.m_data["price"]);
            }
            else if(Boolean(this.m_data["currency"]) && this.m_data["currency"] == Currency.CASH)
            {
               this.m_buyCashButton.visible = true;
               this.m_buyCashButton.setAmountText(this.m_data["price"]);
            }
         }
      }
      
      private function onBuyClick(event:Event) : void
      {
         this.m_window.close();
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data["name"]);
         GroomingBarnManager.getInstance().buy(item,this.m_data["currency"]);
      }
      
      private function onRedeemFreeClick(event:Event) : void
      {
         this.m_window.close();
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data["name"]);
         GroomingBarnManager.getInstance().buy(item,this.m_data["currency"]);
      }
      
      private function onGrowYearlingClick(event:Event) : void
      {
         var randomBaby:RandomItemGrowableBaby = null;
         var foal:Array = Global.world.getObjectsByName(this.m_data["name"]);
         if(foal.length > 0)
         {
            this.m_window.pause();
            randomBaby = foal[0] as RandomItemGrowableBaby;
            randomBaby.tryGrowUp(this.m_window.unpause,this.m_window.building);
         }
      }
   }
}

