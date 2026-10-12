package Widgets.Windows.LimitedGifting
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.AutoCloseToasterWindow;
   
   public class LimitedGiftingSendToasterWindow extends AutoCloseToasterWindow
   {
      
      protected static const ASSET_PATH:String = "assets/dialogs/FV_GenericBanner_icon.swf";
      
      private var m_rewardItem:String;
      
      private var m_featureName:String;
      
      public function LimitedGiftingSendToasterWindow(rewardItem:String = null, featureName:String = "limitedGifting", windowPath:String = "assets/dialogs/FV_GenericBanner_icon.swf")
      {
         super(windowPath);
         this.m_rewardItem = rewardItem;
         this.m_featureName = featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         FarmStatsManager.count("dialog",this.m_featureName,"toaster_gift");
         var reward:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardItem);
         var mainFrame:ZwFrame = new ZwFrame(m_window.bannerad_mc);
         addWidget(mainFrame);
         mainFrame.addWidget(new ZwTextField(m_window.bannerad_mc.generic_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_senderToaster",{"rewardName":reward.friendlyTitle})));
         var farmIcon:FarmIcon = new FarmIcon(m_window.bannerad_mc.icon_mc,reward.icon);
         addWidget(farmIcon);
      }
   }
}

