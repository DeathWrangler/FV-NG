package GameMode
{
   import Classes.MapResource;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.NeighborActions.TrickNeighborAction;
   import Classes.VisitorManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.AskBuyPopup;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.MFSRequestManager;
   import Managers.NPCManager;
   import Managers.TrickOrTreatManager;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Constants.Market.Currency;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GMHalloweenTrick extends GMSetAltGraphic
   {
      
      private static const OUT_OF_LICENSES:String = "outOfLicenses";
      
      private const altGraphicName:String = "web";
      
      private const W2W_ASSET:String = "assets/decorations/deco_ghostavatar.png";
      
      private const TYPE_ALT_GRAPHIC:int = 1;
      
      private const TYPE_OVERLAY:int = 2;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      public function GMHalloweenTrick()
      {
         super(this.altGraphicName);
         m_selectedToolTipLocalizeKey = "ClickToTrick";
      }
      
      override protected function setCursorImage(e:Event) : void
      {
         super.setCursorImage(e);
         updateCursorText(ZLocUtils.t("FarmGame","AltGraphicRemainingCursorFew",{"quantity":this.trickLicenses}));
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         var overlayType:int = 0;
         var result:Boolean = false;
         var mapObject:MapResource = object as MapResource;
         if(mapObject != null && mapObject.getItem() != null && this.canPerformAction(mapObject))
         {
            overlayType = this.getAltGraphicType(mapObject);
            if(overlayType == this.TYPE_ALT_GRAPHIC && mapObject.altGraphic == "")
            {
               result = true;
            }
            else if(overlayType == this.TYPE_OVERLAY && mapObject.overlay == "")
            {
               result = true;
            }
         }
         return result;
      }
      
      private function getAltGraphicType(mapObject:MapResource) : int
      {
         var result:int = 0;
         for(var i:int = 0; i < TrickNeighborAction.validOverlays.length; i++)
         {
            if(mapObject.isAltGraphicAvailable(TrickNeighborAction.validOverlays[i]))
            {
               result = this.TYPE_ALT_GRAPHIC;
               break;
            }
            if(mapObject.isValidOverlayTarget(TrickNeighborAction.validOverlays[i]))
            {
               result = this.TYPE_OVERLAY;
               break;
            }
         }
         return result;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var object:MapResource = null;
         var popMode:Boolean = false;
         var dialogKey:String = null;
         var friendName:String = null;
         var friendGender:String = null;
         var dialog:AskBuyPopup = null;
         if(m_highlightedObject)
         {
            object = m_highlightedObject as MapResource;
            if(object)
            {
               if(this.isObjectSelectable(object))
               {
                  popMode = true;
                  if(this.canPerformAction(m_highlightedObject) && this.trickLicenses > 0)
                  {
                     VisitorManager.getInstance().queueActionType(m_highlightedObject,NeighborActionConstants.ACTION_TYPE_TRICK_NEIGHBOR);
                     VisitorManager.getInstance().doAction(new TrickNeighborAction(m_highlightedObject));
                     this.useTrickLicense();
                     Global.player.addFeatureCredits(TrickOrTreatManager.instance.featureCreditName,1);
                     popMode = false;
                  }
                  if(popMode || this.trickLicenses == 0)
                  {
                     TrickOrTreatManager.instance.exitGameMode();
                     dialogKey = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getStringConstant(OUT_OF_LICENSES);
                     friendName = Global.worldManager.getVisitName(true);
                     friendGender = Global.worldManager.getVisitGender();
                     dialog = new AskBuyPopup(ZLocUtils.t("Dialogs",dialogKey),GenericPopup.TYPE_ASKBUY,this.onNotifyAskBuyTrickCallback,null,true,true,"",false);
                     UI.displayPopup(dialog,false);
                  }
                  else
                  {
                     updateCursorText(ZLocUtils.t("FarmGame","AltGraphicRemainingCursorFew",{"quantity":this.trickLicenses}));
                  }
               }
            }
            else
            {
               object.displayStatus(ZLocUtils.t("FarmGame","CannotApply_" + m_graphic));
            }
         }
      }
      
      protected function canPerformAction(object:WorldObject) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(object) && Boolean(!Global.worldManager.isVisitingCommunityNeighbor()) && !this.isVisitingModelFarm())
         {
            result = true;
         }
         return result;
      }
      
      protected function isVisitingModelFarm() : Boolean
      {
         return NPCManager.getInstance().getModelFarmVisitId() == VisitorManager.getInstance().visitedUserId;
      }
      
      protected function notifyTrickDialogCallback(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {"images":[{
               "href":"{SN_APP_URL}",
               "src":Global.getAssetURL(this.W2W_ASSET)
            }]};
            Global.farmSocialNetwork.publishFeedStory("HalloweenTrickW2W",bundleData,[Global.worldManager.getVisiting()],false);
            FarmStatsManager.count("Halloween","Notifytrick","share");
         }
         else
         {
            FarmStatsManager.count("Halloween","Notifytrick","cancel");
         }
      }
      
      protected function onNotifyAskBuyTrickCallback(event:GenericPopupEvent) : void
      {
         var featureLicenseItemName:String = null;
         var featureLicenseItemPack:String = null;
         var packItem:FarmItem = null;
         var mr:MapResource = null;
         if(event.button == AskBuyPopup.ASK)
         {
            featureLicenseItemName = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getStringConstant("featureCreditLicenseItem");
            FarmStatsManager.count("request","request_more",TrickOrTreatManager.instance.featureCreditName,featureLicenseItemName,"",Global.worldManager.currentWorldType);
            MFSRequestManager.getInstance().makeAskItemsRequest(TrickOrTreatManager.instance.featureCreditName,featureLicenseItemName);
         }
         else if(event.button == AskBuyPopup.BUY)
         {
            featureLicenseItemPack = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getStringConstant("featureCreditLicensePack");
            packItem = Global.farmGameSettingsManager.getFarmItemByName(featureLicenseItemPack);
            mr = new MapResource(featureLicenseItemPack);
            if(Global.player.canBuyCash(packItem.cash,false))
            {
               FarmStatsManager.count("fv_cash_buy",packItem.type,packItem.name,packItem.cash.toString());
               TransactionManager.addTransaction(new TBuyItemPutGiftbox(packItem,Currency.CASH,1,false,true,function(result:Object):void
               {
                  var licenseItem:* = undefined;
                  var giftCount:* = undefined;
                  var i:* = undefined;
                  if(result)
                  {
                     licenseItem = Global.farmGameSettingsManager.getFarmItemByName(FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getStringConstant("featureCreditLicenseItem"));
                     giftCount = Global.player.getGiftCountForItem(licenseItem.name);
                     for(i = 0; i < giftCount; i++)
                     {
                        licenseItem.onUse(0,{
                           "isGift":false,
                           "allowReshopping":false
                        });
                        Global.player.removeGift(null,licenseItem.name);
                     }
                     TrickOrTreatManager.instance.updateTotalTrickLicenses();
                     TrickOrTreatManager.instance.enterGameMode();
                  }
               }),true);
            }
            else
            {
               this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",packItem.cash,packItem.type);
               if(this.m_impulseBuyDialog != null)
               {
                  this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
               }
               else
               {
                  MT4DManager.getInstance().addEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.onImpulseBuyCancel);
               }
            }
         }
      }
      
      private function onImpulseBuyCancel(event:Event) : void
      {
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
         else
         {
            MT4DManager.getInstance().removeEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.onImpulseBuyCancel);
         }
      }
      
      protected function get trickLicenses() : int
      {
         return Global.player.numAltGraphicCredits(TrickOrTreatManager.instance.altGraphicCreditName);
      }
      
      protected function useTrickLicense() : void
      {
         Global.player.decAltGraphicCredits(TrickOrTreatManager.instance.altGraphicCreditName);
      }
   }
}

