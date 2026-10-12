package Widgets.Windows.LootableFixedFeatureBuilding
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class PostHarvestWindow extends FarmWindow
   {
      
      protected var m_deliveredItem:FarmItem;
      
      protected var m_deliveredItemQuantity:int;
      
      protected var m_futuretem:FarmItem;
      
      protected var m_shareUrl:String;
      
      protected var m_locPrefix:String;
      
      protected var m_buildingName:String;
      
      private var m_dialogBackground:String;
      
      private var m_npcUrl:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_npcLoader:ImageLoader = null;
      
      private var m_npcIcon:DisplayObject = null;
      
      private var m_slotBGIcon:DisplayObject;
      
      public function PostHarvestWindow(windowAssetRelUrl:String, deliveredItem:FarmItem, deliveredItemQuantity:int, futureItem:FarmItem, shareUrl:String, locPrefix:String, buildingName:String, dialogBgUrl:String, npcUrl:String)
      {
         super(windowAssetRelUrl);
         this.m_futuretem = futureItem;
         this.m_deliveredItem = deliveredItem;
         this.m_deliveredItemQuantity = deliveredItemQuantity;
         this.m_shareUrl = shareUrl;
         this.m_locPrefix = locPrefix;
         this.m_buildingName = buildingName;
         this.m_dialogBackground = dialogBgUrl;
         this.m_npcUrl = npcUrl;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         if(this.m_npcUrl != null)
         {
            this.m_npcLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_npcUrl));
            this.m_npcLoader.getContent(this.onNpcLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      private function onNpcLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_npcIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var levelIndex:int = 0;
         var futureItemIcon:FarmIcon = null;
         var futureItemTooltip:FarmTextTooltip = null;
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_locPrefix + "PostHarvestPopupTitle")));
         addWidget(new FarmTextField(m_window.name_tf,ZLocUtils.t("Dialogs",this.m_locPrefix + "PostHarvestPopupDeliveredItem",{
            "itemLimit":this.m_deliveredItemQuantity,
            "item":ZLocUtils.tk_pk(this.m_deliveredItem.friendlyName,"",this.m_deliveredItemQuantity),
            "building":ZLocUtils.tk_pk(this.m_deliveredItem.friendlyName)
         })));
         addWidget(new FarmTextField(m_window.generic_0_tf,ZLocUtils.t("Dialogs",this.m_locPrefix + "PostHarvestPopupShareQuestion")));
         addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","Share"),this.onShare));
         addWidget(new FarmTextField(m_window.amount_tf,ZLocUtils.t("Dialogs","GiftAmount",{"quantity":this.m_deliveredItemQuantity.toString()})),this.m_deliveredItemQuantity > 1);
         addWidget(new FarmIcon(m_window.loader_mc,this.m_deliveredItem.icon));
         if(this.m_futuretem != null)
         {
            addWidget(new FarmTextField(m_window.generic_1_tf,ZLocUtils.t("Dialogs",this.m_locPrefix + "PostHarvestPopupFutureItemText")));
            futureItemIcon = addWidget(new FarmIcon(m_window.icon_mc,this.m_futuretem.icon)) as FarmIcon;
            futureItemTooltip = new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(this.m_futuretem.friendlyName));
            futureItemIcon.attachTooltip(futureItemTooltip);
         }
         if(Boolean(m_window.mc_MOTD_noTitle) && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_MOTD_noTitle));
         }
         if(Boolean(m_window.mc_NPC) && Boolean(this.m_npcIcon))
         {
            m_window.mc_NPC.addChild(this.m_npcIcon);
            m_window.mc_NPC.visible = true;
         }
         var slotV80Path:String = Global.worldSettingsManager.getSlotBGImagePath("V80");
         if(slotV80Path)
         {
            for(levelIndex = 0; m_window.hasOwnProperty("mc_Slot_V_" + levelIndex); levelIndex++)
            {
               this.m_slotBGIcon = null;
               ImageLoader.getInstance(Global.getAssetURL(slotV80Path)).getContent(this.onSlotUrlLoaded);
               if(this.m_slotBGIcon)
               {
                  m_window["mc_Slot_V_" + levelIndex].addChild(this.m_slotBGIcon);
                  m_window["mc_Slot_V_" + levelIndex].visible = true;
               }
            }
         }
         var slotH60Path:String = Global.worldSettingsManager.getSlotBGImagePath("H60");
         if(slotH60Path)
         {
            for(levelIndex = 0; m_window.hasOwnProperty("mc_Slot_H_" + levelIndex); levelIndex++)
            {
               this.m_slotBGIcon = null;
               ImageLoader.getInstance(Global.getAssetURL(slotH60Path)).getContent(this.onSlotUrlLoaded);
               if(this.m_slotBGIcon)
               {
                  m_window["mc_Slot_H_" + levelIndex].addChild(this.m_slotBGIcon);
                  m_window["mc_Slot_H_" + levelIndex].visible = true;
               }
            }
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.name_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.name_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.name_tf);
            TemplateUIUtility.applyExpansionGlowFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionGlowFilter(m_window.amount_tf);
            TemplateUIUtility.applyExpansionGlowFilter(m_window.generic_0_tf);
            TemplateUIUtility.applyExpansionGlowFilter(m_window.generic_1_tf);
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      private function onShare(event:Event) : void
      {
         var bundleData:Object = {
            "reward_name":this.m_deliveredItem.friendlyName,
            "reward_link":this.m_shareUrl,
            "images":[{
               "href":"{SN_APP_URL}" + this.m_shareUrl,
               "src":this.m_deliveredItem.icon
            }]
         };
         FarmStatsManager.count("feed","feed",this.m_buildingName,"share_gift",this.m_deliveredItem.name);
         GlobalEngine.socialNetwork.publishFeedStory(this.m_buildingName + "_harvested",bundleData,[],false);
         this.close();
      }
   }
}

