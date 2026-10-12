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
   import Managers.MystreeNurseryManager;
   import Transactions.TMystreeTransform;
   import ZLocalization.LocalizationObjectToken;
   
   public class MystreeSapling extends Tree
   {
      
      private static const TRANSFORM_URL:String = "assets/effects/effect_mysterycrate.swf";
      
      private static const FEED_BUNDLE:String = "MystreeGrown";
      
      private var m_adultItem:FarmItem;
      
      public var m_plotId:String;
      
      private var m_rewardLink:String;
      
      public function MystreeSapling(itemName:String = null, plotId:String = null)
      {
         super(itemName);
         this.m_plotId = plotId;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.hasOwnProperty("plotId"))
         {
            this.m_plotId = data.plotId;
         }
      }
      
      private function transform(adultName:String) : void
      {
         var currentPosition:Vector3 = this.getPosition();
         var id:Number = this.getId();
         detach();
         var adult:Tree = new Tree(adultName);
         adult.setMetadata(this.getMetadata());
         adult.attachToPersistentData(this.persistentDataKey);
         adult.setOuter(Global.world);
         adult.setPosition(currentPosition.x,currentPosition.y,currentPosition.z);
         adult.conditionallyReattach();
         adult.setId(id);
         adult.setState(STATE_BARE);
         MystreeNurseryManager.getInstance().setClaimedTreeFeatureOption(adultName);
      }
      
      private function onTransformComplete(resultData:Object) : void
      {
         if(Boolean(resultData) && Boolean(resultData.adultName) && Boolean(resultData.rewardLink))
         {
            this.m_adultItem = Global.farmGameSettingsManager.getFarmItemByName(resultData.adultName);
            this.m_rewardLink = resultData.rewardLink;
            this.transform(this.m_adultItem.name);
            this.showCompletedDialog(this.m_rewardLink);
            Global.world.setDefaultGameMode();
            FarmStatsManager.count("Mystree","Reward",this.m_plotId,this.m_adultItem.friendlyTitle);
         }
      }
      
      public function showTransformAnimation() : void
      {
         var overlayParams:Object = new Object();
         overlayParams.offsetX = 40;
         overlayParams.offsetY = 60;
         dispOverlay(TRANSFORM_URL,overlayParams);
      }
      
      private function showCompletedDialog(rewardLink:String) : void
      {
         var itemName:LocalizationObjectToken = ZLocUtils.tk_pk(this.m_adultItem.friendlyName);
         var body:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,FEED_BUNDLE,{"itemName":itemName});
         var adultPopup:GenericIconPopup = new GenericIconPopup(body,GenericPopup.TYPE_SHARE,this.onAdultDialogResponse,this.m_adultItem.iconUrl);
         adultPopup.rewardUrl = rewardLink;
         UI.displayPopup(adultPopup,false,"Mystree_BabyGrown",true);
      }
      
      public function sendTransformTransaction() : void
      {
         TransactionManager.addTransaction(new TMystreeTransform(this,this.m_plotId,this.onTransformComplete),true);
      }
      
      private function onAdultDialogResponse(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
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
            GlobalEngine.socialNetwork.publishFeedStory(FEED_BUNDLE,bundleData,[],false);
         }
      }
      
      override public function showMenu() : void
      {
         if(!MystreeNurseryManager.getInstance().canGetMystree(this.m_plotId))
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
         if(MystreeNurseryManager.getInstance().canGetMystree(this.m_plotId))
         {
            MystreeNurseryManager.getInstance().onMystreePlaced(this.m_plotId);
            this.sendTransformTransaction();
         }
         else
         {
            super.onClick();
         }
      }
   }
}

