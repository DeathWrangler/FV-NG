package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.JMInnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class FrontierInnovationBuildingUpgradeWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_iconUrl:String;
      
      private var m_buildingName:String;
      
      private var m_subtext1Tf:ZwTextField;
      
      private var m_subtext2Tf:ZwTextField;
      
      private var m_shareBt:FarmAnimatedTextButton;
      
      private var m_showGiftMc:Boolean;
      
      public function FrontierInnovationBuildingUpgradeWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null, iconUrl:String = "", building:String = "hardy", showGift:Boolean = false)
      {
         super(dialogAsset,true,true);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_dialogBackground = dialogBackground;
         this.m_iconUrl = iconUrl;
         this.m_showGiftMc = showGift;
         this.m_buildingName = building;
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
               number = JMInnovationManager.getInstance().getRewardCount(this.m_featureName);
               type = JMInnovationManager.getInstance().getIngredientType(this.m_featureName);
               addWidget(new FarmTextField(m_window.innovation_mc.info3_tf,ZLocUtils.t("Dialogs","jungleInnovationText",{
                  "type":type,
                  "number":number
               })));
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var iconUrl:String = null;
         var bonusItemName:String = null;
         var bonusItem:FarmItem = null;
         var rewardIcon:FarmIcon = null;
         var npc_mc:MovieClip = null;
         var frameNumber:int = 0;
         super.postLoadComplete();
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         if(m_window != null)
         {
            this.conditionallyDisplayJungleInnovationCard();
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GenericText",{"itemName":itemName}))) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.generic_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.generic_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.generic_tf);
               }
            }
            else if(m_window.hasOwnProperty("title_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"Great Job!")) as ZwTextField;
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
               addWidget(this.m_subtext1Tf = new ZwTextField(m_window["subtext1_tf"],"You just upgraded the Hardy Home!"));
               if(this.m_buildingName == "hardyhome")
               {
                  this.m_subtext1Tf.text = "The Hardy Home is complete! Harvest it everyday for fabulous rewards!";
               }
               else if(this.m_buildingName == "finalReward")
               {
                  this.m_subtext1Tf.text = "You’ve earned the reward(s) below for reaching the last milestone!";
               }
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
               addWidget(this.m_subtext2Tf = new ZwTextField(m_window["subtext2_tf"],"Keep collecting Frontier Coinage to upgrade it completely!"));
               if(this.m_buildingName == "hardyhome")
               {
                  this.m_subtext2Tf.text = "";
               }
               else if(this.m_buildingName == "finalReward")
               {
                  this.m_subtext2Tf.text = "Now keep harvesting your Hardy Home everyday and get rich rewards!";
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.subtext2_tf);
               }
            }
            if(m_window.hasOwnProperty("generic4_tf"))
            {
               addWidget(new ZwTextField(m_window["generic4_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Generic4Text",{"itemName":itemName})));
            }
            else if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_gift_mc = m_window.giftbox_mc;
               if(this.m_showGiftMc)
               {
                  this.m_gift_mc.visible = true;
               }
               else
               {
                  this.m_gift_mc.visible = false;
               }
            }
            if(m_window.hasOwnProperty("share_bt") && this.m_buildingName != "finalReward")
            {
               addWidget(this.m_shareBt = new FarmAnimatedTextButton(m_window["share_bt"],"Share!",this.buttonCallback));
            }
            else if(m_window.hasOwnProperty("accept_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome",this.buttonCallback));
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               iconUrl = Global.getAssetURL("assets/buildings/xnf_hardyhome1_icon.png");
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
                  if(iconUrl == null)
                  {
                     iconUrl = this.m_reward.iconUrl;
                  }
               }
               addWidget(new FarmIcon(m_window["icon_mc"],iconUrl));
            }
            else if(m_window.hasOwnProperty("opf_mc"))
            {
               this.addWidget(new ObjectPreviewFrame(m_window.opf_mc,this.m_reward,null,[this.m_zoomingScale],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            }
            else if(m_window.hasOwnProperty("reward_mc"))
            {
               iconUrl = Global.getAssetURL(this.m_iconUrl);
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
                  if(iconUrl == null)
                  {
                     iconUrl = this.m_reward.iconRelativeUrl;
                     if(iconUrl.indexOf("unwitherringbox") >= 0)
                     {
                        iconUrl = iconUrl.replace("unwitherringbox","unwitherringgoldruby_200");
                     }
                     iconUrl = Global.getAssetURL(iconUrl);
                  }
               }
               addWidget(new FarmIcon(m_window["reward_mc"],iconUrl));
            }
            if(m_window.hasOwnProperty("bonus_mc"))
            {
               bonusItemName = this.m_reward.getDefaultItemName();
               if(bonusItemName)
               {
                  bonusItem = Global.farmGameSettingsManager.getFarmItemByName(bonusItemName);
                  m_window["bonus_mc"].visible = false;
                  if(bonusItem)
                  {
                     if(Boolean(m_window["bonus_mc"].hasOwnProperty("name_tf")) && Boolean(m_window["bonus_mc"].hasOwnProperty("icon2_mc")))
                     {
                        addWidget(new ZwTextField(m_window["bonus_mc"]["name_tf"],bonusItem.friendlyTitle));
                        rewardIcon = addWidget(new FarmIcon(m_window["bonus_mc"].icon2_mc)) as FarmIcon;
                        rewardIcon.setIconSize(100,100);
                        rewardIcon.setSmoothing(true);
                        rewardIcon.loadIcon(bonusItem.iconUrl);
                        rewardIcon.visible = true;
                        this.m_gift_mc.visible = false;
                     }
                  }
               }
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
            if(m_window.hasOwnProperty("npc_mc"))
            {
               npc_mc = m_window["npc_mc"] as MovieClip;
               frameNumber = 1;
               if(this.m_featureName.indexOf("first") > 0)
               {
                  frameNumber = 1;
               }
               else if(this.m_featureName.indexOf("second") > 0)
               {
                  frameNumber = 2;
               }
               else if(this.m_featureName.indexOf("third") > 0)
               {
                  frameNumber = 3;
               }
               npc_mc.visible = true;
               npc_mc.gotoAndStop(frameNumber);
            }
         }
      }
      
      private function buttonCallback(evt:Event) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(evt);
         }
         close();
      }
      
      override protected function onClose(evt:Event) : void
      {
         if(this.m_showGiftMc)
         {
            this.m_callback(evt);
         }
         super.onClose(evt);
      }
   }
}

