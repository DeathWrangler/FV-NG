package Widgets.Windows
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AnimalSanctuaryV2MilestonePopup extends FarmWindow
   {
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_reward2:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      protected var m_closeBt:FarmButton = null;
      
      protected var subtext1_tf:ZwTextField = null;
      
      protected var subtext2_tf:ZwTextField = null;
      
      private var m_iconPreview:ObjectPreviewFrame;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      private var m_okay_bt:FarmAnimatedTextButton;
      
      private var m_iconUrl:String;
      
      private var m_icon_mc:FarmIcon;
      
      private var m_stage:int;
      
      private var m_isBonusReward:Boolean;
      
      private var m_stage_complete_mc:MovieClip;
      
      private var m_milestone_cons_mc:FarmIcon;
      
      private var m_milestone_reward_mc:FarmIcon;
      
      private var m_milestone_name_tf:ZwTextField;
      
      private var m_milestone_cons_next_mc:FarmIcon;
      
      public function AnimalSanctuaryV2MilestonePopup(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, rewardItem2:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null, imageIcon:String = null, stage:int = 0, isBonusReward:Boolean = false)
      {
         this.m_reward = rewardItem;
         this.m_reward2 = rewardItem2;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_dialogBackground = dialogBackground;
         this.m_iconUrl = imageIcon;
         this.m_stage = stage;
         this.m_isBonusReward = isBonusReward;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         super(dialogAsset,true,true);
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var level:int = 0;
         var c1Item:FarmItem = null;
         var levelTemp:int = 0;
         var c2Item:FarmItem = null;
         super.postLoadComplete();
         var itemFriendlyTitle:String = "";
         var itemIconUrl:String = "";
         if(this.m_reward != null)
         {
            itemFriendlyTitle = this.m_reward.friendlyTitle;
            itemIconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
         }
         var itemFriendlyTitle2:String = "";
         var itemIconUrl2:String = "";
         if(this.m_reward2)
         {
            itemFriendlyTitle2 = this.m_reward2.friendlyTitle;
            itemIconUrl2 = this.m_reward2.getImageByName(FarmItem.ICON_FEED);
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("stage_complete_mc"))
            {
               this.m_stage_complete_mc = m_window["stage_complete_mc"] as MovieClip;
               this.m_stage_complete_mc.visible = true;
               if(this.m_stage_complete_mc.hasOwnProperty("title_tf"))
               {
                  if(this.m_isBonusReward)
                  {
                     addWidget(new ZwTextField(this.m_stage_complete_mc["title_tf"],"Congratulations!"));
                  }
                  else
                  {
                     addWidget(new ZwTextField(this.m_stage_complete_mc["title_tf"],"Sanctuary Upgraded!"));
                  }
               }
               if(this.m_stage_complete_mc.hasOwnProperty("milestone_name_tf"))
               {
                  this.m_milestone_name_tf = new ZwTextField(this.m_stage_complete_mc["milestone_name_tf"]);
                  if(this.m_stage < 4)
                  {
                     this.m_milestone_name_tf.text = "You have completed " + this.manager.ANIMAL_SANCTUARY_NAME[this.manager.getSelectedAnimalSlot() - 1].toString() + " stage " + this.m_stage.toString() + "! Keep Going!";
                  }
                  else if(this.m_isBonusReward)
                  {
                     this.m_milestone_name_tf.text = "You have saved all the animals and received the " + itemFriendlyTitle;
                  }
                  this.m_milestone_name_tf.visible = true;
               }
               if(this.m_stage_complete_mc.hasOwnProperty("milestone_reward_mc"))
               {
                  this.m_milestone_reward_mc = new FarmIcon(this.m_stage_complete_mc["milestone_reward_mc"]);
                  this.m_milestone_reward_mc.loadIcon(itemIconUrl);
                  if(this.m_isBonusReward)
                  {
                     this.m_milestone_reward_mc.setIconSize(150,150);
                  }
                  else
                  {
                     this.m_milestone_reward_mc.setIconSize(100,100);
                  }
                  this.m_milestone_reward_mc.visible = true;
               }
               if(this.m_stage_complete_mc.hasOwnProperty("milestone_cons_mc"))
               {
                  this.m_milestone_cons_mc = new FarmIcon(this.m_stage_complete_mc["milestone_cons_mc"]);
                  this.m_milestone_cons_mc.visible = false;
                  level = this.m_stage;
                  if(!this.manager.isFeatureCompleted && level < 4)
                  {
                     c1Item = Global.farmGameSettingsManager.getFarmItemByName(this.manager.MILESTONE_CONSUMABLES_REWARDS[level - 1][0]);
                     if(c1Item)
                     {
                        this.m_milestone_cons_mc.loadIcon(c1Item.iconUrl);
                        this.m_milestone_cons_mc.setIconSize(50,50);
                        this.m_milestone_cons_mc.visible = true;
                        this.m_milestone_cons_mc.attachTooltip(new FarmTextTooltip(c1Item.friendlyTitle));
                     }
                  }
               }
               if(this.m_stage_complete_mc.hasOwnProperty("milestone_cons_next_mc"))
               {
                  this.m_milestone_cons_next_mc = new FarmIcon(this.m_stage_complete_mc["milestone_cons_next_mc"]);
                  this.m_milestone_cons_next_mc.visible = false;
                  levelTemp = this.m_stage;
                  if(!this.manager.isFeatureCompleted && levelTemp < 4)
                  {
                     c2Item = Global.farmGameSettingsManager.getFarmItemByName(this.manager.MILESTONE_CONSUMABLES_REWARDS[levelTemp - 1][1]);
                     if(c2Item)
                     {
                        this.m_milestone_cons_next_mc.loadIcon(c2Item.iconUrl);
                        this.m_milestone_cons_next_mc.setIconSize(50,50);
                        this.m_milestone_cons_next_mc.visible = true;
                        this.m_milestone_cons_next_mc.attachTooltip(new FarmTextTooltip(c2Item.friendlyTitle));
                     }
                  }
               }
               if(this.m_stage_complete_mc.hasOwnProperty("okay_bt"))
               {
                  if(this.m_stage >= 4)
                  {
                     this.m_share_bt = addWidget(new FarmAnimatedTextButton(this.m_stage_complete_mc["okay_bt"],"Share!",this.shareCallbackLast)) as FarmAnimatedTextButton;
                     this.m_share_bt.visible = true;
                  }
                  else
                  {
                     this.m_share_bt = addWidget(new FarmAnimatedTextButton(this.m_stage_complete_mc["okay_bt"],"Share!",this.shareCallback)) as FarmAnimatedTextButton;
                     this.m_share_bt.visible = true;
                  }
               }
            }
            if(this.m_isBonusReward)
            {
               this.m_share_bt.callback = this.shareCallbackBonusReward;
            }
            else
            {
               this.m_share_bt.callback = this.shareCallback;
            }
         }
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
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
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.m_reward.iconUrl
            }],
            "user":Global.player.firstName,
            "item":this.m_reward.friendlyTitle,
            "stage":(this.m_stage + 1).toString(),
            "sanctuaryname":this.manager.ANIMAL_SANCTUARY_NAME[this.manager.getSelectedAnimalSlot() - 1].toString()
         };
         GlobalEngine.socialNetwork.publishFeedStory("AnimalSanctuaryV2MilestoneShare",bundleData,[],false,null);
         this.onClose(e);
      }
      
      private function shareCallbackLast(e:Event) : void
      {
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.m_reward.icon
            }],
            "user":Global.player.firstName,
            "item":this.m_reward.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("AnimalSanctuary_share_last_milestoneReward",bundleData,[],false,null);
         this.onClose(e);
      }
      
      private function shareCallbackBonusReward(e:Event) : void
      {
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.m_reward.icon
            }],
            "user":Global.player.firstName,
            "item":this.m_reward.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("AnimalSanctuary_share_bonusReward",bundleData,[],false,null);
         this.onClose(e);
      }
   }
}

