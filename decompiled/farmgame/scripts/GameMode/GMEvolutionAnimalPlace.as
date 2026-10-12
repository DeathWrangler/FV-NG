package GameMode
{
   import Classes.Animal;
   import Classes.Constants.Experiments;
   import Classes.EvolutionAnimal;
   import Classes.FarmGameObject;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.ZapFirstPlacementDialogTask;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Transactions.TAnimalPlace;
   import flash.events.MouseEvent;
   
   public class GMEvolutionAnimalPlace extends GMObjectMove
   {
      
      protected var m_animalType:String;
      
      private var m_extraData:Object;
      
      public function GMEvolutionAnimalPlace(animalType:String = null, isGift:Boolean = false, buildingId:Number = 0, repopGift:Boolean = true, currency:String = "", extraData:Object = null)
      {
         if(animalType)
         {
            this.m_animalType = animalType;
         }
         this.m_extraData = extraData;
         m_cid = buildingId;
         m_storedOrigin = buildingId;
         super(null,null,isGift,repopGift,false,currency);
      }
      
      protected function createSelectedObject() : void
      {
         m_highlightedPoint = getMouseTilePos();
         var animal:EvolutionAnimal = new EvolutionAnimal(this.m_animalType,this.m_extraData);
         animal.setOuter(Global.world);
         animal.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
         m_selectedObject = animal as FarmGameObject;
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         if(!m_selectedObject)
         {
            this.createSelectedObject();
            if(m_selectedObject.canBeSurfaced())
            {
               FeatureBuildingSurfacingManager.getInstance().highlightBuildings(m_selectedObject as MapResource);
            }
         }
         return super.onMouseMove(event);
      }
      
      protected function createTransaction() : Transaction
      {
         return new TAnimalPlace(m_selectedObject as Animal,m_isGift,m_cid,m_currency);
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var isValidItem:Boolean = false;
         var mapResource:MapResource = null;
         var farmItem:FarmItem = null;
         var item:XML = null;
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
               if(canMultiPlace())
               {
                  Global.world.addGameMode(this.getMultiPlaceGameMode());
               }
               else
               {
                  Global.world.setDefaultGameMode();
               }
               IdleTaskQueue.getInstance().addTask(new ZapFirstPlacementDialogTask(this.m_animalType));
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

