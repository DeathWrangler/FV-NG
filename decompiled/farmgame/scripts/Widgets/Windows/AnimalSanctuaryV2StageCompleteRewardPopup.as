package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AnimalSanctuaryV2StageCompleteRewardPopup extends FarmWindow
   {
      
      internal var m_reward1:String;
      
      internal var m_reward2:String;
      
      private var m_stageCompleteMc:MovieClip;
      
      private var m_stage_reward_mc:FarmIcon;
      
      private var m_milestone_reward_mc:FarmIcon;
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      private var reward_1:FarmItem;
      
      private var reward_2:FarmItem;
      
      private var m_isBonus:Boolean;
      
      public function AnimalSanctuaryV2StageCompleteRewardPopup(dialogAsset:String, featureName:String, reward1:String, reward2:String, isBonus:Boolean = false)
      {
         this.m_reward1 = reward1;
         this.m_reward2 = reward2;
         if(reward1)
         {
            this.reward_1 = Global.farmGameSettingsManager.getFarmItemByName(this.m_reward1);
         }
         if(reward2)
         {
            this.reward_2 = Global.farmGameSettingsManager.getFarmItemByName(this.m_reward2);
         }
         this.m_isBonus = isBonus;
         super(dialogAsset,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("stage_complete_mc"))
            {
               this.m_stageCompleteMc = m_window["stage_complete_mc"] as MovieClip;
               this.m_stageCompleteMc.visible = true;
               if(this.m_stageCompleteMc.hasOwnProperty("title_tf"))
               {
                  if(this.m_isBonus)
                  {
                     addWidget(new ZwTextField(this.m_stageCompleteMc["title_tf"],"Congratulations!"));
                  }
                  else
                  {
                     addWidget(new ZwTextField(this.m_stageCompleteMc["title_tf"],"Animal Saved!"));
                  }
               }
               if(this.m_stageCompleteMc.hasOwnProperty("subtext_tf"))
               {
                  if(this.m_isBonus)
                  {
                     addWidget(new ZwTextField(this.m_stageCompleteMc["subtext_tf"],"You have saved all the animals and received the " + this.reward_1.friendlyTitle));
                  }
                  else
                  {
                     addWidget(new ZwTextField(this.m_stageCompleteMc["subtext_tf"],"You have successfully saved and recieved " + this.reward_2.friendlyTitle + " and it’s sanctuary!"));
                  }
               }
               if(this.m_stageCompleteMc.hasOwnProperty("final_animal_mc"))
               {
                  this.m_stage_reward_mc = new FarmIcon(this.m_stageCompleteMc["final_animal_mc"]);
                  this.m_stage_reward_mc.loadIcon(this.reward_1.getImageByName(FarmItem.ICON_FEED));
                  this.m_stage_reward_mc.setIconSize(200,200);
                  this.m_stage_reward_mc.visible = true;
               }
               if(this.m_stageCompleteMc.hasOwnProperty("final_animal_reward_mc"))
               {
                  this.m_milestone_reward_mc = new FarmIcon(this.m_stageCompleteMc["final_animal_reward_mc"]);
                  if(this.m_isBonus)
                  {
                     this.m_milestone_reward_mc.visible = false;
                  }
                  else
                  {
                     this.m_milestone_reward_mc.loadIcon(this.reward_2.getImageByName(FarmItem.ICON_FEED));
                     this.m_milestone_reward_mc.setIconSize(100,100);
                     this.m_milestone_reward_mc.visible = true;
                  }
               }
               if(this.m_stageCompleteMc.hasOwnProperty("okay_bt"))
               {
                  if(this.m_isBonus)
                  {
                     this.m_share_bt = addWidget(new FarmAnimatedTextButton(this.m_stageCompleteMc["okay_bt"],"Share!",this.shareCallbackFinalReward)) as FarmAnimatedTextButton;
                  }
                  else
                  {
                     this.m_share_bt = addWidget(new FarmAnimatedTextButton(this.m_stageCompleteMc["okay_bt"],"Share!",this.shareCallbackLast)) as FarmAnimatedTextButton;
                  }
                  this.m_share_bt.visible = true;
               }
            }
         }
      }
      
      private function shareCallbackLast(e:Event) : void
      {
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.reward_1.iconUrl
            }],
            "user":Global.player.firstName,
            "item":this.reward_1.friendlyTitle,
            "item1":this.reward_2.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("AnimalSanctuaryV2AnimalStageShare",bundleData,[],false,null);
         onClose(e);
      }
      
      private function shareCallbackFinalReward(e:Event) : void
      {
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.reward_1.iconUrl
            }],
            "user":Global.player.firstName,
            "item":this.reward_1.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("AnimalSanctuaryV2AnimalSanctuaryShare",bundleData,[],false,null);
         onClose(e);
      }
   }
}

