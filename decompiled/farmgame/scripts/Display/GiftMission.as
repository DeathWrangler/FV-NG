package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.SmartPopupManager;
   import Transactions.TGiftGive;
   import com.adobe.crypto.MD5;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GiftMission extends Dialog
   {
      
      public static const STATUS_NONE:String = "none";
      
      public static const STATUS_HELP_COW:String = "help_cow";
      
      public static const STATUS_GIVE_HOME:String = "give_home";
      
      public static const STATUS_OWNED_PAID:String = "owned_paid";
      
      public static const STATUS_NOT_OWNED_PAID:String = "not_owned_paid";
      
      public static const STATUS_NOT_OWNED:String = "not_owned";
      
      public static const STATUS_MAX_GIFT:String = "max_gift";
      
      public static const STATUS_FIND_HOME:String = "find_home";
      
      public static const SECRET_KEY:String = "farmville1is4the3best4game4ever";
      
      public static const HEARTS_URL:String = "assets/missions/hearts_cow.png";
      
      private var DIALOG_ASSET:String = "assets/dialogs/FV_GiftMission.swf";
      
      private var m_happyAnimalURL:String = "";
      
      private var m_sadAnimalURL:String = "";
      
      private var m_storkURL:String = "";
      
      private var m_animalType:String = "";
      
      private var m_giftState:String = "none";
      
      private var m_lonelyCowId:String = "";
      
      private var m_name:String = "";
      
      private var m_accept:GenericButton;
      
      private var m_reject:GenericButton;
      
      private var m_coins:int = 0;
      
      private var m_item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_animalType);
      
      private var m_sig:String = MD5.hash(this.m_animalType + GiftMission.SECRET_KEY + this.m_lonelyCowId + "8415");
      
      public function GiftMission(giftState:String, animalType:String = "", lonelyCowId:String = "", name:String = "", coins:int = 0, modal:Boolean = true)
      {
         m_dialogAsset = this.DIALOG_ASSET;
         this.m_giftState = giftState;
         this.m_lonelyCowId = lonelyCowId;
         this.m_name = name;
         this.m_coins = coins;
         this.m_animalType = animalType;
         this.m_happyAnimalURL = this.m_item.getImageByName("icon",false);
         this.m_sadAnimalURL = this.m_item.getImageByName("icon",false);
         this.m_storkURL = this.m_item.getImageByName("icon",false);
         super(modal);
      }
      
      public static function isValidStatus(status:String) : Boolean
      {
         if(status == GiftMission.STATUS_GIVE_HOME || status == GiftMission.STATUS_OWNED_PAID || status == GiftMission.STATUS_NOT_OWNED_PAID || status == GiftMission.STATUS_NOT_OWNED || status == GiftMission.STATUS_MAX_GIFT)
         {
            return true;
         }
         return false;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.initListeners();
         this.initButtons();
         this.initDialog();
         StatsManager.milestone("lonely_md");
      }
      
      private function initListeners() : void
      {
         m_window.giftmission_mc.accept_bt.addEventListener(MouseEvent.CLICK,this.onAcceptClick);
         m_window.giftmission_mc.cancel_bt.addEventListener(MouseEvent.CLICK,this.onCancelClick);
      }
      
      private function removeListeners() : void
      {
         m_window.giftmission_mc.accept_bt.removeEventListener(MouseEvent.CLICK,this.onAcceptClick);
         m_window.giftmission_mc.cancel_bt.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
      }
      
      private function initButtons() : void
      {
         var tfAccept:String = ZLocUtils.t("Dialogs",this.m_animalType + "_Accept");
         var tfCancel:String = ZLocUtils.t("Dialogs",this.m_animalType + "_Cancel");
         m_window.giftmission_mc.accept_bt.visible = true;
         m_window.giftmission_mc.cancel_bt.visible = true;
         switch(this.m_giftState)
         {
            case GiftMission.STATUS_HELP_COW:
               m_window.giftmission_mc.accept_bt.x = 179;
               tfAccept = ZLocUtils.t("Dialogs",this.m_animalType + "_AcceptCow");
               tfCancel = ZLocUtils.t("Dialogs",this.m_animalType + "_IgnoreCow");
               break;
            case GiftMission.STATUS_GIVE_HOME:
               m_window.giftmission_mc.accept_bt.x = 245;
               tfAccept = ZLocUtils.t("Dialogs",this.m_animalType + "_AcceptGiveHomeCow");
               m_window.giftmission_mc.cancel_bt.visible = false;
               break;
            case GiftMission.STATUS_FIND_HOME:
               tfAccept = ZLocUtils.t("FarmGame","Share");
               tfCancel = ZLocUtils.t("Dialogs","Cancel");
               break;
            default:
               m_window.giftmission_mc.accept_bt.x = 245;
               m_window.giftmission_mc.cancel_bt.visible = false;
         }
         this.m_accept = new GenericButton(m_window.giftmission_mc.accept_bt,this.onAcceptClick);
         this.m_accept.text = tfAccept;
         this.m_reject = new GenericButton(m_window.giftmission_mc.cancel_bt,this.onCancelClick);
         this.m_reject.text = tfCancel;
      }
      
      private function initDialog() : void
      {
         var coins:Number = NaN;
         var maxGifts:int = 0;
         switch(this.m_giftState)
         {
            case GiftMission.STATUS_HELP_COW:
               this.setGreeting(ZLocUtils.t("Dialogs",this.m_animalType + "_HelpCowFindFarm"));
               this.setImage(1,this.m_sadAnimalURL);
               FarmStatsManager.count("idle_timer_event","lost_animal","view",this.m_animalType);
               break;
            case GiftMission.STATUS_GIVE_HOME:
               this.setGreeting(ZLocUtils.t("Dialogs",this.m_animalType + "_GiveCowHome"));
               this.setImage(0,HEARTS_URL);
               this.setImage(1,this.m_happyAnimalURL);
               break;
            case GiftMission.STATUS_FIND_HOME:
               this.setGreeting(ZLocUtils.t("Dialogs",this.m_animalType + "_FindCowHome"));
               this.setImage(1,this.m_storkURL);
               FarmStatsManager.count("dairyfarm","found_calf_harvest","display",this.m_animalType);
               break;
            case GiftMission.STATUS_OWNED_PAID:
               this.setGreeting(ZLocUtils.t("Dialogs",this.m_animalType + "_OwnedCowPaid",{"user":ZLocUtils.tn(this.m_name)}));
               this.setImage(0,HEARTS_URL);
               this.setImage(1,this.m_happyAnimalURL);
               break;
            case GiftMission.STATUS_NOT_OWNED_PAID:
               coins = Global.farmGameSettingsManager.getNumber("lonelyCowTooLateCoins");
               this.setGreeting(ZLocUtils.t("Dialogs",this.m_animalType + "_NotOwnedCowPaid"));
               this.setImage(1,this.m_happyAnimalURL);
               break;
            case GiftMission.STATUS_NOT_OWNED:
               this.setGreeting(ZLocUtils.t("Dialogs",this.m_animalType + "_NotOwnedCow"));
               this.setImage(1,this.m_happyAnimalURL);
               break;
            case GiftMission.STATUS_MAX_GIFT:
               maxGifts = Global.farmGameSettingsManager.getInt("maxGiftLimit");
               this.setGreeting(ZLocUtils.t("Dialogs","MaxGifts",{"quantity":maxGifts}));
               this.setImage(1,this.m_happyAnimalURL);
         }
      }
      
      private function setGreeting(text:String) : void
      {
         if(m_window != null && Boolean(text))
         {
            m_window.giftmission_mc.greeting_tf.text = text;
         }
      }
      
      private function setImage(mcindex:int, url:String = "") : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(Global.getAssetURL(url),function(event:Event):void
         {
            var dispObj:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               dispObj = icon.content;
               if(mcindex == 0)
               {
                  m_window.giftmission_mc.image_mc.addChild(dispObj);
               }
               else
               {
                  m_window.giftmission_mc.image1_mc.addChild(dispObj);
               }
            }
         });
      }
      
      private function onAcceptClick(event:MouseEvent) : void
      {
         var images:Array = null;
         var variation:String = null;
         var feedVariant:int = 0;
         var emailData:Object = null;
         var imagesCalf:Array = null;
         var emailDataCalf:Object = null;
         if(getTrackerEnabled())
         {
            SmartPopupManager.getInstance().popupAccepted(m_trackerKey,"Share");
         }
         event.stopPropagation();
         close();
         this.removeListeners();
         switch(this.m_giftState)
         {
            case GiftMission.STATUS_HELP_COW:
               images = [{
                  "src":Global.getAssetURL(this.m_sadAnimalURL),
                  "href":"{SN_APP_URL}{creative:lonelycow}lonelycow.php?owner_id=" + Global.player.snUser.uid + "&amp;lonely_cow_id=" + this.m_lonelyCowId + "&amp;animalType=" + this.m_animalType + "&amp;lonely_cow_sig=" + this.m_sig
               }];
               variation = "";
               feedVariant = Global.experimentManager.getExperimentVariant("fv_fb_feed_changes");
               if(this.m_animalType == "bull" && feedVariant != 0)
               {
                  variation = "_" + String(feedVariant);
               }
               GlobalEngine.socialNetwork.publishFeedStory(this.m_animalType + variation + "_LonelyCow",{
                  "player_name":Global.player.snUser.firstName,
                  "lonely_cow_id":this.m_lonelyCowId,
                  "lonely_cow_sig":this.m_sig,
                  "animal_type":this.m_animalType,
                  "images":images,
                  "fallbackAction":"generic_LonelyCow"
               },[],false);
               emailData = {
                  "item_name":this.m_item.friendlyName,
                  "reward_link":"lonelycow.php?owner_id=" + Global.player.snUser.uid + "&amp;lonely_cow_id=" + this.m_lonelyCowId + "&amp;animalType=" + this.m_animalType + "&amp;lonely_cow_sig=" + this.m_sig
               };
               TransactionManager.addTransaction(new TGiftGive(this.m_animalType + "_LonelyCow",emailData,[]));
               FarmStatsManager.count("idle_timer_event","lost_animal","click_help",this.m_animalType);
               break;
            case GiftMission.STATUS_FIND_HOME:
               imagesCalf = [{
                  "src":Global.getAssetURL(this.m_storkURL),
                  "href":"{SN_APP_URL}{creative:lonelycow}lonelycow.php?owner_id=" + Global.player.snUser.uid + "&amp;lonely_cow_id=" + this.m_lonelyCowId + "&amp;animalType=" + this.m_animalType + "&amp;lonely_cow_sig=" + this.m_sig
               }];
               GlobalEngine.socialNetwork.publishFeedStory(this.m_animalType + "_LonelyCow",{
                  "player_name":Global.player.snUser.firstName,
                  "lonely_cow_id":this.m_lonelyCowId,
                  "lonely_cow_sig":this.m_sig,
                  "animal_type":this.m_animalType,
                  "images":imagesCalf,
                  "fallbackAction":"generic_LonelyCow"
               },[],false);
               emailDataCalf = {
                  "item_name":this.m_item.friendlyName,
                  "reward_link":"lonelycow.php?owner_id=" + Global.player.snUser.uid + "&amp;lonely_cow_id=" + this.m_lonelyCowId + "&amp;animalType=" + this.m_animalType + "&amp;lonely_cow_sig=" + this.m_sig
               };
               TransactionManager.addTransaction(new TGiftGive(this.m_animalType + "_LonelyCow",emailDataCalf,[]));
               FarmStatsManager.count("dairyfarm","found_calf_harvest","click_accept",this.m_animalType);
               break;
            case GiftMission.STATUS_GIVE_HOME:
               UI.displayGiftBoxWindow();
         }
      }
      
      private function onCancelClick(event:MouseEvent) : void
      {
         if(getTrackerEnabled())
         {
            SmartPopupManager.getInstance().popupDeclined(m_trackerKey,"Cancel");
         }
         event.stopPropagation();
         close();
         this.removeListeners();
         switch(this.m_giftState)
         {
            case GiftMission.STATUS_HELP_COW:
               if(this.hasSound())
               {
                  this.playSound();
               }
               FarmStatsManager.count("idle_timer_event","lost_animal","cancel",this.m_animalType);
               break;
            case GiftMission.STATUS_FIND_HOME:
               FarmStatsManager.count("dairyfarm","found_calf_harvest","click_cancel",this.m_animalType);
         }
      }
      
      public function hasSound() : Boolean
      {
         var soundUrl:String = null;
         var item:XML = null;
         var result:Boolean = false;
         if(this.m_item != null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               soundUrl = this.m_item.getStringFromDataSource("sounds","sound","url");
               if(soundUrl)
               {
                  result = true;
               }
            }
            else if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               result = this.m_item.sounds.length > 0;
            }
            else
            {
               item = this.m_item.xml;
               if(item)
               {
                  result = item.sounds.sound.length() > 0;
               }
            }
         }
         return result;
      }
      
      protected function playSound() : void
      {
         var soundUrl:String = null;
         var soundId:String = null;
         var rand:int = 0;
         var soundArr:Array = null;
         var arrLen:int = 0;
         var item:XML = null;
         if(this.m_item != null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               soundArr = this.m_item.sounds;
               arrLen = int(soundArr.length);
               if(arrLen > 0)
               {
                  rand = Math.round(Math.random() * (arrLen - 1));
                  soundUrl = soundArr[rand];
               }
            }
            else
            {
               item = this.m_item.xml;
               if(item)
               {
                  if(item.sounds.sound.length())
                  {
                     rand = Math.round(Math.random() * (item.sounds.sound.length() - 1));
                     soundUrl = item.sounds.sound[rand].@url;
                  }
               }
            }
            if(soundUrl)
            {
               soundId = this.m_item.name;
               SoundManager.addSound(soundId,Global.getAssetURL(soundUrl));
               SoundManager.playSound(soundId);
            }
         }
      }
   }
}

