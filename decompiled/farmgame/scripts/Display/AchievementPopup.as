package Display
{
   import Classes.Achievement;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   import Widgets.Constants.Market.Currency;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class AchievementPopup extends Dialog
   {
      
      private var m_achievement:Achievement;
      
      private var m_sound:String;
      
      private var m_dialogShare:Boolean = GlobalEngine.currentTime > Global.farmGameSettingsManager.getInt("achievementTimer",60) * 1000;
      
      private var m_link:String;
      
      private var m_share:GenericButton;
      
      private var m_cancel:GenericButton;
      
      private var m_giveReward:Boolean = false;
      
      private var m_returnReward:Boolean = false;
      
      private var m_addRewardHandler:Function = null;
      
      private var m_rewardMessage:String = "";
      
      public function AchievementPopup(achievement:Achievement, link:String, difficulty:int, giveReward:Boolean = true, rewardMessage:String = "", addRewardHandler:Function = null)
      {
         m_dialogAsset = "assets/dialogs/FV_Achievement_Popup.swf";
         SoundManager.addSound("achieve1",Global.getAssetURL("assets/sounds/ui/sfx_achieve_stage1.mp3"),false);
         SoundManager.addSound("achieve2",Global.getAssetURL("assets/sounds/ui/sfx_achieve_stage2.mp3"),false);
         SoundManager.addSound("achieve3",Global.getAssetURL("assets/sounds/ui/sfx_achieve_stage3.mp3"),false);
         SoundManager.addSound("achieve4",Global.getAssetURL("assets/sounds/ui/sfx_achieve_stage4.mp3"),false);
         this.m_achievement = achievement;
         this.m_achievement.currentLevel = difficulty;
         this.m_giveReward = giveReward;
         this.m_rewardMessage = rewardMessage;
         this.m_addRewardHandler = addRewardHandler;
         this.m_link = link;
         if(Global.hud.isVisualEffectsLocked())
         {
            this.m_returnReward = true;
            Global.player.xp -= this.m_achievement.xp;
            Global.player.gold -= this.m_achievement.gold;
         }
         super(true);
      }
      
      private function setAchievementRibbon(ribbonName:String) : void
      {
         var frame:int = 0;
         switch(ribbonName)
         {
            case "YellowRibbon":
               frame = 1;
               this.m_sound = "achieve1";
               break;
            case "WhiteRibbon":
               frame = 2;
               this.m_sound = "achieve2";
               break;
            case "RedRibbon":
               frame = 3;
               this.m_sound = "achieve3";
               break;
            case "BlueRibbon":
               frame = 4;
               this.m_sound = "achieve4";
         }
         m_window.ribbons_mc.gotoAndStop(frame);
      }
      
      override protected function onLoadComplete() : void
      {
         var key:String;
         var url:String;
         var descriptionLoc:String = null;
         var icon:Loader = null;
         super.onLoadComplete();
         m_window.congratulations_tf.text = ZLocUtils.t("Dialogs","Congratulations");
         this.setAchievementRibbon(this.m_achievement.currentRibbon);
         key = this.m_achievement.name + "_" + this.m_achievement.currentRibbon + "_friendlyName";
         m_window.youGot_tf.text = ZLocUtils.t("Dialogs","YouGotRibbon",{"ribbon":ZLocUtils.tk("Achievements",key,"definite")});
         m_window.reward_tf.text = ZLocUtils.t("Dialogs","Reward");
         if(this.m_achievement.gift != "")
         {
            if(this.m_giveReward)
            {
               if(this.m_addRewardHandler != null)
               {
                  this.m_addRewardHandler(this.m_achievement.gift);
               }
               else
               {
                  Global.player.addGift(this.m_achievement.gift);
               }
            }
            if(this.m_achievement.gold != 0)
            {
               descriptionLoc = "AchievementRewardGift";
            }
            else
            {
               descriptionLoc = "AchievementRewardNoCoin";
            }
         }
         else
         {
            descriptionLoc = "AchievementRewardNoGift";
         }
         setTrackerKey("Achievements");
         if(this.m_rewardMessage != "")
         {
            descriptionLoc = this.m_rewardMessage;
         }
         m_window.description_tf.text = ZLocUtils.t("Dialogs",descriptionLoc,{
            "quantity":this.m_achievement.xp,
            "coinQuantity":this.m_achievement.gold
         });
         url = this.m_achievement.getImageByName("icon_100");
         icon = LoadingManager.load(url,function(event:Event):void
         {
            var dispObj:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               dispObj = icon.content;
               m_window.icon.addChild(dispObj);
            }
         });
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         if(this.m_dialogShare)
         {
            this.m_share = new GenericButton(m_window.share_bt,this.onShareClick);
            this.m_share.text = ZLocUtils.t("Dialogs","Share");
         }
         else
         {
            this.m_share = new GenericButton(m_window.share_bt,this.onCloseClick);
            this.m_share.text = ZLocUtils.t("Dialogs","Accept");
            FarmStatsManager.count("Achievement","Share_Unavailable",this.m_achievement.name,this.m_achievement.currentLevel.toString());
         }
         this.m_cancel = new GenericButton(m_window.cancel_bt,this.onCloseClick);
         this.m_cancel.text = ZLocUtils.t("Dialogs","Cancel");
         SoundManager.playSound(this.m_sound);
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         TransactionManager.addTransaction(new TCancelFriendReward([this.m_link]));
         FarmStatsManager.count("Achievement","Click_cancel",this.m_achievement.name,this.m_achievement.currentLevel.toString());
         event.stopPropagation();
         this.close();
      }
      
      override public function onShareClick(event:MouseEvent) : void
      {
         var ribbonImage:String = null;
         var countToNextLevel:int = 0;
         super.onShareClick(event);
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         FarmStatsManager.count("Achievement","Click_share_wealth",this.m_achievement.name,this.m_achievement.currentLevel.toString());
         switch(this.m_achievement.currentRibbon)
         {
            case "YellowRibbon":
               ribbonImage = this.m_achievement.getImageByName("icon_yellow");
               break;
            case "WhiteRibbon":
               ribbonImage = this.m_achievement.getImageByName("icon_white");
               break;
            case "RedRibbon":
               ribbonImage = this.m_achievement.getImageByName("icon_red");
               break;
            case "BlueRibbon":
               ribbonImage = this.m_achievement.getImageByName("icon_blue");
         }
         var images:Array = [{
            "src":ribbonImage,
            "href":"{SN_APP_URL}" + this.m_link
         }];
         var ribbon:String = "Achievements:" + this.m_achievement.currentRibbon;
         var achievementText:String = "Notifications:Achievement_ShortStory_Body_" + this.m_achievement.name;
         var count:int = this.m_achievement.getCurrentCount();
         if(this.m_achievement.currentRibbon == "BlueRibbon")
         {
            achievementText = "Notifications:Achievement_ShortStory_Body_" + this.m_achievement.name + "_blueribbon";
            GlobalEngine.socialNetwork.publishFeedStory("GetAchievement",{
               "achievement_type":this.m_achievement.title,
               "subCategory":this.m_achievement.friendlyName,
               "achievementText":achievementText,
               "creative":ribbon,
               "images":images,
               "ribbon_type":ribbon,
               "ribbon_count":count,
               "reward_link":this.m_link,
               "first_name":Global.player.firstName
            },[],false);
         }
         else
         {
            countToNextLevel = this.m_achievement.countToNextLevel;
            GlobalEngine.socialNetwork.publishFeedStory("GetAchievement",{
               "achievement_type":this.m_achievement.title,
               "subCategory":this.m_achievement.friendlyName,
               "achievementText":achievementText,
               "creative":ribbon,
               "images":images,
               "ribbon_type":ribbon,
               "ribbon_count":count,
               "reward_link":this.m_link,
               "next_ribbon_type":this.m_achievement.nextRibbonColor,
               "next_ribbon_count":countToNextLevel,
               "first_name":Global.player.firstName
            },[],false);
         }
         event.stopPropagation();
         this.close();
      }
      
      override public function close() : void
      {
         if(this.m_giveReward || this.m_returnReward)
         {
            Global.hud.unlockVisualEffects();
            Global.player.xp += this.m_achievement.xp;
            Global.player.updateWorldCurrency(Currency.COINS,this.m_achievement.gold,true);
         }
         super.close();
      }
   }
}

