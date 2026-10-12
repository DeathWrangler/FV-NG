package Classes
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MystreeReskinManager;
   import Managers.MystreeReskinManagerWithEMH;
   import Transactions.TMystreeReskinTransform;
   import ZLocalization.LocalizationObjectToken;
   
   public class MystreeReskinSapling extends Animal
   {
      
      private static const TRANSFORM_URL:String = "assets/effects/effect_mysterycrate.swf";
      
      private static const FEED_BUNDLE:String = "MystreeGrown";
      
      private static const FEATURE_TRACKING:String = "GPF_spookyrampshow";
      
      private var m_adultItem:FarmItem;
      
      public var m_plotId:String;
      
      public var m_featureName:String;
      
      private var m_rewardLink:String;
      
      private var m_itemPlaced:Boolean = false;
      
      private var STATE_EGG_OPEN:String = "built_1";
      
      public function MystreeReskinSapling(itemName:String = null, plotId:String = null, featureName:String = null)
      {
         super(itemName);
         this.m_plotId = plotId;
         this.m_featureName = featureName;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.hasOwnProperty("plotId"))
         {
            this.m_plotId = data.plotId;
         }
      }
      
      private function transformItem(adultName:String) : void
      {
         var adult:Object = null;
         var currentPosition:Vector3 = this.getPosition();
         var id:Number = this.getId();
         detach();
         var adultItem:String = this.m_adultItem.type;
         if(adultItem == "animal")
         {
            adult = new Animal(adultName);
            adult.setState(STATE_BARE);
         }
         else if(adultItem == "decoration")
         {
            adult = new Decoration(adultName);
            adult.setState("static");
         }
         else
         {
            adult = new Tree(adultName);
         }
         adult.setMetadata(this.getMetadata());
         adult.attachToPersistentData(this.persistentDataKey);
         adult.setOuter(Global.world);
         adult.setPosition(currentPosition.x,currentPosition.y,currentPosition.z);
         adult.conditionallyReattach();
         adult.setId(id);
         var adultCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_adultItem.name);
         MystreeReskinManager.getInstance(this.m_featureName).setClaimedTreeFeatureOption(adultCode);
      }
      
      public function onTransformComplete(resultData:Object) : void
      {
         var DifficultyLevel:String = null;
         if(Boolean(resultData) && Boolean(resultData.adultName) && Boolean(resultData.rewardLink))
         {
            this.m_adultItem = Global.farmGameSettingsManager.getFarmItemByName(resultData.adultName);
            this.m_rewardLink = resultData.rewardLink;
            this.transformItem(this.m_adultItem.name);
            this.showCompletedDialog(this.m_rewardLink);
            Global.world.setDefaultGameMode();
            DifficultyLevel = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel().toString();
            FarmStatsManager.count(FEATURE_TRACKING,"Reward",this.m_adultItem.friendlyTitle,this.m_plotId,DifficultyLevel);
         }
      }
      
      override public function getCurrentImageName() : String
      {
         if(this.m_itemPlaced)
         {
            return this.STATE_EGG_OPEN;
         }
         return super.getCurrentImageName();
      }
      
      public function showTransformAnimation() : void
      {
         this.m_itemPlaced = true;
         setState("built_1");
         var overlayParams:Object = new Object();
         overlayParams.offsetX = 40;
         overlayParams.offsetY = 60;
         dispOverlay(TRANSFORM_URL,overlayParams);
      }
      
      private function showCompletedDialog(rewardLink:String) : void
      {
         var windowName:String = MystreeReskinManager.getInstance(this.m_featureName).getWindowName();
         var bundleId:String = windowName + "GrownBaby_" + this.m_adultItem.code;
         var itemName:LocalizationObjectToken = ZLocUtils.tk_pk(this.m_adultItem.friendlyName);
         var body:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,bundleId);
         if(body == "" || body.length < 1)
         {
            bundleId = windowName + "GrownBaby";
            body = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,bundleId,{"itemName":itemName});
         }
         var adultPopup:GenericIconPopup = new GenericIconPopup(body,GenericPopup.TYPE_SHARE,this.onAdultDialogResponse,this.m_adultItem.iconUrl);
         adultPopup.rewardUrl = rewardLink;
         UI.displayPopup(adultPopup,false,bundleId,true);
      }
      
      public function sendTransformTransaction() : void
      {
         FarmStatsManager.count(this.m_featureName,"Place_Sapling",this.m_plotId);
         TransactionManager.addTransaction(new TMystreeReskinTransform(this,this.m_plotId,this.m_featureName,this.onTransformComplete),true);
      }
      
      private function onAdultDialogResponse(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         var bundleId:String = MystreeReskinManager.getInstance(this.m_featureName).getWindowName();
         bundleId += "GrownBaby";
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "reward_link":event.rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + event.rewardLink,
                  "src":this.m_adultItem.iconUrl
               }],
               "item":this.m_adultItem.friendlyTitle
            };
            GlobalEngine.socialNetwork.publishFeedStory(bundleId,bundleData,[],false);
         }
      }
      
      override public function showMenu() : void
      {
         if(!MystreeReskinManager.getInstance(this.m_featureName).canGetMystree(this.m_plotId))
         {
            m_menuItems = [];
            if(Global.player.level >= Global.farmGameSettingsManager.getInt("sellLockLevel"))
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Sell"),
                  "action":SELL_OBJECT
               });
            }
            UI.displayMenu(m_menuItems,onMenuClick);
         }
      }
      
      override public function onClick() : void
      {
         if(MystreeReskinManager.getInstance(this.m_featureName).canGetMystree(this.m_plotId))
         {
            MystreeReskinManager.getInstance(this.m_featureName).onMystreePlaced(this.m_plotId);
            this.sendTransformTransaction();
         }
         else
         {
            super.onClick();
         }
      }
   }
}

