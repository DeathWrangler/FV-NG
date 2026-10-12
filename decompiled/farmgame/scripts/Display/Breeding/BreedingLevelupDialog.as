package Display.Breeding
{
   import Classes.ZItem.FarmItem;
   import Classes.breeding.AnimalBreedingSkillState;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Engine.Managers.TransactionManager;
   import Managers.breeding.AnimalBreedingManager;
   import Transactions.BreedingProjects.TGetBreedingLevelUpShareLink;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class BreedingLevelupDialog extends FarmDynamicDialog
   {
      
      public static const IMPORT_FEATURE_NAME:String = "featureName";
      
      public static const SHORTCUT_LEVEL_NUM:String = "LevelNum";
      
      public static const SHORTCUT_TITLE_TEXT:String = "titleText";
      
      public static const SHORTCUT_LEVELUP_TEXT:String = "LevelUpText";
      
      public static const SHORTCUT_SHARE_BUTTON:String = "shareButton";
      
      public static const SHORTCUT_REWARD_ITEM_1:String = "RewardItem1";
      
      public static const SHORTCUT_REWARD_IMG_1:String = "RewardImage1";
      
      public static const SHORTCUT_REWARD_NAME_1:String = "RewardName1";
      
      public static const SHORTCUT_REWARD_IMG_2:String = "RewardImage2";
      
      public static const SHORTCUT_REWARD_NAME_2:String = "RewardName2";
      
      public static const SHORTCUT_NEXT_LEVEL_NUM:String = "NextLevelNum";
      
      public static const SHORTCUT_NEXT_REWARD_IMG:String = "NextRewardImage";
      
      public static const SHORTCUT_NEXT_REWARD_NAME:String = "NextRewardName";
      
      public static const LOVE_POTION_ITEM_CODE:String = "gk";
      
      public static const LOVE_POTION_ASSET_PATH:String = "assets/decorations/deco_lovepotionnobg_icon.png";
      
      private var m_skillState:AnimalBreedingSkillState = null;
      
      private var m_featureName:String = "";
      
      private var m_rewardsArray:Array = new Array();
      
      private var m_nextBigReward:Array = new Array();
      
      private var m_nextBigRewardLevel:int = 0;
      
      public function BreedingLevelupDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         super.setup();
         this.m_featureName = this.getImport(IMPORT_FEATURE_NAME);
         this.m_skillState = Global.player.getBreedingSkillStateForFeature(this.m_featureName);
         this.m_rewardsArray = Global.animalBreedingSettings.getRewardsForLevel(this.m_skillState.level,this.m_featureName);
         this.m_nextBigRewardLevel = Global.animalBreedingSettings.getNextBigReward(this.m_skillState.level);
         this.m_nextBigReward = Global.animalBreedingSettings.getRewardsForLevel(this.m_nextBigRewardLevel,this.m_featureName);
         setShortcutAttribute(SHORTCUT_LEVEL_NUM,TextFieldView.ATTRIBUTE_TEXT,this.getModifiedLevel(this.m_skillState.level));
         setShortcutAttribute(SHORTCUT_TITLE_TEXT,TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Breeding_" + this.m_featureName + "_LevelupDialog_Title"));
         setShortcutAttribute(SHORTCUT_LEVELUP_TEXT,TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Breeding_" + this.m_featureName + "_LevelupDialog_Text",{"levelNum":this.m_skillState.level}));
         var breedingLevelBurstAsset:String = AnimalBreedingManager.BASE_BREEDING_DIALOG_ASSET_PATH + this.m_featureName + "/breedingLevelBurst.png";
         setShortcutAttribute("levelIcon",ImageController.ATTRIBUTE_SOURCE,breedingLevelBurstAsset);
         this.setUpShareButton();
         this.setUpRewards();
      }
      
      private function setUpShareButton() : void
      {
         setShortcutAttribute(SHORTCUT_SHARE_BUTTON,ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","BreedingShareButton"));
         this.setShortcutListener(SHORTCUT_SHARE_BUTTON,WidgetControllerEvent.BUTTON_PRESSED,this.onShareButtonPress);
      }
      
      private function onShareButtonPress(event:WidgetControllerEvent) : void
      {
         TransactionManager.addTransaction(new TGetBreedingLevelUpShareLink(this.m_featureName,this.m_skillState.level));
         event.getController().setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
      }
      
      private function setUpRewards() : void
      {
         var reward:Object = null;
         var rewardItem:FarmItem = null;
         if(this.m_rewardsArray.length == 1 || this.m_rewardsArray.length == 2)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_rewardsArray[0]["value"]);
            if(rewardItem != null)
            {
               if(rewardItem.code == LOVE_POTION_ITEM_CODE)
               {
                  setShortcutAttribute(SHORTCUT_REWARD_IMG_2,ImageController.ATTRIBUTE_SOURCE,LOVE_POTION_ASSET_PATH);
               }
               else
               {
                  setShortcutAttribute(SHORTCUT_REWARD_IMG_2,ImageController.ATTRIBUTE_SOURCE,rewardItem.icon);
               }
               setShortcutAttribute(SHORTCUT_REWARD_NAME_2,TextFieldView.ATTRIBUTE_TEXT,"x" + this.m_rewardsArray[0]["quantity"]);
            }
         }
         if(this.m_rewardsArray.length >= 2)
         {
            rewardItem = this.getBigRewardItem();
            if(rewardItem != null)
            {
               setShortcutAttribute(SHORTCUT_REWARD_ITEM_1,BaseWidgetView.ATTRIBUTE_OBSTRUCT,true);
               setShortcutAttribute(SHORTCUT_REWARD_ITEM_1,BaseWidgetView.ATTRIBUTE_VISIBLE,true);
               setShortcutAttribute(SHORTCUT_REWARD_IMG_1,ImageController.ATTRIBUTE_SOURCE,rewardItem.icon);
               setShortcutAttribute(SHORTCUT_REWARD_NAME_1,TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.tk_pk_asTitle(rewardItem.friendlyName));
            }
         }
         else
         {
            setShortcutAttribute(SHORTCUT_REWARD_ITEM_1,BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
            setShortcutAttribute(SHORTCUT_REWARD_ITEM_1,BaseWidgetView.ATTRIBUTE_VISIBLE,false);
         }
         for each(reward in this.m_nextBigReward)
         {
            if(reward.hasOwnProperty("bigReward") && reward["bigReward"] == "true")
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(reward["value"]);
               if(rewardItem != null)
               {
                  setShortcutAttribute(SHORTCUT_NEXT_LEVEL_NUM,TextFieldView.ATTRIBUTE_TEXT,this.getModifiedLevel(this.m_nextBigRewardLevel));
                  setShortcutAttribute(SHORTCUT_NEXT_REWARD_IMG,ImageController.ATTRIBUTE_SOURCE,rewardItem.icon);
                  setShortcutAttribute(SHORTCUT_NEXT_REWARD_NAME,TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.tk_pk_asTitle(rewardItem.friendlyName));
               }
            }
         }
      }
      
      private function getBigRewardItem() : FarmItem
      {
         var reward:Object = null;
         var result:FarmItem = null;
         for each(reward in this.m_rewardsArray)
         {
            if(reward.hasOwnProperty("bigReward") && reward["bigReward"] == "true")
            {
               result = Global.farmGameSettingsManager.getFarmItemByCode(reward["value"]);
               break;
            }
         }
         return result;
      }
      
      private function getModifiedLevel(level:int) : String
      {
         var result:String = "";
         if(level < 10)
         {
            result = " " + level.toString();
         }
         else
         {
            result = level.toString();
         }
         return result;
      }
   }
}

