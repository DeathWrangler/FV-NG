package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.EvolutionShareDialog;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.EvolutionManager;
   import Transactions.TGenericTransaction;
   import flash.events.MouseEvent;
   
   public class EvolutionAnimal extends Animal
   {
      
      protected static const FEED:String = "Feed";
      
      protected static const COMPLETE_NOW_LEVEL_ONE_PRICE:int = 10;
      
      protected static const COMPLETE_NOW_LEVEL_TWO_PRICE:int = 20;
      
      protected static const COMPLETE_NOW_LEVEL_THREE_PRICE:int = 30;
      
      protected static const FEED_REQUIRED_LEVEL_ONE:int = 5;
      
      protected static const FEED_REQUIRED_LEVEL_TWO:int = 10;
      
      protected static const FEED_REQUIRED_LEVEL_THREE:int = 15;
      
      private static const SHOW_EVOLUTION_DIALOG:String = "ShowEvolutionDialog";
      
      private static const CRAFT_FOOD:String = "craftfood";
      
      private static const EVOLVE_ANIMAL:String = "evolveAnimal";
      
      private static const COMPLETE_NOW:String = "CompleteNow";
      
      private static const EVOLUTION_STORAGE_WARNING:String = "EvolutionStorageWarning";
      
      private var m_showMenu:Boolean;
      
      private var m_isElderAnimal:Boolean;
      
      private var m_numFed:int;
      
      private var m_feedType:String;
      
      private var m_history:Array;
      
      private var m_hasStartedCompleteNowFlow:Boolean;
      
      private var m_harvestReward:String;
      
      public function EvolutionAnimal(animalType:String = null, extraData:Object = null)
      {
         super(animalType);
         this.m_showMenu = false;
         this.m_history = extraData as Array;
         if(!this.m_history)
         {
            this.m_history = new Array(getItemName());
         }
      }
      
      public function isElderAnimal() : Boolean
      {
         return this.m_isElderAnimal;
      }
      
      public function get feedType() : String
      {
         return this.m_feedType;
      }
      
      public function set feedType(type:String) : void
      {
         this.m_feedType = type;
      }
      
      public function get history() : Array
      {
         return this.m_history;
      }
      
      private function initializeIDSData() : void
      {
         var IDSData:Object = getPersistentData("EvolutionAnimal");
         if(IDSData != null)
         {
            if(IDSData.hasOwnProperty("feed"))
            {
               this.m_numFed = IDSData.feed;
            }
            if(IDSData.hasOwnProperty("history"))
            {
               this.m_history = IDSData.history;
            }
         }
      }
      
      public function loadMenu() : void
      {
         if(EvolutionManager.instance.isElderAnimal(getItemName()))
         {
            this.m_isElderAnimal = true;
         }
         this.initializeIDSData();
         this.m_showMenu = true;
      }
      
      override protected function onAddToInventory() : void
      {
         var popup:GenericIconPopup = new GenericIconPopup(ZLocUtils.t("Dialogs",EVOLUTION_STORAGE_WARNING),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmAddToInventory,this.getItem().icon,true,true,"",false,GenericIconPopup.GENERIC_CALLOUT_ASSET,null,true,false,"");
         UI.displayPopup(popup,false);
      }
      
      public function toggleMenu(visible:Boolean) : void
      {
         this.m_showMenu = visible;
      }
      
      private function onConfirmAddToInventory(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            super.onAddToInventory();
         }
      }
      
      override protected function buildTooltipText() : String
      {
         var toolTip:String = "";
         if(EvolutionManager.s_isInitialized)
         {
            toolTip = super.buildTooltipText();
            this.m_feedType = EvolutionManager.instance.getFeedType(getItemName());
            this.m_isElderAnimal = EvolutionManager.instance.isElderAnimal(getItemName());
            if(!this.m_isElderAnimal)
            {
               toolTip += "\n" + ZLocUtils.t("Dialogs","EvoloutionAnimalToolTip",{
                  "feedCount":this.feedCompleted,
                  "feedTotal":this.feedRequired
               });
            }
            else
            {
               toolTip += "\n" + "Growth Complete";
            }
         }
         return toolTip;
      }
      
      public function get feedCompleted() : int
      {
         return this.m_numFed;
      }
      
      public function set feedCompleted(num:int) : void
      {
         this.m_numFed = num;
      }
      
      public function get feedRequired() : int
      {
         var result:int = 0;
         switch(this.m_feedType)
         {
            case EvolutionManager.FEED_COMMON:
               result = FEED_REQUIRED_LEVEL_ONE;
               break;
            case EvolutionManager.FEED_UNCOMMON:
               result = FEED_REQUIRED_LEVEL_TWO;
               break;
            case EvolutionManager.FEED_RARE:
               result = FEED_REQUIRED_LEVEL_THREE;
         }
         return result;
      }
      
      override public function setPersistentDataVolatile(persistentData:Object, featureName:String, dataName:String = null) : void
      {
         super.setPersistentDataVolatile(persistentData,featureName,dataName);
      }
      
      override protected function generateMenuItems() : void
      {
         super.generateMenuItems();
         m_menuItems.push({
            "label":"Look Inside",
            "action":SHOW_EVOLUTION_DIALOG
         });
         if(!this.m_isElderAnimal)
         {
            if(this.m_numFed >= this.feedRequired)
            {
               m_menuItems.push({
                  "label":"Grow Animal",
                  "action":EVOLVE_ANIMAL
               });
            }
            else if(EvolutionManager.instance.getfeedAmount(this.m_feedType) <= 0)
            {
               m_menuItems.push({
                  "label":"Craft Food",
                  "action":CRAFT_FOOD
               });
            }
            else
            {
               m_menuItems.push({
                  "label":"Feed Animal",
                  "action":FEED
               });
            }
            if(this.feedCompleted < this.feedRequired)
            {
               m_menuItems.push({
                  "label":"Complete Now",
                  "action":COMPLETE_NOW
               });
            }
         }
      }
      
      override public function onDelete() : void
      {
         sellConfirmationHandler();
      }
      
      override public function showMenu() : void
      {
         getPersistentData("EvolutionAnimal");
         var blah:Number = this.getId();
         if((persistentDataKey != null || this.m_showMenu) && EvolutionManager.s_isInitialized)
         {
            super.showMenu();
         }
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         var sendTransaction:Boolean = false;
         var params:Array = null;
         var crateDialog:EvolutionShareDialog = null;
         super.onFinishPlace(transactionResult);
         if(this.m_history)
         {
            sendTransaction = false;
            if(this.m_history.length == 1 && this.m_history[0] != getItemName())
            {
               this.m_history.push(getItemName());
               sendTransaction = true;
            }
            else if(this.m_history.length > 1)
            {
               this.m_history.push(getItemName());
               sendTransaction = true;
            }
            if(sendTransaction)
            {
               params = [persistentDataKey,this.m_history];
               TransactionManager.addTransaction(new TGenericTransaction("EvolutionService","updateHistory",this.updateHistoryCallback,params));
            }
            if(EvolutionManager.instance.isElderAnimal(getItemName()) && sendTransaction)
            {
               this.m_isElderAnimal = true;
               crateDialog = new EvolutionShareDialog(getItemName(),true);
               UI.displayPopup(crateDialog);
               Global.player.addGift("deco_animalcrate2");
               Global.world.enterForcePlaceMode("deco_animalcrate2");
            }
         }
         this.m_feedType = EvolutionManager.instance.getFeedType(getItemName());
         this.m_showMenu = true;
      }
      
      private function updateHistoryCallback(result:Object) : void
      {
      }
      
      override public function move() : void
      {
         var popup:GenericIconPopup = null;
         if(!Global.player.getSeenFlag(EvolutionManager.EVOLVE_ANIMAL_MOVE_STORE_WARNING))
         {
            popup = new GenericIconPopup(ZLocUtils.t("Dialogs","EvolutionMoveStorageWarning"),GenericPopup.TYPE_OK,this.onFinishStorageWarning,this.getItem().icon,true,true,"",false,GenericIconPopup.GENERIC_CALLOUT_ASSET,null,true,false,"");
            UI.displayPopup(popup,false);
         }
         else
         {
            super.move();
         }
      }
      
      private function onFinishStorageWarning(event:GenericPopupEvent) : void
      {
         Global.player.setSeenFlag(EvolutionManager.EVOLVE_ANIMAL_MOVE_STORE_WARNING,false,true);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(m_wanderingObject != this)
            {
               switch(item.action)
               {
                  case FEED:
                     EvolutionManager.instance.feed(this,this.m_feedType,1);
                     break;
                  case SHOW_EVOLUTION_DIALOG:
                     EvolutionManager.instance.showEvolutionDialog(this);
                     break;
                  case CRAFT_FOOD:
                     EvolutionManager.instance.openCraftShop();
                     break;
                  case COMPLETE_NOW:
                     EvolutionManager.instance.beginCompleteNowFlow(this);
                     this.m_hasStartedCompleteNowFlow = true;
                     break;
                  case EVOLVE_ANIMAL:
                     EvolutionManager.instance.showEvolveChoiceDialog(this);
                  default:
                     super.onMenuClick(event);
               }
            }
         }
      }
      
      public function get startedCompletNowFlow() : Boolean
      {
         return this.m_hasStartedCompleteNowFlow;
      }
      
      public function set startedCompletNowFlow(value:Boolean) : void
      {
         this.m_hasStartedCompleteNowFlow = value;
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var itemName:String = null;
         var animalItem:FarmItem = null;
         var popup:GenericIconPopup = null;
         if(Boolean(result[1]) && Boolean(result[1].hasOwnProperty("evo")))
         {
            itemName = result[1]["evo"];
            this.m_harvestReward = itemName;
            animalItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            popup = new GenericIconPopup(ZLocUtils.t("Dialogs","EvolutionHarvest",{"item":ZLocUtils.tk_pk(animalItem.friendlyName)}),GenericPopup.TYPE_SHARE,this.onHarvestShareCallBack,this.getItem().icon,true,true,"",false,GenericIconPopup.GENERIC_CALLOUT_ASSET,null,true,false,"");
            UI.displayPopup(popup,false);
         }
         super.onHarvestComplete(result);
      }
      
      private function onHarvestShareCallBack(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            EvolutionManager.instance.postFeed(this.m_harvestReward);
         }
      }
      
      public function calculateCompleteNowCost() : int
      {
         var result:int = 0;
         switch(this.m_feedType)
         {
            case EvolutionManager.FEED_COMMON:
               result = COMPLETE_NOW_LEVEL_ONE_PRICE;
               break;
            case EvolutionManager.FEED_UNCOMMON:
               result = COMPLETE_NOW_LEVEL_TWO_PRICE;
               break;
            case EvolutionManager.FEED_RARE:
               result = COMPLETE_NOW_LEVEL_THREE_PRICE;
         }
         return result;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(EvolutionManager.s_isInitialized)
         {
            this.m_showMenu = true;
         }
      }
      
      public function onCompleteNowAccept(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.completeNow();
         }
         else
         {
            this.m_hasStartedCompleteNowFlow = false;
         }
      }
      
      private function completeNow() : void
      {
         var totalCost:int = this.calculateCompleteNowCost();
         if(Global.player.canBuyCash(totalCost,true))
         {
            EvolutionManager.instance.showEvolveChoiceDialog(this,null,totalCost);
         }
      }
   }
}

