package Widgets.Windows.Orchards
{
   import Classes.ImageLoader;
   import Classes.OrchardFeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class PostBuildingCompleteWindow extends FarmWindow
   {
      
      protected var m_rewardItem:FarmItem;
      
      protected var m_buildingName:String;
      
      protected var m_building:OrchardFeatureBuilding = null;
      
      protected var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      public function PostBuildingCompleteWindow(windowAssetRelUrl:String, rewardItem:FarmItem, buildingName:String, building:OrchardFeatureBuilding, dialogBackground:String = null)
      {
         super(windowAssetRelUrl);
         this.m_rewardItem = rewardItem;
         this.m_buildingName = buildingName;
         this.m_building = building;
         this.m_dialogBackground = dialogBackground;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_buildingName + "_PostBuildingCompleteTitle")));
         addWidget(new FarmTextField(m_window.item_tf,ZLocUtils.t("Dialogs",this.m_buildingName + "_PostBuildingCompleteSubtitle")));
         addWidget(new FarmTextField(m_window.info_tf,ZLocUtils.t("Dialogs",this.m_buildingName + "_PostBuildingCompleteItemReward",{"item":this.m_rewardItem.friendlyTitle})));
         addWidget(new FarmTextField(m_window.info2_tf,ZLocUtils.t("Dialogs",this.m_buildingName + "_PostBuildingCompleteItemGiftBox")));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Continue"),this.onAccept));
         addWidget(new FarmIcon(m_window.icon_mc,this.m_rewardItem.getImageByName(FarmItem.ICON_FEED)));
         if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionSubTextColor(m_window.item_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.item_tf);
            TemplateUIUtility.applyExpansionSubTextColor(m_window.info_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.info_tf);
         }
      }
      
      private function onAccept(event:Event) : void
      {
         this.close();
      }
   }
}

