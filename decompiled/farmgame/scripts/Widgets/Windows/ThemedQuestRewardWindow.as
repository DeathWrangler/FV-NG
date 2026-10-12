package Widgets.Windows
{
   import Classes.Quest.FarmQuest;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.ThemedQuestManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.events.Event;
   
   public class ThemedQuestRewardWindow extends FarmWindow
   {
      
      private static const ASSET:String = "assets/dialogs/FV_themedQuest_puzzle_reward.swf";
      
      private static const PUZZLE_ICON:String = "assets/buildings/building_puzzle_feature_icon.png";
      
      private static const DEFAULT_BUNDLE_ID:String = "PuzzleHousePuzzleComplete";
      
      public static const PUZZLE_ALL_COMPLETE:String = "PuzzleHouseAllPuzzlesComplete";
      
      private var m_farmQuest:FarmQuest;
      
      private var m_rewarditem:FarmItem;
      
      private var m_featureName:String;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_bundleID:String;
      
      public function ThemedQuestRewardWindow(featureName:String, currentQuest:FarmQuest = null, bundleID:String = "PuzzleHousePuzzleComplete")
      {
         this.m_featureName = featureName;
         this.m_farmQuest = currentQuest;
         this.m_bundleID = bundleID;
         super(ASSET);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","Congrats")));
         }
         if(m_window.hasOwnProperty("copy_tf"))
         {
            if(ThemedQuestManager.instance.isThemedUberQuest(this.m_featureName,this.m_farmQuest.name))
            {
               addWidget(new ZwTextField(m_window.copy_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_completeAll")));
            }
            else
            {
               addWidget(new ZwTextField(m_window.copy_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_complete")));
            }
         }
         if(m_window.hasOwnProperty("subcopy_tf"))
         {
            addWidget(new ZwTextField(m_window.subcopy_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_limitedReward")));
         }
         if(this.m_farmQuest.farmRewards.length > 0 && this.m_farmQuest.farmRewards[0].type == "item_grant")
         {
            this.m_rewarditem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_farmQuest.farmRewards[0].value);
            if(m_window.hasOwnProperty("icon_mc") && Boolean(this.m_rewarditem))
            {
               addWidget(new ObjectPreviewFrame(m_window.icon_mc,this.m_rewarditem,null,null,[150]));
            }
         }
         if(m_window.hasOwnProperty("giftbox_tf"))
         {
            addWidget(new ZwTextField(m_window.giftbox_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_giftbox")));
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_shareButton = new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Share"),this.onShare));
         }
      }
      
      private function onShare(event:Event) : void
      {
         this.m_shareButton.enabled = false;
         close();
         var bundleData:Object = {
            "user":Global.player.firstName,
            "images":[{
               "href":"{SN_APP_URL}",
               "src":Global.getAssetURL(PUZZLE_ICON)
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory(this.m_bundleID,bundleData,[],false);
      }
   }
}

