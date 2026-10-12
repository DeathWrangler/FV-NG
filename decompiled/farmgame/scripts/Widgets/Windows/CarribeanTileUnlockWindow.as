package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class CarribeanTileUnlockWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      private static const SERVICE_NAME:String = "CasablancaInnovationService";
      
      public static const BRAZIL_TILE_UNLOCK_COUNT:String = "5egw";
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_tileName:String;
      
      public function CarribeanTileUnlockWindow(dialogAsset:String, featureName:String, tileName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null)
      {
         dialogAsset = "assets/dialogs/expansion/FV_RewardDialog.swf";
         dialogBackground = "assets/dialogs/spooky/RewardDialog.png";
         super(dialogAsset);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_dialogBackground = dialogBackground;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         this.m_tileName = tileName;
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var tileItem:FarmItem = null;
         var iconUrl:String = null;
         var Icon:FarmIcon = null;
         super.postLoadComplete();
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],"Congrats!")) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.generic_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.generic_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.generic_tf);
               }
            }
            else if(m_window.hasOwnProperty("title_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"Congrats!")) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
               }
            }
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               addWidget(new ZwTextField(m_window["generic2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Generic2Text",{"itemName":itemName})));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.generic2_tf);
               }
            }
            else if(m_window.hasOwnProperty("subtext1_tf"))
            {
               tileItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_tileName);
               addWidget(new ZwTextField(m_window["subtext1_tf"],"You have got 10 free Points in Spooks N\' Treats!"));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
               }
            }
            if(m_window.hasOwnProperty("generic3_tf"))
            {
               addWidget(new ZwTextField(m_window["generic3_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Generic3Text",{"itemName":itemName})));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.generic3_tf);
               }
            }
            else if(m_window.hasOwnProperty("subtext2_tf"))
            {
               addWidget(new ZwTextField(m_window["subtext2_tf"],"Unlock land to get more!"));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.subtext2_tf);
               }
            }
            if(m_window.hasOwnProperty("accept_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Cool",this.onButtonClick));
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
            }
            if(m_window.hasOwnProperty("close_bt"))
            {
               m_window["close_bt"].visible = false;
            }
            if(m_window.hasOwnProperty("reward_mc"))
            {
               iconUrl = Global.getAssetURL("assets/dialogs/spooky/innovation/chef_coin.png");
               if(iconUrl)
               {
                  Icon = addWidget(new FarmIcon(m_window["reward_mc"])) as FarmIcon;
                  Icon.setIconSize(200,200);
                  Icon.setSmoothing(true);
                  Icon.loadIcon(iconUrl);
                  Icon.visible = true;
               }
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
         }
      }
      
      override protected function afterLoad() : void
      {
         if(m_window.hasOwnProperty("close_bt"))
         {
            setCloseButtonVisible(false);
         }
      }
      
      public function onButtonClick(event:Event) : void
      {
         this.close();
      }
   }
}

