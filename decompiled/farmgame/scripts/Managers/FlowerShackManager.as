package Managers
{
   import Classes.Constants.BlossomConstants;
   import Classes.FlowerShackFeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGenericTransactionWithFeed;
   import Widgets.Windows.FlowerShackBuyNectarWindow;
   import Widgets.Windows.FlowerShackNutureWindow;
   import Widgets.Windows.FlowerShackWindow;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FlowerShackManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "flower_shack";
      
      public static const BUILDING_NAME:String = "theflowershack";
      
      public static const FLOWERSHACK_BUY_NECTAR_DIALOG_URL:String = "assets/dialogs/FlowerShack/FV_FlowerShack_buyNectar.swf";
      
      public static const FLOWERSHACK_NUTURE_DIALOG_URL:String = "assets/dialogs/FlowerShack/FV_FlowerShack_Nurture.swf";
      
      public static const SERVICE_CLASS:String = "FlowerShackService";
      
      public static const ON_BUY_CURRENCY:String = "onBuyWorldCurrency";
      
      public static const ON_NUTURE_ALL:String = "onNutureAll";
      
      public static const ACTION_INIT:String = "onInitFeature";
      
      public static const WORLD_CURRENY_PRICE:Number = 0.2;
      
      public static const BLOSSOM_COST:int = 5;
      
      public static const BOQUET_COST:int = 10;
      
      public static const BOTH_BLOSSOM_SUBTYPE:String = "both";
      
      private static const OPEN_UI_DELAY:int = 4000;
      
      public static const ON_ASK_FOR_CURRENCY:String = "onAskForCurrency";
      
      public static const GRANT_CURRENCY:String = "isGranted";
      
      public static const GRANT_CURRENCY_AMOUNT:int = 200;
      
      public var MAX_NECTAR:int = 1000;
      
      private var m_flowerShackWindow:FlowerShackWindow;
      
      private var m_currencyName:String = "nectar";
      
      public var ASK_FEED_FREQUENCY:int;
      
      public var ASK_FEED_FREQUENCY_KEY:String;
      
      public var BUNDLE_ID:String;
      
      private var m_timer:Timer;
      
      private var m_items:Array;
      
      public function FlowerShackManager(featureName:String = "flower_shack")
      {
         super(FEATURE_NAME);
         this.populateFeatureConfig();
      }
      
      public static function getInstance(featureName:String = "flower_shack") : FlowerShackManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,FlowerShackManager) as FlowerShackManager;
      }
      
      public function askForCurrencyItem() : void
      {
         TransactionManager.addTransaction(new TGenericTransactionWithFeed(SERVICE_CLASS,ON_ASK_FOR_CURRENCY,null,[m_featureName]));
      }
      
      public function canBuyItem(item:FarmItem) : Boolean
      {
         return Global.player.canBuyWithCurrency(this.currencyName,item.cost,false);
      }
      
      public function populateFeatureConfig() : void
      {
         var itemXml:XML = null;
         if(m_featureConfig)
         {
            this.m_currencyName = m_featureConfig.currency.@name.toString();
            this.ASK_FEED_FREQUENCY = m_featureConfig.feed.@throttleTime.toString();
            this.ASK_FEED_FREQUENCY_KEY = m_featureName + "AskCurrency";
            this.BUNDLE_ID = m_featureName + "ShareReward";
            this.MAX_NECTAR = Number(m_featureConfig.currency.@limit.toString());
            if(!this.m_items)
            {
               this.m_items = new Array();
            }
            for each(itemXml in m_featureConfig.items.item)
            {
               this.m_items.push(String(itemXml.@code));
            }
         }
      }
      
      public function initFeature() : void
      {
         var currencyGrant:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,GRANT_CURRENCY);
         if(currencyGrant == null)
         {
            Global.player.updateWorldCurrency(this.currencyName,GRANT_CURRENCY_AMOUNT);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ACTION_INIT,null,[m_featureName]));
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,GRANT_CURRENCY,true);
         }
      }
      
      public function showUI(event:Event = null) : void
      {
         if(this.m_flowerShackWindow)
         {
            this.m_flowerShackWindow = null;
         }
         this.m_flowerShackWindow = new FlowerShackWindow();
         UI.displayPopup(this.m_flowerShackWindow);
      }
      
      public function showFlowerShackAndOpenWindow() : void
      {
         var numObj:Array = Global.world.getObjectsByName(BUILDING_NAME);
         if(numObj.length)
         {
            this.showUI();
         }
         else
         {
            Global.world.enterForcePlaceMode(BUILDING_NAME,true,0,false,false);
         }
      }
      
      private function panToBuildingAndShowUI(buildingName:String) : void
      {
         ItemFinderManager.getInstance().highlightWorldItems(buildingName);
         this.m_timer = new Timer(OPEN_UI_DELAY,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,function(e:Event):void
         {
            showUI();
         });
         this.m_timer.start();
         InputManager.disableInput();
      }
      
      public function buyNecatarWindow() : void
      {
         var buyWindow:FlowerShackBuyNectarWindow = new FlowerShackBuyNectarWindow(m_featureName);
         UI.displayPopup(buyWindow,false,"",true);
      }
      
      public function nutureAllWindow() : void
      {
         var nutureWindow:FlowerShackNutureWindow = new FlowerShackNutureWindow(m_featureName);
         UI.displayPopup(nutureWindow,false,"",true);
      }
      
      public function buyCurrencyItem(quantity:int) : void
      {
         var cashValue:int = this.getWorldCurrencyCost(quantity);
         if(Global.player.canBuyCash(cashValue,true))
         {
            Global.player.cash -= cashValue;
            this.updateWorldCurrency(quantity);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ON_BUY_CURRENCY,this.onBuyComplete,[m_featureName,quantity]));
         }
      }
      
      private function onBuyComplete(result:Object) : void
      {
         if(!result)
         {
         }
      }
      
      public function updateWorldCurrency(quantity:int) : void
      {
         var cashValue:int = this.getWorldCurrencyCost(quantity);
         var result:Boolean = false;
         if(cashValue > 0)
         {
            result = Global.player.updateWorldCurrency(this.m_currencyName,quantity);
            if(result && Boolean(this.m_flowerShackWindow))
            {
               this.m_flowerShackWindow.update();
            }
         }
      }
      
      public function getWorldCurrencyCost(quantity:int = 0) : Number
      {
         return Math.round(WORLD_CURRENY_PRICE * quantity);
      }
      
      public function showMiniMarketDialog() : void
      {
      }
      
      public function get playerNectarCount() : Number
      {
         var value:int = 0;
         return int(Global.player.getWorldCurrencyTotal(this.m_currencyName));
      }
      
      public function get currencyName() : String
      {
         return this.m_currencyName;
      }
      
      public function get nectarCost() : int
      {
         return 2;
      }
      
      public function resetWindow() : void
      {
         this.m_flowerShackWindow = null;
      }
      
      public function closeWindow() : void
      {
         if(this.m_flowerShackWindow)
         {
            this.m_flowerShackWindow.close();
         }
      }
      
      public function nutureAllBlossomsOrBoquets(subtype:String) : void
      {
         var totalWitheredItems:Array = null;
         var i:int = 0;
         var currencyQty:int = Global.player.getWorldCurrencyTotal(this.currencyName);
         var totalCost:int = this.getTotalNutureCostBySubtype(subtype);
         if(totalCost > 0 && currencyQty >= totalCost)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ON_NUTURE_ALL,null,[m_featureName,subtype]));
            Global.player.updateWorldCurrency(this.currencyName,totalCost * -1);
            totalWitheredItems = this.getTotalWitheredItemsBySubtype(subtype);
            for(i = 0; i < totalWitheredItems.length; i++)
            {
               (totalWitheredItems[i] as FlowerShackFeatureBuilding).setFullGrown();
            }
         }
      }
      
      public function getTotalNutureCostBySubtype(subtype:String) : int
      {
         var totalWitheredItems:Array = null;
         var totalCost:int = 0;
         var nectarCost:int = FlowerShackManager.BLOSSOM_COST;
         if(subtype == BlossomConstants.FULL_BLOSSOM_SUBTYPE)
         {
            nectarCost = FlowerShackManager.BOQUET_COST;
         }
         if(subtype == FlowerShackManager.BOTH_BLOSSOM_SUBTYPE)
         {
            totalCost = this.getTotalNutureCostBySubtype(BlossomConstants.SINGLE_BLOSSOM_SUBTYPE);
            totalCost += this.getTotalNutureCostBySubtype(BlossomConstants.FULL_BLOSSOM_SUBTYPE);
         }
         else
         {
            totalWitheredItems = this.getTotalWitheredItemsBySubtype(subtype);
            totalCost = totalWitheredItems.length * nectarCost;
         }
         return totalCost;
      }
      
      public function getTotalWitheredItemsBySubtype(subtype:String) : Array
      {
         var object:FlowerShackFeatureBuilding = null;
         var objects:Array = Global.world.getObjectsByClass(FlowerShackFeatureBuilding);
         var totalWitheredItems:Array = new Array();
         for each(object in objects)
         {
            if(object.isWithered() && (object.getItem().subType == subtype || subtype == FlowerShackManager.BOTH_BLOSSOM_SUBTYPE))
            {
               totalWitheredItems.push(object);
            }
         }
         return totalWitheredItems;
      }
      
      public function getFlowerShackItems() : Array
      {
         var result:Array = new Array();
         return Global.farmGameSettingsManager.getFarmItemNamesByClassName("FlowerShackFeatureBuilding");
      }
      
      public function getFlowerShackBlossomItems() : Object
      {
         var flowerShackItem:String = null;
         var item:FarmItem = null;
         var blossoms:Array = new Array();
         var boquets:Array = new Array();
         var result:Object = new Object();
         var flowershackItems:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("FlowerShackFeatureBuilding");
         if(Boolean(flowershackItems) && flowershackItems.length > 0)
         {
            for each(flowerShackItem in flowershackItems)
            {
               if(flowerShackItem.length)
               {
                  item = Global.farmGameSettingsManager.getFarmItemByName(flowerShackItem) as FarmItem;
                  if(item)
                  {
                     if(item.subType == BlossomConstants.SINGLE_BLOSSOM_SUBTYPE)
                     {
                        blossoms.push(item.name);
                     }
                     else if(item.subType == BlossomConstants.FULL_BLOSSOM_SUBTYPE)
                     {
                        boquets.push(item.name);
                     }
                  }
               }
            }
         }
         boquets.sort();
         blossoms.sort();
         result["blossoms"] = blossoms;
         result["bouquets"] = boquets;
         return result;
      }
      
      public function getRemainingNectarToBuy(subtype:String) : int
      {
         var cost:int = 0;
         var requiredNectarQty:int = this.getTotalNutureCostBySubtype(subtype);
         var currentNectarQty:int = Global.player.getWorldCurrencyTotal(this.currencyName);
         if(currentNectarQty < requiredNectarQty)
         {
            cost = requiredNectarQty - currentNectarQty;
         }
         return cost;
      }
      
      public function getCropItemNamesAsArray() : Array
      {
         var itemName:String = null;
         var result:Array = new Array();
         for(var i:int = 0; i < this.m_items.length; i++)
         {
            itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_items[i]);
            if(Boolean(itemName) && Boolean(itemName.length))
            {
               result.push(itemName);
            }
         }
         return result;
      }
   }
}

