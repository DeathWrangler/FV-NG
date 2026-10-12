package Transactions
{
   import Classes.Idle.LonelyAnimalIdleTask;
   import Classes.ZItem.FarmItem;
   import Display.FarmDynamicDialog;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Events.GenericPopupEvent;
   import Managers.CrossPromoManager;
   import Managers.FarmGameSettingsManager;
   import Managers.MapTriggerManager;
   import Widgets.Constants.Market.Currency;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.events.Event;
   
   public class TExpandFarm extends TFarmTransaction
   {
      
      public static const METHOD_EXPAND_FARM:String = "expandFarm";
      
      private static const SMALLEST_EXPANSION_SIZE:uint = 14;
      
      private static var m_soundAdded:Boolean = false;
      
      protected var m_itemName:String;
      
      protected var m_currencyUnit:String;
      
      private var m_updateCashOrCoin:Boolean = true;
      
      private var m_expansionInProgressWindow:GenericPopup = null;
      
      public function TExpandFarm(itemName:String, updateCashOrCoin:Boolean = true, currencyUnit:String = "cash")
      {
         if(!m_soundAdded)
         {
            m_soundAdded = true;
            SoundManager.addSound("expand",Global.getAssetURL("assets/sounds/actions/sfx_farm_expand.mp3"),false);
         }
         super();
         this.m_itemName = itemName;
         this.m_currencyUnit = currencyUnit;
         this.m_updateCashOrCoin = updateCashOrCoin;
      }
      
      override public function perform() : void
      {
         this.m_expansionInProgressWindow = UI.displayMessage("Please wait just a moment while we expand your farm!",GenericPopup.TYPE_MODAL,null,"",true);
         signedCall("FarmService." + METHOD_EXPAND_FARM,this.m_itemName,this.m_currencyUnit);
      }
      
      protected function onExpandFarmFeed(event:GenericPopupEvent) : void
      {
         var imageUrl:String = null;
         var images:Array = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            imageUrl = Global.farmGameSettingsManager.getImageByName(this.m_itemName,"icon");
            images = [{
               "src":imageUrl,
               "href":"{SN_APP_URL}{creative:expandfarm}index.php"
            }];
            bundleData = {
               "farm_type":Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName).friendlyName,
               "images":images
            };
            GlobalEngine.socialNetwork.publishFeedStory("ExpandFarm",bundleData,[],false);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         var newX:int = 0;
         var newY:int = 0;
         var farmItem:FarmItem = null;
         var squares:int = 0;
         var farmXML:XML = null;
         var onShare:Function = null;
         var dialog:FarmDynamicDialog = null;
         var toyland:String = null;
         if(result != null)
         {
            newX = int(result.sizeX);
            newY = int(result.sizeY);
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
            if(farmItem)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  squares = farmItem.getIntFromDataSource("squares");
               }
               else if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  squares = farmItem.getIntFromDataSource("squares");
               }
               else
               {
                  farmXML = farmItem.xml;
                  squares = int(farmXML.@squares);
               }
               if(squares == newX && squares == newY)
               {
                  Global.selectedAvatar.getStateMachine().removeAllStates();
                  if(this.m_updateCashOrCoin)
                  {
                     if(this.m_currencyUnit == Currency.CASH)
                     {
                        Global.player.cash -= farmItem.realCashCost;
                     }
                     else
                     {
                        Global.player.updateWorldCurrency(this.m_currencyUnit,-farmItem.cost);
                     }
                  }
                  if(farmItem.subType == "treasure")
                  {
                     toyland = Global.worldManager.currentWorldType;
                     Global.worldManager.ReLoadFarm(Global.worldManager.currentWorldType,false);
                  }
                  else
                  {
                     Global.world.loadObject(result);
                     Global.world.addPlayerAvatar(Global.player.avatar);
                     Global.selectedAvatar = Global.player.avatar;
                  }
                  Global.worldSettingsManager.zoomCenterViewportPostWorldLoad();
                  Global.world.optionallyEnableExpansionMarketing();
                  onShare = function(event:Event):void
                  {
                     dialog.destroy();
                     var imageUrl:String = Global.farmGameSettingsManager.getImageByName(m_itemName,"icon");
                     var images:Array = [{
                        "src":imageUrl,
                        "href":"{SN_APP_URL}{creative:expandfarm}index.php"
                     }];
                     var bundleData:Object = {
                        "farm_type":Global.farmGameSettingsManager.getFarmItemByName(m_itemName).friendlyName,
                        "images":images
                     };
                     GlobalEngine.socialNetwork.publishFeedStory("ExpandFarm",bundleData,[],false);
                  };
                  if(this.m_expansionInProgressWindow)
                  {
                     this.m_expansionInProgressWindow.close();
                     this.m_expansionInProgressWindow = null;
                  }
                  dialog = FarmDynamicDialog.createDialog("ExpandFarmDialog",FarmDynamicDialog);
                  if(farmItem.subType == "treasure")
                  {
                     dialog = FarmDynamicDialog.createDialog("ExpandFarmWithTreasuresDialog",FarmDynamicDialog);
                  }
                  dialog.setup();
                  dialog.setShortcutListener("shareButton",WidgetControllerEvent.BUTTON_PRESSED,onShare);
                  dialog.show();
                  CrossPromoManager.getInstance().showOutOfBoundPromo();
                  MapTriggerManager.getInstance().createMapTriggers();
                  LonelyAnimalIdleTask.conditionallyRedrawLonelyAnimal();
                  SoundManager.playSound("expand");
               }
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_EXPAND_FARM;
         result.itemName = this.m_itemName;
         return result;
      }
   }
}

