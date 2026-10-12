package Managers
{
   import Classes.FeaturePresent;
   import Classes.RewardCreditsBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TOpenFeaturePresent;
   
   public class FeaturePresentsManager
   {
      
      private static var m_instance:FeaturePresentsManager;
      
      private static var m_initialized:Boolean = false;
      
      private static const OPEN_OVERLAY_URL:String = "assets/effects/effect_mysterycrate2.swf";
      
      private var m_featurePresents:Array = new Array();
      
      private var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      private var m_presentToShare:FeaturePresent = null;
      
      private var m_rewardLinkToShare:String = "";
      
      private var m_featureName:String = "";
      
      public function FeaturePresentsManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use FeaturePresentsManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : FeaturePresentsManager
      {
         if(m_instance == null)
         {
            m_instance = new FeaturePresentsManager();
         }
         return m_instance;
      }
      
      public function loadObjects(featurePresents:Object) : void
      {
         var featureName:String = null;
         var featureObj:Object = null;
         var friendUid:String = null;
         var friendObj:Object = null;
         var presentTimestamp:String = null;
         var presentObj:Object = null;
         var fullFriendUid:String = null;
         var uid:Array = null;
         var friendId:String = null;
         if(featurePresents)
         {
            for(featureName in featurePresents)
            {
               featureObj = featurePresents[featureName];
               for(friendUid in featureObj)
               {
                  friendObj = featureObj[friendUid];
                  for(presentTimestamp in friendObj)
                  {
                     presentObj = friendObj[presentTimestamp];
                     fullFriendUid = friendUid;
                     uid = friendUid.split(":",2);
                     friendId = fullFriendUid;
                     if(uid.length == 2)
                     {
                        friendId = uid[1];
                     }
                     this.m_featurePresents.push(new FeaturePresent(featureName,fullFriendUid,friendId,Number(presentTimestamp),presentObj.itemCode,Number(presentObj.opened)));
                  }
               }
            }
            this.m_featurePresents.sort(this.sortOnTimestamp);
         }
      }
      
      public function displayPlaceFeaturePrompt() : void
      {
         var itemFlag:String = null;
         var splitFlags:Array = null;
         var featureName:String = null;
         var giftItem:FarmItem = null;
         var buildings:Array = null;
         var hasGift:Boolean = false;
         var placeMessage:String = null;
         var placeMessage2:String = null;
         var itemFlags:Object = Global.player.itemFlags;
         for(itemFlag in itemFlags)
         {
            if(itemFlag.indexOf("_lastPresent") >= 0)
            {
               splitFlags = itemFlag.split("_",2);
               featureName = splitFlags[0];
               giftItem = Global.farmGameSettingsManager.getFarmItemByName(featureName);
               if(giftItem)
               {
                  buildings = Global.world.getObjectsByName(featureName);
                  if((buildings.length < 1 || buildings[0] == null) && !Global.player.getSeenFlag(featureName + "_placeReprompt") && this.m_featurePresents.length > 0)
                  {
                     hasGift = Global.player.hasGiftItem(giftItem.code);
                     this.m_featureName = featureName;
                     if(hasGift)
                     {
                        placeMessage = ZLocUtils.t("Dialogs",featureName + "_PlaceBuildingForPresents",{"item":ZLocUtils.tk_pk(giftItem.friendlyName)});
                        if(placeMessage != null && placeMessage != "")
                        {
                           UI.displayPopup(new GenericPopup(placeMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.placeFeaturePromptCallback));
                        }
                     }
                     else
                     {
                        placeMessage2 = ZLocUtils.t("Dialogs",featureName + "_NoBuildingForPresents",{"item":ZLocUtils.tk_pk(giftItem.friendlyName)});
                        if(placeMessage2 != null && placeMessage2 != "")
                        {
                           UI.displayPopup(new GenericPopup(placeMessage2,GenericPopup.TYPE_OK));
                        }
                     }
                     Global.player.setSeenFlag(this.m_featureName + "_placeReprompt");
                  }
               }
            }
         }
      }
      
      private function placeFeaturePromptCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            Global.world.enterForcePlaceMode(this.m_featureName);
         }
      }
      
      private function sortOnTimestamp(a:FeaturePresent, b:FeaturePresent) : Number
      {
         var aPresent:Number = Number(a.creationTimestamp);
         var bPresent:Number = Number(b.creationTimestamp);
         var result:Number = 0;
         if(aPresent < bPresent)
         {
            result = 1;
         }
         else if(aPresent > bPresent)
         {
            result = -1;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      public function openPresent(building:RewardCreditsBuilding, presentData:FeaturePresent) : void
      {
         TransactionManager.addTransaction(new TOpenFeaturePresent(building,presentData,this.postOpenPresentCallback),true);
      }
      
      private function postOpenPresentCallback(building:RewardCreditsBuilding, presentData:FeaturePresent, rewardLink:String) : void
      {
         var index:Number = NaN;
         var item:FarmItem = null;
         var featurePresent:FeaturePresent = null;
         var buildingPos:Vector3 = null;
         var screen:Vector2 = null;
         if(presentData != null)
         {
            for(index = 0; index < this.m_featurePresents.length; index++)
            {
               featurePresent = this.m_featurePresents[index];
               if(featurePresent.friendId == presentData.friendId && featurePresent.creationTimestamp == presentData.creationTimestamp && featurePresent.presentItemCode == presentData.presentItemCode)
               {
                  featurePresent.openTimestamp = GlobalEngine.serverTime;
                  break;
               }
            }
            item = Global.farmGameSettingsManager.getFarmItemByCode(presentData.presentItemCode);
            if(item)
            {
               Global.player.addGift(item.name);
               this.m_presentToShare = presentData;
               this.m_rewardLinkToShare = rewardLink;
               this.m_rewardCreditsBuilding = building;
               buildingPos = building.getPosition();
               screen = IsoMath.tilePosToPixelPos(buildingPos.x,buildingPos.y,buildingPos.z);
               Global.ui.displayOverlaySWF(Global.getAssetURL(OPEN_OVERLAY_URL),screen,null,-100,function():void
               {
                  var message:GenericIconPopup = null;
                  if(m_rewardLinkToShare != "")
                  {
                     message = new GenericIconPopup(ZLocUtils.t("Dialogs",presentData.featureName + "_ShareOpenPresent",{"item":ZLocUtils.tk_pk(item.friendlyName)}),GenericPopup.TYPE_SHARECANCEL,onConfirmShareItem,item.icon,false,true,"",true);
                     UI.displayPopup(message,false);
                  }
               });
            }
         }
      }
      
      private function onConfirmShareItem(event:GenericPopupEvent) : void
      {
         var item:FarmItem = null;
         var friendName:String = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT && this.m_presentToShare != null)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_presentToShare.presentItemCode);
            if(item)
            {
               friendName = Global.friendManager.getFriendName(this.m_presentToShare.friendId,true);
               bundleData = {
                  "item":item.friendlyName,
                  "friend_name":friendName,
                  "images":[{
                     "href":"{SN_APP_URL}{creative:picture}index.php",
                     "src":item.icon
                  }]
               };
               if(this.m_rewardLinkToShare != "")
               {
                  bundleData.images = [{
                     "href":"{SN_APP_URL}" + this.m_rewardLinkToShare,
                     "src":item.icon
                  }];
                  bundleData.reward_link = this.m_rewardLinkToShare;
               }
               GlobalEngine.socialNetwork.publishFeedStory(this.m_presentToShare.featureName + "_OpenPresent",bundleData,[],false);
            }
         }
         this.m_rewardCreditsBuilding.displayStorageDialog();
         this.m_rewardCreditsBuilding = null;
         this.m_rewardLinkToShare = null;
         this.m_presentToShare = null;
      }
      
      public function get featurePresents() : Array
      {
         return this.m_featurePresents;
      }
   }
}

