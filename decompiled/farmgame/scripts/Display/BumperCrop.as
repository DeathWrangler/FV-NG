package Display
{
   import Classes.Avatar.FarmAvatar;
   import Classes.FarmvilleClothingLoader;
   import Classes.IUser;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import MyLife.NPC.SimpleNPC;
   import Transactions.TGetAvatarData;
   import Transactions.TResetBumperCrop;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFormat;
   
   public class BumperCrop extends Dialog
   {
      
      private static const AVATAR_SCALE:Number = 1.5;
      
      public static const STATUS_NONE:String = "none";
      
      public static const STATUS_BUMPER_CROP:String = "bumper_crop";
      
      public static const STATUS_BIG_MOMENT:String = "big_moment";
      
      public static const STATUS_COME_BACK:String = "come_back";
      
      public static const STATUS_THANKS_PAID:String = "thanks_paid";
      
      public static const STATUS_ORIGINATOR_PAID:String = "originator_paid";
      
      public static const STATUS_NON_ORIGINATOR_PAID:String = "non_originator_paid";
      
      public static const STATUS_HELPED:String = "bc_helped";
      
      public static const STATUS_EXPIRED:String = "bc_expired";
      
      public static const STATUS_LIMIT:String = "bc_limit";
      
      public static const STATUS_SELF:String = "self";
      
      private var m_tfOver:TextFormat;
      
      private var m_tfNormal:TextFormat;
      
      private var m_dialogState:String = "none";
      
      private var m_originatorId:String;
      
      private var m_parentId:String;
      
      private var m_coinsPaid:String;
      
      private var m_totalCrops:String;
      
      private var m_accept:GenericButton;
      
      private var m_reject:GenericButton;
      
      private var m_remainingHours:Number;
      
      private var m_level:String;
      
      private var m_item:FarmItem;
      
      private var m_originatorName:String;
      
      public function BumperCrop(dialogState:String, itemName:String = "", originatorId:String = "", parentId:String = "", coinsPaid:String = "0", remainingHours:Number = 0, totalCrops:String = "0", level:String = "", originatorName:String = "", modal:Boolean = true)
      {
         m_dialogAsset = "assets/dialogs/FV_BumperCrop.swf";
         this.m_dialogState = dialogState;
         this.m_originatorId = originatorId;
         this.m_parentId = parentId;
         this.m_coinsPaid = coinsPaid;
         this.m_totalCrops = totalCrops;
         this.m_remainingHours = remainingHours;
         this.m_level = level;
         this.m_originatorName = originatorName;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         super(modal);
      }
      
      public static function isValidStatus(status:String) : Boolean
      {
         if(status == BumperCrop.STATUS_BIG_MOMENT || status == BumperCrop.STATUS_COME_BACK || status == BumperCrop.STATUS_THANKS_PAID || status == BumperCrop.STATUS_ORIGINATOR_PAID || status == BumperCrop.STATUS_NON_ORIGINATOR_PAID || status == BumperCrop.STATUS_LIMIT)
         {
            return true;
         }
         return false;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.m_tfOver = new TextFormat();
         this.m_tfOver.size = 15;
         this.m_tfNormal = new TextFormat();
         this.m_tfNormal.size = 14;
         this.initListeners();
         this.initButtons();
         this.initDialog();
      }
      
      private function initListeners() : void
      {
         m_window.bumperCrop_mc.accept_bt.addEventListener(MouseEvent.CLICK,this.onAcceptClick);
         m_window.bumperCrop_mc.cancel_bt.addEventListener(MouseEvent.CLICK,this.onCancelClick);
      }
      
      private function removeListeners() : void
      {
         m_window.bumperCrop_mc.accept_bt.removeEventListener(MouseEvent.CLICK,this.onAcceptClick);
         m_window.bumperCrop_mc.cancel_bt.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
      }
      
      private function initButtons() : void
      {
         var tfAccept:String = ZLocUtils.t("Dialogs","BumperCropHelpButton");
         var tfCancel:String = ZLocUtils.t("Dialogs","BumperCropSpoilButton");
         m_window.bumperCrop_mc.accept_bt.visible = true;
         m_window.bumperCrop_mc.cancel_bt.visible = true;
         switch(this.m_dialogState)
         {
            case BumperCrop.STATUS_BUMPER_CROP:
               tfAccept = ZLocUtils.t("Dialogs","BumperCropHelpButton");
               tfCancel = ZLocUtils.t("Dialogs","BumperCropSpoilButton");
               break;
            case BumperCrop.STATUS_BIG_MOMENT:
               tfAccept = ZLocUtils.t("Dialogs","BigMomentYupButton");
               tfCancel = ZLocUtils.t("Dialogs","BigMomentNawButton");
               break;
            case BumperCrop.STATUS_COME_BACK:
               tfAccept = ZLocUtils.t("Dialogs","BumperCropOkButton");
               m_window.bumperCrop_mc.accept_bt.x = 280;
               m_window.bumperCrop_mc.cancel_bt.visible = false;
               break;
            case BumperCrop.STATUS_THANKS_PAID:
               if(Number(this.m_level) < Global.farmGameSettingsManager.getNumber("bumperCropPlayerLevelLimit"))
               {
                  tfAccept = ZLocUtils.t("Dialogs","ThanksPaidSureButton");
                  tfCancel = ZLocUtils.t("Dialogs","ThanksPaidNotButton");
               }
               else
               {
                  tfAccept = ZLocUtils.t("Dialogs","ThanksPaid2SureButton");
                  m_window.bumperCrop_mc.accept_bt.x = 280;
                  m_window.bumperCrop_mc.cancel_bt.visible = false;
               }
               break;
            case BumperCrop.STATUS_ORIGINATOR_PAID:
               tfAccept = ZLocUtils.t("Dialogs","OriginatorPaidAddButton");
               tfCancel = ZLocUtils.t("Dialogs","OriginatorPaidNoButton");
               break;
            case BumperCrop.STATUS_NON_ORIGINATOR_PAID:
               tfAccept = ZLocUtils.t("Dialogs","NonOriginatorPaidAddButton");
               tfCancel = ZLocUtils.t("Dialogs","NonOriginatorPaidNoButton");
         }
         this.m_accept = new GenericButton(m_window.bumperCrop_mc.accept_bt,this.onAcceptClick);
         this.m_accept.text = tfAccept;
         this.m_reject = new GenericButton(m_window.bumperCrop_mc.cancel_bt,this.onCancelClick);
         this.m_reject.text = tfCancel;
      }
      
      private function initDialog() : void
      {
         var hours:Number = NaN;
         var coins:Number = NaN;
         var hour:Number = NaN;
         var coin:Number = NaN;
         switch(this.m_dialogState)
         {
            case BumperCrop.STATUS_BUMPER_CROP:
               TransactionManager.addTransaction(new TResetBumperCrop());
               this.setImage("assets/bumper_crop/bumper_crop_wagon_image.png");
               hours = Math.ceil(Math.round(Global.farmGameSettingsManager.getNumber("bumperCropTimeLimit") / 3600));
               coins = Global.farmGameSettingsManager.getNumber("bumperCrop_Coins_Level_10");
               this.setDialogText(ZLocUtils.t("Dialogs","BumperCropTitle"),ZLocUtils.t("Dialogs","BumperCropBody",{
                  "quantity":hours,
                  "coinQuantity":coins
               }));
               break;
            case BumperCrop.STATUS_BIG_MOMENT:
               this.setImage("assets/bumper_crop/bumper_crop_wagon_image.png");
               hour = Math.ceil(Math.round(Global.farmGameSettingsManager.getNumber("bumperCropTimeLimit") / 3600));
               coin = Global.farmGameSettingsManager.getNumber("bumperCrop_Coins_Level_10");
               this.setDialogText(ZLocUtils.t("Dialogs","BigMomentTitle"),ZLocUtils.t("Dialogs","BigMomentBody",{
                  "coinQuantity":coin,
                  "quantity":hour
               }));
               break;
            case BumperCrop.STATUS_COME_BACK:
               this.setAvatar(Global.player);
               this.setDialogText(ZLocUtils.t("Dialogs","ComeBackTitle"),ZLocUtils.t("Dialogs","ComeBackBody",{"quantity":this.m_remainingHours}));
               break;
            case BumperCrop.STATUS_THANKS_PAID:
               TransactionManager.addTransaction(new TGetAvatarData(this.m_parentId,this.onLoadParentData),true);
               if(Number(this.m_level) < Global.farmGameSettingsManager.getNumber("bumperCropPlayerLevelLimit"))
               {
                  this.setDialogText(ZLocUtils.t("Dialogs","ThanksPaidTitle",{"coinQuantity":this.m_coinsPaid}),ZLocUtils.t("Dialogs","ThanksPaidBody",{"quantity":this.m_remainingHours}));
               }
               else
               {
                  this.setDialogText(ZLocUtils.t("Dialogs","ThanksPaid2Title",{"coinQuantity":this.m_coinsPaid}),ZLocUtils.t("Dialogs","ThanksPaid2Body"));
               }
               break;
            case BumperCrop.STATUS_ORIGINATOR_PAID:
               this.setImage("assets/bumper_crop/bumper_crop_wagon_image.png");
               this.setDialogText(ZLocUtils.t("Dialogs","OriginatorPaidTitle"),ZLocUtils.t("Dialogs","OriginatorPaidBody",{
                  "quantity":this.m_totalCrops,
                  "item":ZLocUtils.tk_pk(this.m_item.friendlyName,"",int(this.m_totalCrops)),
                  "coinQuantity":this.m_coinsPaid
               }));
               FarmStatsManager.count("bumper_crop",this.m_coinsPaid,"originator",this.m_item.name);
               break;
            case BumperCrop.STATUS_NON_ORIGINATOR_PAID:
               this.setAvatar(Global.player);
               this.setDialogText(ZLocUtils.t("Dialogs","NonOriginatorPaidTitle"),ZLocUtils.t("Dialogs","NonOriginatorPaidBody",{
                  "quantity":this.m_totalCrops,
                  "item":ZLocUtils.tk_pk(this.m_item.friendlyName,"",int(this.m_totalCrops)),
                  "coinQuantity":this.m_coinsPaid
               }));
               FarmStatsManager.count("bumper_crop",this.m_coinsPaid,"helper_" + this.m_level,this.m_item.name);
         }
      }
      
      private function setDialogText(title:String, message:String) : void
      {
         if(m_window != null)
         {
            m_window.bumperCrop_mc.title_tf.text = title;
            m_window.bumperCrop_mc.messaging_tf.text = message;
         }
      }
      
      private function setImage(url:String = "") : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(Global.getAssetURL(url),function(event:Event):void
         {
            var dispObj:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               dispObj = icon.content;
               dispObj.x = -15;
               dispObj.y = 0;
               m_window.bumperCrop_mc.image_mc.addChild(dispObj);
            }
         });
      }
      
      private function setAvatar(player:IUser) : void
      {
         var character:SimpleNPC = new SimpleNPC(new FarmvilleClothingLoader());
         var avatarData:Object = null;
         if(player.avatar != null)
         {
            avatarData = player.avatar.getAvatarCustomizationData();
         }
         if(avatarData == null)
         {
            avatarData = FarmAvatar.getDefaultAvatarCustomizationData();
         }
         character.setAvatarCustomizationData(avatarData);
         character.x = 60;
         character.y = 150;
         character.scaleX = character.scaleY = AVATAR_SCALE;
         m_window.bumperCrop_mc.image_mc.addChild(character);
      }
      
      private function onAcceptClick(event:MouseEvent) : void
      {
         event.stopPropagation();
         close();
         this.removeListeners();
         switch(this.m_dialogState)
         {
            case BumperCrop.STATUS_BUMPER_CROP:
               GlobalEngine.socialNetwork.publishFeedStory("BumperCropA",{
                  "originatorId":Global.player.snUser.uid.toString(),
                  "parentId":Global.player.snUser.uid.toString(),
                  "actor":Global.player.snUser.firstName,
                  "item_friendly_name":this.m_item.friendlyName,
                  "item_name":this.m_item.name,
                  "creative":this.m_item.name,
                  "images":this.getBumperCropFeedImages()
               },[],false);
               FarmStatsManager.count("bumper_crop","get_help","originator",this.m_item.name);
               break;
            case BumperCrop.STATUS_BIG_MOMENT:
               MFSRequestManager.getInstance().displayR2AddNeighborWindow("bumperCropRequestPage");
               FarmStatsManager.count("bumper_crop","lets_go","originator",this.m_item.name);
               break;
            case BumperCrop.STATUS_COME_BACK:
               break;
            case BumperCrop.STATUS_THANKS_PAID:
               if(Number(this.m_level) < Global.farmGameSettingsManager.getNumber("bumperCropPlayerLevelLimit"))
               {
                  if(this.m_remainingHours >= Global.farmGameSettingsManager.getNumber("bumperCropFeedTimeLimit"))
                  {
                     GlobalEngine.socialNetwork.publishFeedStory("BumperCropB",{
                        "originatorId":this.m_originatorId,
                        "parentId":Global.player.snUser.uid.toString(),
                        "originator":this.m_originatorName,
                        "item_friendly_name":this.m_item.friendlyName,
                        "item_name":this.m_item.name,
                        "subCategory":"helper_" + this.m_level,
                        "level":this.m_level,
                        "creative":this.m_item.name,
                        "images":this.getBumperCropFeedImages()
                     },[],false);
                  }
               }
               FarmStatsManager.count("bumper_crop","lets_get_rich","helper_" + this.m_level,this.m_item.name);
               break;
            case BumperCrop.STATUS_ORIGINATOR_PAID:
               GlobalEngine.socialNetwork.publishFeedStory("BumperCropC",{
                  "total_friends":this.m_totalCrops,
                  "item_friendly_name":this.m_item.friendlyName,
                  "creative":this.m_item.name,
                  "images":this.getBumperCropFeedImages("{SN_APP_URL}index.php")
               },[],false);
               break;
            case BumperCrop.STATUS_NON_ORIGINATOR_PAID:
               GlobalEngine.socialNetwork.publishFeedStory("BumperCropC",{
                  "total_friends":this.m_totalCrops,
                  "item_friendly_name":this.m_item.friendlyName,
                  "creative":this.m_item.name,
                  "images":this.getBumperCropFeedImages("{SN_APP_URL}index.php")
               },[],false);
         }
      }
      
      private function onCancelClick(event:MouseEvent) : void
      {
         event.stopPropagation();
         close();
         this.removeListeners();
         switch(this.m_dialogState)
         {
            case BumperCrop.STATUS_BUMPER_CROP:
               TransactionManager.addTransaction(new TResetBumperCrop());
               FarmStatsManager.count("bumper_crop","let_spoil","originator",this.m_item.name);
               break;
            case BumperCrop.STATUS_BIG_MOMENT:
               FarmStatsManager.count("bumper_crop","no_request","originator",this.m_item.name);
               break;
            case BumperCrop.STATUS_COME_BACK:
               break;
            case BumperCrop.STATUS_THANKS_PAID:
               FarmStatsManager.count("bumper_crop","not_my_problem","helper_" + this.m_level,this.m_item.name);
               break;
            case BumperCrop.STATUS_ORIGINATOR_PAID:
               FarmStatsManager.count("bumper_crop","no_neighbors","originator",this.m_item.name);
               break;
            case BumperCrop.STATUS_NON_ORIGINATOR_PAID:
               FarmStatsManager.count("bumper_crop","no_neighbors","helper_" + this.m_level,this.m_item.name);
         }
      }
      
      public function getBumperCropFeedImages(clickUrl:String = "") : Array
      {
         var itemIcon1:String = "assets/bumper_crop/bumpercrop01.png";
         var itemIcon2:String = "assets/bumper_crop/bumpercrop02.png";
         var itemIcon3:String = "assets/bumper_crop/bumpercrop03.png";
         var actorId:String = Global.player.snUser.uid.toString();
         var url:String = "{SN_APP_URL}{creative:bumper_crop}bumpercrop.php?originatorId=" + actorId + "&parentId=" + actorId;
         if(clickUrl != "")
         {
            url = clickUrl;
         }
         var images:Array = [];
         images.push({
            "src":Global.getAssetURL(itemIcon3),
            "href":url
         });
         return images;
      }
      
      private function onLoadParentData(player:IUser) : void
      {
         if(player)
         {
            this.setAvatar(player);
         }
      }
   }
}

