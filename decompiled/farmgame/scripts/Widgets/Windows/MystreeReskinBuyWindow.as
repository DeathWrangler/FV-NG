package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.MystreeReskinManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class MystreeReskinBuyWindow extends FarmWindow
   {
      
      private static const X:String = "x";
      
      private var m_featureName:String = null;
      
      private var m_sunshineCount0:ZwTextField;
      
      private var m_sunshineCount1:ZwTextField;
      
      private var m_sunshineCount2:ZwTextField;
      
      private var m_buySunshineBucket0:FarmAnimatedCashButton;
      
      private var m_buySunshineBucket1:FarmAnimatedCashButton;
      
      private var m_buySunshineBucket2:FarmAnimatedCashButton;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      public function MystreeReskinBuyWindow(dialogPath:String, featureName:String = null)
      {
         this.m_featureName = featureName;
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var bucketItem:FarmItem = null;
         var pkgCount:int = 0;
         var windowName:String = MystreeReskinManager.getInstance(this.m_featureName).getWindowName();
         super.postLoadComplete();
         var bucketPackages:Array = MystreeReskinManager.getInstance(this.m_featureName).getBucketPackages();
         if(Boolean(bucketPackages[0]) && m_window.hasOwnProperty("cashbuy0_bt"))
         {
            if(this.m_featureName == "mystree_v2")
            {
               pkgCount = 10;
            }
            else if(this.m_featureName == "mystree_v10")
            {
               pkgCount = 5;
            }
            else
            {
               pkgCount = 5;
            }
            bucketItem = Global.farmGameSettingsManager.getFarmItemByName(bucketPackages[0]);
            if(bucketItem)
            {
               addWidget(this.m_buySunshineBucket0 = new FarmAnimatedCashButton(m_window.cashbuy0_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonWindowText"),bucketItem.cash.toString(),this.onBuyItem1),false);
               this.m_buySunshineBucket0.visible = true;
               if(m_window.hasOwnProperty("count_tf_0") && Boolean(this.m_buySunshineBucket0))
               {
                  addWidget(this.m_sunshineCount0 = new ZwTextField(m_window.count_tf_0,X + pkgCount.toString()),true);
                  this.m_sunshineCount0.visible = true;
               }
            }
         }
         if(Boolean(bucketPackages[1]) && m_window.hasOwnProperty("cashbuy1_bt"))
         {
            if(this.m_featureName == "mystree_v2")
            {
               pkgCount = 20;
            }
            else if(this.m_featureName == "mystree_v10")
            {
               pkgCount = 15;
            }
            else
            {
               pkgCount = 15;
            }
            bucketItem = Global.farmGameSettingsManager.getFarmItemByName(bucketPackages[1]);
            if(bucketItem)
            {
               addWidget(this.m_buySunshineBucket1 = new FarmAnimatedCashButton(m_window.cashbuy1_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonWindowText"),bucketItem.cash.toString(),this.onBuyItem2),false);
               this.m_buySunshineBucket1.visible = true;
               if(m_window.hasOwnProperty("count_tf_1") && Boolean(this.m_buySunshineBucket1))
               {
                  addWidget(this.m_sunshineCount1 = new ZwTextField(m_window.count_tf_1,X + pkgCount.toString()),true);
                  this.m_sunshineCount1.visible = true;
               }
            }
         }
         if(Boolean(bucketPackages[2]) && m_window.hasOwnProperty("cashbuy2_bt"))
         {
            bucketItem = Global.farmGameSettingsManager.getFarmItemByName(bucketPackages[2]);
            if(this.m_featureName == "mystree_v2")
            {
               pkgCount = 30;
            }
            else if(this.m_featureName == "mystree_v10")
            {
               pkgCount = 25;
            }
            else
            {
               pkgCount = 25;
            }
            if(bucketItem)
            {
               addWidget(this.m_buySunshineBucket2 = new FarmAnimatedCashButton(m_window.cashbuy2_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonWindowText"),bucketItem.cash.toString(),this.onBuyItem3),false);
               this.m_buySunshineBucket2.visible = true;
               if(m_window.hasOwnProperty("count_tf_2") && Boolean(this.m_buySunshineBucket2))
               {
                  addWidget(this.m_sunshineCount2 = new ZwTextField(m_window.count_tf_2,X + pkgCount.toString()),true);
                  this.m_sunshineCount2.visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_BuyWindow_title")),true);
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_BuyWindow_body")),true);
         }
      }
      
      private function onSunshine10BuyClick(event:GenericPopupEvent) : void
      {
         var bucketPackages:Array = null;
         if(event.button == GenericPopup.YES)
         {
            bucketPackages = MystreeReskinManager.getInstance(this.m_featureName).getBucketPackages();
            if(bucketPackages[0])
            {
               MystreeReskinManager.getInstance(this.m_featureName).buySunshineBuckets(bucketPackages[0]);
               this.close();
            }
         }
      }
      
      private function onSunshine20BuyClick(event:GenericPopupEvent) : void
      {
         var bucketPackages:Array = null;
         if(event.button == GenericPopup.YES)
         {
            bucketPackages = MystreeReskinManager.getInstance(this.m_featureName).getBucketPackages();
            if(bucketPackages[1])
            {
               MystreeReskinManager.getInstance(this.m_featureName).buySunshineBuckets(bucketPackages[1]);
               this.close();
            }
         }
      }
      
      private function onSunshine30BuyClick(event:GenericPopupEvent) : void
      {
         var bucketPackages:Array = null;
         if(event.button == GenericPopup.YES)
         {
            bucketPackages = MystreeReskinManager.getInstance(this.m_featureName).getBucketPackages();
            if(bucketPackages[2])
            {
               MystreeReskinManager.getInstance(this.m_featureName).buySunshineBuckets(bucketPackages[2]);
               this.close();
            }
         }
      }
      
      private function onBuyItem1(e:Event) : void
      {
         var item:FarmItem = null;
         var bucketPackages:Array = MystreeReskinManager.getInstance(this.m_featureName).getBucketPackages();
         if(bucketPackages[0])
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(bucketPackages[0]);
            UI.displayMessage(ZLocUtils.t("Dialogs","CarnivalFairCraftingBasket" + "BuyConfirmPopup",{
               "cashQuantity":item.cash,
               "item":item.friendlyTitle
            }),GenericPopup.TYPE_ACCEPTCANCEL,this.onSunshine10BuyClick,"",true);
         }
      }
      
      private function onBuyItem2(e:Event) : void
      {
         var item:FarmItem = null;
         var bucketPackages:Array = MystreeReskinManager.getInstance(this.m_featureName).getBucketPackages();
         if(bucketPackages[1])
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(bucketPackages[1]);
            UI.displayMessage(ZLocUtils.t("Dialogs","CarnivalFairCraftingBasket" + "BuyConfirmPopup",{
               "cashQuantity":item.cash,
               "item":item.friendlyTitle
            }),GenericPopup.TYPE_ACCEPTCANCEL,this.onSunshine20BuyClick,"",true);
         }
      }
      
      private function onBuyItem3(e:Event) : void
      {
         var item:FarmItem = null;
         var bucketPackages:Array = MystreeReskinManager.getInstance(this.m_featureName).getBucketPackages();
         if(bucketPackages[2])
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(bucketPackages[2]);
            UI.displayMessage(ZLocUtils.t("Dialogs","CarnivalFairCraftingBasket" + "BuyConfirmPopup",{
               "cashQuantity":item.cash,
               "item":item.friendlyTitle
            }),GenericPopup.TYPE_ACCEPTCANCEL,this.onSunshine30BuyClick,"",true);
         }
      }
      
      override protected function release() : void
      {
         this.m_sunshineCount0 = null;
         this.m_sunshineCount1 = null;
         this.m_sunshineCount2 = null;
         this.m_buySunshineBucket0 = null;
         this.m_buySunshineBucket1 = null;
         this.m_buySunshineBucket2 = null;
         super.release();
      }
      
      override public function close() : void
      {
         super.close();
         MystreeReskinManager.getInstance(this.m_featureName).openMystreeUI();
      }
   }
}

