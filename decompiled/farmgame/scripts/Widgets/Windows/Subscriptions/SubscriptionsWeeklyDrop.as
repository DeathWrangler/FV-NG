package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.SubscriptionsItemDropManager;
   import Managers.SubscriptionsManager;
   import Widgets.Frames.SubscriptionVipItemsBuyFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.SubscriptionCommonDropPopupWindow;
   
   public class SubscriptionsWeeklyDrop extends SubscriptionCommonDropPopupWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_Loot_v3.swf";
      
      public static const ASSET_REWARD_PATH:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_purchaseconfirm.swf";
      
      private static const ASSET_NAME_GOLD:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_Loot_v3.swf";
      
      private static const ASSET_NAME_DIAMOND:String = "assets/dialogs/Subscriptions/FV_SubscriptionLaunch_Loot_v3.swf";
      
      private var m_callBack:Function;
      
      private var m_amount:int;
      
      private var m_item_amount:int;
      
      private var m_vipItemsBuyFrame:SubscriptionVipItemsBuyFrame;
      
      public function SubscriptionsWeeklyDrop(dialogAsset:String, callBack:Function = null, amount:int = 0, item_amount:int = 0)
      {
         super(dialogAsset);
         this.m_callBack = callBack;
         this.m_amount = amount;
         this.m_item_amount = item_amount;
      }
      
      public static function display(callBack:Function = null, amount:int = 0, item_amount:int = 0) : void
      {
         var popUp:SubscriptionsWeeklyDrop = null;
         var assetname:String = ASSET_NAME;
         switch(SubscriptionsManager.instance.getSubscriptionLevel())
         {
            case SubscriptionsManager.LEVEL_RUBY:
            case SubscriptionsManager.LEVEL_GOLD:
            case SubscriptionsManager.LEVEL_DIAMOND:
               assetname = ASSET_NAME_DIAMOND;
               break;
            default:
               assetname = ASSET_NAME;
         }
         popUp = new SubscriptionsWeeklyDrop(assetname,callBack,amount,item_amount);
         UI.displayPopup(popUp);
      }
      
      private function prepareUnicornDropContainer(level:Number) : void
      {
         var unicornManager:SubscriptionsItemDropManager = null;
         var unicornName:String = null;
         if(m_window.newUnicorn_mc)
         {
            if(level == SubscriptionsManager.LEVEL_DIAMOND)
            {
               unicornManager = SubscriptionsItemDropManager.getInstance();
               if(unicornManager.eligibleToClaim())
               {
                  unicornName = unicornManager.getCurrentDropItemName();
                  if(unicornName)
                  {
                     addWidget(new SubscriptionUnicornDropContainer(m_window.newUnicorn_mc,unicornName));
                  }
               }
            }
            else
            {
               m_window.newUnicorn_mc.visible = false;
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         if(this.m_callBack != null)
         {
            this.m_callBack(this.m_amount,"weekly_drop",this.m_item_amount);
         }
         super.postLoadComplete();
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropTitle")),true);
         addWidget(new FarmTextField(m_window.subtitle1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropSubtitle1")),true);
         addWidget(new FarmTextField(m_window.body1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropBody1")),true);
         addWidget(new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropSubtitle",{"amount":this.m_amount.toString()})),true);
         switch(SubscriptionsManager.instance.getSubscriptionLevel())
         {
            case SubscriptionsManager.LEVEL_DIAMOND:
               this.prepareUnicornDropContainer(SubscriptionsManager.instance.getSubscriptionLevel());
            case SubscriptionsManager.LEVEL_RUBY:
            case SubscriptionsManager.LEVEL_GOLD:
               if(m_window.bonus_mc)
               {
                  m_window.bonus_mc.visible = true;
                  addWidget(new FarmTextField(m_window.bonus_mc.bonuscount_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropGoldSubtitle",{"item_amount":this.m_item_amount.toString()})),true);
                  addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropBody",{
                     "amount":this.m_amount.toString(),
                     "total":Global.player.cash.toString()
                  })),true);
               }
               break;
            default:
               addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subscriptionsWeeklyDropBody",{
                  "amount":this.m_amount.toString(),
                  "total":Global.player.cash.toString()
               })),true);
         }
         if(m_window.hasOwnProperty("buyFrame_mc"))
         {
            this.m_vipItemsBuyFrame = new SubscriptionVipItemsBuyFrame(m_window.buyFrame_mc);
            if(this.m_vipItemsBuyFrame)
            {
               addWidget(this.m_vipItemsBuyFrame,true);
            }
         }
         this.vipItemsSet();
      }
      
      private function vipItemsSet() : void
      {
         var items:Array = Global.farmGameSettingsManager.getActiveVipItems();
         if(items)
         {
            this.m_vipItemsBuyFrame.items = items;
         }
      }
      
      override protected function release() : void
      {
         this.m_callBack = null;
         super.release();
      }
   }
}

