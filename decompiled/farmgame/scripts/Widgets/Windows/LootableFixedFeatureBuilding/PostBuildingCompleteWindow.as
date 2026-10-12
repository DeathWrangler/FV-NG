package Widgets.Windows.LootableFixedFeatureBuilding
{
   import Classes.ImageLoader;
   import Classes.LootableFixedFeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.JMInnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class PostBuildingCompleteWindow extends FarmWindow
   {
      
      protected var m_rewardItem:FarmItem;
      
      protected var m_buildingName:String;
      
      protected var m_building:LootableFixedFeatureBuilding = null;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_subtext1:String;
      
      private var m_subtext2:String;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      public function PostBuildingCompleteWindow(windowAssetRelUrl:String, rewardItem:FarmItem, buildingName:String, building:LootableFixedFeatureBuilding, dialogBackground:String)
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
      
      private function conditionallyDisplayJungleInnovationCard() : void
      {
         var number:int = 0;
         var type:String = null;
         if(m_window.innovation_mc)
         {
            m_window.innovation_mc.visible = false;
            if(JMInnovationManager.getInstance().isActive())
            {
               m_window.innovation_mc.visible = true;
               number = JMInnovationManager.getInstance().getRewardCount(this.m_building.featureName);
               type = JMInnovationManager.getInstance().getIngredientType(this.m_building.featureName);
               addWidget(new FarmTextField(m_window.innovation_mc.info3_tf,ZLocUtils.t("Dialogs","jungleInnovationText",{
                  "type":type,
                  "number":number
               })));
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         this.setTemplatizedValues();
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_buildingName + "_PostBuildingCompleteTitle")));
         if(this.m_building.hasReachedMaxExpansionLevel() && Boolean(ZLocUtils.t("Dialogs",this.m_buildingName + "_PostBuildingNoFurtherUpgdradeSubtitle")))
         {
            addWidget(new FarmTextField(m_window[this.m_subtext1],ZLocUtils.t("Dialogs",this.m_buildingName + "_PostBuildingNoFurtherUpgdradeSubtitle")));
         }
         else
         {
            addWidget(new FarmTextField(m_window[this.m_subtext1],ZLocUtils.t("Dialogs",this.m_buildingName + "_PostBuildingCompleteSubtitle")));
         }
         addWidget(new FarmTextField(m_window[this.m_subtext2],ZLocUtils.t("Dialogs",this.m_buildingName + "_PostBuildingCompleteItemReward",{"item":this.m_rewardItem.friendlyTitle})));
         if(m_window.hasOwnProperty("info2_tf"))
         {
            addWidget(new FarmTextField(m_window.info2_tf,ZLocUtils.t("Dialogs",this.m_buildingName + "_PostBuildingCompleteItemGiftBox")));
         }
         else if(m_window.hasOwnProperty("giftbox_mc"))
         {
            this.m_gift_mc = m_window.giftbox_mc;
            this.m_gift_mc.visible = true;
         }
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Continue"),this.onAccept));
         if(m_window.hasOwnProperty("icon_mc"))
         {
            addWidget(new FarmIcon(m_window.icon_mc,this.m_rewardItem.getImageByName(FarmItem.ICON_FEED)));
         }
         else if(m_window.hasOwnProperty("reward_mc"))
         {
            addWidget(new FarmIcon(m_window.reward_mc,this.m_rewardItem.getImageByName(FarmItem.ICON_FEED)));
         }
         this.conditionallyDisplayJungleInnovationCard();
         if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionSubTextColor(m_window[this.m_subtext1]);
            TemplateUIUtility.applyExpansionGlowFilter(m_window[this.m_subtext2]);
         }
      }
      
      private function setTemplatizedValues() : void
      {
         if(m_window.hasOwnProperty("item_tf"))
         {
            this.m_subtext1 = "item_tf";
         }
         else if(m_window.hasOwnProperty("subtext1_tf"))
         {
            this.m_subtext1 = "subtext1_tf";
         }
         if(m_window.hasOwnProperty("info_tf"))
         {
            this.m_subtext2 = "info_tf";
         }
         else if(m_window.hasOwnProperty("subtext2_tf"))
         {
            this.m_subtext2 = "subtext2_tf";
         }
      }
      
      private function onAccept(event:Event) : void
      {
         this.close();
         if(this.m_building)
         {
            this.m_building.displayStorageDialog();
         }
      }
   }
}

