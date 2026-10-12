package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.ItemMembershipManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   
   public class ItemMembershipToasterWindow extends AutoCloseToasterWindow
   {
      
      private var m_item:FarmItem;
      
      public function ItemMembershipToasterWindow(assetPath:String, itemName:String)
      {
         super(assetPath);
         this.isPauseable = false;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window is MovieClip)
         {
            if("title_tf" in m_window)
            {
               addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t("Dialogs","Congratulations")),true);
            }
            if("copy_tf" in m_window && this.m_item is FarmItem)
            {
               addWidget(new ZwTextField(m_window["copy_tf"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_toaster_copy",{"itemName":this.m_item.friendlyTitle})),true);
            }
            if("okay_bt" in m_window)
            {
               addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],ZLocUtils.t("Dialogs","Awesome"),onClose),true);
            }
            if("icon_mc" in m_window && this.m_item is FarmItem)
            {
               addWidget(new FarmIcon(m_window["icon_mc"],this.m_item.iconUrl),true);
            }
            StatsManager.count(ItemMembershipManager.FEATURE_TYPE,StatsTrackingConstants.SURFACING_TOASTER);
         }
      }
   }
}

