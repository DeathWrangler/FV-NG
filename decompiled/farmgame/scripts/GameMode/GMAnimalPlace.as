package GameMode
{
   import Classes.Animal;
   import Classes.Constants.Experiments;
   import Classes.FarmGameObject;
   import Classes.FeatureBuilding;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.ZapFirstPlacementDialogTask;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Transactions.TAnimalPlace;
   import flash.events.MouseEvent;
   
   public class GMAnimalPlace extends GMObjectMove
   {
      
      protected var m_animalType:String;
      
      protected var m_overrideClass:Class;
      
      protected var m_isFromMarket:Boolean;
      
      public function GMAnimalPlace(animalType:String = null, isGift:Boolean = false, buildingId:Number = 0, repopGift:Boolean = true, overrideClass:Class = null, currency:String = "", isFromMarket:Boolean = false)
      {
         if(animalType)
         {
            this.m_animalType = animalType;
         }
         m_cid = buildingId;
         m_storedOrigin = buildingId;
         this.m_overrideClass = overrideClass;
         this.m_isFromMarket = isFromMarket;
         super(null,null,isGift,repopGift,false,currency);
         this.createSelectedObject();
         if(m_selectedObject.canBeSurfaced())
         {
            FeatureBuildingSurfacingManager.getInstance().highlightBuildings(m_selectedObject as MapResource);
         }
      }
      
      protected function createSelectedObject() : void
      {
         m_highlightedPoint = getMouseTilePos();
         var animal:Animal = this.m_overrideClass ? new this.m_overrideClass(this.m_animalType) : new Animal(this.m_animalType);
         animal.setOuter(Global.world);
         animal.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
         m_selectedObject = animal as FarmGameObject;
      }
      
      protected function createTransaction() : Transaction
      {
         return new TAnimalPlace(m_selectedObject as Animal,m_isGift,m_cid,m_currency,this.m_isFromMarket);
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var isValidItem:Boolean = false;
         var mapResource:MapResource = null;
         var farmItem:FarmItem = null;
         var item:XML = null;
         var originObject:WorldObject = null;
         var variant:int = 0;
         super.onMouseUp(event);
         if(m_objectPlacedSuccess)
         {
            if(Global.world.checkNumObjectLimit())
            {
               isValidItem = false;
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_animalType);
                  if(farmItem)
                  {
                     isValidItem = farmItem.type == "animal";
                  }
               }
               else
               {
                  item = Global.farmGameSettingsManager.getItemXMLByName(this.m_animalType);
                  if(item)
                  {
                     isValidItem = item.@type == "animal";
                  }
               }
               mapResource = m_selectedObject as MapResource;
               if(isValidItem && m_isGift == false && m_cid == 0)
               {
                  Global.player.tryBuy(mapResource,m_isGift,null,0,"",m_currency);
               }
               if(!m_selectedObject.isToolGenerated)
               {
                  TransactionManager.addTransaction(this.createTransaction(),true);
               }
               if(canMultiPlace() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POST_PURCHASE_FLOW) < Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
               {
                  Global.world.addGameMode(this.getMultiPlaceGameMode());
               }
               else
               {
                  Global.world.setDefaultGameMode();
               }
               IdleTaskQueue.getInstance().addTask(new ZapFirstPlacementDialogTask(this.m_animalType));
               if(Boolean(Global.flashHotParams["REPOP_WINDOW_ON_ANIMAL_PLACE"]) && Global.flashHotParams["REPOP_WINDOW_ON_ANIMAL_PLACE"] == true)
               {
                  originObject = m_storedOrigin ? Global.world.getObjectById(m_storedOrigin) : null;
                  if(Boolean(originObject) && originObject is FeatureBuilding)
                  {
                     (originObject as FeatureBuilding).displayStorageDialog();
                  }
               }
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_Full"));
               Global.world.addGameMode(this);
            }
         }
         else if((m_selectedObject as MapResource).fromMarket)
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_RETENTION_CORE_CLICK_FLOW_IMPROVEMENT);
            if(variant == 3 || variant == 4 || variant == 7 || variant == 8)
            {
               Global.world.addGameMode(this.getMultiPlaceGameMode());
            }
         }
         return true;
      }
      
      protected function getMultiPlaceGameMode() : GameMode
      {
         return new GMAnimalPlace(this.m_animalType,m_isGift,m_cid,false,null,this.m_currency);
      }
   }
}

