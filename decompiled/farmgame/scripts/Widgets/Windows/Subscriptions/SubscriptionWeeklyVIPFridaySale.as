package Widgets.Windows.Subscriptions
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.SubscriptionCommonDropPopupWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class SubscriptionWeeklyVIPFridaySale extends SubscriptionCommonDropPopupWindow
   {
      
      public static const ZOOM_LEVELS:Array = new Array(2,1.434,0.868,0.585);
      
      public static const ZOOM_WIDTHS:Array = new Array(260,300,320,330);
      
      public static const WEEKLY_VIP_SALE_ITEMS:String = "WEEKLY_VIP_SALE_ITEMS";
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/SubUpgrade2016/FV_SubUpgrade2016_VIPSale_MOTD.swf";
      
      private var m_itemsArray:Array;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function SubscriptionWeeklyVIPFridaySale(dialogAsset:String)
      {
         super(dialogAsset);
      }
      
      public static function display(callBack:Function = null) : void
      {
         var popUp:SubscriptionWeeklyVIPFridaySale = null;
         var assetname:String = ASSET_NAME;
         popUp = new SubscriptionWeeklyVIPFridaySale(assetname);
         UI.displayPopup(popUp);
      }
      
      override protected function postLoadComplete() : void
      {
         var timeLeft:Array = null;
         var itemMcIndex:Number = NaN;
         var itemIndex:Number = NaN;
         var itemFrame:ZwFrame = null;
         super.postLoadComplete();
         Global.player.setSeenFlag("seenVIPFridaySale");
         var discount:Number = Global.vipSalesManager.getVIPDiscount();
         this.m_itemsArray = Global.vipSalesManager.getValidOnSaleItems();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["title_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","subscriptions_VIPFRIDAY_SALE_Title")));
            }
            if(m_window.mainWindow["body_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","subscriptions_VIPFRIDAY_SALE_Text")));
            }
            if(m_window.mainWindow["timer_tf"])
            {
               timeLeft = this.getTimeLeft();
               addWidget(new FarmTextField(m_window.mainWindow.timer_tf,ZLocUtils.t("Dialogs","subscriptions_VIPFRIDAY_SALE_TimerText",{"timeLeft":timeLeft[1]})));
            }
            if(Boolean(m_window.mainWindow["discount_mc"]) && Boolean(m_window.mainWindow["discount_mc"]["discount_tf"]))
            {
               addWidget(new FarmTextField(m_window.mainWindow["discount_mc"]["discount_tf"],ZLocUtils.t("Dialogs","subscriptions_VIPFRIDAY_SALE_DiscountText",{"discount":discount})));
            }
            if(m_window.mainWindow["accept_bt"])
            {
               this.m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","subscriptions_VIPFRIDAY_SALE_ButtonText"),this.onAccept)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow["close_bt"])
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,onClose)) as FarmButton;
            }
            if(this.m_itemsArray.length < 3)
            {
               if(m_window.mainWindow["sale_tf"])
               {
                  addWidget(new ZwWidget(m_window.mainWindow["sale_tf"]));
               }
               itemMcIndex = 0;
               while(m_window.mainWindow["item_" + itemMcIndex + "_mc"])
               {
                  (m_window.mainWindow["item_" + itemMcIndex + "_mc"] as DisplayObject).visible = false;
                  itemMcIndex++;
               }
            }
            else
            {
               itemIndex = 0;
               if(m_window.mainWindow["sale_tf"])
               {
                  addWidget(new ZwWidget(m_window.mainWindow["sale_tf"]),false);
               }
               while(m_window.mainWindow["item_" + itemIndex + "_mc"])
               {
                  itemFrame = new ZwFrame(m_window.mainWindow["item_" + itemIndex + "_mc"]);
                  this.loadItem(itemFrame,itemIndex);
                  itemIndex++;
               }
            }
         }
         FarmStatsManager.count("MOTD","impressions","MOTD_subs_weeklysale");
      }
      
      private function loadItem(frame:ZwFrame, itemIndex:Number) : void
      {
         var defaultItemName:String = "duck";
         var itemToDisplay:FarmItem = this.m_itemsArray[itemIndex] as FarmItem ? this.m_itemsArray[itemIndex] as FarmItem : Global.farmGameSettingsManager.getFarmItemByName(defaultItemName);
         if(frame.element["icon_mc"])
         {
            frame.addWidget(new ObjectPreviewFrame(frame.element["icon_mc"],itemToDisplay,null,ZOOM_LEVELS,ZOOM_WIDTHS));
         }
         if(frame.element["name_tf"])
         {
            frame.addWidget(new FarmTextField(frame.element["name_tf"],ZLocUtils.tk_pk_asTitle(itemToDisplay.friendlyName)));
         }
         if(frame.element["newPrice_tf"])
         {
            frame.addWidget(new FarmTextField(frame.element["newPrice_tf"],itemToDisplay.realCashCost.toString()));
         }
         if(frame.element["oldPrice_tf"])
         {
            frame.addWidget(new FarmTextField(frame.element["oldPrice_tf"],itemToDisplay.cash.toString()));
         }
         frame.visible = true;
      }
      
      private function onAccept(event:MouseEvent) : void
      {
         var item:FarmItem = null;
         this.close();
         FarmStatsManager.count("MOTD","click","MOTD_subs_weeklysale");
         var itemList:Array = Global.vipSalesManager.getValidOnSaleItems();
         var itemNameList:Array = new Array();
         for each(item in itemList)
         {
            itemNameList.push(item.name);
         }
         UI.displayMiniMarketDialog(itemNameList,"vip","",null,true,false,false,false);
      }
      
      private function getTimeLeft() : Array
      {
         var endTime:Number = FarmGameUtil.getMidnightTimestamp() + FarmGameUtil.NUM_MSECS_IN_DAY;
         var currentTime:Number = GlobalEngine.serverTime;
         var timeRemaining:int = (endTime - currentTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return FarmGameUtil.parseTimeLeft(timeRemaining);
      }
   }
}

