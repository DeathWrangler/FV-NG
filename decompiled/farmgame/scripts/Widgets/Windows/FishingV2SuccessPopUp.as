package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Managers.FishingV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FishingV2SuccessPopUp extends FarmWindow
   {
      
      private static const FISH_ICONS:Array = [["tropicalrainbowfish","butteryfish","honeygourami","bubblegumfish","candybasslet"],["strawberryflowerhorn","freshwatericingfish","cookietrout","discuslollyfish"],["cherryblossomfish","chocodipdamselfish","cottoncandybetta"]];
      
      private var m_fishType:int;
      
      private var m_fishIndex:int;
      
      private var m_isBoot:Boolean;
      
      private var m_fishIcon:FarmIcon;
      
      private var m_masteryStarMC:MovieClip;
      
      private var m_retryBT:FarmAnimatedTextButton;
      
      private var m_shareBT:FarmAnimatedTextButton;
      
      private var m_collectionBT:FarmAnimatedTextButton;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_arrow_mc:MovieClip;
      
      private var m_tutorial_2_mc:MovieClip;
      
      private var m_arrow_2_mc:MovieClip;
      
      private var m_firstTimeReward:String;
      
      private var m_reward1_mc:MovieClip;
      
      private var m_reward2_mc:MovieClip;
      
      private var m_reward1_Icon_mc:FarmIcon;
      
      private var m_reward1_tf:ZwTextField;
      
      private var m_reward2_tf:ZwTextField;
      
      private var m_reward2_Icon_mc:FarmIcon;
      
      private var m_blackStarMc:MovieClip;
      
      private var m_rewradItem:FarmItem;
      
      private var m_boot_subtextTf:ZwTextField;
      
      private var m_fishCountTf:ZwTextField;
      
      public function FishingV2SuccessPopUp(assetURL:String, fishType:int, fishIndex:int, isBoot:Boolean, firstTimeReward:String)
      {
         super(assetURL);
         this.m_fishType = fishType;
         this.m_fishIndex = fishIndex;
         this.m_isBoot = isBoot;
         this.m_firstTimeReward = firstTimeReward;
      }
      
      override protected function postLoadComplete() : void
      {
         var rewardItem:FarmItem = null;
         var rewardItem2:FarmItem = null;
         var className:String = null;
         var name:String = null;
         var index:int = 0;
         var levelMC:MovieClip = null;
         super.postLoadComplete();
         if(m_window["title_tf"])
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Fishing Frenzy"));
         }
         if(m_window["boot_subtext_tf"])
         {
            addWidget(this.m_boot_subtextTf = new ZwTextField(m_window["boot_subtext_tf"],"You got a Drowned Shoe! Collect more to exchange for Rods. Try a different rod for better luck."));
            this.m_boot_subtextTf.visible = this.m_isBoot;
         }
         if(m_window.hasOwnProperty("s_reward_0_mc"))
         {
            this.m_reward1_mc = m_window["s_reward_0_mc"] as MovieClip;
            this.m_reward1_tf = new ZwTextField(this.m_reward1_mc["reward_name_tf"],"");
            this.m_reward1_tf.visible = true;
            this.m_reward1_Icon_mc = new FarmIcon(this.m_reward1_mc.success_reward_mc) as FarmIcon;
            this.m_reward1_Icon_mc.visible = true;
            if(this.m_firstTimeReward != "")
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_firstTimeReward);
               if(rewardItem)
               {
                  this.m_reward1_mc.visible = true;
                  this.m_reward1_tf.text = rewardItem.friendlyTitle;
                  this.m_reward1_Icon_mc.loadIcon(rewardItem.iconUrl);
               }
            }
         }
         if(m_window.hasOwnProperty("s_reward_1_mc"))
         {
            this.m_reward2_mc = m_window["s_reward_1_mc"] as MovieClip;
            this.m_reward2_tf = new ZwTextField(this.m_reward2_mc["reward_name_tf"],"");
            this.m_reward2_tf.visible = true;
            this.m_reward2_Icon_mc = new FarmIcon(this.m_reward2_mc.success_reward_mc) as FarmIcon;
            this.m_reward2_Icon_mc.visible = true;
            if(this.m_firstTimeReward != "")
            {
               rewardItem2 = Global.farmGameSettingsManager.getFarmItemByName("consume_turbo_charger");
               if(rewardItem2)
               {
                  this.m_reward2_mc.visible = true;
                  this.m_reward2_tf.text = rewardItem2.friendlyTitle;
                  this.m_reward2_Icon_mc.loadIcon(rewardItem2.iconUrl);
               }
            }
         }
         if(m_window["success_title_tf"])
         {
            addWidget(new ZwTextField(m_window["success_title_tf"],"You caught " + (this.m_isBoot ? "something" : "a Fish")));
         }
         if(m_window.hasOwnProperty("fish_count_tf"))
         {
            this.m_fishCountTf = new ZwTextField(m_window["fish_count_tf"],"");
            this.m_fishCountTf.text = FishingV2Manager.getInstance().getfishCount(this.m_fishType,this.m_fishIndex).toString() + "/9";
            this.m_fishCountTf.visible = !this.m_isBoot;
         }
         if(m_window["class_name_tf"])
         {
            className = this.m_isBoot ? "" : ["Common Fish","Uncommon Fish","Rare Fish"][this.m_fishType];
            addWidget(new ZwTextField(m_window["class_name_tf"],className),!this.m_isBoot);
         }
         if(m_window["fish_name_tf"])
         {
            name = this.m_isBoot ? "Drowned Shoe" : FishingV2Manager.FISH_NAMES[this.m_fishType][this.m_fishIndex];
            addWidget(new ZwTextField(m_window["fish_name_tf"],name));
         }
         if(m_window["fish_icon_mc"])
         {
            this.m_fishIcon = new FarmIcon(m_window["fish_icon_mc"]);
            this.m_rewradItem = Global.farmGameSettingsManager.getFarmItemByName(FishingV2Manager.FISH_CMS_NAME_ARRAY[this.m_fishType][this.m_fishIndex]);
            if(!this.m_isBoot)
            {
               this.m_fishIcon.loadIcon(Global.getAssetURL("assets/animalsnew/" + FishingV2Manager.FISH_CMS_NAME_ARRAY[this.m_fishType][this.m_fishIndex] + "_icon_200.png"));
               this.m_fishIcon.setIconSize(200,200);
            }
            this.m_fishIcon.visible = true;
         }
         if(m_window["mastery_star_mc"])
         {
            this.m_masteryStarMC = m_window["mastery_star_mc"] as MovieClip;
            index = 0;
            while(this.m_masteryStarMC.hasOwnProperty("level_star" + index.toString() + "_mc"))
            {
               levelMC = this.m_masteryStarMC["level_star" + index.toString() + "_mc"] as MovieClip;
               levelMC.visible = !this.m_isBoot && index < FishingV2Manager.getInstance().getMasteryStarsCount(this.m_fishType,this.m_fishIndex);
               index++;
            }
            if(this.m_masteryStarMC.hasOwnProperty("black_star_mc"))
            {
               this.m_blackStarMc = this.m_masteryStarMC["black_star_mc"] as MovieClip;
               this.m_blackStarMc.visible = !this.m_isBoot;
            }
            this.m_masteryStarMC.visible = !this.m_isBoot;
         }
         if(m_window["retry_bt"])
         {
            this.m_retryBT = new FarmAnimatedTextButton(m_window["retry_bt"],"",function(event:Event):void
            {
               FishingV2Manager.getInstance().openCraftingWindow();
               close();
            }) as FarmAnimatedTextButton;
            if(FishingV2Manager.getInstance().isMasteryTrophyGranted())
            {
               this.m_retryBT.visible = false;
            }
            else
            {
               this.m_retryBT.visible = true;
            }
         }
         if(m_window["share_bt"])
         {
            this.m_shareBT = new FarmAnimatedTextButton(m_window["share_bt"],"Share",this.shareCallback) as FarmAnimatedTextButton;
            this.m_shareBT.visible = !this.m_isBoot;
         }
         if(m_window["collection_bt"])
         {
            this.m_collectionBT = new FarmAnimatedTextButton(m_window["collection_bt"],"",function(event:Event):void
            {
               FishingV2Manager.getInstance().showFishCollectionsWindow();
               close();
            }) as FarmAnimatedTextButton;
            this.m_collectionBT.visible = true;
         }
         if(m_window.hasOwnProperty("new_tutorial_mc"))
         {
            this.m_tutorial_mc = m_window["new_tutorial_mc"] as MovieClip;
            this.m_arrow_mc = this.m_tutorial_mc.arrow_mc as MovieClip;
            if(FishingV2Manager.isTutorial2Over())
            {
               this.m_tutorial_mc.visible = false;
            }
            else
            {
               this.m_tutorial_mc.visible = true;
               this.m_tutorial_mc.gotoAndStop(1);
            }
         }
         if(m_window.hasOwnProperty("new_tutorial_2_mc"))
         {
            this.m_tutorial_2_mc = m_window["new_tutorial_2_mc"] as MovieClip;
            this.m_arrow_2_mc = this.m_tutorial_2_mc.arrow_mc as MovieClip;
            this.m_tutorial_2_mc.visible = false;
         }
         if(!FishingV2Manager.isTutorial2Over())
         {
            this.m_retryBT.visible = false;
            this.m_shareBT.visible = false;
         }
      }
      
      override protected function afterLoad() : void
      {
         super.afterLoad();
         m_closeButton.visible = false;
      }
      
      private function shareCallback(e:Event) : void
      {
         var bundleData:Object = null;
         var fi:FarmItem = this.m_rewradItem;
         if(fi != null)
         {
            bundleData = {
               "images":[{
                  "href":"{SN_APP_URL}",
                  "src":fi.icon
               }],
               "user":Global.player.firstName,
               "item":fi.friendlyTitle
            };
         }
         else
         {
            bundleData = {};
         }
         this.m_shareBT.visible = false;
         GlobalEngine.socialNetwork.publishFeedStory("FishingV2_BragFeed",bundleData,[],false,null);
         FarmStatsManager.count("FishingV2","reward_bragfeed",fi.friendlyTitle);
      }
   }
}

