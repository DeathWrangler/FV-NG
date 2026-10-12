package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class FlashUpgradeToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_BannerAd_FlashUpgrade_V2.swf";
      
      private static const ICON_SIZE:int = 60;
      
      public function FlashUpgradeToasterWindow()
      {
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(Global.farmGameSettingsManager.getString("FlashUpgradeGiftName"));
         var farmItemName:String = "";
         if(farmItem != null)
         {
            farmItemName = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
         }
         addWidget(new ZwBaseWidget(m_window.remind_mc));
         addWidget(new ZwButton(m_window.hitbox_mc));
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","FlashUpgradeToasterReward_Title")));
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","FlashUpgradeToasterReward_Subtitle",{"itemName":farmItemName})));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Awesome"),onClose));
      }
      
      override protected function getToasterHeight() : Number
      {
         return m_window.remind_mc.height;
      }
   }
}

