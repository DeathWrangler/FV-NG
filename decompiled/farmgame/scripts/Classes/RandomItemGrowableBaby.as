package Classes
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.GroomingBarnManager;
   import Managers.InstagrowHelper;
   import Transactions.TAnimalTransform;
   import Widgets.Windows.YearlingShareWindow;
   import ZLocalization.LocalizationObjectToken;
   import flash.events.MouseEvent;
   
   public class RandomItemGrowableBaby extends ItemGrowableBaby
   {
      
      private static const OPEN_BARN:String = "openBarn";
      
      private static const FEED_BUNDLE:String = "YearlingGrown";
      
      private static const POPUP_NAME:String = "YearlingGrown_Popup";
      
      protected static const TRANSFORM_URL:String = "assets/effects/effect_mysterycrate.swf";
      
      private static const ASSET_SHARE_YEARLING:String = "assets/dialogs/FV_Yearlings_share.swf";
      
      private var m_transformTransactionResult:Object;
      
      private var m_windowCallback:Function;
      
      private var m_rewardLink:String;
      
      private var m_building:FeatureBuilding;
      
      public function RandomItemGrowableBaby(animalType:String = null)
      {
         super(animalType);
      }
      
      override protected function generateMenuItems() : void
      {
         m_menuItems = [];
         m_menuItems.push({
            "label":ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Open_Barn"),
            "action":OPEN_BARN
         });
         if(InstagrowHelper.playerCanSeeFeature() && shouldShowInstagrowMenuOption())
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","ApplyInstantGrow"),
               "action":APPLY_GROW
            });
         }
         m_menuItems.push({
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         });
         if(allowDelete() && canShowSellMenuItem())
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Sell"),
               "action":SELL_OBJECT
            });
         }
         if(this.getItem().allowAnimalTypeWander && !Global.worldManager.isVisiting())
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Rotate"),
               "action":ROTATE_OBJECT
            });
         }
      }
      
      override protected function transformFailed() : void
      {
         UI.displayMessage(ZLocUtils.t_pk(ZLocConstants.DIALOG_UTIL_PKG,"NotEnoughItem",{
            "itemName":m_growItemFriendly,
            "itemHave":Global.player.getGiftCountForItem(m_growItemNeeded),
            "itemNeed":m_growPrice
         }),GenericPopup.TYPE_YESNO,this.failTransformDialogCallback);
      }
      
      override protected function failTransformDialogCallback(data:Object = null) : void
      {
         if(data.button == GenericPopup.YES)
         {
            GroomingBarnManager.getInstance().openGroomingWindow();
         }
      }
      
      override protected function onTransformComplete(resultData:Object) : void
      {
         var overlayParams:Object = null;
         if(this.m_windowCallback != null)
         {
            this.m_windowCallback();
         }
         if(Boolean(resultData) && Boolean(resultData.adultName))
         {
            this.m_transformTransactionResult = resultData;
            m_adultItem = Global.farmGameSettingsManager.getFarmItemByName(resultData.adultName);
            m_shouldTransform = true;
            FarmStatsManager.count("yearling",m_adultItem.name,"claimed");
            overlayParams = new Object();
            overlayParams.offsetX = 40;
            overlayParams.offsetY = 60;
            this.dispOverlay(TRANSFORM_URL,overlayParams);
         }
      }
      
      override public function transform() : void
      {
         super.transform();
         this.showCompletedDialog();
         if(this.m_building)
         {
            this.m_building.setState(FeatureBuilding.STATE_BARE);
         }
      }
      
      override protected function overlayComplete() : Boolean
      {
         if(m_shouldTransform)
         {
            this.transform();
            m_shouldTransform = !chargeTransform();
         }
         return super.overlayComplete();
      }
      
      public function tryGrowUp(callback:Function = null, building:FeatureBuilding = null) : void
      {
         this.m_building = building;
         this.m_windowCallback = callback;
         if(canTransform())
         {
            if(this.m_building)
            {
               this.m_building.setState(this.m_building.STATE_BUSY);
            }
            m_transactionInProgress = true;
            TransactionManager.addTransaction(new TAnimalTransform(this,this.onTransformComplete),true);
         }
         else
         {
            if(this.m_windowCallback != null)
            {
               this.m_windowCallback();
            }
            this.transformFailed();
         }
      }
      
      private function showCompletedDialog() : void
      {
         var adultPopup:YearlingShareWindow = null;
         var adultObject:Animal = null;
         var itemName:LocalizationObjectToken = ZLocUtils.tk_pk(m_adultItem.friendlyName);
         var body:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,FEED_BUNDLE,{"itemName":itemName});
         if(Boolean(this.m_transformTransactionResult) && Boolean(this.m_transformTransactionResult.rewardLink))
         {
            this.m_rewardLink = this.m_transformTransactionResult.rewardLink;
            adultPopup = new YearlingShareWindow(ASSET_SHARE_YEARLING,this.onShareDialogResponse,m_itemName,m_adultItem);
            m_transactionInProgress = false;
            UI.displayPopup(adultPopup,false,POPUP_NAME,true);
            if(this.m_transformTransactionResult.adultMetadata)
            {
               adultObject = Global.world.getObjectById(this.m_transformTransactionResult.adultId) as Animal;
               if(adultObject)
               {
                  adultObject.setMetadata(this.m_transformTransactionResult.adultMetadata);
               }
            }
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(m_wanderingObject != this)
            {
               generateWanderTime();
               switch(item.action)
               {
                  case OPEN_BARN:
                     GroomingBarnManager.getInstance().openGroomingWindow();
                     break;
                  default:
                     super.onMenuClick(event);
               }
            }
         }
      }
      
      private function onShareDialogResponse() : void
      {
         var bundleData:Object = {
            "reward_link":this.m_rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + this.m_rewardLink,
               "src":m_adultItem.iconUrl
            }],
            "item":m_adultItem.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory(FEED_BUNDLE,bundleData,[],false);
         FarmStatsManager.count("Feed","feed","yearlings","share_grooming_brushes");
      }
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         return false;
      }
   }
}

