package Init.PostInitActionHandlers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.UI;
   import Engine.Helpers.Vector2;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.geom.Point;
   
   public class ProgressBarPostInitAction extends AbstractPostInitAction
   {
      
      public const BABY_LAMB_ITEM_CODE:String = "gJ";
      
      private var m_showLambMessageDialog:GenericDialog = null;
      
      public function ProgressBarPostInitAction()
      {
         super();
      }
      
      override public function execute() : void
      {
         var swfUrl:String = null;
         var params:Object = null;
         var showAnimation:Boolean = Global.player.getSeenFlag("progressBarCompleted") && !Global.player.getSeenFlag("progressBarRewardCompleted");
         if(showAnimation)
         {
            swfUrl = Global.getAssetURL("assets/effects/effect_progressBar_heart.swf");
            params = {
               "instanceName":"effect_mc",
               "addToStage":true,
               "freezeAll":true
            };
            Global.ui.displayOverlaySWF(swfUrl,new Point(0,0),new Vector2(760,600),0,this.onLambAnimationDone,params);
         }
         m_isFinished = true;
      }
      
      private function onLambAnimationDone() : void
      {
         var likedAtUnlock:Boolean = false;
         var emailAtUnlock:Boolean = false;
         var message:String = ZLocUtils.t("Dialogs","ProgressBarLambCompletedText");
         if(Global.player.progressBarData.hasOwnProperty("unlocked_invite_step"))
         {
            likedAtUnlock = Global.player.progressBarData.hasOwnProperty("unlocked_liked_state") && Boolean(Global.player.progressBarData["unlocked_liked_state"]);
            emailAtUnlock = Global.player.progressBarData.hasOwnProperty("unlocked_email_state") && Boolean(Global.player.progressBarData["unlocked_email_state"]);
            if(likedAtUnlock && !emailAtUnlock)
            {
               message = ZLocUtils.t("Dialogs","ProgressBarLambCompletedText_unlockedCase1");
            }
            else if(!likedAtUnlock && emailAtUnlock)
            {
               message = ZLocUtils.t("Dialogs","ProgressBarLambCompletedText_unlockedCase2");
            }
            else if(!likedAtUnlock && !emailAtUnlock)
            {
               message = ZLocUtils.t("Dialogs","ProgressBarLambCompletedText_unlockedCase3");
            }
         }
         Global.player.setSeenFlag("progressBarRewardCompleted");
         this.m_showLambMessageDialog = UI.showMessage(message,UI.BUTTON_LAYOUT_OK,null,Global.getAssetURL("assets/missions/lambbaby_brown_happy.png"),true,this.onLambShare,"feed-progress_bar");
      }
      
      public function onLambShare(event:WidgetControllerEvent) : void
      {
         var rewardLink:String = Global.player.progressBarData["reward_link"];
         var babyLambFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.BABY_LAMB_ITEM_CODE);
         var iconUrl:String = babyLambFarmItem.icon;
         var bundleData:Object = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":iconUrl
            }]
         };
         var messageType:String = "ProgressBarBabyLambReward";
         GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         this.m_showLambMessageDialog.destroy();
      }
   }
}

