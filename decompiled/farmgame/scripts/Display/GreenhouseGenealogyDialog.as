package Display
{
   import Classes.StorageBuilding;
   import Classes.ZItem.SeedItem;
   import Classes.breeding.BreedingFeatureState;
   import Classes.breeding.BreedingState;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GreenhouseGenealogyDialog extends SlotDialog
   {
      
      private var m_breedingState:BreedingState;
      
      private var m_infoPopup:GreenhouseGenealogyInfoPop;
      
      private var m_mainDialog:GreenhouseWithdrawal;
      
      private var m_numSlots:int = 10;
      
      private var m_container:MovieClip;
      
      private var m_blackScreen:MovieClip;
      
      private var m_storageBuilding:StorageBuilding;
      
      private var m_buildingClassName:String;
      
      private const CELL_BACKGROUND_FRAME_ARRAY:Array = [3,2,1];
      
      private const BREEDING_FEATURE_NAME:String = "greenhousebuildable_finished";
      
      public function GreenhouseGenealogyDialog(building:StorageBuilding, buildingClassName:String, mainDialog:GreenhouseWithdrawal, container:MovieClip, breedingState:BreedingState)
      {
         super();
         this.m_storageBuilding = building;
         this.m_buildingClassName = buildingClassName;
         this.m_mainDialog = mainDialog;
         this.m_container = container;
         this.m_breedingState = breedingState;
         this.m_blackScreen = this.m_container.blackScreen_mc;
         this.m_blackScreen.visible = false;
         this.m_container.description_tf.text = ZLocUtils.t("Dialogs","GreenhouseGenealogyDescription");
         m_tiles = new Array();
         for(var idx:int = 0; idx < this.m_numSlots; idx++)
         {
            m_tiles.push(this.m_container["slot_" + idx + "_mc"]);
         }
         this.m_container.infoPopup_mc.visible = false;
         removeTiles();
         this.pushNewData();
         this.fixArrows();
         var compIdx:int = 0;
         while(compIdx < this.getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         this.m_container.arrowButtonLeft_mc.addEventListener(MouseEvent.CLICK,onLtArrowClick);
         this.m_container.arrowButtonRight_mc.addEventListener(MouseEvent.CLICK,onRtArrowClick);
         this.m_container.visible = true;
         this.m_infoPopup = new GreenhouseGenealogyInfoPop(this,this.m_container,m_data[0],0,this.m_breedingState);
      }
      
      override protected function getNumSlots() : int
      {
         return this.m_numSlots;
      }
      
      override protected function fixArrows() : void
      {
         if(Boolean(this.m_container) && Boolean(this.m_container.arrowButtonLeft_mc) && Boolean(this.m_container.arrowButtonRight_mc))
         {
            this.m_container.arrowButtonLeft_mc.visible = m_tileSet > 0 ? true : false;
            this.m_container.arrowButtonRight_mc.visible = (m_tileSet + 1) * this.getNumSlots() < m_data.length ? true : false;
         }
      }
      
      override protected function addComponent(compIdx:int, index:int = 0) : void
      {
         var tile:MovieClip = null;
         var data:Object = null;
         var seedItem:SeedItem = null;
         var masteryLevel:int = 0;
         var currentProg:int = 0;
         var nextGoal:int = 0;
         var maxGoal:int = 0;
         var seedIconUrl:String = null;
         if(Boolean(m_tiles) && m_data[index + compIdx] != null)
         {
            tile = m_tiles[compIdx] as MovieClip;
            data = m_data[index + compIdx];
            seedItem = BuySeedPackages.getSeedFromSeedPackageName(data.item.cashName) as SeedItem;
            masteryLevel = seedItem.masteryStars + 1;
            tile.mastery_mc.stars_mc.gotoAndStop(masteryLevel + 1);
            tile.genealogy_cell_mc.gotoAndStop(this.CELL_BACKGROUND_FRAME_ARRAY[data.unlockedState]);
            currentProg = seedItem.mastery.currentProgress;
            nextGoal = seedItem.mastery.remainingCropsToNextLevel + currentProg;
            maxGoal = seedItem.mastery.totalCropsNeededMax;
            if(currentProg < maxGoal)
            {
               tile.mastery_mc.progressBar_mc.scaleX = currentProg / nextGoal;
            }
            else
            {
               tile.mastery_mc.progressBar_mc.scaleX = 1;
            }
            if(tile.mastery_mc.progressBar_mc.scaleX > 1)
            {
               tile.mastery_mc.progressBar_mc.scaleX = 1;
            }
            seedIconUrl = Global.getAssetURL(data.item.iconRelativeUrl);
            this.loadIcon(seedIconUrl,tile.icon_mc);
            ZLocUtils.setTextAsTitle(tile,"cropType_tf",seedItem.friendlyName);
            tile.visible = true;
            tile.addEventListener(MouseEvent.CLICK,this.showInfoPop);
            tile.buttonMode = true;
         }
      }
      
      private function showInfoPop(event:MouseEvent) : void
      {
         var idx:int = int(event.currentTarget.name.split("_")[1]);
         this.m_breedingState = Global.player.breedingState;
         this.m_infoPopup.openFreshPanel(m_data[idx],idx,this.m_breedingState);
         this.m_container.infoPopup_mc.visible = true;
      }
      
      public function hideInfoPop() : void
      {
         this.m_container.infoPopup_mc.visible = false;
      }
      
      public function openNursery(index:int = 0) : void
      {
         this.m_mainDialog.openNursery(index);
      }
      
      private function loadIcon(path:String, container:MovieClip) : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(path,function(event:Event):void
         {
            var dispObj:* = icon.content;
            dispObj.scaleX = dispObj.scaleY = 0.5;
            Utilities.removeAllChildren(container);
            container.addChild(dispObj);
            container.visible = true;
         });
      }
      
      protected function pushNewData() : void
      {
         var object:Object = null;
         m_data = [];
         m_tileSet = 0;
         var featureState:BreedingFeatureState = this.m_breedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
         var genealogyArray:Array = featureState.genealogy;
         var genLength:int = int(genealogyArray.length);
         for(var idx:int = 0; idx < genLength; idx++)
         {
            object = new Object();
            object.genealogy = genealogyArray[idx];
            object.unlockedState = featureState.unlockedStates[idx].unlockState;
            object.item = Global.farmGameSettingsManager.getFarmItemByCode(genealogyArray[idx].itemCode);
            m_data.push(object);
         }
      }
   }
}

