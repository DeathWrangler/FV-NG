package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.JMInnovationManager;
   import Managers.OrderBoard.FarmRun2018Manager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class FarmRun2018SingleRewardPopup extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_closeBt:FarmButton = null;
      
      protected var subtext1_tf:ZwTextField = null;
      
      protected var subtext2_tf:ZwTextField = null;
      
      private const WORLD_REWARD_NAMES_ARRAY:Array = ["horse_decorator","pegacorn_firebeetle","unicorn_sharkfin","horse_shinyarmour"];
      
      private const WORLD_NAMES_ARRAY:Array = ["santavillage","fforest","atlantis","rainforest"];
      
      private var m_iconPreview:ObjectPreviewFrame;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      private var m_okay_bt:FarmAnimatedTextButton;
      
      private var BONUS_REWARD:String = "pegacorn_crowned";
      
      public function FarmRun2018SingleRewardPopup(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null)
      {
         super(dialogAsset,true,true);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_dialogBackground = dialogBackground;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function get manager() : FarmRun2018Manager
      {
         return FarmRun2018Manager.getInstance(this.m_featureName);
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
         var buttonCallback:Function = null;
         var worldRew:Boolean = false;
         var worldId:int = 0;
         var world:String = null;
         var worldElement:String = null;
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
         var worldReward:Boolean = true;
         var finalReward:Boolean = false;
         var finalworld:Boolean = false;
         var item:String = this.m_reward.name;
         var finalWorldRewardName:String = this.WORLD_REWARD_NAMES_ARRAY[3];
         if(item == this.BONUS_REWARD)
         {
            finalReward = true;
         }
         if(item == finalWorldRewardName)
         {
            finalworld = true;
         }
         if(this.WORLD_REWARD_NAMES_ARRAY.indexOf(item) == -1)
         {
            worldReward = false;
         }
         if(m_window != null)
         {
            this.conditionallyDisplayJungleInnovationCard();
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GenericText",{"itemName":itemName}))) as ZwTextField;
               if(this.m_featureName != "AmazonSafariCraftingBasket")
               {
                  if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
                  {
                     TemplateUIUtility.applyExpansionTextColor(m_window.generic_tf);
                     TemplateUIUtility.applyExpansionBevelFilter(m_window.generic_tf);
                     TemplateUIUtility.applyExpansionDropShadowFilter(m_window.generic_tf);
                  }
               }
            }
            else if(m_window.hasOwnProperty("title_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"CONGRATS!")) as ZwTextField;
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
               if(this.m_featureName != "AmazonSafariCraftingBasket")
               {
                  if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
                  {
                     TemplateUIUtility.applyExpansionSubTextColor(m_window.generic2_tf);
                  }
               }
            }
            else if(m_window.hasOwnProperty("subtext1_tf"))
            {
               this.subtext1_tf = addWidget(new ZwTextField(m_window["subtext1_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GenericText",{"itemName":itemName}))) as ZwTextField;
               if(!worldReward)
               {
                  this.subtext1_tf.text = "Hurrah! You’ve reached a milestone!";
               }
               if(finalReward)
               {
                  this.subtext1_tf.text = "Hurrah! You’ve completed the Farm Run!";
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
               }
            }
            if(m_window.hasOwnProperty("generic3_tf"))
            {
               addWidget(new ZwTextField(m_window["generic3_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Generic2Text",{"reward":itemName})));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.generic3_tf);
               }
            }
            else if(m_window.hasOwnProperty("subtext2_tf"))
            {
               this.subtext2_tf = addWidget(new ZwTextField(m_window["subtext2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Generic3Text",{"reward":itemName}))) as ZwTextField;
               if(!worldReward && !finalworld)
               {
                  this.subtext2_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Generic3MileStoneText",{"reward":itemName});
               }
               if(finalworld)
               {
                  this.subtext2_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Generic3MileStoneText",{"reward":itemName});
               }
               if(finalReward)
               {
                  this.subtext2_tf.text = "Here is your grand prize! You\'ve won a " + itemName + " !";
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
               this.m_gift_mc.visible = true;
            }
            worldRew = worldReward || finalReward;
            if(worldRew)
            {
               if(m_window.hasOwnProperty("share_bt"))
               {
                  buttonCallback = this.onClose;
                  if(this.m_callback != null)
                  {
                     buttonCallback = this.m_callback;
                  }
                  this.m_share_bt = addWidget(new FarmAnimatedTextButton(m_window["share_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ShareButtonText",{"itemName":itemName}),this.shareCallback)) as FarmAnimatedTextButton;
                  this.m_share_bt.text = "Share";
                  this.m_share_bt.visible = true;
               }
            }
            else if(m_window.hasOwnProperty("okay_bt"))
            {
               buttonCallback = this.onClose;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               this.m_okay_bt = addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ShareButtonText",{"itemName":itemName}),buttonCallback)) as FarmAnimatedTextButton;
               this.m_okay_bt.visible = true;
            }
            world = "";
            if(this.manager)
            {
               world = Global.worldManager.currentWorldType;
            }
            if(Boolean(this.manager) && this.WORLD_NAMES_ARRAY.indexOf(world) == -1)
            {
               world = this.manager.getFarmrunWorldFromPoints();
            }
            if(world != "")
            {
               worldId = this.manager.getworldIndexFromName(world);
            }
            else
            {
               worldId = 3;
            }
            worldElement = "world" + (worldId + 1) + "BG_mc";
            if(m_window.hasOwnProperty(worldElement))
            {
               m_window[worldElement].visible = true;
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               addWidget(this.m_iconPreview = new ObjectPreviewFrame(m_window["icon_mc"] as MovieClip,this.m_reward,null,null,[200]),true);
               this.m_iconPreview.attachTooltip(new FarmTextTooltip(itemName));
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
            }
            else if(m_window.hasOwnProperty("opf_mc"))
            {
               this.addWidget(new ObjectPreviewFrame(m_window.opf_mc,this.m_reward,null,[this.m_zoomingScale],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            }
            else if(m_window.hasOwnProperty("reward_mc"))
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
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
                  m_window["bonus_mc"].visible = true;
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
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
         if(this.isWorldReward() || this.isFinalReward())
         {
            if(m_closeButton)
            {
               m_closeButton.visible = true;
            }
         }
      }
      
      public function isFinalReward() : Boolean
      {
         return this.m_reward.name == this.BONUS_REWARD;
      }
      
      public function isWorldReward() : Boolean
      {
         var value:Boolean = true;
         if(this.WORLD_REWARD_NAMES_ARRAY.indexOf(this.m_reward.name) == -1)
         {
            value = false;
         }
         return value;
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(event);
         }
         super.onClose(event);
      }
      
      private function shareCallback(e:Event) : void
      {
         var fi:FarmItem = this.m_reward;
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":fi.icon
            }],
            "user":Global.player.firstName,
            "item":fi.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("farmrun2018_share_milestoneReward",bundleData,[],false,null);
         if(this.m_callback != null)
         {
            this.m_callback(e);
         }
         super.onClose(e);
         FarmStatsManager.count("GPF_FarmRunV10_2020","reward_bragfeed",fi.friendlyTitle);
      }
   }
}

