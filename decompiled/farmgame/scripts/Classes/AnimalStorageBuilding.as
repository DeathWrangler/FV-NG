package Classes
{
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.InstagrowHelper;
   import Managers.MapResourceHelper;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class AnimalStorageBuilding extends HarvestableStorageBuilding
   {
      
      public static const IS_FEEDING:String = "feeding";
      
      public static const FEEDING_SUCCESS_URL:String = "assets/overlays/effect_fertilizer_fertilizing.swf";
      
      public static const FEEDING_WAITING_URL:String = "assets/overlays/effect_dairyfarm_sparkle.swf";
      
      protected static var m_fedOverlayLoader:ImageLoader = ImageLoader.getInstance(Global.getAssetURL(FEEDING_WAITING_URL));
      
      protected var m_instagrowStatsPhylum:String = "animal_building";
      
      protected var m_fedOverlay:DisplayObject = null;
      
      protected var m_fedOverlayRequested:Boolean = false;
      
      protected var m_friendFedAnimalBuildingCount:int = 0;
      
      protected var m_animalsFed:Boolean = false;
      
      protected var m_queuedFeeding:Boolean = false;
      
      private var is_busy:Boolean = false;
      
      public function AnimalStorageBuilding(itemName:String = null)
      {
         super(itemName);
      }
      
      public function set busy(b:Boolean) : void
      {
         this.is_busy = b;
      }
      
      public function get busy() : Boolean
      {
         return this.is_busy;
      }
      
      override protected function updatePlantTimeOnStore(itemCount:int, resource:MapResource) : void
      {
         if(itemCount == 0 && resource is HarvestableResource)
         {
            plantTime = (resource as HarvestableResource).plantTime;
            setState(STATE_BARE);
         }
         else
         {
            super.updatePlantTimeOnStore(itemCount,resource);
         }
      }
      
      override protected function getHarvestTooltip() : String
      {
         var toolTip:String = super.getHarvestTooltip();
         if(this.m_friendFedAnimalBuildingCount > 0)
         {
            toolTip += "\n" + ZLocUtils.t("FarmGame","AnimalBuilding_fed",{"quantity":this.m_friendFedAnimalBuildingCount});
         }
         return toolTip;
      }
      
      public function feedAnimals() : void
      {
      }
      
      public function conditionallyAttachFedOverlay() : void
      {
         var parent:DisplayObjectContainer = null;
         if(this.m_animalsFed || !Global.worldManager.isVisiting() && this.m_friendFedAnimalBuildingCount > 0)
         {
            if(!this.m_fedOverlayRequested && this.m_fedOverlay == null)
            {
               m_fedOverlayLoader.getContent(this.onFedOverlayLoad);
               this.m_fedOverlayRequested = true;
            }
            else if(this.m_fedOverlay != null && (this.m_displayObject as Sprite).numChildren > 0)
            {
               (this.m_displayObject as Sprite).addChild(this.m_fedOverlay);
               this.m_fedOverlay.scaleX = 2;
               this.m_fedOverlay.scaleY = 2;
            }
         }
         else if(!this.m_animalsFed && this.m_fedOverlay != null && this.m_fedOverlay.parent != null)
         {
            parent = this.m_fedOverlay.parent;
            if(!(parent is Loader))
            {
               parent.removeChild(this.m_fedOverlay);
               this.m_fedOverlay = null;
            }
         }
      }
      
      protected function onFedOverlayLoad(content:DisplayObject, info:Object = null) : void
      {
         if(content != null)
         {
            this.m_fedOverlay = content;
            (this.m_fedOverlay as MovieClip).play();
            this.conditionallyAttachFedOverlay();
         }
      }
      
      override public function showMenu() : void
      {
         if(!inQueue())
         {
            if(this.canInstantGrow())
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","ApplyInstantGrow"),
                  "action":APPLY_GROW
               });
            }
            super.showMenu();
            FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_open",this.m_instagrowStatsPhylum,"","","User opens context menu from " + this.m_instagrowStatsPhylum);
         }
         else
         {
            displayStatus(ZLocUtils.t("FarmGame","Harvesting"));
         }
      }
      
      protected function canInstantGrow() : Boolean
      {
         var instagrowHelper:InstagrowHelper = new InstagrowHelper(MapResourceHelper.TYPE_ALL,false);
         return m_isFullyBuilt && !isBuildingExperimentLocked() && instagrowHelper.canExecuteOn(this);
      }
      
      override public function conditionallyRedraw(force:Boolean = false) : void
      {
         super.conditionallyRedraw(force);
         this.conditionallyAttachFedOverlay();
      }
      
      public function canFeedOnVisit() : Boolean
      {
         return !this.m_animalsFed && VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FEED_ACTION);
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(this.m_animalsFed && this.m_fedOverlay == null)
         {
            this.conditionallyAttachFedOverlay();
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.friendFedAnimalBuildingCount)
         {
            this.m_friendFedAnimalBuildingCount = data.friendFedAnimalBuildingCount;
         }
      }
      
      override public function getActionText() : String
      {
         return ZLocUtils.t("FarmGame","Feeding");
      }
      
      public function get featureName() : String
      {
         return this.getItemName();
      }
   }
}

