package Widgets.Windows.MOTD
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.PerformancePromotionManager;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   
   public class PerformancePromotionWidgetMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public static const ZLOC_PACKAGE_DIALOGS:String = ZLocConstants.DIALOG_UTIL_PKG;
      
      private static const FEATURE_NAME:String = "PERFORMANCE_PROMOTION";
      
      private var m_manager:PerformancePromotionManager;
      
      private var m_featureName:String = null;
      
      private var m_giftImageContainer:FarmIcon = null;
      
      private var m_promotionalGift:FarmItem = null;
      
      public function PerformancePromotionWidgetMOTD(displayParams:Object = null)
      {
         super(displayParams);
         this.m_featureName = FEATURE_NAME;
         this.m_manager = PerformancePromotionManager.getInstance();
      }
      
      public function get promotionalGiftImage() : String
      {
         if(this.m_promotionalGift)
         {
         }
         return this.m_promotionalGift["runtimeGift"];
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.m_promotionalGift = Global.farmGameSettingsManager.getFarmItemByCode(Global.flashHotParams[this.currentMOTD.runtimeGift]);
         this.m_manager.rewardItem(this.m_promotionalGift,this.currentMOTD.runtimeGift);
         if(m_window.mainWindow)
         {
            m_window.mainWindow.rewardName_tf.text = this.m_promotionalGift.friendlyTitle;
            m_window.mainWindow.rewardName_tf.visible = true;
            m_window.mainWindow.generic2_tf.visible = true;
            m_window.mainWindow.generic4_tf.text = ZLocUtils.t("Dialogs","performance_promotion_giftbox_text");
            m_window.mainWindow.generic4_tf.visible = true;
            m_window.mainWindow.generic_tf.htmlText = ZLocUtils.t("Dialogs","performance_promotion_body_text",{"promotionalGift":this.m_promotionalGift.friendlyTitle});
            m_window.mainWindow.generic_tf.visible = true;
            if(m_window.mainWindow.hasOwnProperty("icon_mc"))
            {
               this.m_giftImageContainer = addWidget(new FarmIcon(m_window.mainWindow.icon_mc)) as FarmIcon;
               this.m_giftImageContainer.loadIcon(this.m_promotionalGift.getImageByName("icon"));
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_manager = null;
         this.m_featureName = null;
         super.release();
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         this.m_manager.onBragFeed(Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_promotionalGift.code));
         this.close();
      }
   }
}

