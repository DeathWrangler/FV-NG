package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.BringBackWinterManager;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class BBWinterRewardWindow extends FarmWindow
   {
      
      public static const PREVIEWWIDTH:Number = 150;
      
      public static const ANIMAL_ZOOM_LEVEL_1:Number = 2;
      
      public static const ANIMAL_ZOOM_LEVEL_2:Number = 2.5;
      
      private var m_type:String = null;
      
      private var m_featureName:String = null;
      
      private var m_rewardName:String = null;
      
      private var m_rewardLink:String = null;
      
      private var m_closeBt:FarmAnimatedButton;
      
      private var m_titleTf:FarmTextField;
      
      private var m_subTitleTf:FarmTextField;
      
      private var m_extraTf:FarmTextField;
      
      private var m_shareBt:FarmAnimatedTextButton;
      
      private var m_egg_ani:MovieClip;
      
      private var m_eggMc:MovieClip;
      
      private var m_icon_mc:MovieClip;
      
      private var m_multiplier:Number;
      
      private var m_isBonus:Boolean;
      
      private var m_title:FarmTextField;
      
      private var m_subtitle:FarmTextField;
      
      private var m_itemPreview:ObjectPreviewFrame = null;
      
      private var m_itemPreviewImage:FarmIcon = null;
      
      private var m_index:int = 0;
      
      private var m_itemIndex:int = 0;
      
      protected var m_learnMore_mc:FarmAnimatedButton;
      
      public function BBWinterRewardWindow(type:String, featureName:String, rewardName:String, multiplier:Number = 1, isBonus:Boolean = false, index:int = 0, itemIndex:int = 0)
      {
         this.m_type = type;
         this.m_isBonus = isBonus;
         this.m_featureName = featureName;
         this.m_rewardName = rewardName;
         this.m_multiplier = multiplier;
         this.m_index = index;
         this.m_itemIndex = itemIndex;
         var assetPath:String = BringBackWinterManager.getInstance(this.m_featureName).getRewardDialogPathFor(type);
         super(assetPath,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var windowName:String = null;
         var itemPreview:ObjectPreviewFrame = null;
         var item:FarmItem = null;
         var rewardItem:FarmItem = null;
         var replaceObj:Object = null;
         var subText:String = null;
         var pointsTf:String = null;
         var multiplier:Number = NaN;
         var rewardPkg:Object = null;
         var totalPointsTf:String = null;
         var milestoneMc:MovieClip = null;
         var mc:MovieClip = null;
         var defaultItemName:String = null;
         var baseItem:FarmItem = null;
         var xml:XML = null;
         var itemPreview2:ObjectPreviewFrame = null;
         super.postLoadComplete();
         if(m_window)
         {
            windowName = BringBackWinterManager.getInstance(this.m_featureName).getWindowName();
            if(m_window.hasOwnProperty("generic_tf"))
            {
               addWidget(this.m_title = new FarmTextField(m_window["generic_tf"],ZLocUtils.t("Dialogs",windowName + "_sfCounterCongratsTitle")),true);
               if(this.m_isBonus)
               {
                  this.m_title.text = "Bonus Earned!";
               }
            }
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
               replaceObj = {"itemName":rewardItem.friendlyTitle};
               subText = this.m_type == BringBackWinterManager.REWARD_PATH ? ZLocUtils.t("Dialogs",windowName + "_redeem_reward",replaceObj) : ZLocUtils.t("Dialogs",windowName + "_redeem_reward_first_time",replaceObj);
               addWidget(this.m_subtitle = new FarmTextField(m_window["generic2_tf"],subText),true);
               if(this.m_isBonus)
               {
                  this.m_subtitle.text = "You received " + rewardItem.friendlyTitle + " for rescuing all the animals!";
               }
            }
            if(m_window.hasOwnProperty("base_reward_mc"))
            {
               (m_window["base_reward_mc"] as MovieClip).visible = false;
               if(m_window["base_reward_mc"].hasOwnProperty("generic4_tf"))
               {
                  addWidget(new FarmTextField(m_window["base_reward_mc"]["generic4_tf"],ZLocUtils.t("Dialogs","in_your_gift_box")),false);
               }
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               (m_window["giftbox_mc"] as MovieClip).visible = true;
            }
            if(m_window.hasOwnProperty("multiplier_mc"))
            {
               multiplier = this.m_multiplier;
               (m_window["multiplier_mc"] as MovieClip).visible = true;
               for each(rewardPkg in BringBackWinterManager.getInstance(this.m_featureName).getRewardPkgs())
               {
                  if(rewardPkg.name == this.m_rewardName)
                  {
                     pointsTf = rewardPkg.bonus.toString();
                     break;
                  }
               }
               if(m_window["multiplier_mc"].hasOwnProperty("milestone_mc"))
               {
                  milestoneMc = m_window["multiplier_mc"]["milestone_mc"] as MovieClip;
                  if(multiplier == 1)
                  {
                     milestoneMc.gotoAndStop(1);
                  }
                  else if(multiplier == 2)
                  {
                     milestoneMc.gotoAndStop(2);
                  }
                  else if(multiplier == 3)
                  {
                     milestoneMc.gotoAndStop(3);
                  }
                  else if(multiplier == 4)
                  {
                     milestoneMc.gotoAndStop(4);
                  }
               }
               addWidget(new FarmTextField(m_window["multiplier_mc"]["points_tf"],pointsTf));
               totalPointsTf = (multiplier * Number(pointsTf)).toString();
               addWidget(new FarmTextField(m_window["multiplier_mc"]["points_total_tf"],totalPointsTf));
               if(BringBackWinterManager.getInstance(this.m_featureName).isFeatureEnd())
               {
                  m_window["multiplier_mc"].visible = false;
               }
            }
            itemPreview = null;
            if(m_window.hasOwnProperty("opf_mc_1"))
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
               itemPreview = new ObjectPreviewFrame(m_window["opf_mc_1"],item,null,null,[200]);
               addWidget(itemPreview,true);
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               this.m_icon_mc = m_window.icon_mc as MovieClip;
            }
            if(this.m_index != 0)
            {
               if(m_window.hasOwnProperty("egg_ani"))
               {
                  this.m_egg_ani = m_window.egg_ani as MovieClip;
                  this.m_egg_ani.visible = true;
                  if(this.m_egg_ani.hasOwnProperty("egg_mc"))
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
                     this.m_eggMc = this.m_egg_ani.egg_mc as MovieClip;
                     this.m_eggMc.gotoAndStop(this.m_index);
                     this.m_eggMc.visible = true;
                  }
                  this.m_egg_ani.play();
                  this.m_egg_ani.addEventListener(Event.ENTER_FRAME,this.listenForEggAnimationEnd,false,0,true);
               }
            }
            else
            {
               this.loadrewardicon();
            }
            if(m_window.hasOwnProperty("transform_mc"))
            {
               mc = m_window["transform_mc"] as MovieClip;
               mc.visible = true;
               item = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
               defaultItemName = "";
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  defaultItemName = item.getStringFromDataSource("breedingAdult");
               }
               else
               {
                  xml = item.xml;
                  defaultItemName = xml.breedingAdult;
               }
               if(Boolean(defaultItemName) && defaultItemName != "")
               {
                  baseItem = Global.farmGameSettingsManager.getFarmItemByName(defaultItemName);
                  if(mc.hasOwnProperty("opf_mc_1"))
                  {
                     itemPreview = new ObjectPreviewFrame(mc["opf_mc_1"],baseItem,null,[ANIMAL_ZOOM_LEVEL_2]);
                     addWidget(itemPreview,true);
                  }
               }
               if(mc.hasOwnProperty("opf_mc_2"))
               {
                  itemPreview2 = new ObjectPreviewFrame(mc["opf_mc_2"],item,null,[ANIMAL_ZOOM_LEVEL_2]);
                  addWidget(itemPreview2,true);
               }
               mc.play();
            }
            if(m_window.hasOwnProperty("share_bt"))
            {
               addWidget(this.m_shareBt = new FarmAnimatedTextButton(m_window["share_bt"],ZLocUtils.t("Dialogs",this.m_featureName + "ShareButtonText"),this.onShareFeed),true);
            }
            if(m_window.hasOwnProperty("learnMore_mc"))
            {
               this.m_learnMore_mc = addWidget(new FarmAnimatedTextButton(m_window.learnMore_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"LearnMore"),this.openUrl),true) as FarmAnimatedButton;
            }
         }
         if(this.m_type == BringBackWinterManager.BONUS_REWARD_PATH)
         {
            this.recursivelyPlay(m_window);
         }
      }
      
      protected function recursivelyPlay(container:DisplayObjectContainer) : void
      {
         var displayContainer:DisplayObjectContainer = null;
         if(container is MovieClip)
         {
            MovieClip(container).play();
         }
         for(var childIdx:int = 0; childIdx < container.numChildren; childIdx++)
         {
            displayContainer = container.getChildAt(childIdx) as DisplayObjectContainer;
            if(Boolean(displayContainer) && displayContainer.numChildren > 1)
            {
               this.recursivelyPlay(displayContainer);
            }
         }
      }
      
      public function listenForEggAnimationEnd(e:Event = null) : void
      {
         if(this.m_egg_ani.currentFrame == 63)
         {
            this.m_egg_ani.gotoAndStop(1);
            this.m_egg_ani.visible = false;
            this.loadrewardicon();
         }
      }
      
      private function loadrewardicon() : void
      {
         var item:FarmItem = null;
         item = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
         if(this.m_itemPreview)
         {
            removeWidget(this.m_itemPreview);
            this.m_itemPreview = null;
         }
         if(this.m_itemPreviewImage)
         {
            removeWidget(this.m_itemPreviewImage);
            this.m_itemPreviewImage = null;
         }
         if(Boolean(item) && !this.m_itemPreview)
         {
            this.m_itemPreview = new ObjectPreviewFrame(m_window.icon_mc,item,null,null,[200]);
            addWidget(this.m_itemPreview,true);
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         this.m_featureName = null;
         this.m_rewardName = null;
         this.m_type = null;
      }
      
      protected function onShareFeed(event:Event) : void
      {
         if(this.m_shareBt)
         {
            this.m_shareBt.enabled = false;
         }
         if(this.m_rewardName === BringBackWinterManager.getInstance(this.m_featureName).getBonusReward())
         {
            BringBackWinterManager.getInstance(this.m_featureName).shareBonusBragFeed(this.m_rewardName);
         }
         else
         {
            BringBackWinterManager.getInstance(this.m_featureName).shareBragFeed(this.m_rewardName);
         }
         this.onClose(null);
      }
      
      private function openUrl(event:Event) : void
      {
         navigateToURL(new URLRequest(ZLocUtils.t("Dialogs","MOTD_MERRY_MARSHALL_linkURL")),"_blank");
      }
   }
}

