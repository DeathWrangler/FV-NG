package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FishingV2FinalPopUp extends FarmWindow
   {
      
      private var m_titleTF:ZwTextField;
      
      private var m_retryBT:FarmAnimatedTextButton;
      
      private var m_collectionBT:FarmAnimatedTextButton;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_body2Tf:ZwTextField;
      
      private var m_featureName:String;
      
      private var m_collectionTrophy:MovieClip;
      
      private var m_masteryTrophy:MovieClip;
      
      private var m_acceptBtn:FarmAnimatedTextButton;
      
      private var m_ismastery:Boolean;
      
      private var m_rewardTrophy:FarmItem;
      
      public function FishingV2FinalPopUp(featureName:String, assetURL:String, type:String)
      {
         var rewardItem:FarmItem = null;
         this.m_featureName = featureName;
         super(assetURL);
         if(type == "Mastery")
         {
            this.m_ismastery = true;
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName("cocostonebasstrophy");
            this.m_rewardTrophy = rewardItem;
         }
         else
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName("cottoncandybettatrophy");
            this.m_rewardTrophy = rewardItem;
            this.m_ismastery = false;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window["title_tf"])
         {
            if(this.m_ismastery)
            {
               this.m_titleTF = addWidget(new ZwTextField(m_window["title_tf"],"Fish Mastery Trophy Earned!")) as ZwTextField;
            }
            else
            {
               this.m_titleTF = addWidget(new ZwTextField(m_window["title_tf"],"Fish Collection Trophy Earned!")) as ZwTextField;
            }
            this.m_titleTF.visible = true;
         }
         if(m_window["body_tf"])
         {
            if(this.m_ismastery)
            {
               this.m_bodyTf = addWidget(new ZwTextField(m_window["body_tf"],"Congrats! You have mastered your collection in this lake and earned a Mastery Trophy!")) as ZwTextField;
            }
            else
            {
               this.m_bodyTf = addWidget(new ZwTextField(m_window["body_tf"],"Congrats! You have completed your collection in this lake and earned a Collection Trophy!")) as ZwTextField;
            }
            this.m_bodyTf.visible = true;
         }
         if(m_window["body2_tf"])
         {
            if(this.m_ismastery)
            {
               this.m_body2Tf = addWidget(new ZwTextField(m_window["body2_tf"],"This Trophy is harvestable for 2 weeks! Keep harvesting to get consumable rewards!")) as ZwTextField;
            }
            else
            {
               this.m_body2Tf = addWidget(new ZwTextField(m_window["body2_tf"],"This Trophy is harvestable for 2 weeks! Keep harvesting to get Choco Pretzel Rod and Rainbow Marshmallow Bait!")) as ZwTextField;
            }
            this.m_body2Tf.visible = true;
         }
         if(m_window["collection_trophy_mc"])
         {
            this.m_collectionTrophy = m_window["collection_trophy_mc"] as MovieClip;
            this.m_collectionTrophy.visible = !this.m_ismastery;
         }
         if(m_window["mastery_trophy_mc"])
         {
            this.m_masteryTrophy = m_window["mastery_trophy_mc"] as MovieClip;
            this.m_masteryTrophy.visible = this.m_ismastery;
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            this.m_acceptBtn = addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Share!",this.shareCallbackTrophy),false) as FarmAnimatedTextButton;
            this.m_acceptBtn.visible = true;
         }
      }
      
      private function shareCallbackTrophy(e:Event) : void
      {
         var fi:FarmItem = this.m_rewardTrophy;
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":fi.icon
            }],
            "user":Global.player.firstName,
            "item":fi.friendlyTitle
         };
         close();
         GlobalEngine.socialNetwork.publishFeedStory("FishingV2_Trophy",bundleData,[],false,null);
         FarmStatsManager.count("FishingV2","reward_bragfeed",fi.friendlyTitle);
      }
   }
}

