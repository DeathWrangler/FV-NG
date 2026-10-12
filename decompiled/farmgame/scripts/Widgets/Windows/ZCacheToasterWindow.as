package Widgets.Windows
{
   import Cache.Classes.UI.ZCacheUI;
   import Cache.Interfaces.IZCache;
   import Classes.MOTD.ZCacheMOTDHandler;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGrantZCacheGift;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class ZCacheToasterWindow extends ToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_BannerAd_ZCache.swf";
      
      public static const TYPE_PROMPT:String = "zcache_prompt";
      
      public static const TYPE_REMINDER:String = "zcache_reminder";
      
      private static const SANDBOX_OFFSET_X:Number = 20;
      
      private static const ICON_SIZE:int = 60;
      
      private var m_zCacheUI:ZCacheUI;
      
      private var m_toasterType:String;
      
      public function ZCacheToasterWindow(toasterType:String = "zcache_prompt")
      {
         this.m_toasterType = toasterType;
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var farmItem:FarmItem = null;
         var farmItemName:String = null;
         var farmIcon:FarmIcon = null;
         super.postLoadComplete();
         switch(this.m_toasterType)
         {
            case TYPE_PROMPT:
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(Global.farmGameSettingsManager.getString("enabledZCacheGiftName"));
               farmItemName = "";
               if(farmItem != null)
               {
                  farmIcon = new FarmIcon(m_window.prompt_mc.icon_mc);
                  farmIcon.loadIcon(farmItem.icon);
                  farmIcon.setIconSize(ICON_SIZE,ICON_SIZE);
                  addWidget(farmIcon);
                  farmItemName = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
               }
               addWidget(new ZwBaseWidget(m_window.prompt_mc));
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","ZCacheToaster_Title")));
               addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","ZCacheToaster_Prompt_Body",{"itemName":farmItemName})));
               addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t("Dialogs","ZCacheToaster_Prompt_Subtitle")));
               addWidget(new FarmAnimatedTextButton(m_window.prompt_mc.accept_bt,ZLocUtils.t("Dialogs","Okay"),this.showPermissionDialog));
               addWidget(new FarmAnimatedTextButton(m_window.prompt_mc.cancel_bt,ZLocUtils.t("Dialogs","NoThanks"),this.onClose));
               break;
            case TYPE_REMINDER:
               addWidget(new ZwBaseWidget(m_window.remind_mc));
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","ZCacheToaster_Title")));
               addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","ZCacheToaster_Remind_Body")));
               addWidget(new FarmAnimatedTextButton(m_window.remind_mc.accept_bt,ZLocUtils.t("Dialogs","Okay"),this.onClose));
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
      
      private function showPermissionDialog(event:Event) : void
      {
         var zCache:IZCache = GlobalZCache.instance;
         var sandboxUrl:String = Global.getAssetURL(Global.farmGameSettingsManager.getString("zCacheSandboxUrl"));
         this.m_zCacheUI = new ZCacheUI(zCache,Global.stage,sandboxUrl,true,true);
         this.m_zCacheUI.offsets = new Point(20,0);
         if(this.m_zCacheUI)
         {
            this.m_zCacheUI.showPermissionsPrompt(this.onPermissionResponse);
         }
      }
      
      private function onPermissionResponse(allowed:Boolean) : void
      {
         FarmStatsManager.count("zcache","flash_permission",allowed ? "allowed" : "denied","toaster");
         if(allowed && !Global.player.getSeenFlag(ZCacheMOTDHandler.ZCACHE_GIFT_GIVEN))
         {
            TransactionManager.addTransaction(new TGrantZCacheGift(ZCacheMOTDHandler.ZCACHE_GIFT_GIVEN_TOASTER),true);
         }
         if(this.m_zCacheUI)
         {
            this.m_zCacheUI = null;
         }
         close();
      }
   }
}

