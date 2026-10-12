package GameMode
{
   import Classes.DucklingAnimal;
   import Classes.FarmGameObject;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Transactions.TDucklingAnimalPlace;
   import flash.events.MouseEvent;
   
   public class GMDucklingAnimalPlace extends GMObjectMove
   {
      
      private var m_animalType:String;
      
      private var m_newDuckling:Boolean = false;
      
      public function GMDucklingAnimalPlace(selectedObject:FarmGameObject, animalType:String = null, isGift:Boolean = false, buildingId:Number = 0, repopGift:Boolean = true)
      {
         if(animalType)
         {
            this.m_animalType = animalType;
         }
         m_cid = buildingId;
         m_storedOrigin = buildingId;
         super(selectedObject,null,isGift,repopGift);
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         var animal:DucklingAnimal = null;
         if(!m_selectedObject)
         {
            m_highlightedPoint = getMouseTilePos();
            animal = new DucklingAnimal(this.m_animalType);
            animal.setOuter(Global.world);
            animal.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
            m_selectedObject = animal as FarmGameObject;
            this.m_newDuckling = true;
         }
         return super.onMouseMove(event);
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var duckAnimal:DucklingAnimal = null;
         if(m_selectedObject)
         {
            duckAnimal = m_selectedObject as DucklingAnimal;
            if(Boolean(!m_dropSuspended && m_containerCollision != null) && Boolean(duckAnimal) && duckAnimal.hasAnyProgress())
            {
               this.setupDialog(event);
               m_containerCollision.stopOverlay();
            }
         }
         this.handleValidMove(event);
         return true;
      }
      
      private function setupDialog(event:MouseEvent) : void
      {
         var delegateCallback:Function;
         var duckAnimal:DucklingAnimal;
         var ducklingItem:FarmItem;
         var keepDialog:GenericIconPopup;
         m_dropSuspended = true;
         delegateCallback = function(popupEvent:GenericPopupEvent):void
         {
            m_dropSuspended = false;
         };
         duckAnimal = m_selectedObject as DucklingAnimal;
         ducklingItem = Global.farmGameSettingsManager.getFarmItemByName(duckAnimal.getItemName());
         keepDialog = new GenericIconPopup(ZLocUtils.t("Dialogs","Duckling_StoreFail"),GenericPopup.TYPE_OK,delegateCallback,ducklingItem.icon);
         UI.displayPopup(keepDialog,false);
      }
      
      private function handleValidMove(event:MouseEvent) : void
      {
         var isValidItem:Boolean = false;
         var mapResource:MapResource = null;
         var farmItem:FarmItem = null;
         var item:XML = null;
         super.onMouseUp(event);
         if(m_objectPlacedSuccess && this.m_newDuckling)
         {
            if(Global.world.checkNumObjectLimit())
            {
               Global.world.setDefaultGameMode();
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
               if(isValidItem && !m_isGift && m_cid == 0)
               {
                  Global.player.tryBuy(mapResource,m_isGift);
               }
               TransactionManager.addTransaction(new TDucklingAnimalPlace(m_selectedObject as DucklingAnimal,m_isGift,m_cid),true);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_Full"));
               Global.world.addGameMode(this);
            }
         }
      }
   }
}

