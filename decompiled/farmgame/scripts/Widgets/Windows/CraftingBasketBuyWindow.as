package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.CraftingBasket;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.CraftingBasketDifficultyLevelManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class CraftingBasketBuyWindow extends FarmWindow
   {
      
      private static const X:String = "x";
      
      private var m_featureName:String = null;
      
      private var m_sunshineCount0:ZwTextField;
      
      private var m_sunshineCount1:ZwTextField;
      
      private var m_sunshineCount2:ZwTextField;
      
      private var m_sunshineCount3:ZwTextField;
      
      private var m_buySunshineBucket0:FarmAnimatedCashButton;
      
      private var m_buySunshineBucket1:FarmAnimatedCashButton;
      
      private var m_buySunshineBucket2:FarmAnimatedCashButton;
      
      private var m_buySunshineBucket3:FarmAnimatedCashButton;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var pkgCount:int;
      
      private var m_bucketPackages:Array = null;
      
      public function CraftingBasketBuyWindow(dialogPath:String, featureName:String = null, bucketPackages:Array = null)
      {
         this.m_featureName = featureName;
         this.m_bucketPackages = bucketPackages;
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var bucketItem:FarmItem = null;
         super.postLoadComplete();
         if(Boolean(this.m_bucketPackages[0]) && m_window.hasOwnProperty("cashbuy0_bt"))
         {
            bucketItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_bucketPackages[0]);
            this.pkgCount = 1;
            if(bucketItem)
            {
               addWidget(this.m_buySunshineBucket0 = new FarmAnimatedCashButton(m_window.cashbuy0_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonWindowText"),bucketItem.cash.toString(),this.onSunshine1BuyClick),false);
               this.m_buySunshineBucket0.visible = true;
               if(m_window.hasOwnProperty("count_tf_0") && Boolean(this.m_buySunshineBucket0))
               {
                  addWidget(this.m_sunshineCount0 = new ZwTextField(m_window.count_tf_0,X + this.pkgCount.toString()),true);
                  this.m_sunshineCount0.visible = true;
               }
            }
         }
         if(Boolean(this.m_bucketPackages[1]) && m_window.hasOwnProperty("cashbuy1_bt"))
         {
            bucketItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_bucketPackages[1]);
            this.pkgCount = 10;
            if(bucketItem)
            {
               addWidget(this.m_buySunshineBucket1 = new FarmAnimatedCashButton(m_window.cashbuy1_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonWindowText"),bucketItem.cash.toString(),this.onSunshine10BuyClick),false);
               this.m_buySunshineBucket1.visible = true;
               if(m_window.hasOwnProperty("count_tf_1") && Boolean(this.m_buySunshineBucket1))
               {
                  addWidget(this.m_sunshineCount1 = new ZwTextField(m_window.count_tf_1,X + this.pkgCount.toString()),true);
                  this.m_sunshineCount1.visible = true;
               }
            }
         }
         if(Boolean(this.m_bucketPackages[2]) && m_window.hasOwnProperty("cashbuy2_bt"))
         {
            bucketItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_bucketPackages[2]);
            this.pkgCount = 30;
            if(bucketItem)
            {
               addWidget(this.m_buySunshineBucket2 = new FarmAnimatedCashButton(m_window.cashbuy2_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonWindowText"),bucketItem.cash.toString(),this.onSunshine30BuyClick),false);
               this.m_buySunshineBucket2.visible = true;
               if(m_window.hasOwnProperty("count_tf_2") && Boolean(this.m_buySunshineBucket2))
               {
                  addWidget(this.m_sunshineCount2 = new ZwTextField(m_window.count_tf_2,X + this.pkgCount.toString()),true);
                  this.m_sunshineCount2.visible = true;
               }
            }
         }
         if(Boolean(this.m_bucketPackages[3]) && m_window.hasOwnProperty("cashbuy3_bt"))
         {
            bucketItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_bucketPackages[3]);
            this.pkgCount = 50;
            if(bucketItem)
            {
               addWidget(this.m_buySunshineBucket3 = new FarmAnimatedCashButton(m_window.cashbuy3_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonWindowText"),bucketItem.cash.toString(),this.onSunshine50BuyClick),false);
               this.m_buySunshineBucket3.visible = true;
               if(m_window.hasOwnProperty("count_tf_3") && Boolean(this.m_buySunshineBucket3))
               {
                  addWidget(this.m_sunshineCount3 = new ZwTextField(m_window.count_tf_3,X + this.pkgCount.toString()),true);
                  this.m_sunshineCount3.visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "BuyWindow_title_text")),true);
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "BuyWindow_body_text")),true);
         }
      }
      
      private function onSunshine1BuyClick(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","onSunshineBuyClickText",{
            "count":1,
            "s":""
         });
         UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onSunshine1BuyClickConfirm,"",true,true);
      }
      
      private function onSunshine1BuyClickConfirm(event:GenericPopupEvent) : void
      {
         var buyResult:Boolean = false;
         var m_basket:CraftingBasket = null;
         if(event.button == GenericPopup.CANCEL)
         {
            return;
         }
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_bucketPackages[0]);
         if(Global.player.canBuyCash(item.cash))
         {
            buyResult = Global.player.tryBuy(null,false,item,0);
            if(buyResult)
            {
               m_basket = new CraftingBasket(this.m_featureName);
               m_basket.buyCurrencyItem(item,1);
            }
         }
      }
      
      private function onSunshine10BuyClick(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","onSunshineBuyClickText",{
            "count":10,
            "s":"s"
         });
         UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onSunshine10BuyClickConfirm,"",true,true);
      }
      
      private function onSunshine10BuyClickConfirm(event:GenericPopupEvent) : void
      {
         var buyResult:Boolean = false;
         var m_basket:CraftingBasket = null;
         if(event.button == GenericPopup.CANCEL)
         {
            return;
         }
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_bucketPackages[1]);
         if(Global.player.canBuyCash(item.cash))
         {
            buyResult = Global.player.tryBuy(null,false,item,0);
            if(buyResult)
            {
               m_basket = new CraftingBasket(this.m_featureName);
               m_basket.buyCurrencyItem(item,10);
            }
         }
      }
      
      private function onSunshine50BuyClick(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","onSunshineBuyClickText",{
            "count":50,
            "s":"s"
         });
         UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onSunshine50BuyClickConfirm,"",true,true);
      }
      
      private function onSunshine50BuyClickConfirm(event:GenericPopupEvent) : void
      {
         var buyResult:Boolean = false;
         var m_basket:CraftingBasket = null;
         if(event.button == GenericPopup.CANCEL)
         {
            return;
         }
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_bucketPackages[3]);
         if(Global.player.canBuyCash(item.cash))
         {
            buyResult = Global.player.tryBuy(null,false,item,0);
            if(buyResult)
            {
               m_basket = new CraftingBasket(this.m_featureName);
               m_basket.buyCurrencyItem(item,50);
            }
         }
      }
      
      private function onSunshine30BuyClick(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","onSunshineBuyClickText",{
            "count":30,
            "s":"s"
         });
         UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onSunshine30BuyClickConfirm,"",true,true);
      }
      
      private function onSunshine30BuyClickConfirm(event:GenericPopupEvent) : void
      {
         var buyResult:Boolean = false;
         var m_basket:CraftingBasket = null;
         if(event.button == GenericPopup.CANCEL)
         {
            return;
         }
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_bucketPackages[2]);
         if(Global.player.canBuyCash(item.cash))
         {
            buyResult = Global.player.tryBuy(null,false,item,0);
            if(buyResult)
            {
               m_basket = new CraftingBasket(this.m_featureName);
               m_basket.buyCurrencyItem(item,30);
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_sunshineCount0 = null;
         this.m_sunshineCount1 = null;
         this.m_sunshineCount2 = null;
         this.m_sunshineCount3 = null;
         this.m_buySunshineBucket0 = null;
         this.m_buySunshineBucket1 = null;
         this.m_buySunshineBucket2 = null;
         this.m_buySunshineBucket3 = null;
         super.release();
      }
      
      override public function close() : void
      {
         super.close();
         var x:CraftingBasketDifficultyLevelManager = new CraftingBasketDifficultyLevelManager(this.m_featureName);
         x.showCraftingMainWindow();
      }
   }
}

