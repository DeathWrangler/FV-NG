package Display
{
   import Classes.Mastery;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   import Widgets.Constants.Market.Currency;
   import ZLocalization.LocalizationObjectToken;
   import flash.events.MouseEvent;
   
   public class MasteryPopup extends Dialog
   {
      
      protected var m_mastery:Mastery;
      
      private var m_link:String;
      
      private var m_share:GenericButton;
      
      private var m_cancel:GenericButton;
      
      private var m_giveReward:Boolean = false;
      
      private var m_returnReward:Boolean = false;
      
      private const GET_MASTERY_FEED_ACTION:String = "GetMastery_new";
      
      private const DOUBLE_GET_MASTERY_FEED_ACTION:String = "DoubleGetMastery";
      
      private const DEFAULT_DIALOG_ASSET:String = "assets/dialogs/FV_CropMasteryPopUp.swf";
      
      public function MasteryPopup(mastery:Mastery, link:String, difficulty:int, giveReward:Boolean = true, dialogAsset:String = "assets/dialogs/FV_CropMasteryPopUp.swf")
      {
         m_dialogAsset = dialogAsset;
         SoundManager.addSound("masteryLevelUp",Global.getAssetURL("assets/sounds/sfx_crop_mastery_02.mp3"),false);
         this.m_mastery = mastery;
         this.m_mastery.currentLevel = difficulty;
         this.m_giveReward = giveReward;
         this.m_link = link;
         if(Global.hud.isVisualEffectsLocked())
         {
            this.m_returnReward = true;
            Global.player.xp -= this.m_mastery.xp;
            Global.player.gold -= this.m_mastery.gold;
         }
         super(true);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         SoundManager.playSound("masteryLevelUp");
         m_window.masteryPop_mc.congratulations_tf.text = ZLocUtils.t("Dialogs","Yeehaw");
         var masterylevel:int = this.m_mastery.currentLevel + 1;
         var masteryNameToken:LocalizationObjectToken = ZLocUtils.tk("Items",this.m_mastery.name + "_friendlyName");
         var starName:String = ZLocUtils.t("Dialogs",this.m_mastery.currentStar);
         m_window.masteryPop_mc.masteryLevel_tf.text = ZLocUtils.t("Dialogs","MasteryTitle",{"quantity":masterylevel});
         if(this.m_mastery.gift != "")
         {
            if(this.m_giveReward)
            {
               Global.player.addGift(this.m_mastery.gift);
            }
            if(ZLocUtils.hasString("Dialogs","MasteryRewardGift_" + this.m_mastery.name))
            {
               m_window.masteryPop_mc.playerTitle_tf.htmlText = ZLocUtils.t("Dialogs","MasteryRewardGift_" + this.m_mastery.name,{
                  "item":masteryNameToken,
                  "quantity":this.m_mastery.xp,
                  "coinQuantity":this.m_mastery.gold
               });
            }
            else
            {
               m_window.masteryPop_mc.playerTitle_tf.htmlText = ZLocUtils.t("Dialogs","MasteryRewardGift",{
                  "ordinal":starName,
                  "item":masteryNameToken,
                  "quantity":this.m_mastery.xp,
                  "coinQuantity":this.m_mastery.gold
               });
            }
         }
         else
         {
            m_window.masteryPop_mc.playerTitle_tf.htmlText = ZLocUtils.t("Dialogs","MasteryRewardNoGift",{
               "ordinal":starName,
               "item":masteryNameToken,
               "quantity":this.m_mastery.xp,
               "coinQuantity":this.m_mastery.gold
            });
         }
         setTrackerKey("feed-crop_mastery");
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         this.m_share = new GenericButton(m_window.share_bt,this.onShareClick);
         this.m_share.text = ZLocUtils.t("Dialogs","Share");
         this.m_cancel = new GenericButton(m_window.cancel_bt,this.onCloseClick);
         this.m_cancel.text = ZLocUtils.t("Dialogs","Cancel");
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         if(m_window.hasOwnProperty("close_bt"))
         {
            m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            m_window.share_bt.removeEventListener(MouseEvent.CLICK,this.onShareClick);
         }
         TransactionManager.addTransaction(new TCancelFriendReward([this.m_link]));
         FarmStatsManager.count(this.m_mastery.statsCounter,"Click_cancel",this.m_mastery.code,this.m_mastery.currentLevel.toString());
         event.stopPropagation();
         this.close();
      }
      
      override public function onShareClick(event:MouseEvent) : void
      {
         var masteryFeedBodyText:String = null;
         super.onShareClick(event);
         if(m_window.hasOwnProperty("close_bt"))
         {
            m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            m_window.share_bt.removeEventListener(MouseEvent.CLICK,this.onShareClick);
         }
         FarmStatsManager.count(this.m_mastery.statsCounter,"Click_share_wealth",this.m_mastery.code,this.m_mastery.currentLevel.toString());
         var starImageName:String = "";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_mastery.name);
         if(item.subType == "flowers")
         {
            starImageName = "flower_" + this.m_mastery.name;
         }
         else
         {
            starImageName = "crop_" + this.m_mastery.name;
         }
         var starImage:String = "";
         switch(this.m_mastery.currentStar)
         {
            case "None":
            case "OneStar":
               starImage = "crop_mastery01_cb.png";
               break;
            case "TwoStars":
               starImage = "crop_mastery02_cb.png";
               break;
            case "ThreeStars":
               starImage = "crop_mastery03_cb.png";
         }
         var images:Array = [{
            "src":Global.getAssetURL("assets/newsfeed/" + starImage),
            "href":"{SN_APP_URL}" + this.m_link
         }];
         var resourceString:String = "Mastery_Farm_Trivia_" + this.m_mastery.name;
         var masteryText:String = "";
         if(ZLocUtils.hasString("Notifications",resourceString))
         {
            masteryText = "Notifications:" + resourceString;
         }
         var level:int = this.m_mastery.currentLevel + 1;
         var cur_count:int = this.m_mastery.getCurrentCount();
         var levelSubcategory:String = "Level_" + level.toString();
         var feedAction:String = this.GET_MASTERY_FEED_ACTION;
         if(this.m_mastery.calculateMasteryYield() > 1)
         {
            feedAction = this.DOUBLE_GET_MASTERY_FEED_ACTION;
         }
         if(this.m_mastery.type == "tree")
         {
            masteryFeedBodyText = "Notifications:Mastery_FeedBodyTextTree";
            GlobalEngine.socialNetwork.publishFeedStory(feedAction,{
               "subCategory":levelSubcategory,
               "mastery_level":level,
               "mastery_name":this.m_mastery.friendlyName,
               "mastery_bodytext":masteryFeedBodyText,
               "mastery_trivia":masteryText,
               "images":images,
               "reward_link":this.m_link,
               "first_name":Global.player.firstName,
               "treeName":this.m_mastery.friendlyName,
               "mastery_count":cur_count
            },[],false);
         }
         else
         {
            masteryFeedBodyText = "Notifications:Mastery_FeedBodyText";
            GlobalEngine.socialNetwork.publishFeedStory(feedAction,{
               "subCategory":levelSubcategory,
               "mastery_level":level,
               "mastery_name":this.m_mastery.friendlyName,
               "mastery_bodytext":masteryFeedBodyText,
               "mastery_trivia":masteryText,
               "images":images,
               "reward_link":this.m_link,
               "first_name":Global.player.firstName,
               "mastery_count":cur_count
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
            Global.player.xp += this.m_mastery.xp;
            Global.player.updateWorldCurrency(Currency.COINS,this.m_mastery.gold,true);
         }
         super.close();
      }
   }
}

